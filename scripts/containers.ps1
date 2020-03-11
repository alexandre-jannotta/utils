##########
# proxy
-e http_proxy=http://docker.for.win.localhost:3128 -e https_proxy=http://docker.for.win.localhost:3128
##########
# Connect
docker exec -it container /bin/bash
# Logs
docker logs -f container
##########
# Params
-d # detach : release command line
-p local:container # open port in local network
-e NAME=value # environnement variable
-v /local:/container # bind volume
##########
