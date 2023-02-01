# jenkins-lab2
## Questions.

### Remaining old Questions.
* 4- configure jenkins image to run docker commands on your host docker daemon
* 5- create CI/CD for this repo https://github.com/mahmoud254/jenkins_nodejs_example.git

### New Questions part.
* 1- create docker file to build image for jenkins slave
* 2- create container from this image and configure ssh 
* 3 from jenkins master create new node with the slave container
* 4- integrate slack with jenkins
* 5- send slack message when stage in your pipeline is successful
* 6- install audit logs plugin and test it
* 7- fork the following repo https://github.com/mahmoud254/Booster_CI_CD_Project and add dockerfile to run this django app and  use github actions to build the docker image and push it to your dockerhub


## Answers
### 4- configure jenkins image to run docker commands on your host docker daemon
#### Docker file.
    ```
    FROM jenkins/jenkins:lts
    USER root
    RUN apt-get update -y

    RUN apt-get install apt-transport-https curl gnupg-agent ca-certificates software-properties-common -y
    RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
    RUN apt-get update -y
    RUN apt-get install docker-ce docker-ce-cli containerd.io -y

    RUN usermod -aG docker jenkins

    ```
#### Build and push the image.

    ```
    docker build -t amrtarek6/jenkins_main:version .
    docker push amrtarek6/jenkins_main:version
    ```

### 5- create CI/CD for this repo https://github.com/mahmoud254/jenkins_nodejs_example.git
![image](https://user-images.githubusercontent.com/47079437/215291089-acc413ff-5b53-4b94-9a68-ec20e39d24ca.png)
#### pipeline Code.

    ```
        pipeline {
            agent any
            stages {
                stage('CI') {
                    steps {
                        git 'https://github.com/mahmoud254/jenkins_nodejs_example'
                        withCredentials([usernamePassword(credentialsId: 'Dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh "docker build . -f dockerfile -t ${USER}/node-app:v1"
                            sh "docker login -u ${USER} -p ${PASS}"
                            sh "docker push ${USER}/node-app:v1"
                        }
                    }
                }

                stage('CD') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'Dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh "docker login -u ${USER} -p ${PASS}"
                            sh "docker run -d -p 3030:3000 ${USER}/node-app:v1"
                        }
                    }
                }

            }
            post{ 
                success { 
                    slackSend(message: "success tes")
                }
                failure { 
                    slackSend(message: "failure Run")
                }
            }

        }
    ```
    
### 1- create docker file to build image for jenkins slave
#### Dockefile_slave Code.
    ```
    FROM ubuntu

    USER root
    RUN apt-get update -y
    RUN apt-get install -y openssh-server
    # RUN service ssh start

    RUN apt-get install openjdk-11-jdk -y

    RUN apt-get install git -y

    RUN apt-get install apt-transport-https curl gnupg-agent ca-certificates software-properties-common -y
    RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
    RUN apt-get install docker-ce docker-ce-cli containerd.io -y

    RUN mkdir /root/.ssh
    COPY id_rsa.pub /root/.ssh/authorized_keys
    ENTRYPOINT service ssh start && bash

    ```
### 2- create container from this image and configure ssh
    ssh already cofigured with docker file only need to let id_rsa.pub in the same Dir and configure id_rsa with jenkins Credintials
    ```
    docker build -t amrtarek6/jenkins_slave:version -f Dockefile_slave .
    docker run -it -d --name slave -v /var/run/docker.sock:/var/run/docker.sock amrtarek6/jenkins_slave:version
    ```
    ![image](https://user-images.githubusercontent.com/47079437/216110010-6d0aa214-8d9d-44f8-9164-c485e5b895e8.png)
    ![image](https://user-images.githubusercontent.com/47079437/216119993-bc7cc7f1-03c2-4583-80ae-fe99c83f18eb.png)


### 3 from jenkins master create new node with the slave container
    ![image](https://user-images.githubusercontent.com/47079437/216120254-0d0472a7-8566-49d4-81d7-2c9e605fea78.png)

### 4- integrate slack with jenkins
    ![image](https://user-images.githubusercontent.com/47079437/215879453-11223b66-3c4b-4e85-9b9a-3a79f1db2b63.png)
    ![image](https://user-images.githubusercontent.com/47079437/215880566-43c1561a-67d9-4559-add5-17589bbb372f.png)
    ![image](https://user-images.githubusercontent.com/47079437/215881107-eb7d1c6d-5a3e-4508-b1cf-db9c8f93277e.png)
    ![image](https://user-images.githubusercontent.com/47079437/215881320-729e8c63-c0b4-4ca0-91fe-14de226f8aa4.png)
### 5- send slack message when stage in your pipeline is successful
    ![image](https://user-images.githubusercontent.com/47079437/215890315-46bfd6cf-421d-4d5b-bc83-d7611aa92ad0.png)

### 6- install audit logs plugin and test it
    ![image](https://user-images.githubusercontent.com/47079437/215892107-678d3149-ee25-4d25-8ef1-0f02b2506364.png)
    ![image](https://user-images.githubusercontent.com/47079437/215893938-4a8241ff-33ae-44c3-a496-3847f4398459.png)
### 7- fork the following repo https://github.com/mahmoud254/Booster_CI_CD_Project and add dockerfile to run this django app and  use github actions to build the docker image and push it to your dockerhub

    https://github.com/AmrTarek17/Booster_CI_CD_Project
