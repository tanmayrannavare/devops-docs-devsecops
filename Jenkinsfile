pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Docs') {
            steps {
                sh '''
                  echo "Listing docs directory:"
                  ls docs
                '''
            }
        }

        stage('CI Complete') {
            steps {
                echo 'CI pipeline completed successfully'
            }
        }
    }
}
