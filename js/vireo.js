//
// @file    vireo.js
// @brief   Vireo JavaScript code
// @author  Michael Hucka
// 
//<!---------------------------------------------------------------------------
// This file is part of Vireo, the VIewer for REfreshed Output.
// For more information, please visit https://github.com/mhucka/vireo
// 
// Copyright 2014-2015 California Institute of Technology.
// 
// VIREO is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free
// Software Foundation.  A copy of the license agreement is provided in the
// file named "LICENSE.txt" included with this software distribution and also
// available at http://sbml.org/Software/SBML_Test_Suite/license.html
//------------------------------------------------------------------------- -->


// Vireo checker function.
// ............................................................................
//
// The original version of this was based on crc-reload by "kiwidev":
// http://kiwidev.wordpress.com/2011/07/14/auto-reload-page-if-html-changed/
// https://bitbucket.org/diffused/html-crc-reload
//
// I rewrote nearly everything and renamed and repurposed it for Vireo, but
// the original idea and approach of using ajax + CRC was due to kiwidev's
// work.  I would not have been able to figure out some things without
// starting from that work.  
//
// I could not find any license or distribution statement in the original.
// This (new) work is released under the LGPL v.2 license.

// Whether polling is enabled at all.
//
var checkEnabled = true;

// The numbers are too big to be represented in javascript int, so the gross
// hack employed here is to turn them to strings and do string comparisons
// instead of numerical comparisons.
//
var prevCheckValue = '';

function check(path, md5file, callback) {
    if (checkEnabled) {
        if (md5file) {
            $.ajax({
                type: 'GET',
                cache: false,
                url: md5file,
                success: function(data) {
                    if (prevCheckValue == '') {
                        prevCheckValue = data;
                        return;
                    }
                    if (data != prevCheckValue) {
                        prevCheckValue = data;
                        if (callback) {
                            callback();
                            checkEnabled = false; // Stop until reenabled.
                        }
                    }
                }
            });
        } else {
            /* Fallback approach: get the whole file and compute a CRC 
               ourselves. This is bandwidth-heavy and thus undesirable, so
               it's better if the user provides an md5 file. */
            $.ajax({
                type: 'GET',
                cache: false,
                url: path,
                success: function(data) {
                    var newcrc = crc32(data).toString();
                    if (prevCheckValue == '') {
                        prevCheckValue = newcrc;
                        return;
                    }
                    if (newcrc != prevCheckValue) {
                        prevCheckValue = newcrc;
                        if (callback) {
                            callback();
                            checkEnabled = false; // Stop until reenabled.
                        }
                    }
                }
            });
        }
    }
}

function startCheck(path, frequency, callback) {
    checkEnabled = true;
    md5file = md5filename(path);
    check(path, md5file, null);         // Store the 1st check value.
    setInterval(function() { check(path, md5file, callback); }, 1000 * frequency);
}

function enableCheck(yesno) {
    if (checkEnabled == yesno)
        return;
    checkEnabled = yesno;
    if (checkEnabled) {
        prevCheckValue = '';
    }
}

function md5filename(path) {
    /* Normally we expect a file name like foo.pdf, but this approach
       will work even if there is no dot in the name. */
    var base = path.substr(0, path.lastIndexOf('.')) || path;
    var md5name = base + '.md5';
    if (fileExists(md5name))
        return md5name;
    else
        return null;
}

// Improved crc32 function from http://stackoverflow.com/a/18639999
//
var makeCRCTable = function() {
    var c;
    var crcTable = [];
    for (var n = 0; n < 256; n++){
        c = n;
        for (var k = 0; k < 8; k++){
            c = ((c&1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1));
        }
        crcTable[n] = c;
    }
    return crcTable;
}

var crc32 = function(str) {
    var crcTable = window.crcTable || (window.crcTable = makeCRCTable());
    var crc = 0 ^ (-1);

    for (var i = 0; i < str.length; i++ ) {
        crc = (crc >>> 8) ^ crcTable[(crc ^ str.charCodeAt(i)) & 0xFF];
    }

    return (crc ^ (-1)) >>> 0;
}


function openLog(base, path) {
   last_slash = base.lastIndexOf('/');
   url = base.substring(0, last_slash + 1) + '/' + vireo_log_file;
   window.open(url, '_blank');
   return true;
}


// Miscellaneous helper code.
// ............................................................................

// Function to get the iframe window object.
// Originally based on code from http://stackoverflow.com/a/11797741/743730
//
function getIframeWindow(iframe_object) {
    var doc;

    if (iframe_object.contentWindow) {
        return iframe_object.contentWindow;
    }

    if (iframe_object.window) {
        return iframe_object.window;
    } 

    if (!doc && iframe_object.contentDocument) {
        doc = iframe_object.contentDocument;
    } 

    if (!doc && iframe_object.document) {
        doc = iframe_object.document;
    }

    if (doc && doc.defaultView) {
        return doc.defaultView;
    }

    if (doc && doc.parentWindow) {
        return doc.parentWindow;
    }

    return undefined;
}


// Function to return a message followed by a time stamp.
//
function timeStamp(msg) {
    var now  = new Date().toTimeString().split(" ");
    var time = now[0];
    var zone = now[2];
    return msg + time + " " + zone;
}


// Test if a given URL or file exists.
// The path will be relative to the index.html file.
//
function fileExists(file) {
    var status = false;
    $.ajax({
        url: file,
        success: function(data){
            status = true;
        },
        error: function(data){
        },
    })
    return status;
}
