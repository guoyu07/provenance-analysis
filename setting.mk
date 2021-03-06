# Program: PROCERATO - Program Provenance Analysis
# Author: Duy KHUONG <khuong@eurecom.fr>
# setting.mk

SHELL := /bin/bash

APT_PKGNAMES=apt-pkgnames.list
PIP_PKGNAMES=pip-pkgnames.list
APT_LST=apt.list
PIP_LST=pip.list
APT_SO_LST=apt_sorted.list
PIP_SO_LST=pip_sorted.list
ALL_FILES_LST=all_files.list
INTERESTING_LST=interesting.list
INTERESTING_DIRS_LST=interesting_dirs.list
FILES_INFO=files_info.dat
PROGRAMS_INFO=programs_info.dat
INTERNET_INFO=internet_info.dat
GIT_INFO=git_info.dat

# Final report
REPORT	:= report.xml

# Token files
GITHUB_TOKEN	:= token

# Error log file
ERR_LOG=.error.log

# Debug log file
DEBUG_LOG=.debug.log

# File extensions to be scanned
# .XPI: Firefox add-on file extension (applicable for Linux?)
SCAN_TYPES=so|sh|py|pyc|rb|jar|apk|php|js|pl|xpi

# Specify directories to scan
ifdef DIR
SCAN_DIRS=$(DIR)
else
SCAN_DIRS="/"
endif

# PIP installed packages directory
# It can be shown by:
# pip show -f <any_installed_pakage> | grep Location 
PIP_DIR=/usr/local/lib/python2.7/dist-packages

# Firefox add-on directories
MOZ_EXT_DIR=~/.mozilla/firefox/*/extensions
MOZ_PLG_DIR=~/.mozilla/firefox/*/plugins

# Chrome extension directory

# Web server directory
WEB_DIR=/var/www
