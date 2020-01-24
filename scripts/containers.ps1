##########
# KeyCloak
docker run --name keycloak -d -p 5080:8080 -e 'KEYCLOAK_USER=admin' -e 'KEYCLOAK_PASSWORD=admin' jboss/keycloak
##########
# Sonaqube
docker run --name sonarqube -d -p 9000:9000 sonarqube
##########
# Nexus
docker run --name nexus -d -p 8081:8081 sonatype/nexus3
##########
# Postgres
docker network create postgres
docker volume create postgres-data
docker run --name postgres -d -p 5432:5432 --network postgres -v postgres-data:/var/lib/postgresql/data -e 'POSTGRES_PASSWORD=admin' postgres
# Pgadmin4
docker volume create pgadmin4-data
docker run --name pgadmin4 -d -p 5480:80 --network postgres -v pgadmin4-data:/var/lib/pgadmin -e 'PGADMIN_DEFAULT_EMAIL=admin@nowhere.com' -e 'PGADMIN_DEFAULT_PASSWORD=admin' dpage/pgadmin4
# cli
docker exec -it postgres psql -U postgres
##########
# Mongo
docker network create mongo
docker volume create mongo-data
docker volume create mongo-config
docker run --name mongo -d -p 27017:27017 --network mongo -v mongo-data:/data/db -v mongo-config:/data/configdb mongo
# Gui
docker run --name mongo-express -d -p 27081:8081 --network mongo -e ME_CONFIG_MONGODB_SERVER=mongo mongo-express
# cli
docker exec -it mongo mongo
##########
# proxy
-e http_proxy=http://docker.for.win.localhost:3128 -e https_proxy=http://docker.for.win.localhost:3128
##########
# Connect
docker exec -it nexus /bin/bash
# Logs
docker logs -f gitlab-runner
##########
# Params
-d # detach : release command line
-p local:container # open port in local network
-e NAME=value # environnement variable
-v /local:/container # bind volume
##########
