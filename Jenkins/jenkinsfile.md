# 参考范例jenkinsfile

```
pipeline {
    agent { label '202' }
    parameters{
        //自定义参数
        choice(
            choices: 'NO\n2012iot-core-python\n2012iot-db-manager-python\nhappy-python\n2012iot-cache-python',
            description: '',
            name: 'upgrade_packages'
            )

        choice(
            choices: 'deploy\nrollback',
            description: '',
            name: 'status'
            )
        string(name: 'version', defaultValue: '0', description: '')
    }

    stages {


        //选择是
        stage('Choice'){
            when{
                expression {params.upgrade_packages != "NO"}
            }
            steps{
                 git credentialsId: 'e5d42737-054c-4473-b6ef-5462a10a50a8', url: 'git@git.mwteck.com:ttdv4/'+params.upgrade_packages+'.git'
                 sh 'python3 setup.py bdist_wheel'
                 sh 'cp -a dist/ /data/jenkins/`basename ${WORKSPACE}`'
                 deleteDir()
                 sh 'bash /data/jenkins/build_base.sh ${WORKSPACE}'


            }

        }
       //修改拉取代码以后的配置文件，适配测试环境
        stage('cloneProject'){
            steps{
            git branch: 'master',credentialsId: 'e5d42737-054c-4473-b6ef-5462a10a50a8', url: 'git@git.mwteck.com:hexianjue/chengdu-big-data-platform-api.git'
            }

        }
        //选择是否回滚版本
        stage('ChoiceROLLback'){
            when{
                expression {params.status == "rollback"}
            }
            steps{
                sh 'git checkout $version'
            }
        }


        stage('build_project'){
            steps{
                sh 'bash /data/jenkins/build_project.sh ${WORKSPACE}'
            }
        }

    }

    post {
        //是否删去workspace
        always {
            echo 'One way or another, I have finished'
            //deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }    
}



```
