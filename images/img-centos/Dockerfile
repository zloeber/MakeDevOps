FROM centos:current
ENV container docker

#### Force non-interactive bash invocation to read standard env
####  Ref:  http://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
ENV BASH_ENV /etc/bashrc

# Copy init scripts
RUN mkdir /startup
COPY init /startup
RUN chmod ug+x /startup/*

CMD ["./startup/S01startup.sh"]

LABEL description="CentOS Base Image" \
	os="CentOS" \
	os_ver="7.5.1804"