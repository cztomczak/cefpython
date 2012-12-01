"""
setup.bat:
-----------
del cheese.pyd
call python "setup.py" build_ext --inplace
pause

run_cheese.py:
-----------------
import cheese
cheese.find()

setup.py:
-----------
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(
  name = 'callback',
  ext_modules=[ 
    Extension("cheese", ["cheese.pyx"]),
    ],
  cmdclass = {'build_ext': build_ext}
) 

"""

"""
cheese.pyx:
--------------
"""

# It can get even easier "Using Cython Declarations from C":
# http://docs.cython.org/src/userguide/external_C_code.html#using-cython-declarations-from-c

cdef extern from "cheesefinder.h":
    ctypedef int (*cheesefunc)(char *name)
    void find_cheeses(cheesefunc user_func)

def find():
    find_cheeses(<cheesefunc>report_cheese)

# When using callbacks from C need to use GIL:
# http://docs.cython.org/src/userguide/external_C_code.html#acquiring-and-releasing-the-gil

cdef int report_cheese(char* name) with gil:
    print("Found cheese: " + name)
    return 0

"""
cheesefinder.h:
------------------

typedef int (*cheesefunc)(char *name);
void find_cheeses(cheesefunc user_func);

static char *cheeses[] = {
  "cheddar",
  "camembert",
  "that runny one",
  0
};

void find_cheeses(cheesefunc user_func) {
  char **p = cheeses;
  int r = 1;
  while (r && *p) {
    r = user_func(*p);
    ++p;
  }
}

"""