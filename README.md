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

---

## 📂 Repository Structure

This section provides a brief overview of the main directories. For specific details, please check the `README.md` file located inside each directory.

### `terraform/`
Contains the Infrastructure as Code (IaC) configuration files. This directory is responsible for provisioning and managing the cloud resources on AWS.
> **Documentation:** Please refer to [terraform/README.md](https://github.com/afet-yonetim-sistemi/ays-devops/blob/main/terraform/README.md) for module details and usage.

### `aws/`
Includes AWS-specific utility scripts and configurations, such as credential management, production monitoring scripts, and SonarQube setups for EC2 instances.


### `vps/`
Contains configuration scripts for Virtual Private Servers (specifically Ubuntu). This includes initial server setup (`initial-setup.sh`), Docker configurations, and user operation management.


---

## Getting Started

### Prerequisites

- **AWS Account**: All deployments are designed to run on Amazon Web Services (AWS). Ensure you have an active AWS account.
- **Terraform**: We use Terraform for infrastructure provisioning. Install Terraform by following the [official installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- **Docker**: Some services may require Docker. Install Docker from [here](https://docs.docker.com/get-docker/).

### Installation

**1. Clone the Repository**:
   ```sh
   git clone <URL>