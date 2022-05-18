#!/bin/bash

### VARIABLES ###
PRE_PACK="openssl-devel pcre-devel make gcc"
VER="1.5.1"


# Setup Colours
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'

boldblack='\E[1;30;40m'
boldred='\E[1;31;40m'
boldgreen='\E[1;32;40m'
boldyellow='\E[1;33;40m'
boldblue='\E[1;34;40m'
boldmagenta='\E[1;35;40m'
boldcyan='\E[1;36;40m'
boldwhite='\E[1;37;40m'

Reset="tput sgr0"      #  Reset text attributes to normal
                       #+ without clearing screen.

cecho ()                     # Coloured-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
message=$1
color=$2
echo -e "$color$message" ; $Reset
return
}

clear

cecho "Installing/upgrading your web server..." $boldgreen

yum -y -q install $PRE_PACK > /dev/null


mkdir -p /src
cd /src

wget -q http://www.haproxy.org/download/1.5/src/haproxy-$VER.tar.gz
tar xzf haproxy-$VER.tar.gz && rm -f haproxy*.tar.gz;
cd haproxy-$VER

cecho "Configuring and Making HAPROXY" $boldgreen

make TARGET=linux2628 CPU=x86_64 USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE=1     # compiles it with compression and ssl support; use CPU=x86_64 for CentOS x64 or i686 where approriate

cecho "Installing HAPROXY" $boldgreen
make install


cecho "Adding HAProxy User" $boldyellow
id -u haproxy &>/dev/null || useradd -s /usr/sbin/nologin -r haproxy


cecho "Creating config and Adding Daemon" $boldgreen

cp /usr/local/sbin/haproxy* /usr/sbin/     # copy binaries to /usr/sbin
cp /src/haproxy-$VER/examples/haproxy.init /etc/init.d/haproxy     # copy init script in /etc/init.d
chmod +x /etc/init.d/haproxy     # setting permission on init script
mkdir -p /etc/haproxy     # creating directory where the config file must reside
cp /src/haproxy-$VER/examples/examples.cfg /etc/haproxy/haproxy.cfg     # copy example config file
mkdir -p /var/lib/haproxy     # create directory for stats file
touch /var/lib/haproxy/stats     # creating stats file


cecho "checking config and starting service" $boldyellow
service haproxy check     # checking configuration file is valid
service haproxy start     # starting haproxy to verify it is working
chkconfig haproxy on     # setting haproxy to start with VM

exit 0