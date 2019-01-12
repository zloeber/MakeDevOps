## Example Sessions

Here are some example sessions for various things I've done. As I remember to do so I'll keep adding more to build up a set of 'recipies'.

```bash
make install-awless install-envman

# Setup a localized environment with some convenience SSO and other env vars.
envman init
envman add -k ARG_USERNAME -v zachary.loeber.consultant@nielsen.com
envman add -k ARG_USERPASS -v '<password>'


# Use saml auth with awless
awless switch saml

# Get authenticated via saml and your custom env vars
envman run bash -c 'make sso-login'

# From here on out you need only run the last commands to access via saml

# Start an instance
awless start instance id=i-0c931769eabd5cdc9
```


```bash
# Install cloudmapper (Centos only currently)
$HOME/deploy/scripts/install-cloudmapper.sh

# Configure cloudmapper from within the pipenv virtual env you are now in
rm -rf ./confg.json
pipenv run python cloudmapper.py configure add-account --name nielsen_dev --id 1 --default true
pipenv run python cloudmapper.py configure add-cidr --cidr 10.237.184.0/21 --name nielsen_dev_int

pipenv run python cloudmapper.py collect --profile saml

```