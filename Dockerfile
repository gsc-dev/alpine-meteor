FROM mhart/alpine-node:4.6.2
WORKDIR /root

ENV HOME=/root METEORD_DIR=/docker/meteor NODE_VERSION=7.3.0 GYP_DEFINES="linux_use_gold_flags=0" BUILD_PACKAGES="python make gcc g++ git libuv bash curl tar bzip2 sudo openssl ca-certificates libstdc++ freetype-dev freetype fontconfig imagemagick"

# Install dependencies
RUN apk --no-cache add ${BUILD_PACKAGES}
RUN apk --no-cache add graphicsmagick --repository http://dl-3.alpinelinux.org/alpine/edge/community/

# Install locale package for Mongo DB
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-i18n-2.23-r3.apk
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-bin-2.23-r3.apk
RUN apk --no-cache add glibc-2.23-r3.apk glibc-bin-2.23-r3.apk glibc-i18n-2.23-r3.apk
RUN /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8

# Update Node
RUN	npm install -g npm@3 \
	&& npm install -g node-gyp \
	&& node-gyp install ${NODE_VERSION}

ADD scripts $METEORD_DIR

# Switch to Meteor linux user
RUN addgroup -S meteor
RUN adduser  -S -g "Meteor Run Time" -s /bin/bash -G meteor -D meteor -h /meteor
RUN echo '%meteor ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV HOME=/meteor GYP_DEFINES="linux_use_gold_flags=0" METEORD_DIR=/docker/meteor
USER meteor

# Install Phantom JS and Meteor
RUN npm install -g phantomjs-prebuilt
RUN curl https://install.meteor.com/ | sh
WORKDIR /meteor

# Production (Meteor Bundle) docker build commands
ONBUILD ADD .build/bundle /app

ONBUILD RUN sh $METEORD_DIR/build_app.sh \
	&& sh $METEORD_DIR/clean-final.sh

ONBUILD EXPOSE 80

# Docker Image Entrypoint
ADD bin /docker/bin
ADD entrypoint /docker/entrypoint

ENTRYPOINT /docker/entrypoint
