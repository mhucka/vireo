#! /bin/sh
#
# @file    vireo.sh
# @brief   Simple script to start/stop/restart vireo-server.py
# @author  Michael Hucka <mhucka@caltech.edu>
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

if [ `id -u` = 0 ]; then
    echo "Do not run this as root; run it as the owner of your document files."
fi

HOME=/home/mhucka
export HOME

VIREO_DIR=/home/mhucka/vireo/whole-cell-meeting-report
VIREO_CMD=$VIREO_DIR/vireo-server.py -p 9005 -o -c make -l

RETVAL=0

case "$1" in
  start)
        $VIREO_CMD
        RETVAL=$?
        ;;
  stop)
        killall vireo-server.py
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
