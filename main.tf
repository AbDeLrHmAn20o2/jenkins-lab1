terraform {
  required_providers {
    jenkins = {
      source  = "taiidani/jenkins"
      version = "~> 0.10"
    }
  }
}

provider "jenkins" {
  server_url = "http://localhost:8080"

  username = var.username
  password = var.api_token
}

resource "jenkins_job" "first_pipeline" {

  name = "first-pipeline"

  template = <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
    <actions/>
    <description>Created by Terraform</description>
    <keepDependencies>false</keepDependencies>

    <properties/>

    <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition">

        <script>

pipeline {

    agent any

    parameters {

        choice(
            name: 'ENVIRONMENT',
            choices: ['dev','stg','prod'],
            description: 'Select Environment'
        )

    }

    stages {

        stage('Hello World') {

            steps {

                echo "Hello World from $${params.ENVIRONMENT}"

            }

        }

        stage('Hello Jenkins') {

            steps {

                echo "Hello Jenkins from $${params.ENVIRONMENT}"

                error("Testing Email Notification")

            }

        }

    }

    post {

        success {

            echo "Pipeline completed successfully!"

        }

        failure {

    echo "Pipeline failed!"

    emailext(
        to: 'bedo2meme@gmail.com',
        subject: "Build Failed: $${env.JOB_NAME}",
        body: """Job: $${env.JOB_NAME}

Build Number: $${env.BUILD_NUMBER}

Status: FAILED

Build URL:
$${env.BUILD_URL}
"""
    )

}

    }

}

        </script>

        <sandbox>true</sandbox>

    </definition>

    <triggers/>

    <disabled>false</disabled>

</flow-definition>

EOF
}