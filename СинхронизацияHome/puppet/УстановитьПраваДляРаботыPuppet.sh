#!/bin/bash

chown -c -R client:client /home/client

chown -c -R puppet:puppet /etc/puppet/files
chown -c -R puppet:puppet /home/puppet

echo Права установлены
