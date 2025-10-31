
pipeline {
  agent any

  environment {
    PYTHON = 'python3'
    DOCKER_IMAGE = 'expetra/budget-analyzer:ci'
    DOCKERHUB_CREDENTIALS = 'dockerhub-creds' // set in Jenkins → Credentials (optional)
    PUSH_IMAGE = 'false'   // set to 'true' to push
    RUN_DEPLOY = 'false'   // set to 'true' to deploy locally on the Jenkins node
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install deps') {
      steps {
        sh '''
          ${PYTHON} -m venv .venv
          . .venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements.txt
        '''
      }
    }

    stage('Run tests') {
      steps {
        sh '''
          . .venv/bin/activate
          pytest -q
        '''
      }
    }

    stage('Docker build') {
      steps {
        sh 'docker build -t ${DOCKER_IMAGE} .'
      }
    }

    stage('Docker push (optional)') {
      when { expression { return env.PUSH_IMAGE == 'true' } }
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${DOCKER_IMAGE}
            docker logout
          '''
        }
      }
    }

    stage('Deploy (optional)') {
      when { expression { return env.RUN_DEPLOY == 'true' } }
      steps {
        sh '''
          chmod +x deploy.sh
          DOCKER_IMAGE=${DOCKER_IMAGE} ./deploy.sh
          docker logs budget-analyzer --since 5s || true
        '''
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: '**/pytest.xml'
      archiveArtifacts artifacts: 'Dockerfile, Jenkinsfile, deploy.sh, budget_analyzer.py, tests/**, requirements.txt, README.md', fingerprint: true
    }
  }
}
