FROM python:3.10-slim as compiler
ENV PYTHONUNBUFFERED 1
ENV PIPENV_VENV_IN_PROJECT 1
WORKDIR /ansible/

RUN apt update && \
    apt install -y pipenv

COPY Pipfile Pipfile.lock .
RUN pipenv install


FROM python:3.10-slim as runner
WORKDIR /app/
COPY --from=compiler /ansible/.venv /ansible/.venv

RUN apt update && \
    apt upgrade -y && \
    apt install -y curl unzip

RUN cd /tmp && \
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws* && \
    rm -f session-manager-plugin*

RUN rm -rf /var/lib/apt/lists/*

# Enable venv
ENV PATH="/ansible/.venv/bin:$PATH"
CMD [ "pip", "freeze" ]
