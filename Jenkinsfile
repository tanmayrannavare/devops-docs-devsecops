pipeline {
    agent any

    tools {
        // Defining tools here keeps the stages cleaner
        scannerHome 'sonar-scanner'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out source code..."
                    checkout scm
                }
            }
        }

        stage('SAST - SonarQube') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    script {
                        // Using the tool name defined in Jenkins Global Tool Configuration
                        def scannerPath = tool 'sonar-scanner'
                        sh "${scannerPath}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Increased timeout slightly; SonarQube background tasks can sometimes take a moment
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('SCA - Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '''
                    --scan ./ 
                    --format HTML 
                    --format JSON
                    --failOnCVSS 7
                ''',
                odcInstallation: 'dependency-check'
            }
        }

        stage('Publish Reports') {
            steps {
                // Grouping report publishing makes the pipeline easier to read
                dependencyCheckPublisher pattern: '**/dependency-check-report.html'
                echo 'Security reports have been published.'
            }
        }

        stage('CI Complete') {
            steps {
                echo 'CI, SAST, and SCA completed successfully.'
            }
        }
    }

    post {
        always {
            // Clean up workspace to save disk space on the agent
            cleanWs()
        }
        failure {
            echo 'Pipeline failed. Please check the SonarQube Quality Gate or Dependency Check logs.'
        }
    }
}
