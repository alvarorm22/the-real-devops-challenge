FROM mongo 

ADD restaurant.json /data 
ADD init.sh /docker-entrypoint-initdb.d/ 
ADD mongod.conf /etc

EXPOSE 27017

VOLUME /data/db
  

