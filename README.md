# Terraform Project for VPC, EC2 Instances, and Load Balancer

## Project Overview

This project sets up a VPC on AWS using Terraform, including the following components:

- **VPC** with 2 subnets:
  - **Public Subnet**: Contains a bastion host.
  - **Private Subnet**: Contains two EC2 instances, one for hosting Jenkins and another for a Kubernetes cluster.
    
- **Internet Gateway**: Provides internet access to the public subnet.
  
- **NAT Gateway**: Provides internet access to the private subnet via Elastic IP.
- **Elastic IP**: Allocated for the NAT Gateway.
- **EC2 Instances**:
  - **Bastion Host**: Located in the public subnet.
  - **Jenkins Server**: Located in the private subnet.
  - **Kubernetes Node**: Located in the private subnet.
- **Load Balancer**: Exposes the Jenkins URL.
- **Key Pairs**: Automatically created and downloaded for SSH access.

## Prerequisites

- Terraform installed on your local machine.
- AWS account with necessary permissions to create the resources.

## Project Structure

├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── README.md
└── key_pairs


## Usage

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review and Apply Configuration

##### Review the variables.tf and terraform.tfvars files to ensure they match your desired configuration.
##### Apply the Terraform configuration:


```bash
terraform apply
```

### Step 4: Access the Bastion Host

##### The bastion host key pair will be downloaded in the key_pairs directory. Use it to SSH into the bastion host:

```bash
ssh -i key_pairs/bastion_key.pem ubuntu@<Bastion-Host-Public-IP>
```


### Step 5: Access Private EC2 Instances for Kubernetes cluster

##### From the bastion host, use the respective key pairs to SSH into the k8s EC2 instances:

```bash
ssh -i k8s_key.pem ubuntu@<k8s-EC2-private-IP>
```


### Step 6: Access Private EC2 Instances for Jenkins

##### From the bastion host, use the respective key pairs to SSH into the Jenkins EC2 instances:

```bash
ssh -i jenkins_key.pem ubuntu@<jenkins-EC2-private-IP>
```

### step 7: Open Jenkins URL:
##### Open your browser and search using the LoadBalancer DNS 

## Cleaning Up
#### To destroy the infrastructure created by this project, run:

```bash
terraform destroy
```







