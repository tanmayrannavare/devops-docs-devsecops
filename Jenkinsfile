pipeline {
    agent any

    stages {

        /* =========================
           SOURCE CODE CHECKOUT
           ========================= */
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        /* =========================
           SAST – SONARQUBE
           ========================= */
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

        /* =========================
           QUALITY GATE
           ========================= */
        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* =========================
           SCA – OWASP DEPENDENCY CHECK
           ========================= */
        stage('SCA - Dependency Check') {
            steps {
                dependencyCheck(
                    odcInstallation: 'dependency-check',
                    scanPath: 'docs',
                    format: 'HTML',
                    failOnCVSS: 7
                )
            }
        }

        /* =========================
           PUBLISH SCA REPORT
           ========================= */
        stage('Publish SCA Report') {
            steps {
                dependencyCheckPublisher pattern: '**/dependency-check-report.html'
            }
        }

        /* =========================
           PIPELINE COMPLETE
           ========================= */
        stage('Pipeline Complete') {
            steps {
                echo '✅ CI + SAST + SCA pipeline completed successfully'
            }
        }
    }

    /* =========================
       POST ACTIONS
       ========================= */
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
