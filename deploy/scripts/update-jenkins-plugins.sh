#!/bin/bash

jenkinsUrlBase='http://jenkins:password1@localhost:8888'

callJenkins() { # funcPath
    curl --silent --show-error -g "${jenkinsUrlBase}${1}"
}

postJenkinsFile() { # funcPath fileName
    curl --silent --show-error -g -d "@${2}" "${jenkinsUrlBase}${1}"
}

callJenkins '/api/xml?tree=jobs[name]' | xmlstarlet sel -t -v '//hudson/job/name' | while read projectName ; do

    echo "Processing ${projectName}..."
    origFile="${projectName}_old.xml"
    newFile="${projectName}_new.xml"
    callJenkins "/job/${projectName}/config.xml" > "$origFile"

    echo " - Updating artifactory url..."
    cat "$origFile" \
        | xmlstarlet ed -P -u '//maven2-moduleset/publishers/org.jfrog.hudson.ArtifactoryRedeployPublisher/details/artifactoryUrl' -v "http://newServer/artifactory" \
    > "${newFile}"

    if false ; then
        echo " - Commiting new config file..."
        postJenkinsFile "/job/${projectName}/config.xml" "$newFile"
    else
        echo " - Dry run: not commiting new config file"
    fi

done
