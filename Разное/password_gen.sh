#!/bin/bash

< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16};echo;

< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-32};echo;

< /dev/urandom tr -dc a-z0-9 | head -c${1:-8};echo;

< /dev/urandom tr -dc A-Z0-9 | head -c${1:-32};echo;
