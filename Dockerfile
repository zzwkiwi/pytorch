FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel

RUN apt-get update && apt-get install -y libgl1-mesa-glx libpci-dev curl nano psmisc zip git && apt-get --fix-broken install -y

RUN conda install -y faiss-gpu scikit-learn pandas flake8 yapf isort yacs gdown future libgcc -c conda-forge

RUN pip install --upgrade pip && python -m pip install --upgrade setuptools && \
    pip install opencv-python tb-nightly matplotlib logger_tt tabulate tqdm wheel mccabe scipy

COPY ./fonts/* /opt/conda/lib/python3.10/site-packages/matplotlib/mpl-data/fonts/ttf/

ARG GIT_COMMIT=main
ARG GH_PR
ARG GH_SLUG=pocl/pocl
ARG LLVM_VERSION=15
LABEL git-commit=$GIT_COMMIT vendor=pocl distro=Ubuntu version=1.0
ENV TERM=dumb
ENV TZ=Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt upgrade -y

RUN apt install -y tzdata
RUN apt install -y build-essential ocl-icd-libopencl1 cmake git pkg-config  make ninja-build ocl-icd-libopencl1 ocl-icd-dev ocl-icd-opencl-dev libhwloc-dev zlib1g zlib1g-dev clinfo dialog apt-utils

RUN apt install -y lsb-release wget software-properties-common gnupg

RUN cd /home ; wget https://apt.llvm.org/llvm.sh ; chmod +x llvm.sh ; ./llvm.sh 15
RUN apt install libclang-15-dev clang-15 llvm-15 libclang-cpp15-dev libclang-cpp15 llvm-15-dev

# 用Mambaforge替换默认的conda
# RUN cd /home ; wget https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc
# RUN sudo apt-key add anaconda.asc
# RUN sudo sh -c 'echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/ /" > /etc/apt/sources.list.d/conda.list'
# RUN sudo apt-get update ; sudo apt-get install mambaforge

# RUN cd /home ; wget https://anaconda.org/conda-forge/mamba/1.5.6/download/linux-64/mamba-1.5.6-py310h51d5547_0.conda ; conda install mamba-1.5.6-py310h51d5547_0.conda
RUN conda update -n base conda
RUN conda install -n base conda-libmamba-solver
RUN conda config --set solver libmamba
RUN conda install mamba -n base -c conda-forge
# 验证安装
RUN mamba --version

# install mambaforge
# RUN cd /home ; wget "https://github.com/conda-forge/miniforge/releases/download/23.11.0-0/Mambaforge-Linux-x86_64.sh" ; chmod +x Mambaforge-Linux-x86_64.sh ; bash Mambaforge-Linux-x86_64.sh
