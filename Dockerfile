FROM jenkins/jenkins:lts
USER root
RUN apt-get update -y

RUN apt-get install apt-transport-https curl gnupg-agent ca-certificates software-properties-common -y
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
RUN apt-get update -y
RUN apt-get install docker-ce docker-ce-cli containerd.io -y

RUN usermod -aG docker jenkins

