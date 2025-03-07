# SOLUTIONS 

## FIX API

- Firstly, I have had to change the `find_restaurants` method of `mongoflask.py` to fix an error:
  
	`query["_id"] = ObjectId(_id)`

```python
def find_restaurants(mongo, _id=None):
query = {}
    if _id:
       	query["_id"] = ObjectId(_id)
return list(mongo.db.restaurant.find(query))
```



  Then, I have changed the `restaurant(id)` method to return a json object if there is a match or a http 204 status code if no match found:


```python
def restaurant(id):
restaurants = find_restaurants(mongo, id)
if (len(restaurants)) > 0:
    return jsonify(restaurants[0])
else:
    return '', 204 
``` 


## Tools and scripts

Some scripts have been developed to build and deploy the images easier:

- Makefile: It import deploy.env file and `build | up | stop | start` the containers. Also `publish` command is available to tag and upload the images to Docker Hub
- docker-compose: Make use this config file to deploy and build images. Dependencies between containers are indicated in this file too.


## MONGODB

This mongo image has been built to start and load the `restaurant.json` file in a collection for itself. It has been indicated in Dockerfile. It can be started with Makefile and docker-compose.

## CI 

A CI flow has been built so that when performing an MR to github a trigger is launched to build the image and upload it to docker hub. This point has been implemented with Travis CI. All dependencies and steps are in .travis.yaml file. 
The flow run as follows:

- MR is push to the GitHub repository
- A trigger is launched in Travis
- All dependencies are installed
- A simple pylint test is executed
- Others tests are executed with Tox in py27, py34, py35 and py36 envirotments.
- Builds the docker images
- Push the images to Docker Hub

## DEPLOYMENT

All of these containers have been deployed in a kubernetes cluster. Yaml config files are provided in k8s folder:

- 1 Deployment with 3 replicas for restaurantapp image
- 1 Statefulset with 1 replicas for mongodb image
- 1 Service to expose the restaurantapp deployment
- 1 Service to expose the mongo statefulset
- 1 Secret for the connection uri


All of these deployments and services can be launched with command: `kubectl create -f <file.yaml>`


We can test this solution in any Kubernetes cluster with the following commands:

`kubectl create -f restaurantapp_secrets.yaml`

`kubectl create -f mongo_statefulset.yaml`

`kubectl create -f mongo_service.yaml`

`kubectl create -f restaurantapp_deployment.yaml`

`kubectl create -f restaurantapp_service.yaml`


`export RESTAURANTAPP_IP=$(kubectl get svc restaurantapp -o jsonpath='{.spec.clusterIP}')`

`curl $RESTAURANTAPP_IP:8080/api/v1/restaurant | jq`

`curl $RESTAURANTAPP_IP:8080/api/v1/restaurant/55f14313c7447c3da7052519 | jq`


If we could want to deploy mongo statefulset with more replicas a shared disk solution should be necessary, for example EFS, glusterfs, ceph, NFS...

## EXAMPLES

`curl $RESTAURANTAPP_IP:8080/api/v1/restaurant/55f14313c7447c3da7052519 | jq`      

```bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   263  100   263    0     0   118k      0 --:--:-- --:--:-- --:--:--  128k
{
  "URL": "http://www.just-eat.co.uk/restaurants-bluebreeze-le3/menu",
  "_id": "55f14313c7447c3da7052519",
  "address": "56 Bonney Road",
  "address line 2": "Leicester",
  "name": "Blue Breeze Fish Bar",
  "outcode": "LE3",
  "postcode": "9NG",
  "rating": 5.5,
  "type_of_food": "Fish & Chips"
}
```


`curl -v $RESTAURANTAPP_IP:8080/api/v1/restaurant/55f14313c7447c3da7052599`  

```bash
 Trying 10.43.58.222...
 Connected to 10.43.58.222 (10.43.58.222) port 8080 (#0)
 GET /api/v1/restaurant/55f14313c7447c3da7052599 HTTP/1.1
 Host: 10.43.58.222:8080
 User-Agent: curl/7.47.0
 Accept:

 HTTP 1.0, assume close after body
 HTTP/1.0 204 NO CONTENT
 Content-Type: text/html; charset=utf-8
 Server: Werkzeug/1.0.1 Python/3.6.12
 Date: Sun, 03 Jan 2021 18:57:27 GMT

 Closing connection 0
```

`curl $RESTAURANTAPP_IP:8080/api/v1/restaurant | jq`

```bash
* Closing connection 0
[
  {
    "URL": "http://www.just-eat.co.uk/restaurants-cn-chinese-cardiff/menu",
    "_id": "55f14312c7447c3da7051b26",
    "address": "228 City Road",
    "address line 2": "Cardiff",
    "name": ".CN Chinese",
    "outcode": "CF24",
    "postcode": "3JH",
    "rating": 5,
    "type_of_food": "Chinese"
  },
  {
    "URL": "http://www.just-eat.co.uk/restaurants-atthairestaurant/menu",
    "_id": "55f14312c7447c3da7051b28",
    "address": "30 Greyhound Road Hammersmith",
    "address line 2": "London",
    "name": "@ Thai Restaurant",
    "outcode": "W6",
    "postcode": "8NX",
    "rating": 4.5,
    "type_of_food": "Thai"
  },
  {
    "URL": "http://www.just-eat.co.uk/restaurants-atthairestaurant/menu",
    "_id": "55f14312c7447c3da7051b29",
    "address": "30 Greyhound Road Hammersmith",
    "address line 2": "London",
    "name": "@ Thai Restaurant",
    "outcode": "W6",
    "postcode": "8NX",
    "rating": 4.5,
    "type_of_food": "Thai"
  }

...

...
```



## DOCKER IMAGES:

- restaurantapp: `alvarorm/restaurantapp`
- mongo: `alvarorm/mymongodb`

## TRAVIS:

- https://travis-ci.com/github/alvarorm22/the-real-devops-challenge


## KUBERNETES ENVIRONMENT:


```bash
k8s|master⚡ ⇒ kubectl get deployments     
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
restaurantapp   3/3     3            3           5m47s

k8s|master⚡ ⇒ kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
restaurantapp-cc49fd7d9-6sk2x   1/1     Running   0          5m51s
restaurantapp-cc49fd7d9-vcfxv   1/1     Running   0          5m51s
restaurantapp-cc49fd7d9-s4bcp   1/1     Running   0          5m51s
mymongodb-0                     1/1     Running   0          101s

k8s|master⚡ ⇒ kubectl get statefulset                           
NAME        READY   AGE
mymongodb   1/1     2m1s

k8s|master⚡ ⇒ kubectl get svc
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
kubernetes      ClusterIP   10.43.0.1      <none>        443/TCP     31d
restaurantapp   ClusterIP   10.43.58.222   <none>        8080/TCP    5m6s
mymongodb       ClusterIP   10.43.67.253   <none>        27017/TCP   4m5s

k8s|master⚡ ⇒ kubectl get secrets
NAME                   TYPE                                  DATA   AGE
default-token-948r2    kubernetes.io/service-account-token   3      31d
restaurantapp-secret   Opaque                                1      6m41s
```
