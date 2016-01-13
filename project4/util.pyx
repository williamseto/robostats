
#
# Contains all classes and functions necessary to run particle filter
# depends on numpy, and cython_gsl library
# 


## build with:
## python setup_util.py build_ext --inplace


import random
import numpy as np

cimport numpy as np

from cython_gsl cimport *
import cython

### import random number generator

cdef gsl_rng *rng_pointer = gsl_rng_alloc(gsl_rng_mt19937)


# --------
# 
# noise parameters
#

cdef double laser_noise = 350.0
cdef double steering_noise = 0.02 # used in motion model
cdef double position_noise = 0.5  #used in motion model


#laser model parms
cdef double p_hit  = 0.95
cdef double p_rand = 0.05
cdef int scan_max  = 3000     #maximum range of laser scan; if greater, then ignore


cdef double world_size = 8000.0 # 8000x8000cm

# ------------------------------------------------
# 
# this is the robot class (particles)
#

cdef class robot(object):

    cdef public double x, y, orientation, weight
    cdef public list scans

    # --------
    # init: 
    #    creates robot and initializes location/orientation 
    #

    def __init__(self):

        self.x = random.random() * world_size # initial x position
        self.y = random.random() * world_size # initial y position
        self.orientation = random.random() * 2.0 * M_PI # initial orientation

        #for debugging
        self.weight = 0.0
        self.scans = []

    # --------
    # set: 
    #    sets a robot coordinate
    #

    cpdef set(self, double new_x, double new_y, double new_orientation):

        if new_orientation < 0 or new_orientation >= (2 * M_PI):
            raise ValueError, 'Orientation must be in [0..2pi]'
        self.x = new_x
        self.y = new_y
        self.orientation = new_orientation


    # --------
    # measurement_prob
    #    computes the probability of a measurement P(Z|X)
    #  
    @cython.cdivision(True)
    cpdef double measurement_prob(self, np.ndarray[np.float_t, ndim=1] measurements,
                               np.ndarray[np.float_t, ndim=2] distancefield,
                               np.ndarray[np.float64_t, ndim=2] mapdata):

        cdef double laser_x, laser_y
        cdef int scan_x, scan_y
        cdef int scan_max = 3000
        cdef int k = 0
        cdef double prob, errorL2, mapval
        cdef float d


        #first determine position of the laser
        #25m away and at same heading as robot

        laser_x = self.x + (25 * cos(self.orientation))
        laser_y = self.y + (25 * sin(self.orientation))


        prob = 1.0
        errorL2 = 0.0

        #180 scans
        while k < 180:

            if measurements[k] < scan_max:
                #calculate endpoint of beam
                scan_angle = self.orientation + ((k-90) * M_PI / 180)
                scan_x = int(laser_x + (measurements[k] * cos(scan_angle) ))
                scan_y = int(laser_y + (measurements[k] * sin(scan_angle) ))


                #if scan out of bounds, particle probably shouldn't be there
                if scan_x < 0 or scan_x > 7999 or scan_y < 0 or scan_y > 7999:
                    return 0.0
                    

                #check distance field
                d = distancefield[scan_x, scan_y]

                #check if scan in gray area, but ignore if scan lies on a wall
                mapval = mapdata[int(scan_x / 10.), int(scan_y / 10.)]
                if mapval < 0.9 and mapval > 0.3 and d > 30:
                    d = 250
                

                errorL2 = errorL2 + pow((d / laser_noise), 2)


            #downsample scans
            k = k + 9

        prob *= (p_hit * (exp(- errorL2 )) + p_rand * (1/ scan_max))
           
        return prob
    


    # --------
    # move: apply motion model P(Xt | Xt-1, ut)
    #   

    cpdef void move(self, double dx, double dy, double dtheta): 

        cdef double x, y, orientation


        #update coordinates using new deltas
        x = self.x + (cos(self.orientation)*dx - sin(self.orientation)*dy)
        y = self.y + (sin(self.orientation)*dx + cos(self.orientation)*dy)
        orientation = self.orientation + dtheta

        #add some noise to the position
        x = x + gsl_ran_gaussian(rng_pointer, position_noise)
        y = y + gsl_ran_gaussian(rng_pointer, position_noise)
        orientation = orientation + gsl_ran_gaussian(rng_pointer, steering_noise)


        #normalize orientation
        
        orientation = fmod(orientation, 2.0*M_PI)
        if orientation < 0:
            orientation = orientation + 2.0*M_PI

        
        self.set(x, y, orientation)



class ParticleFilter(object):



    def __init__(self, mapdata, distancefield, numParticles):


        self.mapdata = mapdata
        self.distancefield = distancefield
        self.numParticles = numParticles
        self.particles = []

        self.initializeParticles()  #actually create particles

        self.last_odometry = [0, 0, 0]
        self.initialized = 0
        self.weights = []
        self.iteration = 0


    def initializeParticles(self):

        self.particles = []
        for i in range(self.numParticles):

            r = robot() #create a particle

            x = random.random() * world_size # initial x position
            y = random.random() * world_size # initial y position

            
            while self.mapdata[int(x/10.)][int(y/10.)] < 0.9:
                x = random.random() * world_size 
                y = random.random() * world_size 


            r.set(x, y, r.orientation)
               
            self.particles.append(r)


    def motion_update(self, odometry):

        self.iteration = self.iteration + 1


        cdef double steering_angle, d

        odometry = map(float, odometry) #convert string to floats

        #use difference in odometries, so no calculation in 1st step
        if self.initialized == 0:
            self.last_odometry = odometry
            self.initialized = 1
            return

        delta = np.subtract(odometry, self.last_odometry)

        
        #get relative motion in frame of previous measurement
        odo_x = cos(-self.last_odometry[2])*delta[0] - sin(-self.last_odometry[2])*delta[1]
        odo_y = sin(-self.last_odometry[2])*delta[0] + cos(-self.last_odometry[2])*delta[1]

        for i in range(self.numParticles):          
            self.particles[i].move(odo_x, odo_y, delta[2])

        self.last_odometry = odometry


    def measurement_update(self, measurement):

        cdef int i

        #when we get laser scan, we have to do motion update and observation update
        measurement = map(float, measurement)

        odometry = measurement[0:3]

        self.motion_update(odometry)
        self.last_odometry = odometry


        scans = np.array(measurement[6:], dtype=np.float)

        self.weights = []
        for i in range(self.numParticles):
            self.weights.append(self.particles[i].measurement_prob(scans, self.distancefield, self.mapdata))

        #normalize weights and get cumsum
        self.weights = np.array(self.weights)
        norm_w = self.weights / sum(self.weights)
        cum_w = np.cumsum(norm_w)


        #some adaptive num. of particles
        if self.iteration > 50:
            self.numParticles = 5000

        if self.iteration > 100:
            self.numParticles = 2500


        ### RESAMPLING SECTION
        
        ### systematic sampling ###
        r = random.random() * (1.0 / self.numParticles)

        #hack to skip first particle, since bad particles weren't going away
        p_idx = 1

        new_particles = []


        for m in range(self.numParticles):
            u = r + (m-1) * (1.0 / self.numParticles)

            while u > cum_w[p_idx]:
                p_idx = p_idx + 1

            #create new particle with same state as selected particle
            p = robot()
            p.set(self.particles[p_idx].x, self.particles[p_idx].y, self.particles[p_idx].orientation) 


            new_particles.append(p)

        self.particles = new_particles
        

#
# Function to get obstacle map for calculating distance field
# Cythonized for speed
#
#
def get_obstaclemap(np.ndarray[np.float64_t, ndim=2] mapdata):


    cdef int map_x, map_y, x, y, val
    cdef double value

    cdef np.ndarray[np.uint8_t, ndim=2] obstaclemap = np.ones([8000, 8000], dtype=np.uint8)

    for x in range(8000):
        for y in range(8000):

            map_x = int(x / 10.)
            map_y = int(y / 10.)

            value = mapdata[map_x, map_y]

            #thresholds for wall information
            if value < 0.015 and value >= 0:

                obstaclemap[x, y] = 0

    return obstaclemap