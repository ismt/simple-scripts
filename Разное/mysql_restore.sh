#!/bin/bash

pv -N file ./t.sql.xz | xz  -d  --threads=0 | pv -cN mysql |  mysql --user=root \
                                                          --password=test \
                                                          --host=127.0.0.1 \
                                                          --max_allowed_packet=1000M \
                                                          --database=test











