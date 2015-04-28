#!/usr/bin/env python
#
# @file    vireo-server.py
# @brief   Web server for Vireo
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

# This was originally inspired by https://github.com/logsol/Github-Auto-Deploy
# This code is quite substantially different, however.


from __future__ import print_function
from subprocess import call, STDOUT
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import os
import sys
import plac
import setproctitle
import logging


# Server code.
# .............................................................................

class VireoHandler(BaseHTTPRequestHandler):
    quiet  = False
    cmd    = None
    port   = None
    dir    = None
    logger = None

    def respond(self, code):
        self.send_response(code)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()


    def do_POST(self):
        self.logger.info('Received post request on port {}'.format(self.port))
        self.respond(204)
        self.run_command()


    # This will block until the call to the command is finished.  That's what we
    # want -- we don't want multiple processes to be started at the same time.
    #
    def run_command(self):
        self.logger.info('Changing to direcory "{}"'.format(self.dir))
        os.chdir(self.dir)
        log = self.logger.get_log()
        self.logger.info('{:-^50}'.format(' Executing "{}" '.format(self.cmd)))
        call([self.cmd], stdout=log, stderr=log, shell=True)
        self.logger.info('{:-^50}'.format(' Done '.format(self.cmd)))


# Approach borrowed from http://stackoverflow.com/a/21632210/743730

class VireoHTTPServer(HTTPServer):
    def serve_forever(self, dir, cmd, port, quiet, logger):
        self.RequestHandlerClass.quiet  = quiet
        self.RequestHandlerClass.dir    = dir
        self.RequestHandlerClass.cmd    = cmd
        self.RequestHandlerClass.port   = port
        self.RequestHandlerClass.logger = logger
        HTTPServer.serve_forever(self)


def main(dir=None, port=None, cmd=None, logfile=None, daemon=False, quiet=False):
    logger = VireoLogger(logfile, quiet)

    if not port:
        logger.fail('No port number supplied.')
    else:
        try:
            port_num = int(port)
            if not (0 < port_num < 65536):
                raise ValueError()
        except ValueError:
            logger.fail('Port number must be an integer between 1 and 65535')

    if not dir:
        dir = os.getcwd()
    try:
        os.chdir(dir)
    except OSError:
        logger.fail('Cannot change to directory "{}"'.format(dir))

    # Check command after changing dir, in case it's a relative path.
    if not command:
        logger.fail('Cannot proceed without a command or script.')
    if command.find(os.sep) >= 0 and not valid_file(command):
        logger.fail('Unable to find file "{}"'.format(command))

    if daemon:
        pid = os.fork()
        setproctitle.setproctitle(os.path.realpath(__file__))
        if pid != 0:
            if not quiet:
                logger.info('Forked Vireo daemon as process {}'.format(pid))
            sys.exit()
        os.setsid()

    try:
        if not quiet:
            logger.info('Vireo running in directory "{}"'.format(str(dir)))
            logger.info('Listening on port {}'.format(port))
        httpd = VireoHTTPServer(('', port_num), VireoHandler)
        httpd.serve_forever(dir, command, port, quiet, logger)
    except (KeyboardInterrupt, SystemExit) as e:
        if e:
            logger.info(str(e))
        if (not httpd is None):
            httpd.socket.close()
        if not quiet:
            if isinstance(e, KeyboardInterrupt):
                logger.info('Received interrupt command from the keyboard.')
            logger.info('Vireo exiting.')


# Helpers
# .............................................................................

class VireoLogger(object):
    quiet   = False
    logger  = None
    outlog  = None

    def __init__(self, logfile, quiet):
        self.quiet = quiet
        self.configure_logging(logfile)

    def configure_logging(self, logfile):
        self.logger = logging.getLogger('Vireo')
        self.logger.setLevel(logging.DEBUG)
        logging.getLogger('Vireo').addHandler(logging.NullHandler())
        if logfile:
            handler = logging.FileHandler(logfile)
        else:
            handler = logging.StreamHandler()
        formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
        self.outlog = handler.stream

    def info(self, *args):
        msg = ' '.join(args)
        self.logger.info(msg)

    def fail(self, *args):
        msg = 'ERROR: ' + ' '.join(args)
        self.logger.error(msg)
        self.logger.error('Exiting.')
        raise SystemExit(msg)

    def get_log(self):
        return self.outlog


def valid_file(file):
    if not os.path.exists(file):   return False
    elif not os.path.isfile(file): return False
    else:                          return True


# Plac annotations for main function arguments
# .............................................................................

# Argument annotation follows (help, kind, abbrev, type, choices, metavar) convention
main.__annotations__ = dict(
    dir     = ('document directory (default: current dir)',      'option', 'd'),
    command = ('command to execute',                             'option', 'c'),
    logfile = ('log file (default: log to stdout)',              'option', 'l'),
    port    = ('port to listen on',                              'option', 'p'),
    daemon  = ('fork and run in daemon mode',                    'flag',   'o'),
    quiet   = ('be quiet (default: print informative messages)', 'flag',   'q'),
)


# Entry point
# .............................................................................

def cli_main():
    plac.call(main)

cli_main()
