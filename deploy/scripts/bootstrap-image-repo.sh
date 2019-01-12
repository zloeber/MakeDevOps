#!/bin/bash
# bootstrap-image-repo.sh

make build-images sso-login repo-login build-repos publish-latest
