# DevOps Repository - Afet Yönetim Sistemi
## Getting Started

### Prerequisites

- **Terraform**: We use Terraform for infrastructure provisioning. Install Terraform by following the [official installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### Installation

**1. Initialize Terraform**:
Navigate to the Terraform directory and initialize Terraform:
   ```sh
   cd terraform
   terraform init
   ```

**2. Apply Terraform Configuration**:
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