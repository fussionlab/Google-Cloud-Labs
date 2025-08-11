read -p "REGION: " REGION
gcloud config set compute/region $REGION
gcloud storage cp -r gs://spls/gsp068/appengine-java21/appengine-java21/* .
cd helloworld/http-server
gcloud app deploy
