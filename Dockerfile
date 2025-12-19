FROM ubuntu
MAINTAINER support@skillup.host


# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    git \
    python3-dev \
    tmux \
    vim \
    bash-completion \
    openssh-server \
    tree \
    sudo
    
# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Add bash completion and set bash as default shell
RUN --mount=type=secret,id=my_secret_var \
    my_secret=$(cat /run/secrets/my_secret_var) \
    && mkdir -p /usr/lib/docker/cli-plugins \
    && curl -LsS https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/bin/docker-compose \
    && chmod +x /usr/bin/docker-compose \
    && curl -sS https://raw.githubusercontent.com/docker/cli/refs/heads/master/contrib/completion/bash/docker -o /etc/bash_completion.d/docker \
    && echo "root:$my_secret" | chpasswd \
    && ln -s /usr/bin/python3 /usr/bin/python
COPY sshd_config /etc/ssh/sshd_config

#for rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /root

COPY rootCA.crt /usr/local/share/ca-certificates/

COPY ["daemon.json", "/etc/docker/"]

# Update the certificate store
RUN update-ca-certificates

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
CMD ["wrapdocker"]

