FROM jenkins/inbound-agent:alpine as jnlp
FROM moby/buildkit as buildkit

FROM maven:3.6.3-jdk-8-slim

RUN apt-get update && \
    apt-get install -y \
        git \
        libfontconfig1 \
        libfreetype6 \
        unzip

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install


COPY --from=buildkit /usr/bin/build* /usr/local/bin/
COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
