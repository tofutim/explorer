# Installation notes for Ubuntu 16.04

## Installing MongoDB
Thursday, March 8, 2018 6:32:24 PM GMT-08:00 
Per https://docs.mongodb.com/master/tutorial/install-mongodb-on-ubuntu/
1. Import public key
```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
```
2. Create list file
```
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
```
3. Reload package database
```
sudo apt-get update
```
4. Install packages
```
sudo apt-get install -y mongodb-org
```
5. Start the service
```
sudo service mongod start
```

## Create the database
1. Create database
```
> use explorerdb
```
2. Create user with read/write access:
```
> db.createUser( { user: "tim", pwd: "3xp!0reR", roles: [ "readWrite" ] } )
```

## Setup explorer
1. Clone the repository
```
git clone https://github.com/iquidus/explorer explorer
```
2. Install node modules
```
cd explorer && npm install --production
```
3. Configure
```
cp ./settings.json.template ./settings.json
```
*Make required changes in settings*
4. Start explorer
```
npm start
```
