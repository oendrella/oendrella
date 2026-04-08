pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '388370472854.dkr.ecr.us-east-1.amazonaws.com/my-app'
    }
    stages {
        stage('Terraform Apply') {
            steps {
                sh 'terraform init -reconfigure'
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Build & Push Image (Kaniko)') {
            steps {
                // Example: run Kaniko in EKS pod or CodeBuild
                sh '''
                kubectl apply -f kaniko.yaml
                '''
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
}
