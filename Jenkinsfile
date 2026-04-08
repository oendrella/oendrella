pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO   = '388370472854.dkr.ecr.us-east-1.amazonaws.com/nginx-app'
    }
    stages {
        stage('Test') {
            steps {
                echo "Hello from Jenkins pipeline"
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init -reconfigure'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Build & Push Image (Kaniko)') {
            steps {
                sh 'kubectl apply -f kaniko-job.yaml'
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'
            }
        }
    }
}
