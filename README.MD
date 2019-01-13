## MakeDevOps - DevOps Exploration Makefile

MakeDevOps is a makefile with supporting scripts to install and work with recent versions of several devops tools like kubectl, crictl, docker-compose, kind, jx, pulumi, draft, az, and more... You can use it as a contained work environment for further devops exploration or pick it apart for script materials for your own tooling automation.

## What is a Makefile?

A Makefile is a 50+ year old [https://en.wikipedia.org/wiki/Make_(software)](unix-based build automation tool) that is often used by developers or sysadmins to **make** compiliation or other tedious tasks more tollerable.

## But Why Gods? Why?

I tend to give technical favoritism to utilities that have self-contained binary releases. These apps often have several installation avenues with conflicting destinations or scraping requirements for attaining recent releases. As I was testing or using different apps, I naturally scripted out their installation.

Dropping these scripts into a Makefile was just convenient at the time. Now this has become a mini out of control framework of sorts with a haphazzard collection of scripts for various shell tasks. But it is still usable.

I tend to install everything to ${HOME}/.local/bin. I've also setup several .env files and other oddball templates you may not like. I welcome improvements, there certainly is room for them.

Oh, I've included quite a large amount of additional scripts, make tasks, and other goodies in this repo that didn't fit anywhere else.

## How do I Use This?

I wrapped the whole thing in a fairly standard CentOS 7 vagrant box that drops you directly in a prompt ready to use `make` for further configuration. From zero to instant command-line devops wizard can be achieved with something like the following:

```bash
export ENABLED_TASKS=(deps devops direnv golang kubernetes kind istio draft)
make config
make add-bin-path install-golang install-kubectl install-kind install-isio-binary
make install-golang install-kubectl install-kind start-kind-session install-helm  install-istio-

```

I've used it to bootstrap several tools I like to alway be handy. Towards that end, there is a default vagrantfile definition that can be used to pull up a makedevops working area that should run almost all tasks in this project if desired.

Of course it can be used right on your workstation as well. Here is the general script to get things working.

```bash
rm -rf ~/.local/makedevops
git clone https://github.com/zloeber/makedevops.git ~/.local/makedevops
ln -s ~/.local/makedevops/Makefile ~/
export MAKEDEVOPS_PATH='~/.local/makedevops'
```

That lets you run make from your home directory if desired (and add additional tasksets for further functionality).

## Why a Makefile?

I've found myself solving some unique problems within some specific constraints that had me doing some heavy Makefile work and realized how useful it was for simple bootstrap operations on Linux, Window Subsystem for Linux, or OSX. So I started adding one off tasks for the many different tools I've been tinkering with into this one project.

## What Tools Are There?

I've added all kinds. But the default set of tasks are pretty small. They are meant for basic operations and to add more tasksets. This can keep the help output more meaningful.

The different tools are separated out for multi-platform installation and to be able to pick and choose from for your own customized Makefile. Almost all tasks are simple scripts that you can use in your own custom tooling so this is kind of a library too. 

### Environment

> **NOTE:** make Tasks are meant to be called from a non-elevated account. Any permissions requirements should be inferred by the AWS/Azure profiles being used. SSO token negotiations can be done via environment variables, the local secrets.env/deploy.env files, SSM, or a combination of these methods.

The included Vagrantfile at the project root will bring up a modest virtual Centos 7 Linux host running with the following configured:

- Docker CE (Bleeding Edge)
- Docker remote api published to localhost:2376 for host based management (plus several other convenience ports)
- Home directory synced up with this project to immediately run `make` for further configuration.
- ./projects 2-way synced with /vagrant/
- Other possible build requirements

Recommended vagrant plugins for this Vagrantfile are:

```bash
vagrant plugin install vagrant-vbguest
```

### Vagrant
Clone this entire repo and from the cloned directory run:

```bash
vagrant up
```

If there are issues with guest share mounting or provisioning try to reboot the guest, force install Virtualbox guest additions, then force a provision operation again. (NOTE: Sometimes simply running `vagrant provision` after running `vagrant up` is all that is required too!)

```bash
vagrant halt
vagrant up
vagrant vbguest
vagrant provision
```

### Usage
All build tasks can be done with the included Makefile. The makefile can be used locally for bootstrapping purposes, as part of the included Vagrant virtual machine, or used for its component parts to customize your own build process (all task definitions are essentially bash scripts with the .env files being sourced in).

You can groom which makefile tasks are loaded to suit your own needs. By default all additional makefiles in the `deploy/tasks/` folder are loaded when invoking make but can be disabled by editing `deploy/Makefile`

# TASKS

Many many build tasks available. Here is how to get quickly started:

```bash
# Configure a generic stack of tasks then show them
make config
make

# Enable the azure task_azure.mk taskset, then show the additional tasks
make TS=azure enable-taskset
make

# Clear up assigned tasksets
make clear-tasksets
```

**NOTE** For further taskset examples please look at the readme.md within the deploy/tasks folder. 