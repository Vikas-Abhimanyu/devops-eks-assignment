pipeline {
  agent any

  environment {
    AWS_REGION = "ap-south-1"
    ECR_REPO   = "149903054702.dkr.ecr.${AWS_REGION}.amazonaws.com/devops-app"
    K8S_MANIFESTS = "k8s/"
  }

  stages {
    stage('Terraform Init & Apply') {
      steps {
        dir('terraform') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-creds'
          ]]) {
            sh '''
              terraform init -backend-config="bucket=my-terraform-state" \
                             -backend-config="key=eks/terraform.tfstate" \
                             -backend-config="region=${AWS_REGION}"
              terraform plan -out=tfplan
              terraform apply -auto-approve tfplan
            '''
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        script {
          sh '''
            docker build -t ${ECR_REPO}:latest ./backend
            docker build -t ${ECR_REPO}-frontend:latest ./frontend
          '''
        }
      }
    }

    stage('Docker Push to ECR') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-creds'
        ]]) {
          sh '''
            aws ecr get-login-password --region ${AWS_REGION} \
              | docker login --username AWS --password-stdin ${ECR_REPO}

            docker push ${ECR_REPO}:latest
            docker push ${ECR_REPO}-frontend:latest
          '''
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-creds'
        ]]) {
          sh '''
            # Ensure kubeconfig is set up (Ansible can bootstrap this)
            aws eks update-kubeconfig --region ${AWS_REGION} --name my-eks-cluster

            kubectl apply -f ${K8S_MANIFESTS}
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline completed successfully: Infra provisioned, images built/pushed, app deployed."
    }
    failure {
      echo "Pipeline failed. Check logs."
    }
  }
}

