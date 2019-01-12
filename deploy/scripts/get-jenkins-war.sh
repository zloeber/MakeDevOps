#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "New Jenkins version number missing"
    exit 1
fi

VERSION=${1}

set -x

cd /usr/share/jenkins/
wget http://updates.jenkins-ci.org/download/war/${VERSION}/jenkins.war -O jenkins.war-${VERSION}
rm jenkins.war && ln -s jenkins.war-${VERSION} jenkins.war
service jenkins restart