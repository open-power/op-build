FROM fedora:37

ARG USER
ARG UID
ARG GID

ENV USER=${USER:-no-user-set}
ENV UID=${UID:-no-uid-set}
ENV GID=${GID:-no-gid-set}
ENV PYTHONUNBUFFERED=1
ENV HB_CONSOLE_TRACE_EN=False

WORKDIR /home/$USER

# Install packages
COPY dnf_packages.sh .
RUN ./dnf_packages.sh && dnf clean all

# Install jfrog-cli for artifactory transactions
RUN curl -fL https://install-cli.jfrog.io | sh
RUN chmod a+x /usr/local/bin/jf

# add $USER
RUN groupadd -g ${GID} -o ${USER}
RUN useradd -l --create-home --shell /bin/bash -u ${UID} -g ${GID} ${USER}
RUN chown -R $USER /home/$USER

# once we prompt USER, we are that user and no longer has sudo
USER ${USER}
RUN mkdir /home/${USER}/.ssh

ENTRYPOINT ["/bin/bash"]
