'''
aws-sso.py

The following environmental variables will be parsed for default 
parameter values (generally making it more docker friendly). Manually entered arguments will take precedence to the environmental variables defined below:

    <PARAMETER> - <ENV VAR> = <Default Value>
    fqdn - ARG_FQDN = 'sts.contoso.com'
    username - ARG_USERNAME = None
    userpass - ARG_USERPASS = None
    region - ARG_REGION = 'us-east-1'
    role - ARG_ROLE = 'none'
    profile - ARG_PROFILE = 'saml'
    profilepath - ARG_PROFILEPATH = '~/.aws/credentials'

Note: ARG_ROLE should be in the following format: role_arn,principal_arn
'''
import sys
import xml.etree.ElementTree as ET
import requests
import getpass
import configparser
import base64
import logging
import traceback
import click
from bs4 import BeautifulSoup
from datetime import timedelta
from os.path import expanduser
from requests_ntlm import HttpNtlmAuth
import re
try:
    from urllib.parse import urlparse
except ImportError:  # Python < 3
    from urlparse import urlparse

import argparse
import os
from datetime import datetime
import boto3


class Output(object):
    """
    Class to centralize all output for a script. Uses click echo commands for pretty output
    (when not supressed). This also sends logs to a central system logger.
    """

    def __init__(self, loggername=__name__, loghandler=logging.NullHandler(), storelogs=True, suppress=False, debugenabled=False):
        self._logger = logging.getLogger(loggername)
        self._logger.addHandler(loghandler)
        self._log = []
        self._storelogs = storelogs
        self._suppress = suppress
        self.debugenabled = debugenabled
        logging.captureWarnings(True)

    def suppress_console_output(self, suppress=None):
        """Suppress/Allow output to the screen"""
        if (suppress is not None) and isinstance(suppress, bool):
            self._suppress = suppress
        else:
            self._suppress = False

    def get_logs(self):
        """
        Return any stored logs.
        """
        return self._log

    def _add_log(self, mylog, logtype='info'):
        """
        Add a log
        """
        if logtype.lower() == 'error':
            self._logger.error(str(mylog))
        elif logtype.lower() == 'warning':
            self._logger.warning(str(mylog))
        elif logtype.lower() == 'debug':
            self._logger.debug(str(mylog))
        elif logtype.lower() == 'exception':
            self._logger.exception(str(mylog))
        else:   # Default to info logs
            self._logger.info(str(mylog))

        if self._storelogs:
            prepend = '{0}'.format(logtype.upper())
            self._log.append('{0}:{1}'.format(prepend, mylog))

    def info(self, text, suppress=None):
        """
        Add informational log
        """
        if suppress is None:
            suppress = self._suppress

        self._add_log(str(text), 'info')

        if not suppress:
            self.echo(text, color='white')

    def debug(self, text, suppress=None):
        """
        Add debug log
        """
        if suppress is None:
            suppress = self._suppress

        if self.debugenabled:
            self._add_log(str(text), 'debug')

            if not suppress:
                self.echo(text, color='white')

    def status(self, text, suppress=None):
        """
        Add a status log
        """
        if suppress is None:
            suppress = self._suppress
        self.info(text, suppress)
        self.line()

    def prompt(self, text, default=0, inputtype=int):
        """
        Prompt for input
        """
        value = click.prompt(text, type=inputtype, default=default)
        return value

    def error(self, text, suppress=None):
        """
        Add an error log
        """
        if suppress is None:
            suppress = self._suppress

        self._add_log(str(text), 'error')

        if not suppress:
            self.echo("ERROR: " + text, color='red')

    def warning(self, text, suppress=None):
        """
        Add a warning log
        """
        if suppress is None:
            suppress = self._suppress

        self._add_log(str(text), 'warning')

        if not suppress:
            self.echo("WARN: " + text, color='yellow')

    def exception(self, exception, suppress=None):
        """
        Add an exception log
        """
        if suppress is None:
            suppress = self._suppress
        if isinstance(exception, Exception):
            exceptionstr = traceback.format_exc(exception)
        else:
            exceptionstr = exception
        self._add_log(exceptionstr, 'exception')

        if not suppress:
            self.echo("EXCEPTION: " + exceptionstr, color='red')

    def warn(self, text, suppress=None):
        """
        Add a warning log
        """
        self.warning(text, suppress)

    def header(self, text, suppress=None):
        """
        Add a header log
        """
        if suppress is None:
            suppress = self._suppress

        subject = "======== {0} ========".format(text).upper()
        border = "="*len(subject)

        if not suppress:
            self.line()
            self.echo(border, color='white')
            self.echo(subject, color='white')
            self.echo(border, color='white')
            self.line()

        self._add_log(border, 'info')
        self._add_log(subject, 'info')
        self._add_log(border, 'info')

    def param(self, text, value, status, suppress=None):
        """
        Add a parameter/setting log
        """
        if suppress is None:
            suppress = self._suppress

        if value and not suppress:
            self.header("SETTING " + text)
            self.status(status)

    def configelement(self, name='', value='', separator=': ', suppress=None):
        """
        Add/display a configuration element
        """
        if suppress is None:
            suppress = self._suppress

        logoutput = '{0}{1}{2}'.format(str(name), str(separator), str(value))
        self.info(logoutput, suppress=True)
        if not suppress:
            click.secho(str(name), fg='cyan', bold=True, nl=False)
            click.secho(str(separator), fg='magenta', nl=False)
            click.secho(str(value), fg='white')

    def footer(self, text, suppress=None):
        """
        Add a footer log
        """
        if suppress is None:
            suppress = self._suppress
        self._add_log(str(text).upper(), 'info')
        if not suppress:
            self.info(text.upper())
            self.line()

    def procout(self, text, suppress=None):
        """
        Process output
        """
        if suppress is None:
            suppress = self._suppress
        if not suppress:
            self.echo(text, dim=True)

    def line(self, suppress=None):
        """
        Add a blank line
        """
        if suppress is None:
            suppress = self._suppress

        if not suppress:
            self.echo(text="")

    def echo(self, text, color="", dim=False):
        """
        Generic echo to screen (replaces print/pprint)
        """
        try:
            click.secho(text, fg=color, dim=dim)
        except:
            from pprint import pprint
            pprint(text)


def get_credentials_with_sso(
        fqdn,
        username,
        region,
        profile,
        profilepath,
        debug,
        arn_regex,
        role,
        verifytoken):
    '''Perform SSO session authentication with AWS'''
    # IdpInitiaedSignOn url template
    idpentryurl = 'https://' + fqdn + \
        '/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices'
    OUTPUT.info('idpentryurl: {0}'.format(idpentryurl))

    # aws variables to write to configuration file, it is possible to remove some or add more
    aws_vars = {
        "output": "json",
        "region": region,
    }

    # awsconfigfile: The file where this script will store the temp credentials under the saml profile
    awsconfigfile = ARG_PROFILEPATH  # '/.aws/credentials'

    # SSL certificate verification: Whether or not strict certificate
    # verification is done, False should only be used for dev/test
    sslverification = ARG_SSLVERIFY  # True

    # Get the federated credentials from the user if not passed in via env vars or argument
    if not username:
        username = OUTPUT.prompt(text='Username:', inputtype=str, default='')
    if ARG_USERPASS:
        password = ARG_USERPASS
    else:
        password = getpass.getpass()
    OUTPUT.line()

    if not username or not password:
        raise Exception('Missing a username or a password or both.')
    # Initiate session handler
    session = requests.Session()

    # Programatically get the SAML assertion
    # Set up the NTLM authentication handler by using the provided credential
    session.auth = HttpNtlmAuth(username, password, session)
    OUTPUT.debug('HTTP GET: {0}'.format(idpentryurl))
    # Opens the initial AD FS URL and follows all of the HTTP302 redirects
    response = session.get(idpentryurl, verify=sslverification)

    # Debug the response if needed
    if debug:
        OUTPUT.info(response.text)

    # Decode the response and extract the SAML assertion
    soup = BeautifulSoup(response.content.decode('utf8'), "html.parser")
    assertion = ''

    # Look for the SAMLResponse attribute of the input tag (determined by
    # analyzing the debug print lines above)
    for inputtag in soup.find_all('input'):
        if inputtag.get('name') == 'SAMLResponse':
            OUTPUT.debug(inputtag.get('value'))
            # print(inputtag.get('value'))
            assertion = inputtag.get('value')

    # if the script is being difficult, try it again, submit dat form
    if not assertion and len(list(soup.find_all(re.compile('(FORM|form)')))):
        OUTPUT.info(
            'Initial form did not redirect, attempting to fill in form with username + pass.')

        # re parse creds into input and click the button
        payload = {}

        for inputtag in soup.find_all(re.compile('(INPUT|input)')):
            name = inputtag.get('name', '')
            value = inputtag.get('value', '')
            if "user" in name.lower():
                # Make an educated guess that this is correct field for username
                payload[name] = username
            elif "email" in name.lower():
                # Some IdPs also label the username field as 'email'
                payload[name] = username
            elif "pass" in name.lower():
                # Make an educated guess that this is correct field for password
                payload[name] = password
            else:
                # Populate the parameter with existing value (picks up hidden fields in the login form)
                payload[name] = value

        # Some IdPs don't explicitly set a form action, but if one is set we should
        # build the idpauthformsubmiturl by combining the scheme and hostname
        # from the entry url with the form action target
        # If the action tag doesn't exist, we just stick with the idpauthformsubmiturl above
        for inputtag in soup.find_all(re.compile('(FORM|form)')):
            action = inputtag.get('action')
            if action:
                parsedurl = urlparse(idpentryurl)
                idpauthformsubmiturl = parsedurl.scheme + "://" + parsedurl.netloc + action

        if not idpauthformsubmiturl:
            raise Exception("uh oh")

        # Performs the submission of the login form with the above post data
        OUTPUT.debug('HTTP POST')
        OUTPUT.debug('- URL: {0}'.format(idpauthformsubmiturl))
        OUTPUT.debug('- data: {0}'.format(payload))
        OUTPUT.debug('- sslverify: {0}'.format(sslverification))
        response = session.post(
            idpauthformsubmiturl,
            data=payload,
            verify=sslverification)

        # Debug the response if needed
        OUTPUT.debug(response.text)

        soup = BeautifulSoup(response.content.decode('utf8'), "html.parser")

        for inputtag in soup.find_all('input'):
            if (inputtag.get('name') == 'SAMLResponse'):
                # print(inputtag.get('value'))
                assertion = inputtag.get('value')

    # Overwrite and delete the credential variables, just for safety
    username = '##############################################'
    password = '##############################################'
    del username
    del password

    if not assertion:
        if 'incorrect' in response.text:
            OUTPUT.error('Supplied credentials are invalid.')
        else:
            OUTPUT.error(
                'SAMLResponse object could not be extracted from response.')

        sys.exit(1)

    # Parse the returned assertion and extract the authorized roles
    awsroles = []
    root = ET.fromstring(base64.b64decode(assertion))

    for saml2attribute in root.iter('{urn:oasis:names:tc:SAML:2.0:assertion}Attribute'):
        if (saml2attribute.get('Name') == 'https://aws.amazon.com/SAML/Attributes/Role'):
            for saml2attributevalue in saml2attribute.iter('{urn:oasis:names:tc:SAML:2.0:assertion}AttributeValue'):
                awsroles.append(saml2attributevalue.text)

    # Note the format of the attribute value should be role_arn,principal_arn
    # but lots of blogs list it as principal_arn,role_arn so let's reverse
    # them if needed
    for awsrole in awsroles:
        chunks = awsrole.split(',')
        if'saml-provider' in chunks[0]:
            newawsrole = chunks[1] + ',' + chunks[0]
            index = awsroles.index(awsrole)
            awsroles.insert(index, newawsrole)
            awsroles.remove(awsrole)

    # narrow down the roles if 'role' regex was supplied
    if role:
        match_string = '.*(' + str(role) + ')'

        awsroles = [role for role in awsroles if re.match(match_string, role.split(
            ',')[0]) and re.match(match_string, role.split(',')[0]).groups()]

    # If I have more than one role, ask the user which one they want,
    # otherwise just proceed
    OUTPUT.line()
    if len(awsroles) > 1 and ARG_ROLE == 'none':
        i = 0
        OUTPUT.info("Please choose the role you would like to assume:")

        current_account = ''
        for awsrole in awsroles:
            if arn_regex:
                matcher = re.match(
                    'arn:aws:iam::(\d{12}):role\/ADFS-([a-zA-Z]*)-(\S*)', awsrole.split(',')[0])

                account, account_name, role = matcher.group(
                    1), matcher.group(2), matcher.group(3)

                if account != current_account:
                    current_account = account
                    OUTPUT.info('Account: {0}'.format(str(account_name)))
                    # print ('\nAccount: ' + str(account) +
                    #       ' ( ' + str(account_name) + ' )')
                OUTPUT.info('\t[{0}]: {1}'.format(i, str(role)))
            else:
                OUTPUT.info('\t[{0}]: {1}'.format(i, awsrole.split(',')[0]))
            i += 1

        selectedroleindex = OUTPUT.prompt(
            text='Selection:', inputtype=int, default=0)

        # Basic sanity check of input
        if int(selectedroleindex) > (len(awsroles) - 1):
            OUTPUT.warn('You selected an invalid role index, please try again')
            sys.exit(1)

        role_arn = awsroles[int(selectedroleindex)].split(',')[0]
        principal_arn = awsroles[int(selectedroleindex)].split(',')[1]
        OUTPUT.info('role arn: {0}'.format(role_arn))
        OUTPUT.info('principal arn: {0}'.format(principal_arn))

    elif ARG_ROLE <> 'none':
        role_arn = ARG_ROLE.split(',')[0]
        principal_arn = ARG_ROLE.split(',')[1]
    elif len(awsroles) == 1:
        role_arn = awsroles[0].split(',')[0]
        principal_arn = awsroles[0].split(',')[1]

    # Use the assertion to get an AWS STS token using Assume Role with SAML
    token = boto3.client("sts").assume_role_with_saml(
        RoleArn=role_arn,
        PrincipalArn=principal_arn,
        SAMLAssertion=assertion)

    OUTPUT.info("You have assumed the role: " + role_arn)

    # Write the AWS STS token into the AWS credential file
    homepath = expanduser("~")
    filename = str(profilepath).replace('~', homepath)

    # Read in the existing config file
    config = configparser.RawConfigParser()
    config.read(filename)

    # Put the credentials into a specific profile instead of clobbering
    # the default credentials
    if not config.has_section(profile):
        config.add_section(profile)

    for k, v in aws_vars.items():
        config.set(profile, k, v)

    config.set(profile, 'aws_access_key_id',
               token["Credentials"]["AccessKeyId"])
    config.set(profile, 'aws_secret_access_key',
               token["Credentials"]["SecretAccessKey"])
    config.set(profile, 'aws_session_token',
               token["Credentials"]["SessionToken"])

    try:
        # Write the updated config file
        OUTPUT.info('Updating AWS Profile: {0}'.format(filename))
        with open(filename, 'w+') as configfile:
            config.write(configfile)

        # Give the user some basic info as to what has just happened
        OUTPUT.header('AWS Profile Update')
        OUTPUT.configelement(name='path', value=filename)
        OUTPUT.configelement(name='profile', value=profile)
    except:
        OUTPUT.warn('Unable to update profile: {0}'.format(filename))

    OUTPUT.line()
    OUTPUT.info(
        'You may safely rerun this script to refresh your access key pair for this profile.')
    OUTPUT.info(
        'To use this credential call the AWS CLI with the --profile option (e.g. aws --profile {0} s3api list-buckets).'.format(profile))
    if verifytoken:
        # verify the token by listing all s3 buckets
        client = boto3.client('s3',
                              aws_access_key_id=token["Credentials"]["AccessKeyId"],
                              aws_secret_access_key=token["Credentials"]["SecretAccessKey"],
                              aws_session_token=token["Credentials"]["SessionToken"])
        buckets = client.list_buckets()
        OUTPUT.info("With the newly generated token, found {0} s3 buckets.".format(
            len(buckets["Buckets"])))


if __name__ == '__main__':
    # Import any passed in environmental variables
    ARG_FQDN = os.environ.get(
        "AWS_STS_SERVER", os.environ.get("ARG_FQDN", 'sts.contoso.com'))
    ARG_USERNAME = os.environ.get("ARG_USERNAME", None)
    ARG_USERPASS = os.environ.get("ARG_USERPASS", None)
    ARG_REGION = os.environ.get(
        "AWS_DEFAULT_REGION", os.environ.get("ARG_REGION", 'us-east-1'))
    ARG_ROLE = os.environ.get("ARG_ROLE", 'none')
    ARG_PROFILE = os.environ.get(
        "AWS_PROFILE", os.environ.get("ARG_PROFILE", 'saml'))
    ARG_PROFILEPATH = os.environ.get("AWS_CONFIG_FILE", os.environ.get("ARG_PROFILEPATH", os.path.join(os.path.expanduser("~"), '.aws', 'credentials')))
    ARG_SSLVERIFY = os.environ.get("ARG_SSLVERIFY", True)

    # Construct useable regex options
    arn_regex_options = {
        'adfs': r'arn:aws:iam::(\d{12}):role\/ADFS-([a-zA-Z]*)-(\S*)',
        'none': None,
    }

    # init the arg parser
    parser = argparse.ArgumentParser(
        description='Use SSO to pull temporary credentials from AWS.')

    parser.add_argument(
        '-username', '--username',
        type=str,
        dest='username',
        default=ARG_USERNAME,
        help="The username to login with.")

    parser.add_argument(
        '-profile', '--profile',
        type=str,
        default=ARG_PROFILE,
        help="The profile to save the credentials into.  By default the profile name will be saml.")

    parser.add_argument(
        '-region', '--region',
        type=str,
        default='us-east-1',
        help="The region that the profile will be set to.  Default is us-east-1")

    parser.add_argument(
        '-regex', '--regex',
        type=str,
        default='adfs',
        help="Regex matcher string to extract 1.) account number 2.) account name 3.) role name from the returned role arns. By default no regex is used and the whole arn is printed. The valid options are: " + str(list(arn_regex_options.keys())) + ".")

    parser.add_argument(
        '-role', '--role',
        help="The Role name that you want to sign in to.  This string will be matched with Regex. If multiple arn's match the regex, options will be presented. If only 1 arn matches it will be automatically selected.")

    parser.add_argument(
        '-debug', '--debug',
        action='store_true',
        help="Enable debug print statements.")

    parser.add_argument('-verifytoken', '--verifytoken', action='store_true',
                        help='Verifies token by querying for s3 buckets.')

    parser.add_argument(
        '-fqdn', '--fqdn',
        type=str,
        default=ARG_FQDN,
        help="Fully Qualified Domain Name (fqdn) of the login service that you are currently using for SSO access to the AWS Management Console.")

    parser.add_argument(
        '-profilepath', '--profilepath',
        default=ARG_PROFILEPATH,
        help="Path to a credentials file for aws profile modification")

    args = parser.parse_args()

    OUTPUT = Output(debugenabled=args.debug)

    get_credentials_with_sso(
        fqdn=args.fqdn,
        username=args.username,
        region=args.region,
        profile=args.profile,
        profilepath=args.profilepath,
        debug=args.debug,
        arn_regex=arn_regex_options[args.regex],
        role=args.role,
        verifytoken=args.verifytoken)
