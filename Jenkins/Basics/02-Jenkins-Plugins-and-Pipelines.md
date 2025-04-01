# Jenkins Plugins and Pipelines

## Table of Contents
1. [Jenkins Plugins](#jenkins-plugins)
   - [Important Jenkins Plugins](#important-jenkins-plugins)
   - [Use Cases for Key Plugins](#use-cases-for-key-plugins)
2. [Jenkins Fingerprint](#jenkins-fingerprint)
   - [Understanding Fingerprints](#understanding-fingerprints)
   - [Enabling and Using Fingerprints](#enabling-and-using-fingerprints)
   - [Practical Applications](#practical-applications)
3. [Pipelines and Jenkinsfile](#pipelines-and-jenkinsfile)
   - [Pipeline Syntax Basics](#pipeline-syntax-basics)
   - [Declarative vs Scripted Pipelines](#declarative-vs-scripted-pipelines)
   - [Jenkins Directives](#jenkins-directives)
     - [Environment Directive](#environment-directive)
     - [Post Directive](#post-directive)
     - [Notification Directive](#notification-directive)
     - [Script Block](#script-block)
     - [When Directive](#when-directive)
     - [Credentials Directive](#credentials-directive)
     - [Input Directive](#input-directive)
     - [Parameters Directive](#parameters-directive)
     - [Stash/Unstash Directives](#stashunstash-directives)
     - [Parallel Stages Directive](#parallel-stages-directive)
4. [Additional Pipeline Configuration](#additional-pipeline-configuration)
   - [Triggers](#triggers)
   - [Options](#options)
   - [Tools](#tools)
   - [Agent Configuration](#agent-configuration)
5. [Pipeline Scripts from SCM](#pipeline-scripts-from-scm)
   - [Setting Up Pipeline Scripts from SCM](#setting-up-pipeline-scripts-from-scm)
   - [Best Practices for Pipeline Scripts from SCM](#best-practices-for-pipeline-scripts-from-scm)
6. [Creating a Pipeline with Parameters](#creating-a-pipeline-with-parameters)
   - [Types of Parameters](#types-of-parameters)
   - [Defining Parameters in Jenkinsfile](#defining-parameters-in-jenkinsfile)
   - [Accessing Parameters in Pipeline](#accessing-parameters-in-pipeline)
7. [Blue Ocean Plugin](#blue-ocean-plugin)
    - [Installing Blue Ocean](#installing-blue-ocean)
   - [Using Blue Ocean Interface](#using-blue-ocean-interface)
   - [Creating Pipelines with Blue Ocean](#creating-pipelines-with-blue-ocean)
8. [Advanced Pipeline Techniques](#advanced-pipeline-techniques)
   - [Parallel Execution](#parallel-execution)
   - [Pipeline Visualization](#pipeline-visualization)
   - [Using Shared Libraries](#using-shared-libraries)
9. [Troubleshooting Jenkins Pipelines](#troubleshooting-jenkins-pipelines)
10. [Example Python Projects with Jenkins Pipelines](#example-python-projects-with-jenkins-pipelines)

## Jenkins Plugins

Jenkins's extensibility is one of its greatest strengths, allowing users to customize their CI/CD environment through plugins.

### Important Jenkins Plugins

| Plugin Name | Purpose | Installation Command |
|-------------|---------|----------------------|
| Git | Integrates Git version control | `jenkins-plugin-cli --plugins git` |
| Pipeline | Supports Jenkins Pipeline jobs | `jenkins-plugin-cli --plugins workflow-aggregator` |
| Docker | Builds and uses Docker containers | `jenkins-plugin-cli --plugins docker-workflow` |
| Blue Ocean | Modern UI for Jenkins Pipeline | `jenkins-plugin-cli --plugins blueocean` |
| Credentials | Stores credentials securely | `jenkins-plugin-cli --plugins credentials` |
| JUnit | Publishes JUnit test results | `jenkins-plugin-cli --plugins junit` |
| Artifactory | Integrates with JFrog Artifactory | `jenkins-plugin-cli --plugins artifactory` |
| Email Extension | Enhanced email notifications | `jenkins-plugin-cli --plugins email-ext` |
| Slack Notification | Sends build notifications to Slack | `jenkins-plugin-cli --plugins slack` |
| Kubernetes | Runs dynamic agents in Kubernetes | `jenkins-plugin-cli --plugins kubernetes` |
| GitHub Integration | Enhanced GitHub integration | `jenkins-plugin-cli --plugins github-integration` |
| NodeJS | Provides NodeJS environment | `jenkins-plugin-cli --plugins nodejs` |
| Python | Provides Python environment | `jenkins-plugin-cli --plugins python` |
| SonarQube Scanner | Integrates SonarQube code analysis | `jenkins-plugin-cli --plugins sonarqube-scanner` |
| OWASP Dependency-Check | Security vulnerability scanning | `jenkins-plugin-cli --plugins dependency-check-jenkins-plugin` |

### Use Cases for Key Plugins

**Git Plugin**
The Git plugin allows Jenkins to pull source code from Git repositories. It's essential for any Jenkins setup that interacts with Git-based version control.

```python
# Example script to interact with Git plugin through Python
import jenkins

# Connect to Jenkins
server = jenkins.Jenkins('http://localhost:8080', username='admin', password='password')

# Configure a job to use Git
xml = '''
<project>
  <scm class="hudson.plugins.git.GitSCM">
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/username/repo.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/main</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
  </scm>
</project>
'''
server.create_job('git-example-job', xml)
```

**Docker Plugin**
This plugin allows you to build, test, and use Docker images directly from your Jenkins Pipeline.

```groovy
// In Jenkinsfile
pipeline {
    agent {
        docker {
            image 'python:3.9'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'python --version'
                sh 'pip install -r requirements.txt'
            }
        }
    }
}
```

**Blue Ocean Plugin**
Blue Ocean provides a modern UI for Jenkins Pipelines, making visualization of complex pipelines much easier.

```python
# Example Python script to check Blue Ocean plugin status
import requests
import json

jenkins_url = "http://localhost:8080"
username = "admin"
password = "password"

# Check if Blue Ocean plugin is installed
response = requests.get(
    f"{jenkins_url}/pluginManager/api/json?depth=1",
    auth=(username, password)
)

plugins = json.loads(response.text)['plugins']
blueocean_installed = any(plugin['shortName'] == 'blueocean' for plugin in plugins)

print(f"Blue Ocean plugin installed: {blueocean_installed}")
```

**Credentials Plugin**
Stores credentials securely in Jenkins to be used by jobs for authentication to various services.

```groovy
// In Jenkinsfile, using credentials
pipeline {
    agent any
    environment {
        GITHUB_CREDS = credentials('github-credentials')
    }
    stages {
        stage('Clone') {
            steps {
                sh 'git clone https://${GITHUB_CREDS_USR}:${GITHUB_CREDS_PSW}@github.com/username/private-repo.git'
            }
        }
    }
}
```

## Jenkins Fingerprint

### Understanding Fingerprints

Jenkins fingerprinting is a mechanism that tracks dependencies between builds and projects. It creates a unique identifier (MD5 hash) for each artifact and tracks where it's used, providing traceability across your CI/CD pipeline.

Benefits of fingerprinting:
- Track which build produced a specific artifact
- Identify where a particular artifact was deployed
- Map dependencies between different projects
- Facilitate auditing and compliance requirements

### Enabling and Using Fingerprints

To enable fingerprinting on artifacts, you need to modify your pipeline or job configuration:

```groovy
// In Jenkinsfile
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                // Build your artifact
                sh 'python setup.py bdist_wheel'
            }
            post {
                success {
                    // Fingerprint the artifact
                    fingerprint 'dist/*.whl'
                }
            }
        }
    }
}
```

For freestyle projects, you can enable fingerprinting in the post-build actions section.

### Practical Applications

**Tracking Application Deployment**

Using fingerprinting to track which version of your application is deployed to different environments:

```python
# Python script to query Jenkins fingerprints via API
import requests
import hashlib
import json

jenkins_url = "http://localhost:8080"
username = "admin"
password = "password"

# Calculate MD5 of a file
def calculate_md5(file_path):
    with open(file_path, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

# Get fingerprint information
def get_fingerprint_info(md5):
    response = requests.get(
        f"{jenkins_url}/fingerprint/{md5}/api/json",
        auth=(username, password)
    )
    if response.status_code == 200:
        return json.loads(response.text)
    return None

# Example usage
artifact_md5 = calculate_md5("./my-app-1.0.0.jar")
fingerprint_info = get_fingerprint_info(artifact_md5)
if fingerprint_info:
    print(f"Artifact was built in job: {fingerprint_info['original']['name']}")
    print(f"Build number: {fingerprint_info['original']['number']}")
    print("Used in:")
    for usage in fingerprint_info['usages']:
        print(f"- {usage['name']}")
```

## Pipelines and Jenkinsfile

### Pipeline Syntax Basics

Jenkins Pipeline is a suite of plugins that supports implementing and integrating continuous delivery pipelines into Jenkins. A pipeline is defined in a file called `Jenkinsfile` that can be committed to a project's source control repository.

Here's a basic example of a Jenkinsfile:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh 'python -m pip install -r requirements.txt'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                sh 'python -m pytest tests/'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
                sh 'python deploy.py'
            }
        }
    }
}
```

### Declarative vs Scripted Pipelines

Jenkins offers two syntaxes for defining pipelines:

**Declarative Pipeline**
- Newer, more structured approach
- Starts with `pipeline` block
- Limited flexibility, but easier to learn
- Provides a clear structure for pipeline definition

```groovy
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
```

**Scripted Pipeline**
- Based on Groovy scripting
- Starts with `node` block
- More flexible and powerful
- Steeper learning curve

```groovy
node {
    stage('Example') {
        echo 'Hello World'
    }
}
```

### Jenkins Directives

Directives are special statements in declarative pipelines that define various aspects of the pipeline behavior.

#### Environment Directive

The `environment` directive defines environment variables for the pipeline or a specific stage:

```groovy
pipeline {
    agent any
    environment {
        DATABASE_URL = 'jdbc:postgresql://localhost:5432/mydb'
        PYTHON_VERSION = '3.9'
    }
    stages {
        stage('Build') {
            environment {
                // Stage-specific environment variable
                STAGE_ENV = 'build'
            }
            steps {
                echo "Building with Python ${PYTHON_VERSION}"
                sh 'python --version'
                echo "Database URL: ${DATABASE_URL}"
                echo "Stage env: ${STAGE_ENV}"
            }
        }
    }
}
```

Environment variables can also be loaded from credential entries:

```groovy
environment {
    AWS_CREDENTIALS = credentials('aws-credentials')
    // Automatically creates AWS_CREDENTIALS_USR and AWS_CREDENTIALS_PSW
}
```

#### Post Directive

The `post` directive defines actions to be run after the completion of a pipeline or stage. It supports several conditions:

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'python -m pytest'
            }
        }
    }
    post {
        always {
            echo 'This will always run'
            junit 'test-reports/**/*.xml'
        }
        success {
            echo 'This will run only on success'
            archiveArtifacts artifacts: 'dist/**/*.whl', fingerprint: true
        }
        failure {
            echo 'This will run only on failure'
            mail to: 'team@example.com',
                 subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                 body: "Pipeline failure: ${env.BUILD_URL}"
        }
        unstable {
            echo 'This will run only if the build is unstable'
        }
        changed {
            echo 'This will run only if the pipeline state has changed'
        }
    }
}
```

#### Notification Directive

While not a built-in directive, notifications are typically handled through post actions or specialized steps:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
    }
    post {
        success {
            // Email notification
            mail to: 'team@example.com',
                 subject: "Build Successful: ${currentBuild.fullDisplayName}",
                 body: "The build was successful: ${env.BUILD_URL}"
                 
            // Slack notification (requires Slack plugin)
            slackSend channel: '#builds',
                      color: 'good',
                      message: "Build Successful: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
        }
        failure {
            // Email notification
            mail to: 'team@example.com',
                 subject: "Build Failed: ${currentBuild.fullDisplayName}",
                 body: "The build failed: ${env.BUILD_URL}"
                 
            // Slack notification
            slackSend channel: '#builds',
                      color: 'danger',
                      message: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
        }
    }
}
```

For custom notifications, you can create a Python script and call it from Jenkins:

```python
# notify.py
import smtplib
from email.message import EmailMessage
import sys

def send_notification(status, job_name, build_number, build_url):
    msg = EmailMessage()
    msg.set_content(f"Build {status} for {job_name} #{build_number}\nSee details at: {build_url}")
    
    msg['Subject'] = f"Jenkins Build {status}: {job_name} #{build_number}"
    msg['From'] = "jenkins@example.com"
    msg['To'] = "team@example.com"
    
    s = smtplib.SMTP('localhost')
    s.send_message(msg)
    s.quit()

if __name__ == "__main__":
    send_notification(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
```

Then in your Jenkinsfile:

```groovy
post {
    success {
        sh 'python notify.py "SUCCESS" "${JOB_NAME}" "${BUILD_NUMBER}" "${BUILD_URL}"'
    }
    failure {
        sh 'python notify.py "FAILURE" "${JOB_NAME}" "${BUILD_NUMBER}" "${BUILD_URL}"'
    }
}
```

#### Script Block

The `script` block allows executing Groovy code inside a declarative pipeline:

```groovy
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                echo 'Before script block'
                
                script {
                    def languages = ['Python', 'Java', 'JavaScript']
                    for (int i = 0; i < languages.size(); i++) {
                        echo "Language ${i}: ${languages[i]}"
                    }
                    
                    def version = sh(script: 'python --version', returnStdout: true).trim()
                    echo "Python version: ${version}"
                    
                    if (version.contains('3.')) {
                        echo 'Python 3 detected'
                    } else {
                        error 'This pipeline requires Python 3'
                    }
                }
                
                echo 'After script block'
            }
        }
    }
}
```

#### When Directive

The `when` directive controls whether a stage should be executed based on conditions:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Test on Linux') {
            when {
                expression { BRANCH_NAME == 'main' || BRANCH_NAME == 'develop' }
                anyOf {
                    environment name: 'DEPLOY_TO', value: 'production'
                    environment name: 'DEPLOY_TO', value: 'staging'
                }
            }
            steps {
                echo 'Running tests on Linux...'
            }
        }
        stage('Deploy to Production') {
            when {
                branch 'main'
                environment name: 'DEPLOY_TO', value: 'production'
            }
            steps {
                echo 'Deploying to Production...'
            }
        }
        stage('Deploy to Staging') {
            when {
                branch 'develop'
                not { environment name: 'DEPLOY_TO', value: 'production' }
            }
            steps {
                echo 'Deploying to Staging...'
            }
        }
    }
}
```

Common `when` conditions:
- `branch`: Execute when the branch matches the pattern
- `environment`: Execute when an environment variable has a specific value
- `expression`: Execute when the Groovy expression evaluates to true
- `allOf`: Execute when all nested conditions are true
- `anyOf`: Execute when at least one nested condition is true
- `not`: Negate a condition
- `buildingTag`: Execute when building a tag
- `tag`: Execute when the tag name matches the pattern
- `changelog`: Execute when the changelog contains a specific pattern
- `changeset`: Execute when the changeset contains specific files

#### Credentials Directive

The `credentials` binding allows secure access to credentials stored in Jenkins:

```groovy
pipeline {
    agent any
    environment {
        // Bind credentials to environment variables
        AWS_CREDS = credentials('aws-credentials')
        DOCKER_HUB = credentials('docker-hub')
        API_KEY = credentials('api-key')
    }
    stages {
        stage('AWS Operations') {
            steps {
                // Access credentials via environment variables
                sh '''
                    aws configure set aws_access_key_id $AWS_CREDS_USR
                    aws configure set aws_secret_access_key $AWS_CREDS_PSW
                    aws s3 ls
                '''
            }
        }
        stage('Docker Operations') {
            steps {
                sh 'docker login -u $DOCKER_HUB_USR -p $DOCKER_HUB_PSW'
                sh 'docker push myorg/myapp:latest'
            }
        }
        stage('API Call') {
            steps {
                // Using a secret text credential
                sh 'curl -H "Authorization: Bearer $API_KEY" https://api.example.com/resource'
            }
        }
    }
}
```

For more complex credentials handling, you can use the withCredentials step:

```groovy
stage('Complex Credentials') {
    steps {
        withCredentials([
            string(credentialsId: 'api-token', variable: 'TOKEN'),
            usernamePassword(credentialsId: 'db-credentials', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASS'),
            file(credentialsId: 'ssh-key-file', variable: 'SSH_KEY')
        ]) {
            sh 'curl -H "Authorization: Bearer $TOKEN" https://api.example.com/resource'
            sh 'PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -c "SELECT * FROM users"'
            sh 'ssh -i $SSH_KEY user@host.example.com "ls -la"'
        }
    }
}
```

#### Input Directive

The `input` step pauses pipeline execution and waits for human input:

```groovy
pipeline {
    agent any
    stages {
        stage('Build and Test') {
            steps {
                echo 'Building and testing...'
                sh 'python -m pytest'
            }
        }
        stage('Deploy to Production') {
            input {
                message "Deploy to production?"
                ok "Yes, deploy it!"
                parameters {
                    string(name: 'VERSION', defaultValue: '1.0.0', description: 'Version to deploy')
                    choice(name: 'ENVIRONMENT', choices: ['staging', 'production'], description: 'Deployment environment')
                }
            }
            steps {
                echo "Deploying version ${VERSION} to ${ENVIRONMENT}..."
                sh "python deploy.py --version=${VERSION} --env=${ENVIRONMENT}"
            }
        }
    }
}
```

For more complex input scenarios, you can use the input step directly:

```groovy
stage('Approval') {
    steps {
        script {
            def userInput = input(
                id: 'userInput',
                message: 'Select deployment options:',
                parameters: [
                    [
                        $class: 'ChoiceParameterDefinition',
                        choices: ['us-east-1', 'us-west-1', 'eu-west-1'].join('\n'),
                        name: 'REGION',
                        description: 'AWS Region'
                    ],
                    [
                        $class: 'BooleanParameterDefinition',
                        name: 'BACKUP_DB',
                        defaultValue: true,
                        description: 'Backup database before deployment?'
                    ]
                ]
            )
            
            echo "Deploying to ${userInput.REGION}"
            if (userInput.BACKUP_DB) {
                echo "Backing up database..."
            }
        }
    }
}
```

#### Parameters Directive

The `parameters` directive defines parameters that a user can specify when triggering the pipeline:

```groovy
pipeline {
    agent any
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'production'], description: 'Deployment environment')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests?')
        text(name: 'RELEASE_NOTES', defaultValue: '', description: 'Release notes')
        password(name: 'DEPLOY_PASSWORD', defaultValue: '', description: 'Deployment password')
        file(name: 'CONFIG_FILE', description: 'Configuration file')
    }
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out branch: ${params.BRANCH}"
                git branch: "${params.BRANCH}", url: 'https://github.com/username/repo.git'
            }
        }
        stage('Test') {
            when {
                expression { params.RUN_TESTS }
            }
            steps {
                echo 'Running tests...'
                sh 'python -m pytest'
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploying to ${params.ENVIRONMENT}"
                echo "Release notes: ${params.RELEASE_NOTES}"
                sh "python deploy.py --env=${params.ENVIRONMENT} --password=${params.DEPLOY_PASSWORD}"
            }
        }
    }
}
```

In Python, you can access these parameters from environment variables:

```python
# deploy.py
import os
import sys
import argparse

def deploy():
    parser = argparse.ArgumentParser()
    parser.add_argument('--env', required=True, help='Deployment environment')
    parser.add_argument('--password', required=True, help='Deployment password')
    args = parser.parse_args()
    
    print(f"Deploying to {args.env} environment")
    
    # In a real scenario, you would validate the password
    # and perform the actual deployment
    
    return 0

if __name__ == "__main__":
    sys.exit(deploy())
```

#### Stash/Unstash Directives

The `stash` and `unstash` steps allow saving and retrieving files between different stages or nodes:

```groovy
pipeline {
    agent none
    stages {
        stage('Build') {
            agent {
                label 'build-agent'
            }
            steps {
                sh 'pip install -r requirements.txt'
                sh 'python setup.py bdist_wheel'
                // Stash the build artifacts for later use
                stash includes: 'dist/**/*.whl', name: 'wheel'
                stash includes: 'scripts/**', name: 'scripts'
            }
        }
        stage('Test') {
            agent {
                label 'test-agent'
            }
            steps {
                // Unstash the artifacts from the build stage
                unstash 'wheel'
                unstash 'scripts'
                sh 'pip install dist/*.whl'
                sh 'python -m pytest'
            }
        }
        stage('Deploy') {
            agent {
                label 'deploy-agent'
            }
            steps {
                // Unstash the artifacts from the build stage
                unstash 'wheel'
                unstash 'scripts'
                sh 'python scripts/deploy.py'
            }
        }
    }
}
```

The stash and unstash steps have several options:
- `name`: A unique identifier for the stash
- `includes`: Ant-style file pattern of files to stash
- `excludes`: Ant-style file pattern of files to exclude
- `useDefaultExcludes`: Whether to use default excludes (default: true)
- `allowEmpty`: Whether to allow stashing nothing (default: false)

#### Parallel Stages Directive

The `parallel` directive allows running multiple stages concurrently:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        echo 'Running unit tests...'
                        sh 'python -m pytest tests/unit'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        echo 'Running integration tests...'
                        sh 'python -m pytest tests/integration'
                    }
                }
                stage('Performance Tests') {
                    steps {
                        echo 'Running performance tests...'
                        sh 'python -m pytest tests/performance'
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }
}
```

You can also specify a `failFast` option to abort all parallel stages if one fails:

```groovy
stage('Parallel Tests') {
    failFast true
    parallel {
        stage('Unit Tests') {
            // ...
        }
        stage('Integration Tests') {
            // ...
        }
    }
}
```

For more complex parallel execution, you can generate stages dynamically:

```groovy
stage('Parallel Tests') {
    steps {
        script {
            def testTypes = ['unit', 'integration', 'performance', 'security']
            def parallelStages = [:]
            
            for (type in testTypes) {
                def testType = type  // Local variable for closure
                parallelStages[testType] = {
                    echo "Running ${testType} tests..."
                    sh "python -m pytest tests/${testType}"
                }
            }
            
            parallel parallelStages
        }
    }
}
```

## Additional Pipeline Configuration

### Triggers

Pipeline triggers define how your pipeline is automatically started:

```groovy
pipeline {
    agent any
    triggers {
        // Run every day at midnight
        cron('0 0 * * *')
        
        // Poll SCM every 15 minutes
        pollSCM('H/15 * * * *')
        
        // Trigger when upstream job 'upstream-job' completes
        upstream(upstreamProjects: 'upstream-job', threshold: hudson.model.Result.SUCCESS)
    }
    stages {
        // ...
    }
}
```

Common trigger types:
- `cron`: Schedule jobs using cron syntax
- `pollSCM`: Check for changes in the SCM on a schedule
- `upstream`: Trigger when upstream jobs complete
- `githubPush`: Trigger on GitHub push events (requires GitHub plugin)

### Options

Pipeline options modify pipeline behavior:

```groovy
pipeline {
    agent any
    options {
        // Set a timeout for the entire pipeline
        timeout(time: 1, unit: 'HOURS')
        
        // Discard old builds, keeping only the 10 most recent
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Don't run concurrent builds
        disableConcurrentBuilds()
        
        // Add timestamps to console output
        timestamps()
        
        // Skip the default checkout
        skipDefaultCheckout()
        
        // Preserve stashes from completed builds
        preserveStashes(buildCount: 5)
    }
    stages {
        // ...
    }
}
```

You can also set options for a specific stage:

```groovy
stage('Deploy') {
    options {
        timeout(time: 30, unit: 'MINUTES')
        retry(3)
    }
    steps {
        // ...
    }
}
```

### Tools

The `tools` directive configures tools that are pre-installed and configured in Jenkins:

```groovy
pipeline {
    agent any
    tools {
        maven 'Maven 3.8.1'
        jdk 'JDK 11'
        python 'Python 3.9'
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn --version'
                sh 'java -version'
                sh 'python --version'
            }
        }
    }
}
```

For tools to be available, they must be configured in Jenkins under "Manage Jenkins" > "Global Tool Configuration".

### Agent Configuration

The `agent` directive specifies where and how your pipeline runs:

```groovy
pipeline {
    // Run on any available agent
    agent any
    
    stages {
        stage('Build on Specific Node') {
            // Run on a specific labeled agent
            agent {
                label 'linux-build-agent'
            }
            steps {
                // ...
            }
        }
        
        stage('Build in Docker') {
            // Run in a Docker container
            agent {
                docker {
                    image 'python:3.9'
                    args '-v /tmp:/tmp'
                }
            }
            steps {
                sh 'python --version'
            }
        }
        
        stage('Build with Docker and Custom Agent') {
            // Run a Docker container on a specific agent
            agent {
                docker {
                    image 'node:14'
                    label 'docker-capable-agent'
                }
            }
            steps {
                sh 'node --version'
            }
        }
        
        stage('Build on Kubernetes') {
            // Run on Kubernetes pod
            agent {
                kubernetes {
                    yaml '''
                    apiVersion: v1
                    kind: Pod
                    spec:
                      containers:
                      - name: python
                        image: python:3.9
                        command:
                        - cat
                        tty: true
                    '''
                    defaultContainer 'python'
                }
            }
            steps {
                sh 'python --version'
            }
        }
    }
}
```

## Pipeline Scripts from SCM

### Setting Up Pipeline Scripts from SCM

Pipeline Scripts from SCM (Source Control Management) allow you to define your Jenkins Pipeline in a `Jenkinsfile` that's checked into your source code repository. This approach follows the "Pipeline as Code" principle, where your pipeline configuration is treated like any other piece of code.

Steps to set up a Pipeline from SCM:

1. **Create a Jenkinsfile**: Create a file named `Jenkinsfile` in the root of your repository. This file will contain your pipeline definition.

2. **Configure Jenkins Job**:
   - In Jenkins, click on "New Item"
   - Enter a name for your job and select "Pipeline"
   - Click "OK"
   - Scroll down to the "Pipeline" section
   - Select "Pipeline script from SCM" from the "Definition" dropdown
   - Select your SCM (Git, Subversion, etc.)
   - Enter your repository URL
   - Specify the branch to build (e.g., `*/main`)
   - Set the "Script Path" to the location of your Jenkinsfile (default is `Jenkinsfile` at the root)
   - Click "Save"

3. **Run Your Pipeline**: Jenkins will now pull your Jenkinsfile from your repository and execute the pipeline as defined.

Here's an example Jenkinsfile for a Python project:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Python Environment') {
            steps {
                sh '''
                python -m venv venv
                . venv/bin/activate
                pip install -r requirements.txt
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                . venv/bin/activate
                pytest --junitxml=test-results.xml
                '''
            }
            post {
                always {
                    junit 'test-results.xml'
                }
            }
        }
        
        stage('Build Distribution') {
            steps {
                sh '''
                . venv/bin/activate
                python setup.py sdist bdist_wheel
                '''
            }
            post {
                success {
                    archiveArtifacts artifacts: 'dist/*', fingerprint: true
                }
            }
        }
    }
}
```

### Best Practices for Pipeline Scripts from SCM

1. **Version Control**: Always keep your Jenkinsfile in the same repository as your application code to ensure they stay in sync.

2. **Validate Jenkinsfile**: Use the Jenkins Pipeline Linter to validate your Jenkinsfile syntax before committing:
   ```bash
   curl -X POST -F "jenkinsfile=<Jenkinsfile" http://your-jenkins-url/pipeline-model-converter/validate
   ```

3. **Use Multibranch Pipelines**: For projects with multiple branches, use Multibranch Pipeline jobs that automatically discover branches and pull requests:
   - Create a new item of type "Multibranch Pipeline"
   - Configure the branch sources (e.g., GitHub)
   - Jenkins will automatically scan the repository and create pipelines for branches containing a Jenkinsfile

4. **Script Security**: Be aware of script security in Jenkins. New methods or classes might need approval from an administrator.

5. **Keep Jenkinsfiles DRY**: Use shared libraries to avoid duplicating code across multiple Jenkinsfiles.

## Creating a Pipeline with Parameters

Parameters allow users to provide input to a pipeline when it runs. This is useful for making pipelines more flexible and reusable.

### Types of Parameters

Jenkins supports several parameter types:

- **String Parameter**: A simple text field
- **Choice Parameter**: A dropdown menu with predefined options
- **Boolean Parameter**: A checkbox
- **File Parameter**: Allows uploading a file
- **Password Parameter**: A password field that masks input
- **Multi-line String Parameter**: For longer text inputs
- **Run Parameter**: Selects a specific build of another project
- **Git Parameter**: Selects a Git branch or tag

### Defining Parameters in Jenkinsfile

Parameters are defined in the `parameters` block within a Declarative Pipeline:

```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'PYTHON_VERSION', defaultValue: '3.9', description: 'Python version to use')
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests?')
        password(name: 'DEPLOY_KEY', defaultValue: '', description: 'Deployment key')
    }
    
    stages {
        stage('Setup') {
            steps {
                echo "Setting up with Python ${params.PYTHON_VERSION}"
            }
        }
        
        stage('Test') {
            when {
                expression { params.RUN_TESTS == true }
            }
            steps {
                echo "Running tests for ${params.ENV} environment"
            }
        }
        
        stage('Deploy') {
            steps {
                echo "Deploying to ${params.ENV}"
                // Use params.DEPLOY_KEY for authentication
            }
        }
    }
}
```

### Accessing Parameters in Pipeline

Parameters are accessed using the `params` object in both Declarative and Scripted Pipelines:

- Declarative: `${params.PARAMETER_NAME}` or `params.PARAMETER_NAME`
- Scripted: `params.PARAMETER_NAME`

Example of a Python script that uses pipeline parameters:

```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'API_ENDPOINT', defaultValue: 'https://api.example.com', description: 'API endpoint to test')
        string(name: 'TIMEOUT', defaultValue: '30', description: 'API timeout in seconds')
    }
    
    stages {
        stage('Run API Test') {
            steps {
                sh """
                python3 -c "
import requests
import sys

try:
    response = requests.get('${params.API_ENDPOINT}', timeout=${params.TIMEOUT})
    print(f'Status code: {response.status_code}')
    response.raise_for_status()
    print('API test successful')
    sys.exit(0)
except Exception as e:
    print(f'API test failed: {e}')
    sys.exit(1)
"
                """
            }
        }
    }
}
```

## Blue Ocean Plugin

### Installing Blue Ocean

Blue Ocean is a modern, visual pipeline editor and execution interface for Jenkins. It provides a more intuitive and visual way to work with pipelines.

To install Blue Ocean:

1. Navigate to "Manage Jenkins" > "Plugins" > "Available Plugins"
2. Search for "Blue Ocean"
3. Select "Blue Ocean" and click "Install without restart"
4. After installation, you'll see a "Blue Ocean" link in your Jenkins sidebar

Alternatively, you can install Blue Ocean using the Jenkins CLI:

```bash
java -jar jenkins-cli.jar -s http://your-jenkins-url -auth username:apitoken install-plugin blueocean
```

### Using Blue Ocean Interface

Once installed, you can access Blue Ocean by:

1. Clicking on the "Blue Ocean" link in the Jenkins sidebar
2. Or by navigating to `http://your-jenkins-url/blue`

The Blue Ocean interface provides:

- A visual dashboard of pipelines
- Detailed pipeline run information with visualizations
- Pipeline stage and step details
- Test and artifact information
- Branch and pull request status

### Creating Pipelines with Blue Ocean

Blue Ocean provides a visual pipeline editor that allows you to create Jenkinsfiles without writing code.

To create a new pipeline with Blue Ocean:

1. Open Blue Ocean
2. Click "Create a new Pipeline"
3. Select your source code repository (GitHub, Bitbucket, etc.)
4. Authorize Jenkins to access your repository
5. Select the repository to create a pipeline for
6. Blue Ocean will create a Jenkinsfile in your repository

The visual editor allows you to:
- Add stages and parallel stages
- Add steps within stages
- Configure environment variables
- Set up post-stage actions
- Add conditionals and other pipeline features

After creating your pipeline visually, Blue Ocean will commit the generated Jenkinsfile to your repository.

## Advanced Pipeline Techniques

### Parallel Execution

Jenkins Pipelines support running steps in parallel, which can significantly reduce build times.

Example of parallel execution:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh '''
                        python -m pytest tests/unit --junitxml=unit-results.xml
                        '''
                    }
                    post {
                        always {
                            junit 'unit-results.xml'
                        }
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh '''
                        python -m pytest tests/integration --junitxml=integration-results.xml
                        '''
                    }
                    post {
                        always {
                            junit 'integration-results.xml'
                        }
                    }
                }
                stage('Performance Tests') {
                    steps {
                        sh '''
                        python performance_tests.py
                        '''
                    }
                }
            }
        }
    }
}
```

### Pipeline Visualization

Jenkins provides several ways to visualize your pipeline execution:

1. **Stage View**: The classic Jenkins Pipeline view that shows stages as columns
2. **Blue Ocean**: Provides a more modern and detailed visualization
3. **Pipeline Graph View**: Displays the pipeline as a graph

You can also generate custom visualizations of your pipeline structure using Mermaid.js:

```mermaid
graph LR
    A[Checkout] --> B[Setup]
    B --> C[Build]
    C --> D{Tests}
    D --> E[Unit Tests]
    D --> F[Integration Tests]
    D --> G[UI Tests]
    E --> H[Deploy]
    F --> H
    G --> H
```

### Using Shared Libraries

Shared Libraries allow you to define reusable code that can be used across multiple pipelines.

To use a shared library:

1. Configure the shared library in Jenkins:
   - Go to "Manage Jenkins" > "Configure System"
   - Scroll to "Global Pipeline Libraries"
   - Add a library with a name, default version, and SCM information

2. Use the library in your Jenkinsfile:

```groovy
@Library('my-shared-library') _

pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                // Call a function from the shared library
                pythonBuild()
            }
        }
        stage('Test') {
            steps {
                // Call another function with parameters
                pythonTest(framework: 'pytest', coverage: true)
            }
        }
    }
}
```

Example of a shared library function for Python projects:

```groovy
// vars/pythonBuild.groovy
def call() {
    sh '''
    python -m venv venv
    . venv/bin/activate
    pip install -r requirements.txt
    python setup.py build
    '''
}

// vars/pythonTest.groovy
def call(Map config) {
    def framework = config.framework ?: 'pytest'
    def coverage = config.coverage ?: false
    
    if (framework == 'pytest') {
        if (coverage) {
            sh '''
            . venv/bin/activate
            python -m pytest --cov=./ --cov-report=xml
            '''
        } else {
            sh '''
            . venv/bin/activate
            python -m pytest
            '''
        }
    } else if (framework == 'unittest') {
        sh '''
        . venv/bin/activate
        python -m unittest discover
        '''
    }
}
```

## Troubleshooting Jenkins Pipelines

Common issues and their solutions:

1. **Pipeline Syntax Errors**:
   - Use the Pipeline Syntax Generator: Access it via `http://your-jenkins-url/pipeline-syntax/`
   - Use the Pipeline Linter

2. **Agent Selection Issues**:
   - Ensure the specified agent exists and is connected
   - Check agent labels match those in your pipeline

3. **Environment Variable Problems**:
   - Print environment variables for debugging:
     ```groovy
     stage('Debug') {
         steps {
             sh 'env | sort'
         }
     }
     ```

4. **Script Security Errors**:
   - Methods may need approval in the script security system
   - Navigate to "Manage Jenkins" > "In-process Script Approval"

5. **Pipeline Timeout Handling**:
   - Add timeouts to prevent jobs from hanging:
     ```groovy
     stage('Deploy') {
         options {
             timeout(time: 30, unit: 'MINUTES')
         }
         steps {
             // Deployment steps
         }
     }
     ```

## Example Python Projects with Jenkins Pipelines

### Example 1: Python Web Application with Flask

```groovy
pipeline {
    agent any
    
    parameters {
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Version to deploy')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh '''
                python -m venv venv
                . venv/bin/activate
                pip install -r requirements.txt
                '''
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh '''
                        . venv/bin/activate
                        pytest tests/unit --junitxml=unit-results.xml
                        '''
                    }
                    post {
                        always {
                            junit 'unit-results.xml'
                        }
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh '''
                        . venv/bin/activate
                        pytest tests/integration --junitxml=integration-results.xml
                        '''
                    }
                    post {
                        always {
                            junit 'integration-results.xml'
                        }
                    }
                }
            }
        }
        
        stage('Static Analysis') {
            steps {
                sh '''
                . venv/bin/activate
                flake8 app
                bandit -r app
                safety check
                '''
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                . venv/bin/activate
                python setup.py sdist bdist_wheel
                '''
            }
            post {
                success {
                    archiveArtifacts artifacts: 'dist/*', fingerprint: true
                }
            }
        }
        
        stage('Deploy') {
            when {
                expression { params.ENV != 'prod' || currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                sh """
                . venv/bin/activate
                
                # Example Python deployment script
                python -c "
import os
import sys

env = '${params.ENV}'
version = '${params.VERSION}'

print(f'Deploying version {version} to {env} environment')

# Simulating deployment steps
if env == 'dev':
    print('Deploying to development server')
    # deployment_command_for_dev
elif env == 'staging':
    print('Deploying to staging server')
    # deployment_command_for_staging
elif env == 'prod':
    print('Deploying to production server')
    # deployment_command_for_prod
else:
    print(f'Unknown environment: {env}')
    sys.exit(1)

print('Deployment completed successfully')
"
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
```

### Example 2: Data Science Pipeline with Python

```groovy
pipeline {
    agent {
        docker {
            image 'python:3.9'
        }
    }
    
    parameters {
        string(name: 'MODEL_VERSION', defaultValue: '1.0.0', description: 'Model version')
        choice(name: 'DATASET', choices: ['small', 'medium', 'full'], description: 'Dataset size')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Environment') {
            steps {
                sh '''
                pip install -r requirements.txt
                '''
            }
        }
        
        stage('Prepare Data') {
            steps {
                sh """
                python data_preparation.py --dataset=${params.DATASET}
                """
            }
            post {
                success {
                    archiveArtifacts artifacts: 'data/processed/*.csv', fingerprint: true
                }
            }
        }
        
        stage('Train Model') {
            steps {
                sh """
                python train_model.py --dataset=${params.DATASET} --version=${params.MODEL_VERSION}
                """
            }
            post {
                success {
                    archiveArtifacts artifacts: 'models/*.pkl', fingerprint: true
                }
            }
        }
        
        stage('Evaluate Model') {
            steps {
                sh """
                python evaluate_model.py --version=${params.MODEL_VERSION}
                """
            }
            post {
                always {
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'reports',
                        reportFiles: 'evaluation.html',
                        reportName: 'Model Evaluation Report'
                    ])
                }
            }
        }
        
        stage('Deploy Model') {
            when {
                branch 'main'
            }
            steps {
                sh """
                python deploy_model.py --version=${params.MODEL_VERSION}
                """
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'logs/*.log', fingerprint: true
        }
    }
}
```