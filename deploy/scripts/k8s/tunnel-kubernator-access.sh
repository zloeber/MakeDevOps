
#!/bin/bash

# Usage: Assuming a vagrant based kubernetes run this script in the same folder of the Vagrantfile
# * Then insert the password (by default: kubernetes)
# * Browse localhost:PROXYPORT

MASTERNODE='master'
PROXYPORT='8001'

#vagrant ssh $MASTERNODE -c "if [ ! -d /home/$USERNAME ]; then sudo useradd $USERNAME -m -s /bin/bash && echo '$USERNAME:$PASSWORD' | sudo chpasswd; fi"

KUBE_HOST=$(vagrant ssh $MASTERNODE -c "kubectl cluster-info | head -n 1 | grep -o -E '([0-9]+\.){3}[0-9]+'")
TARGET=$(vagrant ssh $MASTERNODE -c "kubectl describe services kubernator --namespace=kubernator | grep Endpoints | cut -d':' -f2")
TARGET=$(echo $TARGET | sed -e 's/^[ \t]*//')
VAGRANTUSER=$(vagrant ssh-config $MASTERNODE | grep 'User ' | awk '{print $NF}')
SSHKEYFILE=$(vagrant ssh-config $MASTERNODE | grep IdentityFile | awk '{print $NF}')
SSHPORT=$(vagrant ssh-config $MASTERNODE | grep Port | awk '{print $NF}')

echo ''
echo "Access kubernator - http://localhost:${PROXYPORT}/api/v1/namespaces/kubernator/services/kubernator/proxy/"

ssh -L $PROXYPORT:127.0.0.1:$PROXYPORT ${VAGRANTUSER}@127.0.0.1 -p $SSHPORT -i $SSHKEYFILE

