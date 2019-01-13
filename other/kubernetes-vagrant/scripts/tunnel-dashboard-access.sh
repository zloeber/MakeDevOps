#!/bin/bash

# Usage: Assuming a vagrant based kubernetes (as in https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant-single.html), run this script in the same folder of the Vagrantfile (where you would normally do "vagrant up")
# * Then insert the password (by default: kubernetes)
# * Browse localhost:9090

USERNAME='kubernetes'
PASSWORD='kubernetes'
MASTERNODE='master'
PROXYPORT='8443'

function main() {
    Create_user_on_kubernetes_machine
    SSH_port_forwarding
    echo "Access proxy port: ${PROXYPORT}"
}

function Create_user_on_kubernetes_machine() {
    # Attribution: https://help.ubuntu.com/community/AddUsersHowto
    # Attribution: http://stackoverflow.com/questions/2150882/how-to-automatically-add-user-account-and-password-with-a-bash-script
    vagrant ssh $MASTERNODE -c "if [ ! -d /home/$USERNAME ]; then sudo useradd $USERNAME -m -s /bin/bash && echo '$USERNAME:$PASSWORD' | sudo chpasswd; fi"
}


function SSH_port_forwarding() {
    KUBERNETES_HOST=$(kubectl cluster-info | head -n 1 | grep -o -E '([0-9]+\.){3}[0-9]+')
    # Attribution: https://github.com/kubernetes/dashboard/issues/692
    # * Comment: https://github.com/kubernetes/dashboard/issues/692#issuecomment-251617588
    #     * By bbalzola: https://github.com/bbalzola
    TARGET=$(kubectl describe services kubernetes-dashboard --namespace=kube-system | grep Endpoints | awk '{ print $2 }')

    # Attribution: https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding
    ssh -L $PROXYPORT:$TARGET $USERNAME@$KUBERNETES_HOST
}

main