export NFS_SERVER=`echo $(ipconfig getifaddr en0)`
export NFS_SUBNET=`echo $(ipconfig getifaddr en0 | cut -d "." -f -2).0.0`
export SOURCE_DIR="/Users/${USER}/nfsdata"
export NFS_PATH="${SOURCE_DIR}"
export CFG_KUBECTL_CONTEXT='docker-for-desktop'
export CMD_KUBECTL='kubectl'