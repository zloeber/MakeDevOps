
BASE_URL_8=https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz

#https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm

JDKVER=jdk1.8.0_192

# Quiet pushd/popd commands
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}

function install_targz_folder {
    # 1 = URL
    # 2 = Destination (ie. ~/.local/jdk8)
    URL="${1}"
    FILE=$(basename $URL)
    APP="${FILE%.tar.gz}"
    FOLDER=$(basename "${2}")
    TEMPFILE="${FOLDER}.tar.gz"
    
    echo "FOLDER: ${FOLDER}"
    echo "FILE: ${FILE}"
    echo "APP: ${APP}"

    rm -rf "${TEMPFILE}"
    pushd /tmp
    curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "${URL}"
	if [ ! -f "${TEMPFILE}" ]; then
		echo "Cannot download $FILE from $URL"
		exit 1
	fi

    # Extract to target directory
    #tar -xvf "${FOLDER}.tar.gz"
    echo "TEMPFILE: ${TEMPFILE}"
    tar -xzvf "${TEMPFILE}"
    mv "/tmp/${JDKVER}" "${2}"
}

url=${1:-"${BASE_URL_8}"}
dest=${2:-"${HOME}/.local/jdk8"}

echo "url: ${url}"
echo "dest: ${dest}"
install_targz_folder $url $dest
