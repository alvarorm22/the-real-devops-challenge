#! /bin/sh 
#mongod --fork --logpath /tmp/mongod.log --dbpath /data/db --config /etc/mongod.conf
mongoimport --uri=mongodb://0.0.0.0:27017 -d restaurant -c restaurant --type json --file /data/restaurant.json
#mongod --shutdown 
