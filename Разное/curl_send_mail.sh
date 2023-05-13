#!/usr/bin/env bash

curl --netrc --ssl --mail-from ismmail2@gmail.com --mail-rcpt w@proton.me --user i@gmail.com:'password' --url smtps://smtp.googlemail.com:465 --upload-file test.eml

#--tlsuser "i@gmail.com" --tlspassword "password"