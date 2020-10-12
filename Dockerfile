FROM ubuntu:18.04

# Avoid error messages from apt during image build
ARG DEBIAN_FRONTEND=noninteractive


RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y wget curl gnupg apt-utils build-essential openssh-server git locales

RUN \
  wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && \
  dpkg -i erlang-solutions_2.0_all.deb && \
  apt-get update && \
  apt-get install -y esl-erlang elixir

RUN \
  apt-get update && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get install -y nodejs

RUN \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update && \
  apt-get install -y yarn



# Elixir requires UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV HEX_HTTP_TIMEOUT 120
RUN update-locale LANG=$LANG

RUN mkdir /var/run/sshd

# Create Builder user
RUN useradd --system --shell=/bin/bash --create-home builder

#config builder user for public key authentication
RUN mkdir /home/builder/.ssh/ && chmod 700 /home/builder/.ssh/ && \
  mkdir -p /home/builder/config
COPY ./config/ssh_key.pub /home/builder/.ssh/authorized_keys
RUN chown -R builder /home/builder/ && \
  chgrp -R builder /home/builder/ && \
  chmod 700 /home/builder/.ssh/ && \
  chmod 644 /home/builder/.ssh/authorized_keys


RUN mix local.hex --force --if-missing
RUN mix local.rebar --force

#Configure public keys for sshd
RUN  echo "AuthorizedKeysFile  %h/.ssh/authorized_keys" >> /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
