pipeline {
    agent any

    environment {
    sonarscannerdotnet = tool name : 'sonar_scanner_dotnet', type:'hudson.plugins.sonar.MsBuildSQRunnerInstallation'
    username = 'karangoel'
    }

    stages{
        stage('Intial information') {
            steps {
                echo "Hello, I am in ${GIT_BRANCH} environment"
            }
        }
        stage('Restore packages') {
           steps {
                echo 'Restoring packages'
                bat "dotnet restore WebApplication4.sln"
            }
        }
        stage('Clean') {
            steps {
                echo 'Cleaning code'
                bat "dotnet clean WebApplication4.sln"
            }
        }
        stage('Starting Sonarqube') {
            steps {
                echo 'Starting sonar analysis'
                withSonarQubeEnv('Test_Sonar') {
                    bat "dotnet ${sonarscannerdotnet}\\SonarScanner.MSBuild.dll begin /k:WebApplication4"
                }
            }
        }
        stage('Build') {
            steps {
                echo 'Building code'
                bat "dotnet build WebApplication4.sln --configuration Release"
            }
        }
        stage('Stopping Sonarqube') {
            steps {
                echo 'Stoping sonar analysis'
                withSonarQubeEnv('Test_Sonar') {
                    bat "dotnet ${sonarscannerdotnet}\\SonarScanner.MSBuild.dll end"
                }
            }
        }
        stage('Docker image') {
            steps {
                echo 'Building docker image'
                powershell "docker build -t  i-${username}-${GIT_BRANCH} ."
                bat "docker tag i-${username}-${GIT_BRANCH} dtr.nagarro.com:443/i-${username}-${GIT_BRANCH}:${BUILD_NUMBER}"
            }
        }
        stage('Docker Containers') {
            parallel {
                stage('Pre Container Check'){
                    steps{
                        script{
                            echo 'Checking for an exising container'
                            containerId = powershell(script:"docker ps --filter name=c-${username}-${GIT_BRANCH} --format \"{{.ID}}\"", returnStdout:true, label:'')
                            echo "containerid: $containerId"
                            if(containerId){
                                bat "docker stop ${containerId}"
                                bat "docker rm -f ${containerId}"
                            }
                        }   
                    }
                }
        
                stage('Push Image to DTR'){
                    steps{
                        echo 'Pushing the docker image to the DTR'
                        bat "docker tag i-${username}-${GIT_BRANCH} dtr.nagarro.com:443/i-${username}-${GIT_BRANCH}:${BUILD_NUMBER}"
                        bat "docker push dtr.nagarro.com:443/i-${username}-${GIT_BRANCH}:${BUILD_NUMBER}"
                    }
                }
                
                
            }    
        }
        stage('Docker deployment') {
            steps {
                echo 'Deploying the docker image'
                bat "docker run --name c-${username}-${GIT_BRANCH} -d -p 6200:80 dtr.nagarro.com:443/i-${username}-${GIT_BRANCH}:${BUILD_NUMBER}"
            }
        }
        stage('Helm Chart Deployment') {
            steps {
                script {
                    echo 'Deploying helm charts'
                    namespaceName = powershell(script:"kubectl get ns --field-selector metadata.name=karan${GIT_BRANCH}", returnStdout:true, label:'')
                    echo "namespaceName: ${namespaceName}"
                    if(namespaceName){
                        bat "kubectl delete ns karan${GIT_BRANCH}"
                    }
                    bat "kubectl create ns karan${GIT_BRANCH}"
                    bat "helm install nagp-deployment nagp-chart --set imageName=dtr.nagarro.com:443/i-${username}-${GIT_BRANCH}:${BUILD_NUMBER} -n karan${GIT_BRANCH}"
                }
            }
        }
    }
}