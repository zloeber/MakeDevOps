#!/bin/bash
# Simple script to install and run a bunch of terraform exports

gem install terraforming

make sso-login
terraforming ec2 --profile saml > ec2.tf
terraforming sn --profile saml > subnets.tf
terraforming vpc --profile saml > vpc.tf
terraforming s3 --profile saml > s3.tf
terraforming iamup --profile saml > iamup.tf
terraforming iamp --profile saml > iamp.tf