#!/usr/bin/env python
import rospy
from visualization_msgs.msg import Marker
from geometry_msgs.msg import Point
from std_msgs.msg import ColorRGBA
import numpy as np
import time
import math
import cv2
import os

import util	#our library

#get current directory
__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))


mapfile = os.path.join(__location__, 'map/wean.dat')

logfile = os.path.join(__location__, 'log/ascii-robotdata3.log')


#read map info
mapdata = np.zeros([800, 800])
with open(mapfile) as f:

	#skip the map file headers
	next(f)
	next(f)
	next(f)
	next(f)
	next(f)
	next(f)
	next(f)
	i = 0
	for line in f:
		mapdata[i] = line.split(" ")[:-1]	
		i = i + 1
		

### visualization stuff##################
rospy.init_node('particlefilter')
pub = rospy.Publisher('visualization_marker', Marker, queue_size=1)
pub2 = rospy.Publisher('visualization_marker2', Marker, queue_size=1)

marker = Marker()
marker.header.frame_id = "/map"
marker.header.stamp = rospy.Time.now()
marker.type = marker.POINTS
marker.action = marker.ADD
marker.scale.x = 0.2
marker.scale.y = 0.2
marker.scale.z = 0.0

marker.color.a = 1.0
marker.color.r = 1.0
marker.color.g = 0.0
marker.color.b = 0.0

marker.pose.orientation.w = 1.0
marker.pose.position.x = 0.0
marker.pose.position.y = 0.0
marker.pose.position.z = 0.0
marker.lifetime = rospy.Duration()

marker2 = Marker()
marker2.header.frame_id = "/map"
marker2.header.stamp = rospy.Time.now()
marker2.type = marker.LINE_LIST
marker2.action = marker.ADD
marker2.scale.x = 0.05
marker2.scale.y = 0.2
marker2.scale.z = 0.2

marker2.color.a = 1.0
marker2.color.r = 0.0
marker2.color.g = 0.0
marker2.color.b = 1.0

marker2.pose.orientation.w = 1.0
marker2.lifetime = rospy.Duration()
#########################################



print "precomputing distance field .."
t1 = time.time()

#outsource to cython
obstaclemap = util.get_obstaclemap(mapdata)

(distance_field, labels) = cv2.distanceTransformWithLabels(obstaclemap, cv2.DIST_L2, cv2.DIST_MASK_PRECISE, labelType=cv2.DIST_LABEL_PIXEL)
distance_field = np.array(distance_field, dtype=float)

t2 = time.time()

print "computed distance field in ", (t2-t1)


pf = util.ParticleFilter(mapdata, distance_field, 15000)


with open(logfile) as f:

	i = 0
	for line in f:

		message = line.split(" ")[:-1]	#last element is timestamp

		if message[0] == 'O':
			pf.motion_update(message[1:])


		if message[0] == 'L':
			pf.measurement_update(message[1:])


		#visualize particles
		marker.points = []
		marker2.points = []

		idx = 0

		for particle in pf.particles:

			p = Point() 
			p.x = particle.x / 100.
			p.y = particle.y / 100.
			p.z = 0.0

			#visualize orientation
			p2 = Point() 
			p2.x = p.x + 0.3*math.cos(particle.orientation)
			p2.y = p.y + 0.3*math.sin(particle.orientation)
			p2.z = 0.0
			

			marker.points.append(p)
			marker2.points.append(p)
			marker2.points.append(p2)


			idx = idx + 1

		pub.publish(marker)
		pub2.publish(marker2)

		i = i + 1
		print i




