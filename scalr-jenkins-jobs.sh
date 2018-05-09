#!/bin/bash

# detect OS and install
apt-get update; apt-get install git python-pip -y

# install python tools
pip install jenkins-job-builder yamllint scalr-ctl

# create folders
folders=( "jobs" "config")
for x in "${folders[@]}"
do
  mkdir -p /etc/jenkins_jobs/$x
done

# set up jenkins_jobs config
cat <<EOF >> /etc/jenkins_jobs/jenkins_jobs.ini
[job_builder]
ignore_cache=True
keep_descriptions=False
include_path=.:scripts:~/git/
recursive=False
exclude=.*:manual:./development
allow_duplicates=False

[jenkins]
user=$jenkins_user
password=$jenkins_pass
url=http://localhost:8080
query_plugins_info=False
EOF

# setup scalr-ctl config
cat <<EOF >> /etc/jenkins_jobs/config/scalr-base-conf.yml
API_HOST: $scalrserver
API_KEY_ID: $key_id
API_SECRET_KEY: $secret_key_id
API_SCHEME: https
SSL_VERIFY_PEER: true
accountId: $accountId
colored_output: true
envId: $envId
view: json
EOF

# clone the repo
cd /etc/jenkins_jobs/jobs
if [ -d .git ] ; then
  git pull
else
  git clone $jobs_git ./
fi
cd /etc/jenkins_jobs/jobs/

# create/upate the jobs in the folder
for x in $(ls *.yml)
do
  jenkins-jobs update $x
done
