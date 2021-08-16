# 环境需求
* Linux
Windows系统可以使用Cygwin，已测试✅
* Python3

# 安装方法
## 1. 创建一个Python虚拟环境
（也可以不使用虚拟环境，但建议在虚拟环境中操作）
```
pip3 install virtualenv
virtualenv ~/app_env  # 虚拟环境的路径和名称也可以自己指定
cd ~/app_env
source bin/activate  # 激活该虚拟环境，激活成功后命令行会出现 (app_env) 字样
```
若之后想要取消激活，直接在命令行输入 deactivate 命令即可。

## 2. 安装Nginx, uWSGI, uwsgitop和Supervisor

* Linux：
（CentOS可以使用yum安装Nginx）
```
sudo apt update
sudo apt install nginx
pip3 install uwsgi uwsgitop supervisor
```

* Cygwin：
首先安装Nginx，Cygwin安装Nginx的步骤[见此](##Cygwin安装Nginx)。
接着，使用[apt-cyg](https://github.com/transcode-open/apt-cyg)或者原生的包管理器安装```python3-devel```和```libintl-devel```包。
最后，安装uWSGI, uwsgitop和Supervisor：
```
pip3 install uwsgi uwsgitop supervisor
```

## 3. 下载本项目到虚拟环境目录；安装Python依赖包
```
git clone https://github.com/NewComer00/NJUST_CloudData.git ./app
cd app
pip3 install -r requirements.txt
```

## 4. 给“应用管理”脚本添加执行权限
```
chmod +x app_manager.sh
```

# 使用方法
请先确保虚拟环境已经激活。
## 启动应用
```
./app_manager.sh [-n <数字>] start
```
<数字>表示这是<第几次>交作业，如1表示第一次。
启动后可以在浏览器中访问网站：
```
http://<机器的ip地址>:8080/
```
注：
在执行start命令后，Nginx可能会提示一些文件或目录无法找到。执行```ps -a | grep nginx```来查询是否存在Nginx相关进程，若存在则Nginx已经启动。
若Nginx已经启动，我们需要先执行下面描述的“关闭应用”命令（未启动则不需要执行），接着在相应提示位置新建文件或目录，再次启动应用即可。
## 关闭应用
```
./app_manager.sh stop
```
执行后，关闭所有相关进程。
## 重载应用
当应用的源码被修改，或者supervisor、uwsgi的配置文件被修改时，可以执行重载操作来使改动生效：
```
./app_manager.sh reload
```

# How to stop app?
approot/app_manager stop

4. ```uwsgitop http://localhost:5001```

# 附录

## Cygwin安装Nginx
1. 以管理员身份运行Cygwin。

2. 使用[apt-cyg](https://github.com/transcode-open/apt-cyg)或者原生的包管理器安装```cygrunsrv```和```nginx```包。

3. 执行```cygserver-config```命令，在交互时输入```yes```。

4. 安装Nginx的后台程序：
```
/etc/rc.d/init.d/nginx install
```

5. 安装好的后台程序位于```/usr/sbin/nginx```。
将```/usr/sbin```添加至环境变量，运行帮助指令：
```
nginx -h
```
若正常输出版本信息和帮助信息，即安装成功。

参考：https://www.cnblogs.com/lantor/p/13829773.html
