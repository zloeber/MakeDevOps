## Usage
This is a little wrapper Makefile to build, publish, run, and shell into arbitrary Dockerfiles from other directories.

To use, define your `APP_PATH=/some/path` as a variable when calling make or include an alternate dpl (deploy) file `dpl=centos.env`

Publishing and repo creation are AWS specific currently.

```bash
# Build the container
make build

# Build and publish the container
make release

# Publish a container to AWS-ECR.
# This includes the login to the repo
make publish

# Run the container
make run

# Build and run the container
make up

# Enter a running container shell
make shell

# Stop the running container
make stop

# Build the container with differnt config and deploy file
make cnf=another_config.env dpl=another_deploy.env build
```