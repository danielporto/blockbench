FROM ubuntu:20.04


# install needed packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
               #   ansible require python3
               python3-pip \ 
               sudo \
               openssl \
               # required for build asdf python
               libssl-dev \ 
               curl \
               wget \
               vim \
               zsh \
               openssh-client \
               rsync \
               jq \
               git \
               gnupg \
               unzip \
               # required for compile ethereum devtools
               software-properties-common \
               protobuf-compiler \
               # required to compile restclient and blockbench
              cmake \
              libtool \
              libcurl4-openssl-dev \
              automake \
              autoconf \
              g++ \
#               libboost-all-dev \
#               libz3-dev \
               && rm -rf /var/cache/apt/archives


ARG UID=1097
# RUN addgroup -S dporto && adduser --uid $UID -g dporto dporto && echo 'dporto ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# ARG UID=501
RUN useradd -m --uid=$UID -U dporto && echo 'dporto ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# install packages
RUN pip3 install --upgrade pathlib2 \
                          enum34 \
                          plumbum \
                          eventlet \
                          # sensors
                          futures \
                          requests \
                          numpy \
                          pandas \
                          plumbum \
                          serial \
                          ioctl_opt \
                          pyserial \
                          flask \
                          # pysensors \ not yet compatible with alpine version
                          eventlet \
                          # zookeeper
                          kazoo \
                          ;

# make default alias for python
# RUN  ln -s /usr/local/lib/pyenv/versions/3.7.3/bin/python /usr/bin/python 
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10


# compile install patched restclient-cpp
RUN  git clone https://github.com/danielporto/restclient-cpp.git /opt/restclient-cpp \
    && cd /opt/restclient-cpp  \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
   && echo "ok"

ENV LD_LIBRARY_PATH=/usr/local/lib

COPY . /code
RUN cd /code/src/macro/kvstore \
    && make \
    && cd /code/src/macro/smallbank \
    && make


# USER dporto

# # configure zsh
# RUN PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" ; \
#     echo "alias grep='egrep'" >> ~/.profile ; \
#     echo "export PATH=/opt/solidity/build/solc:$HOME/.asdf/bin:$HOME/.asdf/shims:$(go env GOPATH)/bin:$HOME/istanbul-tools/build/bin:$HOME/goquorum/build/bin:$PATH" >> ~/.profile ; \
#     echo "Done"

WORKDIR /code

CMD /code/src/macro/kvstore/driver 

