# DevOps Repository - Afet Yönetim Sistemi

## Introduction

This repository is part of the Afet Yönetim Sistemi (Disaster Management System) project. It is designed to handle the automated deployment of essential services during a disaster situation. The primary objective is to ensure that all necessary services are deployed rapidly and efficiently to support disaster response and recovery efforts.

## Purpose

In the event of a disaster, timely deployment of services is critical. This repository provides the tools and scripts required to automate the deployment process, ensuring that all necessary applications and infrastructure components are up and running with minimal manual intervention. This automation is crucial for minimizing downtime and maximizing the efficiency of disaster response operations.

## Features

- **Automated Deployment**: Utilizes infrastructure-as-code (IaC) principles to automate the provisioning and configuration of infrastructure.
- **Scalability**: Capable of scaling services up or down based on the current needs during a disaster situation.
- **Monitoring and Logging**: Integrated with monitoring and logging tools to provide real-time insights into the status of deployed services.
- **Security**: Ensures that all deployed services adhere to security best practices to protect sensitive data and maintain operational integrity.

## Getting Started

### Prerequisites

- **AWS Account**: All deployments are designed to run on Amazon Web Services (AWS). Ensure you have an active AWS account.
- **Terraform**: We use Terraform for infrastructure provisioning. Install Terraform by following the [official installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- **Docker**: Some services may require Docker. Install Docker from [here](https://docs.docker.com/get-docker/).

### Installation

**1. Clone the Repository**:
   ```sh
   git clone https://github.com/afet-yonetim-sistemi/devops.git
   cd devops
   ```

**2. Configure AWS Credentials**:
Ensure your AWS credentials are set up. You can configure them using the AWS CLI:
**important**: profile must be set as ays

   ```sh
   aws configure --profile ays
   ```

**3. Initialize Terraform**:
Navigate to the Terraform directory and initialize Terraform:
   ```sh
   cd terraform
   terraform init
   ```

**4. Apply Terraform Configuration**:
Apply the configuration to provision the necessary infrastructure:
   ```sh
   terraform apply
   ```




**Useful commands**
- 


**Destroy all resources**:
Destroy all resources deployed with commands above:
   ```sh
   terraform destroy
   ```

**Show all resources**:
Show all resources deployed with commands above:
   ```sh
   terraform show
   ```
**Format files**:
In working directory format terraform files:
   ```sh
   terraform fmt --recursive
   ```   