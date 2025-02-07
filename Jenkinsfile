pipeline {
    agent any

     environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/ranjanniket/bran.git'
            }
        }

        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=bran \
                    -Dsonar.projectKey=bran'''
                }
            }
        }

        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build ") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "echo 'Buid Docker Image'"
                        sh "docker build -t niket50/bran:${BUILD_NUMBER} ."
                    }
                }
            }
        }

        stage("Push Artifacts") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "echo 'Push to Registry'"
                        sh "docker push niket50/bran:${BUILD_NUMBER}"
                    }
                }
            }
        }


        stage("TRIVY") {
            steps {
                sh "trivy image -f json -o trivyimage.txt niket50/bran:${BUILD_NUMBER}"
            }
        }
        
        stage('Clone & Update Deployment File') {
            steps {
                script {
                    sh '''
                        git clone git@github.com:ranjanniket/bran_manifest.git
                        cd bran_manifest/
                        pwd
                        ls
                        cat deployment.yaml
                        sed -i "s/niket50\\/bran:.*/niket50\\/bran:${BUILD_NUMBER}/" deployment.yaml
                        cat deployment.yaml
                        git add deployment.yaml
                        git commit -m 'Update image tag to ${BUILD_NUMBER}'
                        git remote -v
                        git push origin main
                    '''      
                }
            }
        }

    }


    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}'",
                body: "Project: ${env.JOB_NAME}<br/>" +
                    "Build Number: ${env.BUILD_NUMBER}<br/>" +
                    "URL: ${env.BUILD_URL}<br/>",
                to: 'niketranjan50@gmail.com',
                attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
}

