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
--------------------

# Issues with npm install production

npm WARN deprecated static-favicon@1.0.2: use serve-favicon module
npm WARN deprecated jade@1.3.1: Jade has been renamed to pug, please install the latest version of pug instead of jade
npm WARN deprecated mongodb@2.0.45: Please upgrade to 2.2.19 or higher
npm WARN deprecated bitcoin@1.7.0: Use npmjs.com/bitcoin-core instead as this package is no longer maintained.
npm WARN deprecated connect@2.8.8: connect 2.x series is deprecated
npm WARN deprecated transformers@2.1.0: Deprecated, use jstransformer
npm WARN deprecated constantinople@2.0.1: Please update to at least constantinople 3.1.1
npm WARN deprecated mongodb@2.0.42: Please upgrade to 2.2.19 or higher
npm WARN deprecated node-uuid@1.4.8: Use uuid module instead

> kerberos@0.0.23 install /home/tim/Projects/explorer/node_modules/kerberos
> (node-gyp rebuild) || (exit 0)

/bin/sh: 1: node: not found
gyp: Call to 'node -e "require('nan')"' returned exit status 127 while in binding.gyp. while trying to load binding.gyp
gyp ERR! configure error 
gyp ERR! stack Error: `gyp` failed with exit code: 1
gyp ERR! stack     at ChildProcess.onCpExit (/usr/share/node-gyp/lib/configure.js:354:16)
gyp ERR! stack     at emitTwo (events.js:87:13)
gyp ERR! stack     at ChildProcess.emit (events.js:172:7)
gyp ERR! stack     at Process.ChildProcess._handle.onexit (internal/child_process.js:200:12)
gyp ERR! System Linux 4.4.0-116-generic
gyp ERR! command "/usr/bin/nodejs" "/usr/bin/node-gyp" "rebuild"
gyp ERR! cwd /home/tim/Projects/explorer/node_modules/kerberos
gyp ERR! node -v v4.2.6
gyp ERR! node-gyp -v v3.0.3
gyp ERR! not ok 
explorer@1.6.1 /home/tim/Projects/explorer
