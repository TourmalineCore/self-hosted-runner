FROM ubuntu:24.04

ARG RUNNER_VERSION="2.328.0"
ARG NVM_DIR="/usr/local/share/nvm"
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

# Install base dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
                apt-transport-https \
                apt-utils \
                build-essential \
                ca-certificates \
                cmake \
                curl \
                git \
                git-lfs \
                gnupg \
                iptables \
                jq \
                libffi-dev \
                libssl-dev \
                libyaml-dev \
                locales \
                lsb-release \
                make \
                nano \
                openssh-client \
                pkg-config \
                python3 \
                python3-dev \
                python3-pip \
                python3-venv \
                rsync \
                software-properties-common \
                ssh \
                sudo \
                tar \
                tzdata \
                unzip \
                vim \
                wget \
                xz-utils \
                zip \
                zlib1g-dev \
                zstd

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt install -y --no-install-recommends \
                   containerd.io \
                   docker-buildx-plugin \
                   docker-ce-cli \
                   docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*


# Install GitHub CLI
RUN type -p curl >/dev/null || apt-get install -y curl && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
         https://cli.github.com/packages stable main" \
         > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

# Install Node.js via NVM (LTS + 20) + yarn + pnpm
ENV NVM_DIR=${NVM_DIR}
RUN mkdir -p ${NVM_DIR} /usr/local/lib/node_modules && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . ${NVM_DIR}/nvm.sh && \
    nvm install --lts && nvm alias default 'lts/*' && \
    nvm install 20 && \
    npm install -g yarn pnpm && \
    ln -s ${NVM_DIR}/versions/node/*/bin/node /usr/local/bin/node || true && \
    ln -s ${NVM_DIR}/versions/node/*/bin/npm /usr/local/bin/npm || true && \
    ln -s ${NVM_DIR}/versions/node/*/bin/yarn /usr/local/bin/yarn || true && \
    ln -s ${NVM_DIR}/versions/node/*/bin/pnpm /usr/local/bin/pnpm || true
ENV PATH=${NVM_DIR}/versions/node/*/bin:${PATH}

# Install Python
ENV PYENV_ROOT=/home/runner/.pyenv
RUN curl -fsSL https://pyenv.run | bash && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /etc/profile && \
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /etc/profile && \
    echo 'eval "$(pyenv init -)"' >> /etc/profile
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN bash -lc 'pyenv install 3.10.14 && pyenv install 3.11.9 && pyenv install 3.12.5 && pyenv global 3.12.5' && \
    bash -lc 'pip install --upgrade pip pipx virtualenv'

# install helm https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries
# curl -o - write to file
# chmod +x - make file executable
RUN curl -L https://get.helm.sh/helm-v3.14.4-linux-$TARGETARCH.tar.gz | tar xz &&\
    mv linux-$TARGETARCH/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

# install helm-diff plugin
RUN helm plugin install https://github.com/databus23/helm-diff --version=3.9.6

# install helm-git plugin
RUN helm plugin install https://github.com/aslafy-z/helm-git --version 1.3.0

# install helmfile https://github.com/schlich/devcontainer-features/blob/main/src/helmfile/install.sh
# curl -L - follow redirects
# chmod +x - make file executable
RUN curl -L https://github.com/helmfile/helmfile/releases/download/v0.164.0/helmfile_0.164.0_linux_$TARGETARCH.tar.gz | tar xz && \
    chmod +x helmfile && \
    mv helmfile /usr/local/bin

# Add a user named runner and adding it to sudoers and Docker group
RUN useradd -m runner && \
    groupadd docker && \
    usermod -aG sudo root && \
    usermod -aG sudo runner && \
    usermod -aG docker runner && \
    echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers && \
    echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

# Set up the actions runner
RUN cd /home/runner && \
    mkdir actions-runner && \
    cd actions-runner && \
    curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Change ownership to runner user and install dependencies
RUN chown -R runner /home/runner && \
    /home/runner/actions-runner/bin/installdependencies.sh
RUN mkdir /opt/hostedtoolcache && \
    chown -R runner /opt/hostedtoolcache
RUN echo 'export NVM_DIR="'${NVM_DIR}'"' >> /etc/profile.d/nvm.sh && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /etc/profile.d/nvm.sh && \
    echo 'export PATH="'${NVM_DIR}'/versions/node/$(ls -1 '${NVM_DIR}'/versions/node | tail -n1)/bin:$PATH"' >> /etc/profile.d/nvm.sh


# Copy the start script and make it executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Switch to runner user
USER runner
WORKDIR /home/runner

# Define the entrypoint
ENTRYPOINT ["/start.sh"]
