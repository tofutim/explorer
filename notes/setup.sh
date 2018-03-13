#!/bin/bash
# Copyright (c) 2018 The MotaCoin developers
echo -e "\033[1;33mSetting up MotaCoin Explorer...$RESET"

# environment
RUNNER=`whoami`
echo "Running script as $RUNNER"

# parameters
COINDPATH="~/Projects/MotaCoinDevelopment/src/MotaCoind"
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
UPDATEBLOCKCHAIN=2
UPDATEMARKET=5
UPDATEPEERS=5

# colors
YELLOW="\033[0;33m"
RESET="\e[0m"

defSkip=0

SKIP=${1:-$defSkip}
STEP=0
NSTEPS=10

if [ $SKIP -gt 0 ]
then
  echo -e "$YELLOW Skipping $SKIP step(s)$RESET"
fi

# 9/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Installing and ensuring MotaCoind survives reb$
  echo -e "$YELLOW    - Installing git...$RESET"
  sudo apt install git
  echo -e "$YELLOW    - Cloning repository...$RESET"
  git clone git@github.com:tofutim/MotaCoinDevelopment.git ~/Projects/MotaCoind
  echo -e "$YELLOW    - Installing dependencies...$RESET"
  echo "NOT YET IMPLEMENTED"
  echo -e "$YELLOW    - Making MotaCoind and installing to /usr/local/bin...$RE$
  SAVEDDIR=`pwd`
  cd ~/Projects/MotaCoind/src
  sudo git checkout feature/init
  make -f makefile.unix
  sudo make -f makefile.unix install
  echo -e "$YELLOW    - Setting up Ubuntu service...$RESET"
  cd ~/Projects/MotaCoind/contrib/init
  cp MotaCoind.service.template MotaCoind.service  
  confSearch='User=.*'
  confReplacement='User='$RUNNER''
  sed -i'' "s/$confSearch/$confReplacement/g" MotaCoind.service
  sudo cp MotaCoind.service /etc/systemd/system/.
  sudo chmod 755 /etc/systemd/system/MotaCoind.service
  sudo mkdir -p /etc/motacoin
  sudo cp ~/Projects/MotaCoind/MotaCoin.conf /etc/motacoin/.
  cd $SAVEDDIR
  sudo systemctl start MotaCoind
  COUNTER=0
  while !(nc -z localhost 17421) && [[ $COUNTER -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo -e "$YELLOW    - Waiting for MotaCoind to initialize... ($COUNTER seco$
  done
fi


# 1/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Installing nodejs and npm$RESET"
  sudo apt install -y nodejs npm
  # https://stackoverflow.com/questions/18130164/nodejs-vs-node-on-ubuntu-12-04
  sudo ln -s `which nodejs` /usr/bin/node
  echo
fi

# 2/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Installing mongodb$RESET"
  echo -e "$YELLOW    - Importing public key...$RESET"
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
  echo -e "$YELLOW    - Creating list file...$RESET"
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
  echo -e "$YELLOW    - Reloading package database...$RESET"
  sudo apt update
  echo -e "$YELLOW    - Installing package...$RESET"
  sudo apt install -y mongodb-org
  echo -e "$YELLOW    - Starting mongodb...$RESET"
  sudo service mongodb restart
  COUNTER=0
  while !(nc -z localhost 27017) && [[ $COUNTER -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo -e "$YELLOW    - Waiting for mongo to initialize... ($COUNTER seconds so far)$RESET"
  done
  echo
fi

# 3/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Setting up database $DBNAME using $DBUSER/$DBPASS$RESET"
  mongo admin --eval "db.getSiblingDB('$DBNAME')"
  mongo $DBNAME --eval "db.createUser( { user: '$DBUSER', pwd: '$DBPASS', roles: [ 'readWrite' ] } )" 
  echo
fi

# 4/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Installing dependencies$RESET"
  echo -e "$YELLOW    - Installing libkrb5-dev for kerberos...$RESET" 
  sudo apt install -y libkrb5-dev
  echo -e "$YELLOW    - Installing production dependencies...$RESET"
  npm install --production
  echo -e "$YELLOW    - Installing PM2 task manager...$RESET"
  sudo npm install -g pm2
fi

# 5/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Configuring explorer$RESET"
  echo -e "$YELLOW    - Replicating template...$RESET"
  cp ./settings.json.template ./settings.json
# ideally use jq but sadly jq does not support comments!
# echo -e "$YELLOW    - Installing jq...$RESET"
# apt install -y jq
  echo -e "$YELLOW    - Replacing parameters...$RESET"

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
  echo -e "$YELLOW $STEP/$NSTEPS Initial sync$RESET"
  echo -e "$YELLOW    - Starting server...$RESET"
  pm2 -f start bin/instance --node-args="--stack-size=32000" 
  COUNTER=0
  while !(nc -z localhost 3001) && [[ $COUNTER -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo -e "$YELLOW    - Waiting for explorer to initialize... ($COUNTER seconds so far)$RESET"
  done
  sleep 5
  echo -e "$YELLOW    - Updating coin index...$RESET"
  # note may have to use 'reindex' if issues
  echo "nodejs scripts/sync.js index update"
  echo -e "$YELLOW    - Updating blockchain...$RESET"
  echo "nodejs scripts/sync.js index update" 
  nodejs scripts/sync.js index update
  echo -e "$YELLOW    - Updating market data...$RESET"
  echo "nodejs scripts/sync.js market"
  nodejs scripts/sync.js market
  echo -e "$YELLOW    - Updating peers...$RESET"
  echo "nodejs scripts/peers.js"
  nodejs scripts/peers.js
fi

# 7/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Installing cronjobs$RESET"

  # shamelessly snatched from https://stackoverflow.com/questions/17267904/updating-cron-with-bash-script
  function installCron {
    FREQ=$1   
    DIR=$2
    SCRIPT=$3

    DIRESC=$(sed 's/[\*\.&]/\\&/g' <<<"$DIR")
    SCRIPTESC=$(sed 's/[\*\.&]/\\&/g' <<<"$SCRIPT")

    echo "SCRIPT: $SCRIPT"
    STATUS=`crontab -l | grep "$SCRIPT"`
    echo "STATUS: $STATUS"
    if [ "$STATUS" \> " " ]; then
      if [ "$STATUS" = "*/$FREQ * * * * cd $DIR && $SCRIPT" ]; then
        echo -e "No modifications detected"
      else
        echo -e "Adjusting freq to $FREQ minute(s)"
        STATUSESC=$(sed 's/[\*\.&]/\\&/g' <<<"$STATUS")
        crontab -l | sed "s%$STATUSESC%\*/$FREQ \* \* \* \* cd $DIRESC \&\& $SCRIPTESC%" | crontab -
      fi
    else
      echo -e "CRON not detected - Installing defaults"
      (crontab -l ; echo "*/$FREQ * * * * cd $DIR && $SCRIPT") | crontab -
    fi
  }

  echo -e "$YELLOW    - Update blockchain every $UPDATEBLOCKCHAIN minute(s)...$RESET"
  installCron $UPDATEBLOCKCHAIN $PWD "nodejs scripts/sync.js index update > /dev/null 2>&1"
  echo -e "$YELLOW    - Update market every $UPDATEMARKET minute(s)...$RESET"
  installCron $UPDATEMARKET $PWD "nodejs scripts/sync.js market > /dev/null 2>&1"
  echo -e "$YELLOW    - Update peers every $UPDATEPEERS minute(s)...$RESET"
  installCron $UPDATEPEERS $PWD "nodejs scripts/peers.js > /dev/null 2>&1"
fi

# 8/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Ensure explorer survives reboot$RESET"
  sudo pm2 startup
  sudo pm2 save
fi

# 9/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Installing and ensuring MotaCoind survives reboot$RESET"
  echo -e "$YELLOW    - Installing git...$RESET"
  sudo apt install git
  echo -e "$YELLOW    - Cloning repository...$RESET"
  git clone git@github.com:tofutim/MotaCoinDevelopment.git ~/Projects/MotaCoind
  echo -e "$YELLOW    - Installing dependencies...$RESET"
  echo "NOT YET IMPLEMENTED"
  echo -e "$YELLOW    - Making MotaCoind and installing to /usr/local/bin...$RESET"
  SAVEDDIR=`pwd`
  cd ~/Projects/MotaCoind/src
  sudo git checkout feature/init
  make -f makefile.unix
  sudo make -f makefile.unix install
  echo -e "$YELLOW    - Setting up Ubuntu service...$RESET"
  cd ~/Projects/MotaCoind/contrib/init
  cp MotaCoind.service.template MotaCoind.service  
  confSearch='User=.*'
  confReplacement='User='$RUNNER''
  sed -i'' "s/$confSearch/$confReplacement/g" MotaCoind.service
  sudo cp MotaCoind.service /etc/systemd/system/.
  sudo chmod 755 /etc/systemd/system/MotaCoind.service
  sudo mkdir -p /etc/motacoin
  sudo cp ~/Projects/MotaCoind/MotaCoin.conf /etc/motacoin/.
  cd $SAVEDDIR
  sudo systemctl start MotaCoind
  COUNTER=0
  while !(nc -z localhost 17421) && [[ $COUNTER -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo -e "$YELLOW    - Waiting for MotaCoind to initialize... ($COUNTER seconds so far)$RESET"
  done
fi

# 10/10
((STEP++))
if [ $STEP -gt $SKIP ]
then
  echo -e "$YELLOW $STEP/$NSTEPS Install and configure nginx$RESET"
  echo -e "$YELLOW    - Installing nginx...$RESET"
  sudo apt install -y nginx
  echo "Please manually add this to /etc/nginx/sites-enabled/default"
  echo "	
       location / {
               proxy_pass http://127.0.0.1:3001;
       }"
  echo "then 'sudo service nginx restart'"
fi
