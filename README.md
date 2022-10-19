Terraform AWS Template
======================

Initial Terraform template for AWS IaC projects
-----------------------------------------------

This repository intends to be a pattern, a start, to create a modular infrastructure-as-code project using Terraform in AWS, following the best practices when using S3 remote backend for Terraform states. 

**remote_state** directory contains a Terraform and AWS CLI project to create a remote backend infrastructure containing:

- A S3 bucket to store *remote_state* Terraform state file;
- A S3 bucket to store main project Terraform state file;
- A DynamoDB table to control Terraform state file locking;
- Parameters stored in AWS SSM Paramter Store;

**init.sh** (or *make init-proj* command) will:

- reads AWS access configuration;
- creates a S3 bucket to store remote_state state file, tipically named *terraform-AWS_REGION-ACCOUNTID*;
- using Jinja2 templates and environment variables, creates *provider.tf*, *backend.tf* and *main.tf* files;
- apply *remote_state* Terraform configuration;
- configure provider.tf and backend.tf for the main project.

## Project file structure

```
.
├── variables.tf
├── remote_state
│   ├── ssm.tf
│   ├── s3.tf
│   ├── provider.tf
│   ├── provider.jinja2
│   ├── outputs.tf
│   ├── main.jinja2
│   ├── dynamodb.tf
│   └── backend.jinja2
├── README.md
├── provider.jinja2
├── outputs.tf
├── modules
│   └── .empty
├── MIT-LICENSE.txt
├── Makefile
├── main.tf
├── locals.tf
├── lib
│   └── common.sh
├── init.sh
├── .gitignore
├── data.tf
├── CONTRIBUTING.md
├── config
│   └── .empty
├── cleanup.sh
└── backend.jinja2

```

This template was created to be used with Terraform modules, stored in *modules* directory, and the root module must contains only necessary variables, outputs, data, locals and module calls. You can use your own Terraform modules with this template. 

## Pre-reqs

- An AWS account
- Configured environment to access AWS account
- AWS CLI v2
- Terraform
- Jinja2
- Git
- make
- Bash

## Usage Instructions

### Execution

1. Clone this repository
```
git clone https://github.com/mrbitsdcf/terraform_aws_template.git my-new-supercool-project
```

2. Remove Git configurations
```
cd my-new-supercook-project
rm -rf .git
```

3. Init Git repository with your own configurations
```
git init -b main
git config user.name 'My Name'
git config user.email 'my.email@somewhere.com'
git remote add origin URL
```

4. Configure variables in *init.sh*

The variables *KEY_NAME* and *PREFIX* must be configured to reflect actual values for Terraform statefile name and project name, i.e.: 

```
KEY_NAME="remote-state-project"
PREFIX="project"
```

5. Init the project
```
make init-proj
```

### Using Makefile

We have a Makefile as Terraform interface, with the following commands:

```
⇒  make
Terraform Makefile

clean                          Erase all project. VERY DESTRUCTIVE!
console                        Enter terraform console
destroy                        Prepare tfplan to destroy resources
dry-run                        Prepare tfplan to update resources
init                           Init terraform
init-proj                      Init S3 buckets for tfstate and configure backend
lint                           Lint HCL
run                            Apply tfplan
security                       Run tfsec validation
show                           Show state
validate                       Validate syntax

```

Command *init-proj* corresponds to execute script *init.sh*.

Command *clean* corresponds to execute script *cleanup.sh*.

Command *destroy* executes ```terraform plan``` with *-destroy* and save it to *tfplan* file. To really destroy entire launched infrastructure, execute ```make run```.

## How to contribute

Please read CONTRIBUTING.md guide

## Licensing

Please read MIT-LICENSE.txt. It's 2022.
