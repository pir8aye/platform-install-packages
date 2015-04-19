#!/bin/sh
set -e
wget -O - http://installrepo.kaltura.org/repo/apt/debian/kaltura-deb.gpg.key|apt-key add -

# aptitude has a more advanced API then apt-get and is better at resolving deps. For some reason, it is not installed on all deb based system so lets see if we haveit.

if which aptitude;then
        APT_TOOL=aptitude
else
        APT_TOOL=$APT_TOOL
fi
$APT_TOOL -y update
$APT_TOOL install mysql-server 
$APT_TOOL install kaltura-postinst 
$APT_TOOL install kaltura-base 
$APT_TOOL install kaltura-front 
$APT_TOOL install kaltura-widgets kaltura-html5-studio kaltura-html5lib 
$APT_TOOL install kaltura-sphinx 
$APT_TOOL install kaltura-db 
$APT_TOOL install kaltura-ba