pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SAST - SonarQube') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    script {
                        def scannerHome = tool 'sonar-scanner'
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('SCA - Dependency Check (Docker)') {
            steps {
                sh '''
                docker run --rm \
                  -v "$PWD:/src" \
                  owasp/dependency-check:latest \
                  --scan /src/docs \
                  --format HTML \
                  --out /src
                '''
            }
        }

        stage('Publish SCA Report') {
            steps {
                publishHTML(target: [
                    reportDir: '.',
                    reportFiles: 'dependency-check-report.html',
                    reportName: 'OWASP Dependency Check Report'
                ])
            }
        }

        stage('Pipeline Complete') {
            steps {
                echo 'CI + SAST + SCA completed successfully'
            }
        }
    }

    post {
        success {
            echo 'DevSecOps pipeline SUCCESS'
        }
        failure {
            echo 'DevSecOps pipeline FAILED'
        }
        always {
            cleanWs()
        }
    }
}
