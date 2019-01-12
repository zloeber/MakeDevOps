# Mostly from here:
#  http://kendrickcoleman.com/index.php/Tech-Blog/how-to-install-harbor-on-centos-7-using-bash.html

# $1 = Version (1.7.1)
# $2 = online|offline (online)
# DEST = Cert destination (~/.config/harbor/certs/)

# Quiet pushd/popd commands
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}

VER="${1:-1.7.1}"
MODE="${2:-online}"
CERTDEST="${DEST:-"${HOME}/.config/harbor/certs"}"
FQDN="$(hostname -f)"
MAINUSER=$(logname)
FILE="harbor-online-installer-v${VER}.tgz"
IP=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`

echo "VER: ${VER}"
echo "MODE: ${MODE}"
echo "FQDN: ${FQDN}"
echo "FILE: ${FILE}"
echo "CERTDEST: ${CERTDEST}"
echo "IP: ${IP}"

# Create Self-Signed OpenSSL Certs
mkdir -p /home/$MAINUSER/harbor_install
mkdir -p /home/$MAINUSER/harbor_install/openssl
cd /home/$MAINUSER/harbor_install/openssl
echo subjectAltName = IP:"${IP}" > extfile.cnf
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 3650 -out ca.crt -subj "/C=US/ST=CA/L=San Francisco/O=VMware/OU=IT Department/CN=${FQDN}"
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${FQDN}.key -out ${FQDN}.csr -subj "/C=US/ST=CA/L=San Francisco/O=VMware/OU=IT Department/CN=${FQDN}"
openssl x509 -req -days 3650 -in ${FQDN}.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.cnf -out ${FQDN}.crt

# Copy certs to root for Harbor Inatallation
mkdir -p $CERTDEST
cp -f ${FQDN}.crt $CERTDEST
cp -f ${FQDN}.key $CERTDEST

# Copy certs to Docker to get around X509 unauthorized cert error
sudo mkdir -p /etc/docker/certs.d/${FQDN}/
sudo cp ${FQDN}.crt /etc/docker/certs.d/${FQDN}/
sudo cp ${FQDN}.key /etc/docker/certs.d/${FQDN}/
sudo cp ca.crt /etc/docker/certs.d/${FQDN}/
sudo cp ca.key /etc/docker/certs.d/${FQDN}/
sudo cp /etc/docker/certs.d/${FQDN}/${FQDN}.crt /etc/docker/certs.d/${FQDN}/${FQDN}.cert
sudo cp /etc/docker/certs.d/${FQDN}/ca.crt /etc/docker/certs.d/${FQDN}/ca.cert

# Copy certs to TLS for Notary usage
mkdir -p /home/${MAINUSER}/.docker/tls/${FQDN}:4443/
cp ca.crt /home/${MAINUSER}/.docker/tls/${FQDN}:4443/
cp ca.key /home/${MAINUSER}/.docker/tls/${FQDN}:4443/
cp /home/${MAINUSER}/.docker/tls/${FQDN}:4443/ca.crt /home/${MAINUSER}/.docker/tls/${FQDN}:4443/ca.cert
chown ${MAINUSER}:${MAINUSER} /home/${MAINUSER}/.docker

cd /home/$MAINUSER/harbor_install

wget "https://storage.googleapis.com/harbor-releases/release-1.7.0/${FILE}"

if [ ! -f "${FILE}" ]; then
    echo "Cannot download ${FILE}!"
    exit 1
fi

tar xvf "${FILE}"

cd harbor

sed -i "s|hostname = reg.mydomain.com|hostname = $FQDN|g" harbor.cfg
sed -i "s|ui_url_protocol = http|ui_url_protocol = https|g" harbor.cfg
sed -i "s|ssl_cert = /data/cert/server.crt|ssl_cert = $CERTDEST/$FQDN.crt|g" harbor.cfg
sed -i "s|secretkey_path = /data|secretkey_path = $CERTDEST|g" harbor.cfg
sed -i "s|ssl_cert_key = /data/cert/server.key|ssl_cert_key = $CERTDEST/$FQDN.key|g" harbor.cfg

# Prepare Harbor
./prepare

# Install Harbor
./install.sh # --with-notary --with-clair