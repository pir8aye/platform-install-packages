#!/bin/bash - 
#===============================================================================
#          FILE: sphinx_update.sh
#         USAGE: ./sphinx_update.sh 
#   DESCRIPTION: 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jess Portnoy (), <jess.portnoy@kaltura.com>
#  ORGANIZATION: Kaltura, inc.
#       CREATED: 11/10/14 12:37:31 EST
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

KALTURA_FUNCTIONS_RC=`dirname $0`/kaltura-functions.rc
if [ ! -r "$KALTURA_FUNCTIONS_RC" ];then
	OUT="Could not find $KALTURA_FUNCTIONS_RC so, exiting.."
	echo $OUT
	exit 3
fi
. $KALTURA_FUNCTIONS_RC
RC_FILE=/etc/kaltura.d/system.ini
if [ ! -r "$RC_FILE" ];then
	echo -e "${BRIGHT_RED}ERROR: could not find $RC_FILE so, exiting..${NORMAL}"
	exit 1 
fi
. $RC_FILE
# this if would have been very convenient, however, some users may upgrade from say, 2 versions down and not directly from last so we can't really tell their current status and hence, we should do this each upgrade. Since its CE, the running of this should not take that long anyhow.
#if [ -r $APP_DIR/configurations/sphinx_conf_changed ];then
	if /etc/init.d/kaltura-sphinx status;then
		# disable Sphinx's monit monitoring
		rm $APP_DIR/configurations/monit/monit.d/enabled.sphinx.rc 
		/etc/init.d/kaltura-sphinx stop
	fi
	STMP=`date +%s`
	mkdir -p $BASE_DIR/sphinx.bck.$STMP
	echo "Backing up files to $BASE_DIR/sphinx.bck.$STMP. Once the upgrade is done and tested, please remove this directory to save space"
	mv $BASE_DIR/sphinx/kaltura_*  $LOG_DIR/sphinx/data/binlog.* $BASE_DIR/sphinx.bck.$STMP
	/etc/init.d/kaltura-sphinx start
	ln -sf $APP_DIR/configurations/monit/monit.avail/sphinx.rc $APP_DIR/configurations/monit/monit.d/enabled.sphinx.rc
	php $APP_DIR/deployment/base/scripts/populateSphinxEntries.php
	if [ $? -ne 0 ];then

		echo "Failed to run $APP_DIR/deployment/base/scripts/populateSphinxEntries.php.
	Please try to run it manually and look at the logs"
	fi
	rm $APP_DIR/configurations/sphinx_conf_changed
#fi