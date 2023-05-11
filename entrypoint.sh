#!/bin/bash
set -e

[[ $DEBUG == true ]] && set -x


initialize_mysql_database() {
    service mysql start
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"
    mysql -u root -p'root' -e "CREATE DATABASE counter;"
}

run_application(){
 git clone https://github.com/ustream/homework.git
 pip3 install -r /homework/requirements.txt
 echo "DB_HOST=127.0.0.1" >  /homework/.env && echo "DB_PORT=3306" >>  /homework/.env && echo "DB_USER=root" >>  /homework/.env && echo "DB_PASSWORD=root" >>  /homework/.env && echo "DB_DATABASE=counter" >>  /homework/.env
 python3 /homework/countapp/init_database.py
 cd /homework
 gunicorn --bind 0.0.0.0:5000 --chdir countapp countapp.wsgi:app --reload --timeout=900
}


if [[ -z ${1} ]]; then
  initialize_mysql_database
  run_application
else
  exec "$@"
fi