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

* 附带脚本
```
# 构建基础包脚本
$ cat /data/jenkins/build_base.sh
#!/bin/bash

baseproject_name=`basename $1`
echo "baseproject_name is $baseproject_name"
baseimage_name=$(basename $1|awk -F '_' '{print $2}')
echo "baseimage_name is $baseimage_name"

cd /data/jenkins/${baseproject_name}
docker login --username=mwteck2016 --password=MWteck registry.cn-shanghai.aliyuncs.com
docker pull registry.cn-shanghai.aliyuncs.com/mwteck/base:${baseimage_name}
docker build -t registry.cn-shanghai.aliyuncs.com/mwteck/base:${baseimage_name} .
docker push registry.cn-shanghai.aliyuncs.com/mwteck/base:${baseimage_name}

if [ -d /data/jenkins/${baseproject_name}/dist ];then
	rm -rf /data/jenkins/${baseproject_name}/dist/*
	echo "升级包已经清理完毕"
fi



# 构建项目脚本
$ cat /data/jenkins/build_project.sh
#!/bin/bash
datenow=$(date +%Y-%m-%d-%H-%M-%S)
echo $1
project_path=$1
baseimage_name=$(basename $project_path|awk -F '_' '{print $2}')
docker_image_path=/data/jenkins/`basename $1`/`basename $1`-py
cp -a $project_path/ $docker_image_path/
docker login --username=mwteck2016 --password=MWteck registry.cn-shanghai.aliyuncs.com
docker pull registry.cn-shanghai.aliyuncs.com/mwteck/base:$baseimage_name
cd $docker_image_path/
docker build -t 172.16.1.200:5000/`basename $1`:dev_$datenow .
docker push 172.16.1.200:5000/`basename $1`:dev_$datenow
echo "baseimage_name is ${baseimage_name}"

if [ $? -eq 0 ];then
	kubectl set image deployment/$baseimage_name  *=172.16.1.200:5000/`basename $1`:dev_$datenow  -n t3
	if [ $? -eq 0 ];then
		echo "update `basename $1` success"
		if [ -d /data/jenkins/`basename $1`/`basename $1`-py/`basename $1` ];then
			echo "开始清理本次构建的代码"
			rm -rf /data/jenkins/`basename $1`/`basename $1`-py/`basename $1`/*
		fi
	else
		echo "faild update"
	fi

fi

```





* 范例二

```
pipeline {
    agent { label '201' }
    parameters{

        choice(
            choices: 'deploy\nrollback',
            description: '',
            name: 'status'
            )
        string(name: 'version', defaultValue: '0', description: '')
    }


    stages {
        stage('cloneProject'){
        steps{
            git branch: 't5', credentialsId: 'e5d42737-054c-4473-b6ef-5462a10a50a8', url: 'git@git.mwteck.com:micro/api-admin.git'
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
                sh 'bash /home/jenkins/build_project1.sh ${WORKSPACE}'
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



# 附带脚本
$ cat /home/jenkins/build_project1.sh
#!/bin/bash
datenow=$(date +%Y-%m-%d-%H-%M-%S)
docker login --username=mwteck2016 --password=MWteck registry.cn-shanghai.aliyuncs.com
base_name=$(basename $1)
baseimage_name=$(basename $base_name|awk -F '_' '{print $2}')
cd /home/jenkins/workspace/$base_name
mvn clean package
cd /home/jenkins/workspace/$base_name/target
cat > Dockerfile <<END
FROM tomcat:20190723mwteck
COPY ./$baseimage_name /usr/local/tomcat/webapps/ROOT/
ENV TZ=Asia/Shanghai
ENV LANG en_US.UTF-8
END

docker build -t 172.16.1.200:5000/$baseimage_name:dev_$datenow .
docker push 172.16.1.200:5000/$baseimage_name:dev_$datenow
kubectl set image deployment/$baseimage_name  *=172.16.1.200:5000/$baseimage_name:dev_$datenow  -n t5



```
