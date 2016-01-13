from distutils.core import setup
from Cython.Build import cythonize
from distutils.extension import Extension
import numpy
import cython_gsl

include_gsl_dir = "/usr/include/"
lib_gsl_dir = "/usr/lib/"


extensions = [
    Extension("util", ["util.pyx"],
        include_dirs = [numpy.get_include(),
         				include_gsl_dir,
         				cython_gsl.get_cython_include_dir()],
        libraries = cython_gsl.get_libraries(),
        library_dirs = [lib_gsl_dir,
        				cython_gsl.get_library_dir()]),

]

setup(
  ext_modules = cythonize(extensions),
)




## python setup_util.py build_ext --inplace