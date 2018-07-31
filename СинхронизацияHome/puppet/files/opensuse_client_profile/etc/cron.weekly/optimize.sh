#!/bin/bash

/root/scripts/optimize.sh 2>&1 | tee /var/log/puppet_optimize.log
