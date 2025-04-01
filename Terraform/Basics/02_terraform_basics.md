# Terraform Basics

## Table of Contents
- [Getting Started with Terraform](#getting-started-with-terraform)
  - [Installation](#installation)
  - [Terraform Project Structure](#terraform-project-structure)
- [HashiCorp Configuration Language (HCL) Basics](#hashicorp-configuration-language-hcl-basics)
  - [Basic Syntax](#basic-syntax)
  - [Block Types](#block-types)
- [Provider Examples](#provider-examples)
  - [Local Provider Example](#local-provider-example)
  - [Random Provider Example](#random-provider-example)
- [Basic Terraform Commands](#basic-terraform-commands)
  - [terraform init](#terraform-init)
  - [terraform plan](#terraform-plan)
  - [terraform apply](#terraform-apply)
  - [terraform destroy](#terraform-destroy)
- [Multiple Providers](#multiple-providers)
- [Variables in Terraform](#variables-in-terraform)
  - [Input Variables](#input-variables)
  - [Variable Block Structure](#variable-block-structure)
  - [Using Variables](#using-variables)
    - [Interactive Mode](#interactive-mode)
    - [Command Line Flags](#command-line-flags)
    - [Variable Definition Files](#variable-definition-files)
  - [Variable Definition Precedence](#variable-definition-precedence)
  - [Resource Attributes and Dependencies](#resource-attributes-and-dependencies)
  - [Output Variables](#output-variables)
- [Terraform State](#terraform-state)
  - [State File Basics](#state-file-basics)
  - [State Management Considerations](#state-management-considerations)

## Getting Started with Terraform

### Installation

Install Terraform by downloading the appropriate package for your operating system from the official HashiCorp website:

```bash
# Linux (Ubuntu/Debian) via apt repository
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# macOS (using Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify the installation
terraform --version
```

### Terraform Project Structure

A typical Terraform project consists of several files:

```
project-directory/
├── main.tf          # Main configuration file
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output variable declarations
├── terraform.tfvars # Variable values (optional)
├── providers.tf     # Provider configurations (optional)
└── .terraform/      # Directory created by terraform init (do not edit)
```

## HashiCorp Configuration Language (HCL) Basics

### Basic Syntax

HCL uses a declarative syntax to describe infrastructure:

```hcl
# Block type "label" "name" {
#   key = value
# }

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
    Environment = "Production"
  }
}
```

### Block Types

Common block types in Terraform:

- `provider`: Configures a specific infrastructure provider
- `resource`: Defines an infrastructure resource to be created
- `data`: References existing infrastructure
- `variable`: Defines input variables
- `output`: Defines output values
- `locals`: Defines local variables
- `module`: Encapsulates and reuses configuration

## Provider Examples

### Local Provider Example

The `local` provider allows you to manage local files and directories:

```hcl
# Configure the local provider
provider "local" {}

# Create a local file
resource "local_file" "example" {
  filename = "${path.module}/example.txt"
  content  = "This file was created by Terraform!"
  file_permission = "0644"
}
```

Save this as `main.tf` and run:

```bash
terraform init
terraform apply
```

This will create a file named `example.txt` in your current directory with the specified content and permissions.

### Random Provider Example

The `random` provider generates random values:

```hcl
# Configure the random provider
provider "random" {}

# Generate a random pet name
resource "random_pet" "animal" {
  length    = 2
  separator = "-"
}

# Output the generated name
output "pet_name" {
  value = random_pet.animal.id
}
```

Run:

```bash
terraform init
terraform apply
```

This will generate a random animal name like "happy-elephant" and display it as output.

## Basic Terraform Commands

### terraform init

Initializes a Terraform working directory by downloading providers and modules:

```bash
# Basic initialization
terraform init

# Force copy plugin binaries
terraform init -upgrade

# Use specific plugin directory
terraform init -plugin-dir=PATH

# Reconfigure backend
terraform init -reconfigure

# Migrate state between backends
terraform init -migrate-state
```

### terraform plan

Creates an execution plan, showing what actions Terraform will take:

```bash
# Basic plan
terraform plan

# Save plan to file
terraform plan -out=plan.tfplan

# Plan with variables
terraform plan -var="instance_count=3"

# Plan with variable file
terraform plan -var-file="prod.tfvars"

# Plan destroy
terraform plan -destroy
```

### terraform apply

Applies the changes required to reach the desired state:

```bash
# Interactive apply
terraform apply

# Auto-approve changes without confirmation
terraform apply -auto-approve

# Apply a saved plan
terraform apply plan.tfplan

# Apply with variables
terraform apply -var="instance_count=3"

# Apply with variable file
terraform apply -var-file="prod.tfvars"

# Target specific resources
terraform apply -target=resource_type.resource_name
```

### terraform destroy

Destroys all resources managed by the current Terraform configuration:

```bash
# Interactive destroy
terraform destroy

# Auto-approve destruction without confirmation
terraform destroy -auto-approve

# Destroy with variables
terraform destroy -var="instance_count=3"

# Destroy with variable file
terraform destroy -var-file="prod.tfvars"

# Target specific resources
terraform destroy -target=resource_type.resource_name
```

## Multiple Providers

You can use multiple providers in a single Terraform configuration:

```hcl
# AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Azure Provider
provider "azurerm" {
  features {}
}

# AWS resource
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket"
}

# Azure resource
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}
```

## Variables in Terraform

### Input Variables

Variables allow you to parameterize your configurations:

```hcl
# Define a simple string variable
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "web-server"
}

# Use the variable
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = var.instance_name
  }
}
```

### Variable Block Structure

The full variable block structure:

```hcl
variable "name" {
  description = "Describes the variable's purpose"
  type        = string       # Can be string, number, bool, list, map, set, object, tuple, any
  default     = "value"      # Optional default value
  sensitive   = false        # Whether to hide the value in logs and outputs
  nullable    = false        # Whether null is an acceptable value
  validation {              # Optional validation rules
    condition     = length(var.name) > 4
    error_message = "The name must be more than 4 characters."
  }
}
```

### Using Variables

#### Interactive Mode

If you don't specify a value for a variable without a default, Terraform will prompt you:

```bash
terraform apply

var.instance_name
  Name of the EC2 instance

Enter a value:
```

#### Command Line Flags

Specify variables on the command line:

```bash
# Single variable
terraform apply -var="instance_name=web-server-prod"

# Multiple variables
terraform apply -var="instance_name=web-server-prod" -var="instance_type=t2.micro"
```

#### Variable Definition Files

Store variables in files with `.tfvars` extension:

**terraform.tfvars**:
```hcl
instance_name = "web-server-prod"
instance_type = "t2.micro"
```

```bash
# Use the default terraform.tfvars file
terraform apply

# Specify a custom variable file
terraform apply -var-file="production.tfvars"

# Auto-loaded variable files
# - terraform.tfvars
# - *.auto.tfvars
# - *.auto.tfvars.json
```

Different variable file formats:

**production.tfvars**:
```hcl
region = "us-west-2"
instance_count = 5
```

**development.auto.tfvars**:
```hcl
region = "us-east-1"
instance_count = 2
```

**config.tfvars.json**:
```json
{
  "region": "eu-west-1",
  "instance_count": 3
}
```

### Variable Definition Precedence

Terraform loads variables in the following order, with later sources taking precedence:

1. Environment variables (`TF_VAR_name`)
2. `terraform.tfvars` file
3. `*.auto.tfvars` files (alphabetical order)
4. `-var` and `-var-file` command line options (in order they're provided)

### Resource Attributes and Dependencies

Access attributes from other resources:

```hcl
# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket"
}

# Reference the bucket in another resource
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server"
    Bucket = aws_s3_bucket.example.bucket
  }
}
```

### Output Variables

Output variables make information about your infrastructure available:

```hcl
# Define an output variable
output "instance_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
  sensitive   = false
}

# Define a sensitive output
output "db_password" {
  description = "Database password"
  value       = aws_db_instance.example.password
  sensitive   = true  # Won't be displayed in console output
}
```

Access outputs after apply:

```bash
# Show all outputs
terraform output

# Show specific output
terraform output instance_ip

# Output in JSON format
terraform output -json
```

## Terraform State

### State File Basics

Terraform records the current state of your infrastructure in a state file (`terraform.tfstate`):

```bash
# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource state
terraform state show aws_instance.example
```

### State Management Considerations

Important considerations for state management:

1. **Secret Data**: State may contain sensitive data
2. **Remote Storage**: Store state remotely for team collaboration
3. **State Locking**: Prevent concurrent operations
4. **Backup**: Regularly back up state files
5. **Version Control**: Do NOT commit local state files to version control