#! /bin/sh -x
#
# @file    vireo.sh
# @brief   Simple script to start/stop/restart vireo-server.py
# @author  Michael Hucka <mhucka@caltech.edu>
#
# This script is suitable for Linux/Unix server installations to start and
# stop the Vireo server when (e.g.) the computer reboots.  Depending on your
# operating system and preferences, you might copy this script into
# /etc/init.d, use it with Monit, or do something similar.
#
#<!---------------------------------------------------------------------------
# This file is part of Vireo, the VIewer for REfreshed Output.
# For more information, please visit https://github.com/mhucka/vireo
#
# Copyright 2014-2015 California Institute of Technology.
#
# VIREO is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation.  A copy of the license agreement is provided in the
# file named "LICENSE.txt" included with this software distribution and also
# available at https://github.com/mhucka/vireo/LICENSE.txt.
#------------------------------------------------------------------------- -->

# Change the following variables to correspond to your environment.

HOME=/your/home/dir
export HOME

VIREO_DIR="/change/this/path"
VIREO_PORT=9999
VIREO_CMD="make"
VIREO_LOG="vireo.log"
VIREO_SERVER="$VIREO_DIR/vireo-server.py"


# .............................................................................
# The rest below is generic and probably does not need to be changed.

if [ `id -u` = 0 ]; then
    echo "Do not run this as root; run it as the owner of your document files."
fi

RETVAL=0

case "$1" in
    start)
        "$VIREO_SERVER" -d "$VIREO_DIR" -c "$VIREO_CMD" -l "$VIREO_LOG" -p $VIREO_PORT -o
        RETVAL=$?
        ;;
    stop)
        pkill --signal INT -f "$VIREO_SERVER"
        RETVAL=$?
        ;;
    restart)
        $0 stop
        sleep 5
        $0 start
        RETVAL=$?
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}" >&2
        exit 3
        ;;
esac

exit $RETVAL
