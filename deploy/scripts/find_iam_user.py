#!/usr/bin/env python
# Find the IAM username belonging to the TARGET_ACCESS_KEY
# Useful for finding IAM user corresponding to a compromised AWS credential
# Usage:
#     find_iam_user AWS_ACCESS_KEY_ID
# Requirements:
#
# Environmental variables:
#     AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
#     or
#     AWS_PROFILE
# python:
#   boto, click

import boto.iam
import sys
import click

if len(sys.argv) == 1:
    click.echo(message='Usage: \n find_iam_user AWS_ACCESS_KEY_ID')
    exit(1)

TARGET_ACCESS_KEY = sys.argv[1]

iam = boto.connect_iam()

marker = None
is_truncated = 'true'
users = []

while is_truncated == 'true':
    all_users = iam.get_all_users('/', marker=marker)
    users += all_users['list_users_response']['list_users_result']['users']
    is_truncated = all_users['list_users_response']['list_users_result']['is_truncated']
    if is_truncated == 'true':
        marker = all_users['list_users_response']['list_users_result']['marker']

click.echo(message='Found {0} users, searching...'.format(len(users)))

def find_key():
    for user in users:
        for key_result in iam.get_all_access_keys(user['user_name'])['list_access_keys_response']['list_access_keys_result']['access_key_metadata']:
            aws_access_key = key_result['access_key_id']
            if aws_access_key == TARGET_ACCESS_KEY:
                click.echo(message='Target key belongs to user: {0}'.format(user['user_name']))
                return True
    return False

if not find_key():
    click.echo(message='Did not find access key ({0}) in {1} IAM users'.format(TARGET_ACCESS_KEY, len(users)))
