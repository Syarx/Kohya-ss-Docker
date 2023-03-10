
FROM ubuntu:22.04 AS runtime

RUN rm -rf /workspace && mkdir /workspace

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
apt install -y  --no-install-recommends \
software-properties-common \
git \
openssh-server \
libglib2.0-0 \
libsm6 \
libxrender1 \
libxext6 \
ffmpeg \
wget \
curl \
unzip \
zip \
nano \
python3-pip python3 python3.10-venv \
apt-transport-https ca-certificates && \
update-ca-certificates

WORKDIR /workspace
RUN git clone https://github.com/Thund3rPat/kohya_ss-linux.git
WORKDIR /workspace/kohya_ss-linux
RUN python3 -m venv venv
RUN . venv/bin/activate
 
RUN pip install --use-pep517 --upgrade -r requirements.txt
RUN accelerate config default
 
ENV PATH="/workspace/kohya_ss-linux/venv/bin:$PATH"
 
RUN pip install -U jupyterlab ipywidgets jupyter-archive
RUN jupyter nbextension enable --py widgetsnbextension

# ADD install.py .
# RUN python3 -m install --skip-torch-cuda-test

RUN apt clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
  
ADD relauncher.py .
ADD start.sh /start.sh
RUN chmod a+x /start.sh

SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]