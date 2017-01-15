FROM alpine
MAINTAINER Pema Geyleg <pema@casecommons.org>
ARG project_name
LABEL application=${project_name}

# Install system dependencies
RUN apk add --no-cache --update curl bash jq py2-pip gcc python-dev openssl-dev libffi-dev musl-dev

# Install python dependencies
RUN pip install awscli ansible boto boto3

COPY . /deploy
WORKDIR /deploy