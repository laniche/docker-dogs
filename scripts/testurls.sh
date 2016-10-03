#!/bin/bash

BASE_URL='http://dockerlab.dok'

# =============================================================================

CLL="\r$(printf '%*s\n' 80)\r"
SEP="\r$(printf '%0.1s' "-"{1..80})"
COLOR_WHITE="\033[1;37m"
COLOR_LIGHT_GRAY="\033[0;37m"
COLOR_NONE="\033[0m"
function echo_line    { echo -en "${CLL}$*\n"; }
function echo_title   { echo -en "\n${SEP}\n\t\033[1;37m$*\033[0m\n${SEP}\n"; }
function echo_success { echo -en "${CLL}$*\033[69G\033[0;39m[   \033[1;32mOK\033[0;39m    ]\n"; }
function echo_failure { echo -en "${CLL}$*\033[69G\033[0;39m[ \033[1;31mFAILED\033[0;39m  ]\n"; }
function echo_warning { echo -en "${CLL}$*\033[69G\033[0;39m[ \033[1;33mWARNING\033[0;39m ]\n"; }

# =============================================================================

function testUrl {
    RESULT=$(curl -sSf -o /dev/null $1 2>&1) \
    && echo_success $1 \
    || { echo_failure $1 ; echo_line "\t${RESULT}\n" ; }
}

# =============================================================================
clear

echo_title "Base URL"
testUrl "${BASE_URL}"
testUrl "${BASE_URL}/"
testUrl "${BASE_URL}/index.html"

echo_title "PHP"
testUrl "${BASE_URL}/index.php"
testUrl "${BASE_URL}/test"

echo_title "Assets"
testUrl "${BASE_URL}/assets"
testUrl "${BASE_URL}/assets/"
testUrl "${BASE_URL}/assets/app.css"
testUrl "${BASE_URL}/assets/.htaccess"

echo_title "Errors"
testUrl "${BASE_URL}/wrong"
testUrl "${BASE_URL}/wrong/"
testUrl "${BASE_URL}/wrong/index.php"
testUrl "${BASE_URL}/wrong/file.png"
testUrl "${BASE_URL}/error/404"
testUrl "${BASE_URL}/error/500"
