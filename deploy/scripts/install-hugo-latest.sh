#!/bin/bash
# Change to temporary directory
pushd /tmp/

platform=`sh -c 'uname -s 2>/dev/null || echo not'`
binpath=${1:-"${HOME}/.local/bin"}
echo "Detected platform: $platform"
echo "Destination binpath: $binpath"
# Get JSON response of latest releases, find the one we want, 
# pretty-up the URL, then download it
curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
| grep "browser_download_url.*hugo_[^extended].*_${platform}-64bit\.tar\.gz" \
| cut -d ":" -f 2,3 \
| tr -d \" \
| wget -qi -

# Unzip hugo binary
tarball="$(find . -name "*${platform}-64bit.tar.gz" 2>/dev/null )"
tar -xzf $tarball

# Give hugo binary executable permissions
chmod +x hugo

# Move hugo binary to a location that is already on your PATH
mv hugo ${binpath}

# Go back to previous directory
popd

# Display hugo binary location and version
location="$(which hugo)"