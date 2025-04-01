# Terraform with AWS

## Table of Contents
- [1. Introduction to Terraform with AWS](#1-introduction-to-terraform-with-aws)
- [2. AWS IAM](#2-aws-iam)
  - [2.1 IAM Overview](#21-iam-overview)
  - [2.2 Programmatic Access](#22-programmatic-access)
  - [2.3 AWS CLI & IAM](#23-aws-cli--iam)
  - [2.4 AWS IAM with Terraform](#24-aws-iam-with-terraform)
  - [2.5 IAM Policies with Terraform](#25-iam-policies-with-terraform)
- [3. AWS S3](#3-aws-s3)
  - [3.1 S3 Overview](#31-s3-overview)
  - [3.2 S3 with Terraform](#32-s3-with-terraform)
  - [3.3 S3 Bucket Policies](#33-s3-bucket-policies)
- [4. AWS DynamoDB](#4-aws-dynamodb)
  - [4.1 DynamoDB Overview](#41-dynamodb-overview)
  - [4.2 DynamoDB with Terraform](#42-dynamodb-with-terraform)
- [5. AWS EC2](#5-aws-ec2)
  - [5.1 EC2 Overview](#51-ec2-overview)
  - [5.2 EC2 with Terraform](#52-ec2-with-terraform)
  - [5.3 EC2 Security Groups](#53-ec2-security-groups)

## 1. Introduction to Terraform with AWS

Terraform is an Infrastructure as Code (IaC) tool created by HashiCorp that allows you to define and provision infrastructure using a declarative configuration language. When working with AWS, Terraform provides a powerful way to manage cloud resources in a consistent and repeatable manner.

**Key Benefits of Terraform with AWS:**
- **Declarative Configuration**: Define what you want, not how to do it
- **Infrastructure as Code**: Version control your infrastructure
- **Resource Graph**: Terraform builds a dependency graph and creates/updates resources in the correct order
- **Change Planning**: Preview changes with `terraform plan` before applying them
- **Provider Ecosystem**: AWS provider is robust and continuously updated

To get started with Terraform and AWS, you need to:
1. Install Terraform
2. Configure AWS credentials
3. Create Terraform configuration files
4. Initialize, plan, and apply your infrastructure

## 2. AWS IAM

### 2.1 IAM Overview

AWS Identity and Access Management (IAM) enables you to securely control access to AWS services and resources. With IAM, you can create and manage AWS users and groups, and use permissions to allow or deny their access to AWS resources.

**Key IAM Components:**
- **Users**: Individual AWS users with unique credentials
- **Groups**: Collections of users under one set of permissions
- **Roles**: Sets of permissions that can be assumed by entities
- **Policies**: Documents that define permissions

### 2.2 Programmatic Access

Programmatic access allows you to interact with AWS through API calls using access keys. This is essential for Terraform to manage AWS resources.

**Setting Up Programmatic Access:**
1. Create an IAM user with appropriate permissions
2. Generate access keys (Access Key ID and Secret Access Key)
3. Configure credentials for use with Terraform

**Best Practices:**
- Never share access keys
- Implement the principle of least privilege
- Rotate access keys regularly
- Consider using IAM roles with temporary credentials

### 2.3 AWS CLI & IAM

The AWS Command Line Interface (CLI) is a unified tool to manage AWS services from the command line.

**Installing AWS CLI:**
```bash
# For macOS (using Homebrew)
brew install awscli

# For Windows (using Chocolatey)
choco install awscli

# For Linux
pip install awscli
```

**Configuring AWS CLI:**
```bash
aws configure
```

This will prompt you for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., us-west-2)
- Default output format (e.g., json)

**Common IAM Commands with AWS CLI:**

```bash
# List IAM users
aws iam list-users

# Create a new IAM user
aws iam create-user --user-name newuser

# Attach a policy to a user
aws iam attach-user-policy --user-name newuser --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create access keys for a user
aws iam create-access-key --user-name newuser

# List attached policies for a user
aws iam list-attached-user-policies --user-name newuser

# Delete a user
aws iam delete-user --user-name newuser
```

### 2.4 AWS IAM with Terraform

Terraform allows you to manage IAM users, groups, roles, and policies as code. Here's how to create IAM resources using Terraform:

**Provider Configuration:**
```hcl
provider "aws" {
  region = "us-west-2"
  # Credentials can be specified here or via environment variables
  # access_key = "AKIAIOSFODNN7EXAMPLE"
  # secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
```

**Creating an IAM User:**
```hcl
resource "aws_iam_user" "example_user" {
  name = "example-user"
  path = "/system/"

  tags = {
    Environment = "Production"
    Role        = "Developer"
  }
}

# Create access keys for the user
resource "aws_iam_access_key" "example_user_key" {
  user = aws_iam_user.example_user.name
}

# Output the access key (be cautious with sensitive outputs)
output "access_key_id" {
  value = aws_iam_access_key.example_user_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.example_user_key.secret
  sensitive = true
}
```

**Creating an IAM Group and Adding Users:**
```hcl
resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group_membership" "dev_team" {
  name = "dev-team-membership"
  
  users = [
    aws_iam_user.example_user.name,
    # Add other users here
  ]
  
  group = aws_iam_group.developers.name
}
```

**Creating an IAM Role:**
```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Environment = "Production"
  }
}
```

### 2.5 IAM Policies with Terraform

IAM policies define permissions for AWS actions. Terraform makes it easy to create and attach these policies.

**Inline Policy:**
```hcl
resource "aws_iam_user_policy" "user_policy" {
  name = "s3-access"
  user = aws_iam_user.example_user.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::example-bucket",
          "arn:aws:s3:::example-bucket/*"
        ]
      }
    ]
  })
}
```

**Managed Policy:**
```hcl
resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-policy"
  description = "Allow read access to S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "user_policy_attach" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# Attach policy to group
resource "aws_iam_group_policy_attachment" "group_policy_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}
```

**Using AWS Managed Policies:**
```hcl
resource "aws_iam_user_policy_attachment" "admin_access" {
  user       = aws_iam_user.example_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```

## 3. AWS S3

### 3.1 S3 Overview

Amazon Simple Storage Service (S3) is an object storage service offering industry-leading scalability, data availability, security, and performance.

**Key S3 Concepts:**
- **Buckets**: Containers for objects stored in S3
- **Objects**: Files and metadata stored in buckets
- **Keys**: Unique identifiers for objects in a bucket
- **Versioning**: Keeps multiple versions of an object in a bucket
- **Access Control**: Bucket policies, ACLs, IAM policies

### 3.2 S3 with Terraform

Terraform allows you to create and manage S3 buckets with various configurations.

**Creating a Basic S3 Bucket:**
```hcl
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-terraform-example-bucket"
  
  tags = {
    Name        = "My Terraform Bucket"
    Environment = "Dev"
  }
}

# Configure bucket versioning
resource "aws_s3_bucket_versioning" "example_versioning" {
  bucket = aws_s3_bucket.example_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure bucket access control
resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.example_bucket.id
  acl    = "private"
}
```

**Configuring S3 Bucket Encryption:**
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "example_encryption" {
  bucket = aws_s3_bucket.example_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

**S3 as a Static Website:**
```hcl
resource "aws_s3_bucket_website_configuration" "example_website" {
  bucket = aws_s3_bucket.example_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
```

**Uploading Files to S3:**
```hcl
resource "aws_s3_object" "example_object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "example-file.txt"
  source = "${path.module}/files/example-file.txt"
  etag   = filemd5("${path.module}/files/example-file.txt")
  
  content_type = "text/plain"
}
```

### 3.3 S3 Bucket Policies

S3 bucket policies are JSON documents that define what actions are allowed or denied on the bucket.

**Example Bucket Policy:**
```hcl
resource "aws_s3_bucket_policy" "allow_access" {
  bucket = aws_s3_bucket.example_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.example_bucket.arn}/*"
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp": "192.0.2.0/24"
          }
        }
      }
    ]
  })
}
```

## 4. AWS DynamoDB

### 4.1 DynamoDB Overview

Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability.

**Key DynamoDB Concepts:**
- **Tables**: Collection of items (records)
- **Items**: Group of attributes
- **Attributes**: Fundamental data elements
- **Primary Key**: Uniquely identifies each item in a table
- **Secondary Indexes**: Alternative access patterns

### 4.2 DynamoDB with Terraform

Terraform allows you to create and manage DynamoDB tables and their properties.

**Creating a Basic DynamoDB Table:**
```hcl
resource "aws_dynamodb_table" "example_table" {
  name           = "example-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  tags = {
    Name        = "example-dynamodb-table"
    Environment = "production"
  }
}
```

**Pay-Per-Request Pricing Mode:**
```hcl
resource "aws_dynamodb_table" "on_demand_table" {
  name         = "example-on-demand-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }
}
```

**Adding Global Secondary Index:**
```hcl
resource "aws_dynamodb_table" "with_gsi" {
  name           = "example-with-gsi"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  attribute {
    name = "TopScore"
    type = "N"
  }

  global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }
}
```

**Adding Time-to-Live (TTL):**
```hcl
resource "aws_dynamodb_table" "with_ttl" {
  name           = "example-with-ttl"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }
}
```

**DynamoDB Autoscaling:**
```hcl
resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.example_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}
```

## 5. AWS EC2

### 5.1 EC2 Overview

Amazon Elastic Compute Cloud (EC2) provides resizable compute capacity in the cloud. EC2 instances are virtual servers that can run applications.

**Key EC2 Concepts:**
- **Instance Types**: Different combinations of CPU, memory, storage, and networking capacity
- **AMI (Amazon Machine Image)**: Templates for instances with preconfigured software
- **Security Groups**: Virtual firewalls for instances
- **Key Pairs**: Secure login information for instances
- **EBS (Elastic Block Store)**: Persistent storage volumes

### 5.2 EC2 with Terraform

Terraform makes it easy to create and manage EC2 instances and their associated resources.

**Creating a Basic EC2 Instance:**
```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI ID (varies by region)
  instance_type = "t2.micro"
  
  tags = {
    Name = "example-instance"
  }
}
```

**Instance with Key Pair and User Data:**
```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/ssh/id_rsa.pub")
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Terraform" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "WebServer"
  }
}
```

**Instance with EBS Volume:**
```hcl
resource "aws_instance" "with_ebs" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
  }
  
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 100
    volume_type = "gp2"
    encrypted   = true
  }
  
  tags = {
    Name = "InstanceWithEBS"
  }
}
```

**Instance with IAM Role:**
```hcl
resource "aws_iam_role" "instance_role" {
  name = "instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_instance" "with_role" {
  ami                  = "ami-0c55b159cbfafe1f0"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  
  tags = {
    Name = "InstanceWithRole"
  }
}
```

### 5.3 EC2 Security Groups

Security groups act as virtual firewalls for EC2 instances, controlling inbound and outbound traffic.

**Creating a Security Group:**
```hcl
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow web and SSH traffic"
  vpc_id      = aws_vpc.main.id  # If using a custom VPC
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Restrict SSH access
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "WebSecurityGroup"
  }
}

resource "aws_instance" "web_with_sg" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_sg.name]
  
  tags = {
    Name = "WebWithSG"
  }
}
```

**Security Group Rules as Separate Resources:**
```hcl
resource "aws_security_group" "base_sg" {
  name        = "base-sg"
  description = "Base security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.base_sg.id
}

resource "aws_security_group_rule" "allow_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.base_sg.id
}
```

**Security Group Referencing Another Security Group:**
```hcl
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Database security group"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "DBSecurityGroup"
  }
}
```