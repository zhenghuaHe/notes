import groovy.json.JsonSlurper
node {
    env.BUILD_USER          = "Jenkins_timer"
    env.BUILD_USER_ID       = "Jenkins_timer"
    load(SETTINGS)
    env.GRADLE_USER_HOME    = "/data/jenkins/files/gradle"
    ALLOW_BRANCH            = true
    ACTION                  = "deploy"
    HOSTS                   = "172.17.1.110"
    RUN_AS_ROOT             = true
    CLEAN_WORKSPACE         = true
    BUILD_OUTPUT_DIR        = "build/outputs/apk/${APP_ENV}/release"
    APK_OUTPUT_DIR          = "/data/web/mirrors/adnavi/android"
    SCM_REVISION_SPIT       = SCM_REVISION.toLowerCase().replace('origin/', '')
    YYWWD                   = sh(returnStdout: true, script: "date +%y%W%u").trim()
    APK_NAME                = "ADNAVI_${SCM_REVISION_SPIT}.${BUILD_NUMBER}_${APP_ENV}Release"
    GIT_NAME                = "git@172.17.10:Auto/AD_NAVI.git"
    REPO_NAME               = "ssh://xiaoming.li@172.17.1.10:29418/Auto/Ad_Navi_Reposerver"
    APP_LANG                = "android"
    NODE_STAGE_INIT         = "android"
    NODE_STAGE_GIT          = "android"
    NODE_STAGE_BUILD        = "android"
    BUILD_DIR               = "AD_NAVI/Module_AppMain"
    BUILD_COMMAND           = "../gradlew assembleRelease -PversionName=${SCM_REVISION_SPIT}.${BUILD_NUMBER}"
    // BUILD_COMMAND           = "../gradlew assembleRelease -PversionCode=${VERSIONCODE} -PversionName=${SCM_REVISION_SPIT}.${BUILD_NUMBER}"
    
}

Start()

def Start() {
    // 项目初始化
    node(NODE_STAGE_INIT) {
        stage('\u27A1 Stage 1: Pre-Process') {
            Base.PreProcess()
            echo "Set build node to '${NODE_STAGE_BUILD}'"
        }
    }

    // 拉取项目代码
    node(NODE_STAGE_GIT) {
        stage("\u2756 Stage 2: Checkout Repo") {
            Base.CleanWorkspace()
            Git.Controller()
            sh("git clone https://mirrors.tuna.tsinghua.edu.cn/git/git-repo .repo/repo")
            sh("repo init -u $REPO_NAME && repo sync")
            sh("repo forall -c git checkout $SCM_REVISION_SPIT")
            sh("sed -i 's@xcserver:8082@xcserver.ecarx.com.cn:8082@g' ./AD_NAVI/build.gradle ")
            sh("chmod +x AD_NAVI/gradlew && echo sdk.dir=/opt/sdk >> AD_NAVI/local.properties")
        }
    }



    // 项目编译
    node(NODE_STAGE_BUILD) {
        stage('\u272F Stage 3: Build Project') {
            if (fileExists("AD_NAVI/Module_AppMain/config.txt")) {
                MM = sh(returnStdout: true, script: "awk -F: '/vehicleType/ {print \$2}' AD_NAVI/Module_AppMain/config.txt").trim()
                OO = sh(returnStdout: true, script: "awk -F: '/brandId/ {print \$2}' AD_NAVI/Module_AppMain/config.txt").trim()
                BB = sh(returnStdout: true, script: "awk -F: '/branchCode/ {print \$2}' AD_NAVI/Module_AppMain/config.txt").trim()
                VersionName = sh(returnStdout: true, script: "awk -F: '/versionName/ {print \$2}' AD_NAVI/Module_AppMain/config.txt").trim()

                
                // 确认index
                index = 0
                Response = sh(returnStdout: true, script: 'curl -s http://xiaoming.zhu:11487f9c4cd785b2c324adffdc33ec5cfc@172.16.1.101:8080/job/lbs_android/api/json?pretty=true\\&tree=allBuilds\\\\[id,displayName,result\\\\]').trim()
                // echo "${Response}"
                def jsonSlurper = new JsonSlurper()
                 //获取到的是Map对象
                def map = jsonSlurper.parseText(Response)
                for (s in map.allBuilds) {
                    if ( s.result == "SUCCESS" && s.displayName.contains(VersionName)) {
                        index ++
                        println(s.displayName)
                    }
                }
                if ( BUILD_USER == "Jenkins_timer" ) {
                    index = 999
                }

                println "index-----------"
                println(index)
                println "end  index-----------"
                
                VersionNameList = VersionName.split("\\.")
                VersionCode = VersionNameList[0].toInteger()*10000000 + VersionNameList[1].toInteger()*100000 + VersionNameList[2].toInteger()*1000 + index

                if ( "${params.baseName}" == "Test-demo.1.0.779810.apk" ) {
                    APK_NAME = "ADNAVI_${SCM_REVISION_SPIT}.${type}.${YYWWD}${ReleaseBuildInfo_OO}${ReleaseBuildInfo_VV}${BUILD_NUMBER}${ReleaseBuildInfo_BB}_${APP_ENV}Release"
                    println "APKNAME------: ${APK_NAME} ------"
                } else {
                    APK_NAME = "${params.baseName}"
                    println "APKNAME------: ${APK_NAME} ------"
                }

                GIT_HASH = GIT_COMMIT_ID[0..5]
                BUILD_COMMAND = "export ReleaseVersion=${VersionName}.${type};export ReleaseBuildInfo=${YYWWD}${ReleaseBuildInfo_OO}${ReleaseBuildInfo_VV}${BUILD_NUMBER}${ReleaseBuildInfo_BB};export GitHash=${GIT_HASH}; ../gradlew assembleRelease -PversionCode=${VersionCode} -PversionName=${SCM_REVISION_SPIT}.${type}.${YYWWD}${ReleaseBuildInfo_OO}${ReleaseBuildInfo_VV}${BUILD_NUMBER}${ReleaseBuildInfo_BB}"
            }
            println "APK_NAME------: ${APK_NAME} ------"
            println "BUILD_COMMAND------: ${BUILD_COMMAND} ------"
            println "VersionName--------: ${VersionName}.${type} -------"
            println "VersionNameList--------: ${VersionNameList} -------"
            println "VersionCode--------: ${VersionCode} -------"
            println "GitHash--------: ${GIT_HASH} -------"
            println "ReleaseVersion--------: ${VersionName}.${type} -------"
            println "ReleaseBuildInfo--------: ${YYWWD}${ReleaseBuildInfo_OO}${ReleaseBuildInfo_VV}${BUILD_NUMBER}${ReleaseBuildInfo_BB} -------"
            println "BUILD_COMMAND------: ${BUILD_COMMAND} ------"
            Compile.Controller()
        }
    }



    // 二维码
    node(NODE_STAGE_BUILD) {
        stage("\u2756 Stage 4: Set QRcode") {
            // Set QRcode
            sh("qrcode \"https://mirrors.com.cn/adnavi/android/${APK_NAME}.apk\" > ${WORKSPACE}/${BUILD_DIR}/${BUILD_OUTPUT_DIR}/${APK_NAME}.jpg")
            // Set build name & descriptionSCM_REVISION
            currentBuild.displayName = BUILD_NUMBER  + '-' + APP_ENV + '-' + VersionName
            currentBuild.description = "release by ${BUILD_USER}<br />branch: ${SCM_REVISION}<br />desc: ${DESCRIPTION}<br /><a href=\"https://mirrors.com.cn/adnavi/android/${APK_NAME}.apk\">点击下载</a><br><img src='https://mirrors.com.cn/adnavi/android/${APK_NAME}.jpg' width=200px height=200px><br>"
        }
    }
    
    // 同步apk和和二维码图片
    node("master") {
        stage('\u272F Stage 5: Rsync Project') {
            env.ANSIBLE_FORCE_COLOR = true
            ansiColor('xterm') {
                sh("ansible-playbook -u root ${JENKINSFILE}/ansible/common-deploy.yml -i \"$HOSTS, \" -e  \"FILEUSER=ecarx code_dir=${WORKSPACE}/${BUILD_DIR}/${BUILD_OUTPUT_DIR} deploy_dir=${APK_OUTPUT_DIR}\"")
            }
        }
    }
    
    // 通知
    return
}
