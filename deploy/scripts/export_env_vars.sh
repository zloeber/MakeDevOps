#!/bin/bash
# Exports all env vars found in the file passed in
if [ -f ${1} ]
then
  #Load Variables
  while read assignment; do
    export ${assignment}
  done < ${1}
fi
