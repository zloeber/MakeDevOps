#!/bin/bash

set -e
# set -x

. torsocks on

echo -e "\n> fetching a random hashbang.sh endpoint..."
endpoint=$(curl -s "https://hashbang.sh/server/stats" | jq "keys|.[]" -Mr | shuf -n 1)

if [[ -z $endpoint ]]; then
   echo "fatal: failed to fetch an endpoint over torsocks"
   exit 1
fi

mkrand() {
   prefix=$(cat /usr/share/dict/words | shuf -n 1 | tr -dc 'a-z' | head -c 4)
   prefixlen=$(echo -n ${prefix} | wc -c)
   len=$(expr ${1:-20} - ${prefixlen})
   suffix=$(openssl rand -base64 ${len} | tr -dc '_a-z-0-9')
   echo -n "${prefix}${suffix}"
}

echo "> generating a random 10 character username..."
username=${1:-$(mkrand 10)}

echo -e "> generating a temporary 4096-bit rsa key pair...\n"
sshkey_priv=$(mktemp hashbang.XXXXX)
sshkey_pub="${sshkey_priv}.pub"
rm ${sshkey_priv} && ssh-keygen -t rsa -b 4096 -C '' -N '' -f $sshkey_priv

echo -ne "\n> creating shell for user '${username}' on host '${endpoint}': "
curl -s -d '{"user":"'"${username}"'","key":"'"$(cat ${sshkey_pub})"'","host":"'"${endpoint}"'"}' -H 'Content-Type: application/json' https://hashbang.sh/user/create

echo -e "\n> shreding public key..."
shred -uz ${sshkey_pub} 2>&1 > /dev/null

echo -e "\nTHE FOLLOWING CONNECTION STRING HAS BEEN COPIED TO YOUR CLIPBOARD:"
cmd=$(echo -n "ssh -4 -o IdentityFile=${sshkey_priv} UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=false ${username}@${endpoint}")
echo -n $cmd | xclip
echo -e "\n${cmd}"

echo -e "\nBE SURE TO DESTROY THE PRIVATE KEY WHEN FINISHED:"
echo -e "\nshred -uz ${sshkey_priv}\n"