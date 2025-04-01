# Remote State and Terraform Provisioners

## Table of Contents
- [1. Remote State](#1-remote-state)
  - [1.1 Understanding Terraform State](#11-understanding-terraform-state)
  - [1.2 Remote State Storage](#12-remote-state-storage)
  - [1.3 State Locking](#13-state-locking)
  - [1.4 Backend Configuration](#14-backend-configuration)
  - [1.5 Remote State Data Source](#15-remote-state-data-source)
- [2. Terraform State Commands](#2-terraform-state-commands)
  - [2.1 State List](#21-state-list)
  - [2.2 State Show](#22-state-show)
  - [2.3 State Move](#23-state-move)
  - [2.4 State Pull and Push](#24-state-pull-and-push)
  - [2.5 State Remove](#25-state-remove)
- [3. Terraform Provisioners](#3-terraform-provisioners)
  - [3.1 Provisioner Types](#31-provisioner-types)
  - [3.2 Remote Exec Provisioner](#32-remote-exec-provisioner)
  - [3.3 Local Exec Provisioner](#33-local-exec-provisioner)
  - [3.4 File Provisioner](#34-file-provisioner)
  - [3.5 Failure Behavior](#35-failure-behavior)
  - [3.6 Connection Configuration](#36-connection-configuration)
  - [3.7 Provisioner Best Practices](#37-provisioner-best-practices)

## 1. Remote State

### 1.1 Understanding Terraform State

Terraform state is a JSON file that maps real-world resources to your configuration, tracks metadata, and improves performance for large infrastructures. The state file is crucial for Terraform to function correctly.

**Key Concepts:**
- **Resource Mapping**: Links configuration to real-world resources
- **Metadata**: Tracks resource dependencies
- **Performance**: Caches resource attributes to optimize plan operations
- **Collaboration**: Enables team work on the same infrastructure

**Default Local State:**
By default, Terraform stores state locally in a file named `terraform.tfstate`. A backup of the previous state is also maintained as `terraform.tfstate.backup`.

```bash
# List files in the current directory to see state files
ls -la *.tfstate*
```

### 1.2 Remote State Storage

Storing state remotely solves several problems:

- **Team Collaboration**: Multiple team members can access the same state
- **Security**: Sensitive information in state can be better protected
- **Reliability**: Remote state is typically stored in highly available services
- **CI/CD Integration**: Easier integration with automated workflows

**Popular Remote State Backends:**

| Backend | Description | Benefits |
|---------|-------------|----------|
| AWS S3 | Amazon S3 with optional DynamoDB locking | Highly available, versioned, secure |
| Azure Storage | Azure Blob Storage with lease locking | Integrated with Azure ecosystem |
| Google Cloud Storage | GCS with object versioning | Well-suited for GCP deployments |
| HashiCorp Consul | K/V store with locking | Good for HashiCorp ecosystem |
| Terraform Cloud | HashiCorp's managed service | Integrated workflows, UI, RBAC |
| PostgreSQL | Database backend | Good for existing PostgreSQL users |

### 1.3 State Locking

State locking prevents concurrent operations on the same state file, which could cause corruption or race conditions.

**How State Locking Works:**
1. When Terraform runs an operation that modifies state, it attempts to acquire a lock
2. If another instance of Terraform is holding the lock, the operation will wait or fail
3. After the operation completes, the lock is released

**DynamoDB as a Lock Table:**
When using S3 for remote state storage, DynamoDB can be used for state locking.

```hcl
# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

**State Locking Commands:**
```bash
# Force-unlock the state if a lock is stuck (use with caution)
terraform force-unlock LOCK_ID

# Disable state locking (not recommended)
terraform plan -lock=false
terraform apply -lock=false
```

### 1.4 Backend Configuration

Backends define where and how state is stored. Configure backends in your Terraform configuration.

**S3 Backend Example:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
```

**Azure Storage Backend Example:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

**Google Cloud Storage Backend Example:**
```hcl
terraform {
  backend "gcs" {
    bucket  = "tf-state-production"
    prefix  = "terraform/state"
  }
}
```

**Initializing with Backend Configuration:**
```bash
# Initialize with backend config
terraform init

# Override backend config with CLI flags
terraform init \
  -backend-config="bucket=different-bucket" \
  -backend-config="key=different/path/terraform.tfstate"

# Reconfigure backend
terraform init -reconfigure

# Migrate state from one backend to another
terraform init -migrate-state
```

### 1.5 Remote State Data Source

The `terraform_remote_state` data source retrieves output values from another Terraform configuration's remote state.

**Using Remote State Outputs:**
```hcl
# In one Terraform project
output "vpc_id" {
  value = aws_vpc.main.id
}

# In another Terraform project
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_instance" "app" {
  # Use VPC ID from the remote state
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = data.terraform_remote_state.network.outputs.subnet_id
}
```

## 2. Terraform State Commands

Terraform provides various commands to manage and manipulate state files.

### 2.1 State List

Lists resources within the Terraform state.

```bash
# List all resources in the state
terraform state list

# List resources with a specific prefix
terraform state list aws_instance.*

# List resources matching a pattern
terraform state list 'module.vpc.*'
```

### 2.2 State Show

Shows the attributes of a single resource in the state.

```bash
# Show details of a specific resource
terraform state show aws_instance.web

# Show details of a resource in a module
terraform state show module.vpc.aws_subnet.public[0]

# Pipe output to a file
terraform state show aws_s3_bucket.state > bucket_details.txt
```

### 2.3 State Move

Moves resources within the state, useful for refactoring configurations without destroying and recreating resources.

```bash
# Rename a resource
terraform state mv aws_instance.app aws_instance.web

# Move a resource into a module
terraform state mv aws_instance.app module.app.aws_instance.main

# Move a resource from one module to another
terraform state mv module.old.aws_instance.app module.new.aws_instance.app

# Move an indexed resource
terraform state mv 'aws_subnet.public[0]' 'aws_subnet.private[0]'
```

**Use Cases for State Move:**
- Renaming resources
- Reorganizing configuration by moving resources into modules
- Changing resource addressing formats (e.g., from count to for_each)

### 2.4 State Pull and Push

Allows direct manipulation of state by downloading or uploading it.

```bash
# Download the current state
terraform state pull > current_state.json

# Upload a modified state file (use with extreme caution)
terraform state push modified_state.json

# Push with force flag to override version checks (very dangerous)
terraform state push -force modified_state.json
```

**Warning**: Manual state editing is risky and should be avoided when possible. Always make a backup before attempting to modify state files directly.

### 2.5 State Remove

Removes resources from the Terraform state without destroying the actual infrastructure.

```bash
# Remove a single resource from state
terraform state rm aws_instance.web

# Remove multiple resources
terraform state rm aws_instance.web aws_eip.web

# Remove resources matching a pattern
terraform state rm 'aws_subnet.public[*]'

# Remove all resources in a module
terraform state rm 'module.app.*'
```

**Use Cases for State Remove:**
- Forgetting about resources Terraform should no longer manage
- Handling resources created outside of Terraform
- Preparing for import operations
- Fixing corrupted state

## 3. Terraform Provisioners

Provisioners allow you to execute actions on local or remote machines as part of resource creation or destruction.

### 3.1 Provisioner Types

Terraform offers several types of provisioners:

| Provisioner | Purpose | Usage |
|-------------|---------|-------|
| `remote-exec` | Run commands on a remote resource | Configure new instances |
| `local-exec` | Run commands on the machine running Terraform | Updating local records |
| `file` | Copy files to a remote resource | Deploy configuration files |

**Provisioner Placement:**
Provisioners can be placed within a resource block or within a `null_resource`.

```hcl
# Provisioner within a resource block
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
}

# Provisioner in a null_resource
resource "null_resource" "setup" {
  depends_on = [aws_instance.web]
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
}
```

### 3.2 Remote Exec Provisioner

The `remote-exec` provisioner invokes a script on a remote resource after it is created.

**Inline Commands:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
    }
  }
}
```

**Script File:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  provisioner "remote-exec" {
    script = "${path.module}/scripts/setup.sh"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
    }
  }
}
```

**Multiple Scripts:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/setup.sh",
      "${path.module}/scripts/configure.sh",
      "${path.module}/scripts/deploy.sh"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
    }
  }
}
```

### 3.3 Local Exec Provisioner

The `local-exec` provisioner executes commands on the machine running Terraform.

**Basic Usage:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
```

**With Environment Variables:**
```hcl
resource "aws_db_instance" "db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "admin"
  password             = var.db_password
  
  provisioner "local-exec" {
    command = "python ${path.module}/scripts/update_db_config.py"
    environment = {
      DB_HOST     = self.address
      DB_PORT     = self.port
      DB_NAME     = self.name
      DB_USER     = self.username
      DB_PASSWORD = var.db_password
    }
  }
}
```

**With Working Directory:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  provisioner "local-exec" {
    command     = "npm install && npm run deploy"
    working_dir = "${path.module}/app"
  }
}
```

**With Interpreter:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  provisioner "local-exec" {
    command     = "Add-Content -Path hosts.txt -Value ${self.private_ip}"
    interpreter = ["PowerShell", "-Command"]
  }
}
```

### 3.4 File Provisioner

The `file` provisioner copies files or directories from the machine running Terraform to the provisioned resource.

**Copying a Single File:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  provisioner "file" {
    source      = "${path.module}/files/nginx.conf"
    destination = "/tmp/nginx.conf"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo systemctl restart nginx"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
    }
  }
}
```

**Copying a Directory:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  provisioner "file" {
    source      = "${path.module}/files/app/"
    destination = "/tmp/app"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
    }
  }
}
```

**Using Content Instead of Source:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  provisioner "file" {
    content     = "server {\n  listen 80;\n  root /var/www/html;\n}"
    destination = "/tmp/custom_nginx.conf"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
    }
  }
}
```

### 3.5 Failure Behavior

Provisioners can be configured to behave differently when they fail.

**On Failure Continue:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
    
    on_failure = continue
  }
}
```

**On Failure Fail (default):**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
    
    on_failure = fail
  }
}
```

**Destroy-Time Provisioners:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # This will run when the resource is created
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
  
  # This will run when the resource is destroyed
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl stop nginx",
      "sudo apt-get remove -y nginx"
    ]
  }
}
```

### 3.6 Connection Configuration

Connection blocks define how to connect to remote resources.

**SSH Connection:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/private_key.pem")
      host        = self.public_ip
      port        = 22
      agent       = false
      timeout     = "5m"
    }
  }
}
```

**WinRM Connection:**
```hcl
resource "aws_instance" "windows" {
  ami           = "ami-windows-example"
  instance_type = "t2.micro"
  
  provisioner "remote-exec" {
    inline = [
      "powershell -Command \"Install-WindowsFeature -Name Web-Server\""
    ]
    
    connection {
      type     = "winrm"
      user     = "Administrator"
      password = var.admin_password
      host     = self.public_ip
      port     = 5985
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }
}
```

**Connection in a Null Resource:**
```hcl
resource "null_resource" "provision" {
  depends_on = [aws_instance.web]
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/private_key.pem")
    host        = aws_instance.web.public_ip
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
}
```

### 3.7 Provisioner Best Practices

While provisioners can be useful, there are some best practices to follow:

**Use Provisioners as a Last Resort:**
- Consider using purpose-built resources instead
- For example, use `aws_instance` with `user_data` instead of provisioners

**Alternative Approaches:**
- Use pre-built images (AMIs, custom images)
- Use configuration management tools (Ansible, Chef, Puppet)
- Use cloud-init or similar initialization systems

**When to Use Provisioners:**
- For quick prototyping
- For one-off setup tasks
- When other methods aren't available

**Recommended Pattern for Production:**
```hcl
resource "null_resource" "provision" {
  # Only run when the instance ID changes
  triggers = {
    instance_id = aws_instance.web.id
  }
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/private_key.pem")
    host        = aws_instance.web.public_ip
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
}
```

**Using Terraform Cloud's Remote Execution:**
When using Terraform Cloud, provisioners run on the Terraform Cloud worker, not your local machine. Ensure proper networking and access controls are in place.

```hcl
terraform {
  cloud {
    organization = "example-org"
    workspaces {
      name = "example-workspace"
    }
  }
}
```