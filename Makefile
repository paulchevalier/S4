# To build:
#   make <target>
# Use the 'lib' target first to build the library, then either the Lua
# or Python targets are 'S4lua' and 'python_ext', respectively.

# Set these to the flags needed to link against BLAS and Lapack.
#  If left blank, then performance may be very poor.
#  On Mac OS,
#   BLAS_LIB = -framework vecLib
#   LAPACK_LIB = -framework vecLib
#  On Fedora: dnf install openblas-devel
#  On Debian and Fedora, with reference BLAS and Lapack (slow)
#   BLAS_LIB = -lblas
#   LAPACK_LIB = -llapack
#  NOTE: on Fedora, need to link blas and lapack properly, where X.X.X is some version numbers
#  Linking Command Example: sudo ln -s /usr/lib64/liblapack.so.X.X.X /usr/lib64/liblapack.so
#  blas Example: sudo ln -s /usr/lib64/libopeblas64.so.X.X.X /usr/lib64/libblas.so
#  Can also use -L to link to the explicit libary path 
BLAS_LIB = -lblas
LAPACK_LIB = -llapack

# Specify the flags for Lua headers and libraries (only needed for Lua frontend)
# Recommended: build lua in the current directory, and link against this local version
# LUA_INC = -I./lua-5.2.4/install/include
# LUA_LIB = -L./lua-5.2.4/install/lib -llua -ldl -lm
LUA_INC = -I./lua-5.2.4/install/include
LUA_LIB = -L./lua-5.2.4/install/lib -llua -ldl -lm

# OPTIONAL
# Typically if installed,
#  FFTW3_INC can be left empty
#  FFTW3_LIB = -lfftw3 
#  or, if Fedora and/or fftw is version 3 but named fftw rather than fftw3
#  FTW3_LIB = -lfftw 
#  May need to link libraries properly as with blas and lapack above
FFTW3_INC =
FFTW3_LIB = -lfftw3

# Typically,
#  PTHREAD_INC = -DHAVE_UNISTD_H
#  PTHREAD_LIB = -lpthread
PTHREAD_INC = -DHAVE_UNISTD_H
PTHREAD_LIB = -lpthread

# OPTIONAL
# If not installed:
# Fedora: dnf install libsuitsparse-devel
# Typically, if installed:
#CHOLMOD_INC = -I/usr/include/suitesparse
#CHOLMOD_LIB = -lcholmod -lamd -lcolamd -lcamd -lccolamd
CHOLMOD_INC = -I/usr/include/suitesparse
CHOLMOD_LIB = -lcholmod -lamd -lcolamd -lcamd -lccolamd

# Specify the MPI library
# For example, on Fedora: dnf  install openmpi-devel
#MPI_INC = -I/usr/include/openmpi-x86_64/openmpi/ompi
#MPI_LIB = -lmpi
# or, explicitly link to the library with -L, example below
#MPI_LIB = -L/usr/lib64/openmpi/lib/libmpi.so
#MPI_INC = -I/usr/include/openmpi-x86_64/openmpi
#MPI_LIB = -L/usr/lib64/openmpi/lib/libmpi.so

# Enable S4_TRACE debugging
S4_DEBUG = 1

# Specify custom compilers if needed
CXX = g++
CC  = gcc

#CFLAGS += -O3 -fPIC
CFLAGS = -O3 -msse3 -msse2 -msse -fPIC

# options for Sampler module
OPTFLAGS = -O3

OBJDIR = ./build
S4_BINNAME = $(OBJDIR)/S4
S4_LIBNAME = $(OBJDIR)/libS4.a
S4r_LIBNAME = $(OBJDIR)/libS4r.a

##################### DO NOT EDIT BELOW THIS LINE #####################

#### Set the compilation flags

CPPFLAGS = -I. -IS4 -IS4/RNP -IS4/kiss_fft

ifdef BLAS_LIB
CPPFLAGS += -DHAVE_BLAS
endif

ifdef S4_DEBUG
CPPFLAGS += -DENABLE_S4_TRACE
endif

ifdef LAPACK_LIB
CPPFLAGS += -DHAVE_LAPACK
endif

ifdef FFTW3_LIB
CPPFLAGS += -DHAVE_FFTW3 $(FFTW3_INC)
endif

ifdef PTHREAD_LIB
CPPFLAGS += -DHAVE_LIBPTHREAD $(PTHREAD_INC)
endif

ifdef CHOLMOD_LIB
CPPFLAGS += -DHAVE_LIBCHOLMOD $(CHOLMOD_INC)
endif

ifdef MPI_LIB
CPPFLAGS += -DHAVE_MPI $(MPI_INC)
endif

LIBS = $(BLAS_LIB) $(LAPACK_LIB) $(FFTW3_LIB) $(PTHREAD_LIB) $(CHOLMOD_LIB) $(MPI_LIB)

#### Compilation targets

all: $(S4_LIBNAME)

objdir:
	mkdir -p $(OBJDIR)
	mkdir -p $(OBJDIR)/S4k
	mkdir -p $(OBJDIR)/S4r
	mkdir -p $(OBJDIR)/modules
	
S4_LIBOBJS = \
	$(OBJDIR)/S4k/S4.o \
	$(OBJDIR)/S4k/rcwa.o \
	$(OBJDIR)/S4k/fmm_common.o \
	$(OBJDIR)/S4k/fmm_FFT.o \
	$(OBJDIR)/S4k/fmm_kottke.o \
	$(OBJDIR)/S4k/fmm_closed.o \
	$(OBJDIR)/S4k/fmm_PolBasisNV.o \
	$(OBJDIR)/S4k/fmm_PolBasisVL.o \
	$(OBJDIR)/S4k/fmm_PolBasisJones.o \
	$(OBJDIR)/S4k/fmm_experimental.o \
	$(OBJDIR)/S4k/fft_iface.o \
	$(OBJDIR)/S4k/pattern.o \
	$(OBJDIR)/S4k/intersection.o \
	$(OBJDIR)/S4k/predicates.o \
	$(OBJDIR)/S4k/numalloc.o \
	$(OBJDIR)/S4k/gsel.o \
	$(OBJDIR)/S4k/sort.o \
	$(OBJDIR)/S4k/kiss_fft.o \
	$(OBJDIR)/S4k/kiss_fftnd.o \
	$(OBJDIR)/S4k/SpectrumSampler.o \
	$(OBJDIR)/S4k/cubature.o \
	$(OBJDIR)/S4k/Interpolator.o \
	$(OBJDIR)/S4k/convert.o

S4r_LIBOBJS = \
	$(OBJDIR)/S4r/Material.o \
	$(OBJDIR)/S4r/LatticeGridRect.o \
	$(OBJDIR)/S4r/LatticeGridArb.o \
	$(OBJDIR)/S4r/POFF2Mesh.o \
	$(OBJDIR)/S4r/PeriodicMesh.o \
	$(OBJDIR)/S4r/Shape.o \
	$(OBJDIR)/S4r/Simulation.o \
	$(OBJDIR)/S4r/Layer.o \
	$(OBJDIR)/S4r/Pseudoinverse.o \
	$(OBJDIR)/S4r/Eigensystems.o \
	$(OBJDIR)/S4r/IRA.o \
	$(OBJDIR)/S4r/intersection.o \
	$(OBJDIR)/S4r/predicates.o \
	$(OBJDIR)/S4r/periodic_off2.o

ifndef LAPACK_LIB
  S4_LIBOBJS += $(OBJDIR)/S4k/Eigensystems.o
endif

$(S4_LIBNAME): objdir $(S4_LIBOBJS)
	$(AR) crvs $@ $(S4_LIBOBJS)
$(S4r_LIBNAME): objdir $(S4r_LIBOBJS)
	$(AR) crvs $@ $(S4r_LIBOBJS)

$(OBJDIR)/S4k/S4.o: S4/S4.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/rcwa.o: S4/rcwa.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_common.o: S4/fmm/fmm_common.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_FFT.o: S4/fmm/fmm_FFT.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_kottke.o: S4/fmm/fmm_kottke.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_closed.o: S4/fmm/fmm_closed.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_PolBasisNV.o: S4/fmm/fmm_PolBasisNV.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_PolBasisVL.o: S4/fmm/fmm_PolBasisVL.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_PolBasisJones.o: S4/fmm/fmm_PolBasisJones.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_experimental.o: S4/fmm/fmm_experimental.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fft_iface.o: S4/fmm/fft_iface.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/pattern.o: S4/pattern/pattern.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/intersection.o: S4/pattern/intersection.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/predicates.o: S4/pattern/predicates.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/numalloc.o: S4/numalloc.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/gsel.o: S4/gsel.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/sort.o: S4/sort.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/kiss_fft.o: S4/kiss_fft/kiss_fft.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/kiss_fftnd.o: S4/kiss_fft/tools/kiss_fftnd.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/SpectrumSampler.o: S4/SpectrumSampler.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/cubature.o: S4/cubature.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/Interpolator.o: S4/Interpolator.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/convert.o: S4/convert.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/Eigensystems.o: S4/RNP/Eigensystems.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

	


$(OBJDIR)/S4r/Material.o: S4r/Material.cpp S4r/Material.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/LatticeGridRect.o: S4r/LatticeGridRect.cpp S4r/PeriodicMesh.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/LatticeGridArb.o: S4r/LatticeGridArb.cpp S4r/PeriodicMesh.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/POFF2Mesh.o: S4r/POFF2Mesh.cpp S4r/PeriodicMesh.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/PeriodicMesh.o: S4r/PeriodicMesh.cpp S4r/PeriodicMesh.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/Shape.o: S4r/Shape.cpp S4r/Shape.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/Simulation.o: S4r/Simulation.cpp S4r/Simulation.hpp S4r/StarProduct.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/Layer.o: S4r/Layer.cpp S4r/Layer.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/Pseudoinverse.o: S4r/Pseudoinverse.cpp S4r/Pseudoinverse.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/Eigensystems.o: S4r/Eigensystems.cpp S4r/Eigensystems.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/IRA.o: S4r/IRA.cpp S4r/IRA.hpp S4r/Types.hpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -I. $< -o $@
$(OBJDIR)/S4r/intersection.o: S4r/intersection.c S4r/intersection.h
	$(CC) -c -O3 $< -o $@
$(OBJDIR)/S4r/periodic_off2.o: S4r/periodic_off2.c S4r/periodic_off2.h 
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4r/predicates.o: S4r/predicates.c
	$(CC) -c -O3 $< -o $@
	
#### Lua Frontend

$(OBJDIR)/S4k/main_lua.o: S4/main_lua.c objdir
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(LUA_INC) $< -o $@
S4lua: $(OBJDIR)/S4k/main_lua.o $(S4_LIBNAME) sampler
	$(CXX) $(CFLAGS) $(CPPFLAGS) $< -o $(S4_BINNAME) $(S4_LIBNAME) $(LIBS) $(LUA_LIB)

$(OBJDIR)/S4r/main_lua.o: S4r/main_lua.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(LUA_INC) $< -o $@
$(OBJDIR)/S4r/lua_named_arg.o: S4r/lua_named_arg.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(LUA_INC) $< -o $@
$(OBJDIR)/S4r/S4r.o: S4r/S4r.cpp
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $(LUA_INC) $< -o $@
S4rlua: objdir $(OBJDIR)/S4r/main_lua.o $(OBJDIR)/S4r/lua_named_arg.o $(OBJDIR)/S4r/S4r.o $(S4r_LIBNAME)
	$(CXX) $(CFLAGS) $(CPPFLAGS) $(OBJDIR)/S4r/main_lua.o $(OBJDIR)/S4r/lua_named_arg.o $(OBJDIR)/S4r/S4r.o -o $@ $(S4r_LIBNAME) $(LIBS) $(LUA_LIB)

sampler: FunctionSampler1D.so FunctionSampler2D.so
FunctionSampler1D.so: modules/function_sampler_1d.c modules/function_sampler_1d.h modules/lua_function_sampler_1d.c
	gcc -c $(OPTFLAGS) -fpic -Wall -I. modules/function_sampler_1d.c -o $(OBJDIR)/modules/function_sampler_1d.o
	gcc $(OPTFLAGS) -shared -fpic -Wall $(LUA_INC) -o $(OBJDIR)/FunctionSampler1D.so $(OBJDIR)/modules/function_sampler_1d.o modules/lua_function_sampler_1d.c $(LUA_LIB)
FunctionSampler2D.so: modules/function_sampler_2d.c modules/function_sampler_2d.h modules/lua_function_sampler_2d.c
	gcc -c $(OPTFLAGS) -fpic -Wall -I. modules/function_sampler_2d.c -o $(OBJDIR)/modules/function_sampler_2d.o
	gcc -c -O2 -fpic -Wall -I. modules/predicates.c -o $(OBJDIR)/modules/mod_predicates.o
	gcc $(OPTFLAGS) -shared -fpic -Wall $(LUA_INC) -o $(OBJDIR)/FunctionSampler2D.so $(OBJDIR)/modules/function_sampler_2d.o $(OBJDIR)/modules/mod_predicates.o modules/lua_function_sampler_2d.c $(LUA_LIB)




#### Python extension

S4_pyext: objdir $(S4_LIBNAME)
	sh gensetup.py.sh $(OBJDIR) $(S4_LIBNAME) "$(LIBS)"
	pip install --upgrade ./

clean:
	rm -rf $(OBJDIR)
