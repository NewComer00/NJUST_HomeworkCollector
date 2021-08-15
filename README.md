# How to use?
1. have nginx, uwsgi, uwsgitop and supervisor installed
sudo apt install nginx
pip3 install virtualenv
(venv) pip install uwsgi uwsgitop supervisor
2. approot/app_manager start
3. uwsgitop http://localhost:5001

# How to update app after code being changed?
approot/app_manager reload

# How to stop app?
approot/app_manager stop
