# JenkinsFile用法

    > 流水线分为声明式流水线和脚本化流水线

## 声明式流水线基础
* 在声明式流水线语法中, pipeline 块定义了整个流水线中完成的所有的工作。

```
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any ①
    stages {
        stage('Build') { ②
            steps {
                // ③
            }
        }
        stage('Test') { ④
            steps {
                // ⑤
            }
        }
        stage('Deploy') { ⑥
            steps {
                // ⑦
            }
        }
    }
}


①在任何可用的代理上，执行流水线或它的任何阶段。
②定义 "Build" 阶段。
③执行与 "Build" 阶段相关的步骤。
④定义"Test" 阶段。
⑤执行与"Test" 阶段相关的步骤。
⑥定义 "Deploy" 阶段。
⑦执行与 "Deploy" 阶段相关的步骤。



```

## 脚本化流水线基础

* 在脚本化流水线语法中, 一个或多个 node 块在整个流水线中执行核心工作。 虽然这不是脚本化流水线语法的强制性要求, 但它限制了你的流水线的在`node`块内的工作做两件事:
* 1.通过在Jenkins队列中添加一个项来调度块中包含的步骤。 节点上的执行器一空闲, 该步骤就会运行。
* 2.创建一个工作区(特定为特定流水间建立的目录)，其中工作可以在从源代码控制检出的文件上完成

```
Jenkinsfile (Scripted Pipeline)
node {  ①
    stage('Build') { ②
        // ③
    }
    stage('Test') { ④
        // ⑤
    }
    stage('Deploy') { ⑥
        // ⑦
    }
}
①在任何可用的代理上，执行流水线或它的任何阶段。
②定义 "Build" 阶段。 stage块在脚本化流水线语法中是可选的。 然而在脚本化流水线中实现stage块 ，可以清楚的显示Jenkins UI中的每个stage的任务子集。
③执行与 "Build" 阶段相关的步骤。
④定义 "Test" 阶段。
⑤执行与 "Test" 阶段相关的步骤。
⑥定义 "Deploy" 阶段。
⑦执行与 "Deploy" 阶段相关的步骤。


```
