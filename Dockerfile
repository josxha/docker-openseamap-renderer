FROM ubuntu:16.04

# Set user
ARG OSM_USER=renderaccount
RUN cd /

RUN apt-get update

# Set the locale
RUN apt-get -y install locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN apt-get -y install ant \
					libbatik-java \
					gcc \
					openjdk-8-jre \
					g++ \
					make \
					expat \
					libexpat1-dev \
					zlib1g-dev\
					git\
					autoconf\
					libtool\
					automake1.11\
					openjdk-8-jdk\
					bzip2
RUN useradd -m $OSM_USER
USER $OSM_USER
RUN mkdir ~/src && \
	mkdir /home/$OSM_USER/opt && \
    cd ~/src && \
	git clone https://github.com/drolbr/Overpass-API.git

RUN cd ~/src/Overpass-API/src; \
	libtoolize; \
	automake --add-missing;\
	autoreconf;\
	automake --add-missing && \
	autoreconf && \
	cd ../build && \
	../src/configure CXXFLAGS="-Wall -O2" --prefix=/home/$OSM_USER/opt/overpass && \
	make install -j

RUN cd ~/src && \
    git clone https://github.com/KastB/renderer.git && \
    cd renderer && \
    cd jharbour && \
    ant && \
    cd ../jsearch && \
    ant && \
    cd ../jtile && \
    ant && \
    cd ../searender && \
    make Makefile.linux
 
ADD ./scripts/init.sh /bin/init.sh
USER root
RUN chmod a+x /bin/init.sh
CMD /bin/init.sh
