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
                        sh """
                          ${scannerHome}/bin/sonar-scanner
                        """
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
                dependencyCheck additionalArguments: '''
                    --scan docs
                    --format HTML
                    --failOnCVSS 7
                ''',
                odcInstallation: 'dependency-check'
            }
        }

        stage('Publish SCA Report') {
            steps {
                dependencyCheckPublisher pattern: '**/dependency-check-report.html'
            }
        }

        stage('Pipeline Complete') {
            steps {
                echo 'CI + SAST + SCA completed successfully'
            }
        }
    }
}
