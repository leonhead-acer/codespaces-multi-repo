ARG VARIANT=4.3

FROM ghcr.io/rocker-org/devcontainer/r-ver:${VARIANT}

COPY ./postAttachCommand.sh /tmp

# Install Python packages
COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    && rm -rf /tmp/pip-tmp
