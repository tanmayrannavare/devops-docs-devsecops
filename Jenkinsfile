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

        stage('SCA - Dependency Check') {
            steps {
                dependencyCheck(
                    odcInstallation: 'dependency-check',
                    additionalArguments: '''
                        --scan docs
                        --format HTML
                        --failOnCVSS 7
                    '''
                )
            }
        }

        stage('Publish SCA Report') {
            steps {
                dependencyCheckPublisher pattern: '**/dependency-check-report.html'
            }
        }

        stage('Pipeline Complete') {
            steps {
                echo '✅ CI + SAST + SCA completed successfully'
            }
        }
    }

    post {
        success {
            echo '🎉 DevSecOps pipeline SUCCESS'
        }
        failure {
            echo '❌ DevSecOps pipeline FAILED – check security gates'
        }
        always {
            cleanWs()
        }
    }
}
