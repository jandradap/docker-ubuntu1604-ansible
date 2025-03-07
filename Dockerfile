FROM ubuntu:16.04
LABEL maintainer="Jeff Geerling"

ENV pip_packages "ansible pyopenssl"

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python-software-properties \
       software-properties-common \
       python-setuptools \
       wget rsyslog systemd systemd-cron sudo iproute2 \
       apt-utils \
       ntp tzdata \
       walinuxagent dbus ufw bash-completion iotop sysstat python-apt aptitude \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && wget https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Install Ansible via Pip.
RUN pip install $pip_packages

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
