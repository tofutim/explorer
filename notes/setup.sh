#!/bin/bash
# Copyright (c) 2018 The MotaCoin developers
echo -e "\033[1;33mSetting up MotaCoin Explorer...\e[0m"

# parameters
DBNAME="motadb"
DBUSER="motauser"
DBPASS="m0T43xp!0re"
RPCPORT=17421
RPCUSER="rpcuser"
RPCPASS="password1"
EXPTITLE="MotaCoin Explorer"
EXPCOIN="MotaCoin"
EXPSYMBOL="MTC"
EXPUSER="motauser"
TWITTER="motacoin"
FACEBOOK="motacoin"
GOOGLEPLUS="motacoin"
APIBLOCKINDEX=77
APIBLOCKHASH="000000cd90599a062472be2e2d16c934aa0972ea968c1455389ff9100a8ca909"
APITXHASH="e5766229381fba1efb29cc369b253bf39df6e0edcd54a603751f13c3598794b8"
APIADDRESS="MFGYRrpK5nKC6EfTuJXSbsFqYTKP1CsAjN"
EXCHANGE="BTC"
CRYPTOPIAID="1658"
CCEXKEY="xxx-xxx-xxx-xxx"
GENTX="61f34e6a34cec70f34bc0cdfdaf440d2fa8fcbb66f3c53e9997f575a15a0b6d9"
GENBLOCK="00000adbafb59ecf24b5d0933cab00b251a155f4a26f184bcb544ae08be3af7b"

defSkip=0

SKIP=${1:-$defSkip}
STEP=0
NSTEPS=10

if [ $SKIP -gt 0 ]
then
  echo -e "\033[0;33mSkipping $SKIP step(s)\e[0m"
fi

# 1/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Installing nodejs and npm\e[0m"
  apt install -y nodejs npm
  # https://stackoverflow.com/questions/18130164/nodejs-vs-node-on-ubuntu-12-04
  ln -s `which nodejs` /usr/bin/node
  echo
fi

# 2/10
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

# 3/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Setting up database $DBNAME using $DBUSER/$DBPASS\e[0m"
  mongo admin --eval "db.getSiblingDB('$DBNAME')"
  mongo $DBNAME --eval "db.createUser( { user: '$DBUSER', pwd: '$DBPASS', roles: [ 'readWrite' ] } )" 
  echo
fi

# 4/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
echo -e "\033[0;33m$STEP/$NSTEPS Installing dependencies\e[0m"
echo -e "\033[0;33m   - Installing libkrb5-dev for kerberos...\e[0m"
apt install -y libkrb5-dev
echo -e "\033[0;33m   - Installing production dependencies...\e[0m"
npm install --production
fi

# 5/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Configuring explorer\e[0m"
  echo -e "\033[0;33m   - Replicating template...\e[0m"
  cp ./settings.json.template ./settings.json
# ideally use jq but sadly jq does not support comments!
# echo -e "\033[0;33m   - Installing jq...\e[0m"
# apt install -y jq
  echo -e "\033[0;33m   - Replacing parameters...\e[0m"

  # General
  confSearch='"title": ".*"'
  confReplacement='"title": "'$EXPTITLE'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"coin": ".*"'
  confReplacement='"coin": "'$EXPCOIN'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"symbol": ".*"'
  confReplacement='"symbol": "'$EXPSYMBOL'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json

  # Database
  confSearch='"user": "iquidus"'
  confReplacement='"user": "'$DBUSER'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"password": "3xp!0reR"'
  confReplacement='"password": "'$DBPASS'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"database": ".*"'
  confReplacement='"database": "'$DBNAME'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json

  # Wallet
  confSearch='"port": 9332'
  confReplacement='"port": '$RPCPORT''
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"user": "darkcoinrpc"'
  confReplacement='"user": "'$RPCUSER'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"pass": ".*"'
  confReplacement='"pass": "'$RPCPASS'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json

  # Social media
  confSearch='"twitter": ".*"'
  confReplacement='"twitter": "'$TWITTER'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"facebook": ".*"'
  confReplacement='"facebook": "'$FACEBOOK'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"googleplus": ".*"'
  confReplacement='"googleplus": "'$GOOGLEPLUS'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json

  # API samples
  confSearch='"blockindex": 1337,'
  confReplacement='"blockindex": '$APIBLOCKINDEX','
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"blockhash": ".*"'
  confReplacement='"blockhash": "'$APIBLOCKHASH'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"txhash": ".*"'
  confReplacement='"txhash": "'$APITXHASH'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"address": "RBiXWscC63Jdn1GfDtRj8hgv4Q6Zppvpwb"'
  confReplacement='"address": "'$APIADDRESS'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json

  # Market
  confSearch='"exchange": ".*"'
  confReplacement='"exchange": "'$EXCHANGE'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"cryptopia_id": ".*"'
  confReplacement='"cryptopia_id": "'$CRYPTOPIAID'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"ccex_key": ".*"'
  confReplacement='"ccex_key": "'$CCEXKEY'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json

  # Genesis
  confSearch='"genesis_tx": ".*"'
  confReplacement='"genesis_tx": "'$GENTX'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json
  confSearch='"genesis_block": ".*"'
  confReplacement='"genesis_block": "'$GENBLOCK'"'
  sed -i'' "s/$confSearch/$confReplacement/g" settings.json 
fi  

# 6/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Initial sync\e[0m"
  echo -e "\033[0;33m   - Starting server...\e[0m"
  npm start &
  COUNTER=0
  while !(nc -z localhost 3001) && [[ $COUNTER -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo -e "\033[0;33m   - Waiting for explorer to initialize... ($COUNTER seconds so far)\e[0m"
  done
  sleep 5
  echo -e "\033[0;33m   - Updating coin index...\e[0m"
  # note may have to use 'reindex' if issues
  echo "nodejs scripts/sync.js index update"
  nodejs scripts/sync.js index update
  echo -e "\033[0;33m   - Updating market data...\e[0m"
  echo "nodejs scripts/sync.js market"
  nodejs scripts/sync.js market
  echo -e "\033[0;33m   - Updating peers...\e[0m"
  echo "nodejs scripts/peers.js"
  nodejs scripts/peers.js
  echo -e "\033[0;33m   - Stopping server...\e[0m"
  npm stop
fi

# 7/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "\033[0;33m$STEP/$NSTEPS Installing cronjobs\e[0m"
fi
