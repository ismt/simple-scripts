#!/bin/bash

declare -A  server
server=( [user]=root [password]=test [host]=127.0.0.1)

pv -N file ./t.sql.xz | xzcat  --threads=0 | pv -cN mysql |  \
mysql --user=${server[user]} \
      --password=${server[password]} \
      --host=${server[host]}
      --max_allowed_packet=1000M \
      --database=test

