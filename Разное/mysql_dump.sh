#!/bin/bash


arc="pv -cN mysqldump | xz -1 -c  --threads=0 | pv -cN xz > t.sql.xz"

mysqldump \
    --user=root \
    --password=test \
    --host=127.0.0.1 \
    --max_allowed_packet=1000M \
    --add-locks \
    --extended-insert \
    --lock-tables \
    --routines \
    --quick \
    --no-autocommit \
    dev_api_db | eval  $arc

