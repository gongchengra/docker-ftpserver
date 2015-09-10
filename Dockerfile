# ftp server
#
# VERSION               0.0.2
#
# Links:
# - https://help.ubuntu.com/community/PureFTP
# - http://www.dikant.de/2009/01/22/setting-up-pureftpd-on-a-virtual-server/
# - http://download.pureftpd.org/pub/pure-ftpd/doc/README


FROM ubuntu:14.04
MAINTAINER Jonas Colmsjö "jonas@gizur.com"

RUN cd /etc/apt \
        && sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' sources.list \
        && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
        && apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y inetutils-ftp nano wget


#
# Install supervisord (used to handle processes)
# ----------------------------------------------
#
# Installation with easy_install is more reliable. apt-get don't always work.

RUN apt-get install -y python python-setuptools
RUN easy_install supervisor

ADD ./etc-supervisord.conf /etc/supervisord.conf
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor/


#
# Setup rsyslog
# ---------------------------

RUN apt-get install -y rsyslog

ADD ./etc-rsyslog.conf /etc/rsyslog.conf
ADD ./etc-rsyslog.d-50-default.conf /etc/rsyslog.d/50-default.conf


#
# Download and build pure-ftp
# ---------------------------

RUN wget http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.41.tar.gz
RUN tar -xzf pure-ftpd-1.0.41.tar.gz

RUN apt-get build-dep -y pure-ftpd

RUN cd /pure-ftpd-1.0.41; ./configure optflags=--with-everything --with-privsep --without-capabilities
RUN cd /pure-ftpd-1.0.41; make; make install


#
# Configure pure-ftpd
# -------------------

RUN mkdir -p /etc/pure-ftpd/conf

RUN echo yes > /etc/pure-ftpd/conf/ChrootEveryone
RUN echo no > /etc/pure-ftpd/conf/PAMAuthentication
RUN echo yes > /etc/pure-ftpd/conf/UnixAuthentication
RUN echo "30000 30009" > /etc/pure-ftpd/conf/PassivePortRange
RUN echo "10" > /etc/pure-ftpd/conf/MaxClientsNumber

# Needed in AWS, check the IP of the server (not sure how this works in docker)
#RUN echo "YOURIPHERE" > ForcePassiveIP
#RUN echo "yes" > DontResolve


#
# Setup users, add as many as needed
# ----------------------------------

RUN useradd -m -s /bin/bash wanghao
RUN echo wanghao:Jug3Grec|chpasswd

RUN useradd -m -s /bin/bash gongcheng
RUN echo gongcheng:ToulIch1|chpasswd

#
# Start things
# -------------

ADD ./start.sh /start.sh

EXPOSE 20 21 30000 30001 30002 30003 30004 30005 30006 30007 30008 30009
CMD ["/start.sh"]
