# Working with Terraform

## Table of Contents
- [Advanced Terraform Commands](#advanced-terraform-commands)
  - [State Management Commands](#state-management-commands)
  - [Format and Validation Commands](#format-and-validation-commands)
  - [Workspace Commands](#workspace-commands)
  - [Import and Console Commands](#import-and-console-commands)
- [Mutable vs Immutable Infrastructure](#mutable-vs-immutable-infrastructure)
  - [Mutable Infrastructure](#mutable-infrastructure)
  - [Immutable Infrastructure](#immutable-infrastructure)
  - [Terraform's Approach](#terraforms-approach)
- [Resource Lifecycle Rules](#resource-lifecycle-rules)
  - [create_before_destroy](#create_before_destroy)
  - [prevent_destroy](#prevent_destroy)
  - [ignore_changes](#ignore_changes)
- [Data Sources](#data-sources)
  - [Basic Usage](#basic-usage)
  - [Common Data Sources](#common-data-sources)
- [Meta-Arguments](#meta-arguments)
  - [depends_on](#depends_on)
  - [lifecycle](#lifecycle)
  - [count](#count)
  - [for_each](#for_each)
- [Terraform Functions](#terraform-functions)
  - [Length Function](#length-function)
  - [Other Useful Functions](#other-useful-functions)
- [Version Constraints](#version-constraints)
  - [Provider Version Constraints](#provider-version-constraints)
  - [Terraform Version Constraints](#terraform-version-constraints)

## Advanced Terraform Commands

Beyond the basic commands, Terraform provides advanced commands for various operations:

### State Management Commands

```bash
# List resources in state
terraform state list

# Show details of a resource in state
terraform state show aws_instance.example

# Move a resource to a different address
terraform state mv aws_instance.old aws_instance.new

# Remove a resource from state (without destroying it)
terraform state rm aws_instance.example

# Pull current state and output to stdout
terraform state pull

# Update state from stdin
terraform state push

# Show state file content
terraform show
```

### Format and Validation Commands

```bash
# Format configuration files according to HCL standards
terraform fmt

# Format and display differences
terraform fmt -diff

# Format recursively
terraform fmt -recursive

# Validate configuration file syntax
terraform validate

# Check provider requirements
terraform providers
```

### Workspace Commands

```bash
# List available workspaces
terraform workspace list

# Create a new workspace
terraform workspace new production

# Switch to another workspace
terraform workspace select development

# Show current workspace
terraform workspace show

# Delete a workspace
terraform workspace delete staging
```

### Import and Console Commands

```bash
# Import existing infrastructure into Terraform state
terraform import aws_instance.example i-1234567890abcdef0

# Interactive console for testing expressions
terraform console

# Output a dependency graph visualization
terraform graph | dot -Tsvg > graph.svg
```

## Mutable vs Immutable Infrastructure

### Mutable Infrastructure

Mutable infrastructure is the traditional approach where servers are updated in place:

- **Characteristics:**
  - Systems are continuously modified and updated in place
  - Configuration drift occurs over time
  - Each server has a unique history and state
  - Manual or automated updates applied to existing resources

- **Advantages:**
  - Faster incremental updates
  - Lower immediate resource costs
  - Familiar approach for traditional operations teams

- **Disadvantages:**
  - Configuration drift
  - Snowflake servers
  - Difficult troubleshooting
  - Inconsistent environments

### Immutable Infrastructure

Immutable infrastructure follows a "replace rather than update" approach:

- **Characteristics:**
  - Resources are never modified after deployment
  - Updates involve creating new resources and destroying old ones
  - Each deployment creates identical environments
  - Infrastructure is treated as disposable

- **Advantages:**
  - Consistent, predictable environments
  - Simplified rollbacks
  - Reduced configuration drift
  - Better security and compliance
  - Easier testing

- **Disadvantages:**
  - Higher resource utilization during transitions
  - Potentially longer deployment times
  - Learning curve for teams

### Terraform's Approach

Terraform generally follows an immutable infrastructure approach but offers flexibility:

- Resources are replaced when configuration changes require it
- Some attributes can be updated in-place when the provider supports it
- Lifecycle rules allow fine-tuning of this behavior

## Resource Lifecycle Rules

Lifecycle rules modify Terraform's default behavior when handling resources:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags]
  }
}
```

### create_before_destroy

This rule causes Terraform to create a replacement resource before destroying the original:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
  }
}
```

**Use cases:**
- Minimize downtime during resource replacement
- Ensure new resources are functioning before removing old ones
- Handle dependencies that require a resource to exist continuously

### prevent_destroy

This rule prevents the accidental destruction of critical resources:

```hcl
resource "aws_db_instance" "database" {
  engine         = "mysql"
  instance_class = "db.t3.micro"
  
  lifecycle {
    prevent_destroy = true
  }
}
```

**Use cases:**
- Protect production databases
- Prevent accidental deletion of critical infrastructure
- Safeguard data storage resources

### ignore_changes

This rule tells Terraform to ignore changes to specified attributes:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags          = {
    Name = "example-instance"
  }
  
  lifecycle {
    ignore_changes = [
      tags,
      security_groups,
    ]
  }
}
```

**Use cases:**
- Ignore changes made outside of Terraform
- Prevent replacement when non-critical attributes change
- Accommodate hybrid management scenarios

## Data Sources

Data sources allow Terraform to use information defined outside of Terraform.

### Basic Usage

```hcl
# Fetch information about an existing VPC
data "aws_vpc" "default" {
  default = true
}

# Use the VPC ID in a resource
resource "aws_security_group" "example" {
  name   = "example"
  vpc_id = data.aws_vpc.default.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Common Data Sources

```hcl
# Get the current AWS region
data "aws_region" "current" {}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Read local file content
data "local_file" "config" {
  filename = "${path.module}/config.json"
}

# Get current timestamp
data "time_static" "snapshot" {}
```

## Meta-Arguments

Meta-arguments are special arguments accepted by any resource block.

### depends_on

Explicitly specifies dependencies that Terraform can't automatically infer:

```hcl
# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket"
}

# Create a bucket policy depending on the bucket
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.example.arn}/*"
    }]
  })
  
  # Explicitly declare dependency
  depends_on = [
    aws_s3_bucket.example
  ]
}
```

### lifecycle

Controls how Terraform handles resource creation, updates, and deletion:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags]
  }
}
```

### count

Creates multiple instances of a resource based on a numeric count:

```hcl
# Create 3 EC2 instances
resource "aws_instance" "server" {
  count         = 3
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Server-${count.index + 1}"
  }
}

# Reference specific instance
output "first_server_ip" {
  value = aws_instance.server[0].private_ip
}

# Reference all instances
output "all_server_ips" {
  value = aws_instance.server[*].private_ip
}
```

Conditional creation with count:

```hcl
# Create resource only if condition is true
resource "aws_instance" "dev" {
  count         = var.environment == "development" ? 1 : 0
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### for_each

Creates multiple instances of a resource based on a map or set of strings:

```hcl
# Create multiple EC2 instances with different sizes
resource "aws_instance" "server" {
  for_each      = {
    web  = "t2.micro"
    api  = "t2.small"
    db   = "t2.medium"
  }
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = each.value
  
  tags = {
    Name = "Server-${each.key}"
    Type = each.key
  }
}

# Reference a specific instance
output "api_server_ip" {
  value = aws_instance.server["api"].private_ip
}

# Reference all instances
output "all_server_ips" {
  value = {
    for key, instance in aws_instance.server : 
    key => instance.private_ip
  }
}
```

Using a set with for_each:

```hcl
# Create multiple S3 buckets
resource "aws_s3_bucket" "buckets" {
  for_each = toset(["logs", "backups", "data"])
  
  bucket = "my-company-${each.key}"
}
```

## Terraform Functions

Terraform includes built-in functions for transforming and combining values.

### Length Function

The `length` function returns the number of elements in a list, map, or string:

```hcl
# Use length with a list
variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-1", "subnet-2", "subnet-3"]
}

resource "aws_instance" "server" {
  count         = length(var.subnet_ids)
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_ids[count.index]
}

# Use length for condition
resource "aws_autoscaling_group" "example" {
  count = length(var.subnet_ids) > 0 ? 1 : 0
  
  min_size         = 2
  max_size         = 10
  vpc_zone_identifier = var.subnet_ids
}
```

### Other Useful Functions

```hcl
# String functions
locals {
  name_prefix = "app-${lower(var.environment)}"
  upper_env   = upper(var.environment)
  trimmed     = trimspace(var.input_string)
}

# Numeric functions
locals {
  max_instances  = max(var.min_instances, 2)
  ceiling_value  = ceil(var.floating_value)
  floor_value    = floor(var.floating_value)
}

# Collection functions
locals {
  merged_maps    = merge(var.common_tags, var.specific_tags)
  list_items     = concat(var.list_a, var.list_b)
  first_item     = element(var.list, 0)
  filtered_list  = [for i in var.list : i if i != ""]
}

# Type conversion functions
locals {
  json_data      = jsonencode(var.complex_object)
  string_list    = tolist(var.set_of_strings)
  string_set     = toset(var.list_of_strings)
  integer_value  = tonumber(var.string_number)
}
```

## Version Constraints

### Provider Version Constraints

Specify acceptable provider versions:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0, < 4.0.0"
    }
  }
}
```

Version constraint operators:

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Exact version | `= 1.2.3` |
| `!=` | Not equal | `!= 1.2.3` |
| `>` | Greater than | `> 1.2.3` |
| `>=` | Greater than or equal | `>= 1.2.3` |
| `<` | Less than | `< 1.2.3` |
| `<=` | Less than or equal | `<= 1.2.3` |
| `~>` | Pessimistic constraint (allows only the rightmost version component to increment) | `~> 1.2.3` allows 1.2.4 but not 1.3.0 |

### Terraform Version Constraints

Specify the required Terraform version:

```hcl
terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```

Best practices for version constraints:

1. Always specify required provider versions
2. Use `~>` for minor version flexibility
3. Consider locking major versions to avoid breaking changes
4. Test provider updates before applying to production