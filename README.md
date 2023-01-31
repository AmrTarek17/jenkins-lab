# jenkins-lab2
## Questions.

### Remaining old Questions.
* 4- configure jenkins image to run docker commands on your host docker daemon
* 5- create CI/CD for this repo https://github.com/mahmoud254/jenkins_nodejs_example.git

### New Questions part.
* 1- create docker file to build image for jenkins slave
* 2- create container from this image and configure ssh 
* 3 from jenkins maste create new node with the slave container
* 4- integrate slack with jenkins
![image](https://user-images.githubusercontent.com/47079437/215879453-11223b66-3c4b-4e85-9b9a-3a79f1db2b63.png)
![image](https://user-images.githubusercontent.com/47079437/215880566-43c1561a-67d9-4559-add5-17589bbb372f.png)
![image](https://user-images.githubusercontent.com/47079437/215881107-eb7d1c6d-5a3e-4508-b1cf-db9c8f93277e.png)
![image](https://user-images.githubusercontent.com/47079437/215881320-729e8c63-c0b4-4ca0-91fe-14de226f8aa4.png)
* 5- send slack message when stage in your pipeline is successful
![image](https://user-images.githubusercontent.com/47079437/215890315-46bfd6cf-421d-4d5b-bc83-d7611aa92ad0.png)
* 6- install audit logs plugin and test it
![image](https://user-images.githubusercontent.com/47079437/215892107-678d3149-ee25-4d25-8ef1-0f02b2506364.png)
![image](https://user-images.githubusercontent.com/47079437/215893938-4a8241ff-33ae-44c3-a496-3847f4398459.png)
* 7- fork the following repo https://github.com/mahmoud254/Booster_CI_CD_Project and add dockerfile to run this django app and  use github actions to build the docker image and push it to your dockerhub


## Answers
### 4- configure jenkins image to run docker commands on your host docker daemon
#### Docker file.
    ```
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
    RUN apt-get install docker-ce -y
    RUN usermod -aG docker jenkins

    ```
#### Build and push the image.

    ```
    docker build -t amrtarek6/my-nginx:tagname .
    docker push amrtarek6/my-nginx:tagname
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
                    withCredentials([usernamePassword(credentialsId: 'Amr-Dockerhub', usernameVariable: 'USER_NAME', passwordVariable: 'PASS')]) {
                        sh "docker build . -f dockerfile -t ${USER_NAME}/node-app:v1"
                        sh "docker login -u ${USER_NAME} -p ${PASS}"
                        sh "docker push ${USER_NAME}/node-app:v1"
                    }
                }
            }

            stage('CD') {
                steps {
                    withCredentials([usernamePassword(credentialsId: 'Amr-Dockerhub', usernameVariable: 'USER_NAME', passwordVariable: 'PASS')]) {
                        sh "docker login -u ${USER_NAME} -p ${PASS}"
                        sh "docker run -d -p 3030:3000 ${USER_NAME}/node-app:v1"
                    }
                }
            }
        }
    }
    ```
### Setup Infra
* First setup your GCP account, create new project and change the value of "project_name" variable in terraform.tfvars with your PROJECT-ID.

* Second build the infrastructure by run

    ```bash
    cd GCP-Terraform/
    ```

    ``` 
    terraform init
    terraform apply
    ```
    that will build:
    
    * VPC named "vpc-network"
    * 2 Subnets "management-sub", "restricted-sub"
    * 3 Service Accounts
        * "gke-sa" used by Kubernetes cluster
        * "gke-management-sa" used by Management VM 
        * "docker-gcr-sa" we will use it to push the image to GCR

    * NAT in "management-sub"
    * Private Virtual Machine in "management-sub" subnet to manage the cluster.
    * Private Kubernetes cluster in "restricted-sub" with 3 worker nodes.

        ```bash
        # NOTE
        Only VMs in "management-sub" subnet can access the Kubernetes cluster.
        ```
    you can change some variables values in "terraform.tfvars"
    
### Build & Push Docker Image to GCR
* Build the Docker Image by run

    ```bash
    docker build -t eu.gcr.io/<PROJECT-ID>/my-app:1.0 src/
    ```
* pull Redis image and tag it
    ```bash
    docker pull redis:5.0
    docker tag redis:5.0 eu.gcr.io/<PROJECT-ID>/redis:5.0
    ```
* Setup credentials for docker to Push to GCR using "docker-gcr-sa" Service Account

    ```
    gcloud auth activate-service-account docker-gcr-sa --key-file=KEY-FILE
    gcloud auth configure-docker
    ```
* Push the Images to GCR

    ```
    docker push eu.gcr.io/<PROJECT-ID>/my-app:1.0
    docker push eu.gcr.io/<PROJECT-ID>/redis:5.0
    ```

### Deploy
* After the infrastructure got built, now you can login to the "management-vm" VM using SSH then:
    
    * setup cluster credentials
        ```
        gcloud container clusters get-credentials app-cluster --zone europe-west1-c --project <PROJECT-ID>
        ```
    * Change image in "k8s-yaml-files/deployments/app-deployment.yaml" with your image

    * Change image in "k8s-yaml-files/deployments/redis-pod.yaml" with your image

    * Upload the "k8s-yaml-files" dir to the VM and run
    
        ```
        kubectl apply -f k8s-yaml-files/
        ```

        that will deploy:
        
        * Config Map for environment variables used by demo app
        * Redis Pod and Exopse the pod with ClusterIP service
        * Demo App Deployment and Exopse it with NodePort service
        * Ingress to create HTTP loadbalancer

---
Now, you can access the Demo App by hitting the Ingress IP 

You can try my deployed demo from [here](http://34.160.145.6/)
And you can brows my Demo ScreenShots folder from GCP-Terraform/ScreenShots
