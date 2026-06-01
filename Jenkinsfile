pipeline {
  agent any

  environment {
    IMAGE = "durrello/portfolio-app"
    TAG   = "${env.BUILD_NUMBER}"
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build image') {
      steps {
        script {
          dockerImage = docker.build("${IMAGE}:${TAG}", "-f Dockerfile .")
        }
      }
    }

    stage('Test') {
      steps {
        sh 'chmod +x test.sh && ./test.sh'
      }
    }

    stage('Push to Docker Hub') {
      when { branch 'main' }
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
            dockerImage.push("${TAG}")
            dockerImage.push('latest')
          }
        }
      }
    }
  }

  post {
    success {
      slackSend(
        channel: '#ci',
        color: 'good',
        message: "✅ ${IMAGE}:${TAG} built & pushed — ${env.BUILD_URL}"
      )
    }
    failure {
      slackSend(
        channel: '#ci',
        color: 'danger',
        message: "❌ Build ${env.BUILD_NUMBER} failed — ${env.BUILD_URL}"
      )
    }
  }
}
