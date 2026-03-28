pipeline {
  agent any

  environment {
    AWS_REGION    = "ap-south-1"
    ECR_REGISTRY  = "149903054702.dkr.ecr.${AWS_REGION}.amazonaws.com"
    ECR_BACKEND   = "${ECR_REGISTRY}/devops-app-backend"
    ECR_FRONTEND  = "${ECR_REGISTRY}/devops-app-frontend"
    IMAGE_TAG     = "${BUILD_NUMBER}"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main',
            url: 'https://github.com/Vikas-Abhimanyu/devops-eks-assignment.git'
      }
    }

    stage('Fetch Terraform Outputs') {
      steps {
        script {
          sh '''
            cd terraform
            terraform init -backend-config="region=ap-south-1"
          '''
          env.RDS_ENDPOINT = sh(
            script: 'cd terraform && terraform output -raw rds_endpoint',
            returnStdout: true
          ).trim()
        }
      }
    }

    stage('Build Backend Image') {
      steps {
        sh "docker build -t ${ECR_BACKEND}:${IMAGE_TAG} ./backend"
      }
    }

    stage('Build Frontend Image') {
      steps {
        sh "docker build -t ${ECR_FRONTEND}:${IMAGE_TAG} ./frontend"
      }
    }

    stage('Login to ECR') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            aws ecr get-login-password --region ${AWS_REGION} \
            | docker login --username AWS --password-stdin ${ECR_REGISTRY}
          '''
        }
      }
    }

    stage('Push Images') {
      steps {
        sh "docker push ${ECR_BACKEND}:${IMAGE_TAG}"
        sh "docker push ${ECR_FRONTEND}:${IMAGE_TAG}"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh """
            aws eks update-kubeconfig --region ${AWS_REGION} --name devops-eks

            kubectl apply -f k8s/ 

            kubectl set image deployment/backend backend=${ECR_BACKEND}:${IMAGE_TAG} -n default
            kubectl set image deployment/frontend frontend=${ECR_FRONTEND}:${IMAGE_TAG} -n default

            kubectl set env deployment/backend DB_HOST=${RDS_ENDPOINT} -n default

            kubectl rollout status deployment/backend -n default
            kubectl rollout status deployment/frontend -n default
          """
        }
      }
    }
  }

  post {
    success { echo "Deployment successful" }
    failure { echo "Pipeline failed" }
  }
}
