FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel


ARG GIT_COMMIT=main
ARG GH_PR
ARG GH_SLUG=pocl/pocl
ARG LLVM_VERSION=14

LABEL git-commit=$GIT_COMMIT vendor=pocl distro=Ubuntu version=1.0

ENV TERM=dumb
ENV TZ=Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive


RUN apt update
RUN apt upgrade -y
RUN apt install -y lsb-release wget software-properties-common gnupg
RUN apt install -y tzdata
RUN apt install -y build-essential ocl-icd-libopencl1 cmake git pkg-config  make ninja-build ocl-icd-libopencl1 ocl-icd-dev ocl-icd-opencl-dev libhwloc-dev zlib1g zlib1g-dev dialog apt-utils

RUN cd /home ; wget https://apt.llvm.org/llvm.sh ; chmod +x llvm.sh ; ./llvm.sh 14
RUN apt install -y libclang-14-dev clang-14 llvm-14 libclang-cpp14-dev libclang-cpp14 llvm-14-dev

RUN cd /home ; git clone https://github.com/$GH_SLUG.git ; cd /home/pocl ; git checkout $GIT_COMMIT
RUN cd /home/pocl ; test -z "$GH_PR" || (git fetch origin +refs/pull/$GH_PR/merge && git checkout -qf FETCH_HEAD) && :
RUN cd /home/pocl ; mkdir b ; cd b; cmake -G Ninja -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-${LLVM_VERSION} -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_CUDA=ON ..
RUN cd /home/pocl/b ; ninja install
# removing this picks up PoCL from the system install, not the build dir
RUN cd /home/pocl/b ; rm -f CTestCustom.cmake
CMD cd /home/pocl/b ; ctest -j4 --output-on-failure -L internal
