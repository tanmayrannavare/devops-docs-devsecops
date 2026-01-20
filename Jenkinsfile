pipeline {
    agent any

    environment {
        IMAGE_NAME    = "devsecops-portal"
        IMAGE_TAG     = "${BUILD_NUMBER}"
        SONAR_SCANNER = tool 'sonar-scanner'
        DEP_CHECK     = tool 'dependency-check'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:tanmayrannavare/devops-docs-devsecops.git'
            }
        }

        stage('SAST - SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh "${SONAR_SCANNER}/bin/sonar-scanner"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('SCA - Dependency Check') {
            steps {
                sh '''
                  ${DEP_CHECK}/bin/dependency-check.sh \
                  --scan . \
                  --format HTML \
                  --out dependency-report
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Container Scan - Trivy') {
            steps {
                sh '''
                  trivy image \
                    --exit-code 1 \
                    --severity HIGH,CRITICAL \
                    ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy for DAST') {
            steps {
                sh '''
                  docker rm -f zap-target || true
                  docker run -d -p 8081:80 \
                    --name zap-target \
                    ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('DAST - OWASP ZAP') {
            steps {
                sh '''
                  chmod -R 777 .
                  docker run --rm \
                    -v $(pwd):/zap/wrk \
                    -t zaproxy/zap-stable \
                    zap-baseline.py \
                    -t http://localhost:8081 \
                    -r zap-report.html || true
                '''
            }
        }

        stage('Cleanup DAST') {
            steps {
                sh 'docker rm -f zap-target || true'
            }
        }
    }

    post {
        always {
            script {
                if (fileExists('dependency-report')) {
                    archiveArtifacts artifacts: 'dependency-report/**'
                }
                if (fileExists('zap-report.html')) {
                    archiveArtifacts artifacts: 'zap-report.*'
                }
            }
        }
    }
}
