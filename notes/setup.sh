#!/bin/bash
# Copyright (c) 2015 The MotaCoin developers
echo -e "\033[1;33mSetting up MotaCoin Explorer...\e[0m"

DBNAME="motadb"
DBUSER="motauser"
DBPASS="m0T43xp!0re"

defSkip=0

SKIP=${1:-$defSkip}
STEP=0
NSTEPS=10

if [ $SKIP -gt 0 ]
then
  echo -e "\033[0;33mSkipping $SKIP step(s)\e[0m"
fi

((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Installing nodejs and npm\e[0m"
  apt install nodejs npm
  echo
fi

((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Installing mongodb\e[0m"
  echo -e "\033[0;33m   - Importing public key...\e[0m"
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
  echo -e "\033[0;33m   - Creating list file...\e[0m"
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
  echo -e "\033[0;33m   - Reloading package database...\e[0m"
  apt update
  echo -e "\033[0;33m   - Installing package...\e[0m"
  apt install -y mongodb-org
  echo -e "\033[0;33m   - Starting mongod...\e[0m"
  service mongod start
  COUNTER=0
  while !(nc -z localhost 27017) && [[ $COUNTER -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo -e "\033[0;33m   - Waiting for mongo to initialize... ($COUNTER seconds so far)\e[0m"
  done
  echo
fi

((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Setting up database $DBNAME using $DBUSER/$DBPASS\e[0m"
  mongo admin --eval "db.getSiblingDB('$DBNAME')"
  mongo $DBNAME --eval "db.createUser( { user: '$DBUSER', pwd: '$DBPASS', roles: [ 'readWrite' ] } )" 
  echo
fi

((STEP++))
if [ $STEP -gt $SKIP ]
then
echo -e "\033[0;33m$STEP/$NSTEPS Installing dependencies\e[0m"
fi

