# SSH service image
#
# Based on the example:
# https://docs.docker.com/engine/examples/running_ssh_service/#run-a-test_sshd-container
#
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
      openssh-server \
      rsync \
      curl

RUN mkdir /var/run/sshd

# Password login (disabled)
#RUN echo 'root:elkarbackup' | chpasswd
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN echo "export ELKARBACKUP_URL=http://elkarbackup" >> /etc/profile
RUN echo "export ELKARBACKUP_USER=root" >> /etc/profile


EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
