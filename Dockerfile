    FROM jenkins/jenkins:lts
    USER root
    RUN apt-get update -qq
    RUN apt-get install -qq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    RUN mkdir -p /etc/apt/keyrings
    RUN curl -qq -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    RUN chmod a+r /etc/apt/keyrings/docker.gpg
    RUN apt-get update
    RUN apt-get install docker-ce -y
    RUN usermod -aG docker jenkins
