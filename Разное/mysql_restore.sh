pv -N file ./t.sql.gz | unpigz - | pv -cN mysql |  mysql --user=root \
                                                          --password=test \
                                                          --host=127.0.0.1 \
                                                          --max_allowed_packet=1000M \
                                                          --database=test











