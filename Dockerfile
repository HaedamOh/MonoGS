FROM nvidia/cuda:12.1.1-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY :0
ENV TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9"
ENV NVIDIA_DRIVER_CAPABILITIES="all"

RUN apt-get update && apt-get install -y \
    lsb-release \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    freeglut3-dev \
    mesa-utils \
    libxmu-dev \
    libxi-dev \
    git \
    python3 \
    python3-dev \
    python3-pip \
    libc6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG HOME_DIR=/home/docker_dev
ARG MonoGS_DIR=${HOME_DIR}/MonoGS
RUN git clone https://github.com/tauzn-clock/MonoGS/ --recursive
WORKDIR /MonoGS
RUN pip install --upgrade pip
RUN pip install -r requirement.txt

RUN pip install submodules/diff-gaussian-rasterization
RUN pip install submodules/simple-knn

RUN rm -rf ${MonoGS_DIR} 


ARG GID=1007
ARG UID=1007
ENV UNAME=docker_dev
RUN addgroup --gid $GID $UNAME
RUN adduser --disabled-password --gecos '' --uid $UID --gid $GID $UNAME

# Add additional groups and assign the user to them
RUN groupadd -g 998 docker && \
    groupadd -g 1013 oxford_spires && \
    groupadd -g 1014 nerfstudio && \
    usermod -aG docker,oxford_spires,nerfstudio ${UNAME}
    
WORKDIR ${MonoGS_DIR}

RUN echo "if [ -n \"$PS1\" ]; then PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@docker-\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '; fi" >> /home/${UNAME}/.bashrc

USER ${UNAME}

CMD ["/bin/bash"]