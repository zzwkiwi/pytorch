FROM amd64/ubuntu:22.04

ARG GIT_COMMIT=main
ARG GH_PR
ARG GH_SLUG=pocl/pocl
ARG LLVM_VERSION=17

LABEL git-commit=$GIT_COMMIT vendor=pocl distro=Ubuntu version=1.0

ENV TERM=dumb
ENV TZ=Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive


RUN apt update
RUN apt upgrade -y
RUN apt install -y lsb-release wget software-properties-common gnupg
RUN apt install -y tzdata
RUN apt install -y build-essential clinfo ocl-icd-libopencl1 cmake git pkg-config  make ninja-build ocl-icd-libopencl1 ocl-icd-dev ocl-icd-opencl-dev libhwloc-dev zlib1g zlib1g-dev dialog apt-utils

RUN cd /home ; wget https://apt.llvm.org/llvm.sh ; chmod +x llvm.sh ; ./llvm.sh 17
RUN apt install -y libclang-17-dev clang-17 llvm-17 libclang-cpp17-dev libclang-cpp17 llvm-17-dev

RUN cd /home ; git clone https://github.com/$GH_SLUG.git ; cd /home/pocl ; git checkout $GIT_COMMIT
RUN cd /home/pocl ; test -z "$GH_PR" || (git fetch origin +refs/pull/$GH_PR/merge && git checkout -qf FETCH_HEAD) && :
RUN cd /home/pocl ; mkdir b ; cd b; cmake -G Ninja -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-${LLVM_VERSION} -DCMAKE_INSTALL_PREFIX=/usr ..
RUN cd /home/pocl/b ; ninja install
# removing this picks up PoCL from the system install, not the build dir
RUN cd /home/pocl/b ; rm -f CTestCustom.cmake
CMD cd /home/pocl/b ; ctest -j4 --output-on-failure -L internal

RUN apt install -y wget net-tools git gfortran cmake valgrind nano libomp-dev zlib1g-dev libtiff-dev
RUN apt install -y build-essential cmake git pkg-config libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev gfortran openexr libatlas-base-dev python3-dev python3-numpy libtbb2 libtbb-dev libdc1394-dev libopenexr-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
RUN cd /home ; git clone https://github.com/sowson/clBLAS clBLAS-2.12-sowson 
RUN cd /home/clBLAS-2.12-sowson/src ; mkdir build ; cd build ; cmake .. 
RUN cd /home/clBLAS-2.12-sowson/src/build ; make 
RUN cd /home/clBLAS-2.12-sowson/src/build ; cp library/libclBLAS.so.2.12.0 /usr/lib/x86_64-linux-gnu/libclBLAS.so.2.12.0
