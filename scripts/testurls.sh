#!/bin/bash

BASE_URL='http://dockerlab.dok'

# =============================================================================

CLL="\r$(printf '%*s\n' 80)\r"
SEP="\r$(printf '%0.1s' "-"{1..80})"
function echo_line    { echo -en "${CLL}$*\n"; }
function echo_title   { echo -en "\n\033[1;30;47m${CLL}\t$*\033[0m\n"; }
function echo_success { echo -en "${CLL}$*\033[69G\033[0;39m[   \033[1;32mOK\033[0;39m    ]\n"; }
function echo_failure { echo -en "${CLL}$*\033[69G\033[0;39m[ \033[1;31mFAILED\033[0;39m  ]\n"; }
function echo_warning { echo -en "${CLL}$*\033[69G\033[0;39m[ \033[1;33mWARNING\033[0;39m ]\n"; }

# =============================================================================

function testUrl {
    CODE_NEED=${2:-200}
    CODE_RETURN=$(curl --write-out %{http_code} --silent --output /dev/null $1)

    [ -z "${CODE_NEED##*$CODE_RETURN*}" ] \
        && echo_success "${1} (${CODE_NEED})" \
        || echo_failure "${1} (${CODE_NEED}) -> ${CODE_RETURN}"
}

# =============================================================================
clear
echo_title "Base URL"
testUrl "${BASE_URL}"
testUrl "${BASE_URL}/"
testUrl "${BASE_URL}/index.html"
testUrl "${BASE_URL}/.htaccess" 200,403 # Depend of PHP

echo_title "PHP"
testUrl "${BASE_URL}/index.php"
testUrl "${BASE_URL}/pass"
testUrl "${BASE_URL}/index.php/pass"
testUrl "${BASE_URL}/wrong" 500

echo_title "Assets"
testUrl "${BASE_URL}/assets" 200,301 # Depend of PHP
testUrl "${BASE_URL}/assets/" 200,403 # Depend if inndexing is ON
testUrl "${BASE_URL}/assets/app.css"
testUrl "${BASE_URL}/assets/icon.png"
