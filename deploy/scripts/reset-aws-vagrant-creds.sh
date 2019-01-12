#!/bin/bash
# Simple script to reset the /home/vagrant/.aws/credential file

sourcefile="/vagrant/secrets/aws.credentials"
destfile="/home/vagrant/.aws/credentials"

if [ ! -f $sourcefile ]; then
    echo "${sourcefile} not found!"
else
    cp -f $sourcefile $destfile
    echo "aws credentials file updated!"
fi
