pipeline {
    agent any

    environment {
        IMAGE_NAME = "devsecops-portal"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/tanmayrannavare/devops-docs-devsecops.git'
            }
        }

        stage('SAST - SonarQube Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('SonarQube-Server') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                    waitForQualityGate abortPipeline: true
                }
            }

        stage('SCA - Dependency Check') {
            steps {
                script {
                    def dc = tool 'dependency-check'
                    sh """
                      ${dc}/bin/dependency-check.sh \
                        --scan . \
                        --format HTML \
                        --out dependency-report
                    """
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Container Scan - Trivy') {
            steps {
                sh """
                  trivy image \
                    --exit-code 1 \
                    --severity HIGH,CRITICAL \
                    ${IMAGE_NAME}:${IMAGE_TAG}
                """
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
                    zaproxy/zap-stable \
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
                    archiveArtifacts 'dependency-report/**'
                }
                if (fileExists('zap-report.html')) {
                    archiveArtifacts 'zap-report.*'
                }
            }
        }

        success {
            echo "✅ DevSecOps pipeline completed successfully"
        }

        failure {
            echo "❌ Pipeline failed due to Quality Gate or security issues"
        }
    }
}
