pipeline {
    agent any

    stages {

        /* =========================
           CHECKOUT SOURCE
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
                        sh "${scannerHome}/bin/sonar-scanner"
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
           (PLUGIN-COMPATIBLE SYNTAX)
           ========================= */
        stage('SCA - Dependency Check') {
            steps {
                dependencyCheck(
                    odcInstallation: 'dependency-check',
                    additionalArguments: '''
                        --scan docs
                        --format HTML
                        --failOnCVSS 7
