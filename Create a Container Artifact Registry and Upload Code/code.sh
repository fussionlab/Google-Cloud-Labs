read -p "REGION: " REGION
PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud services enable artifactregistry.googleapis.com
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION

gcloud artifacts repositories create my-docker-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository"
gcloud auth configure-docker $REGION-docker.pkg.dev

mkdir sample-app
cd sample-app
echo "FROM nginx:latest" > Dockerfile

docker build -t nginx-image .

docker tag nginx-image $REGION-docker.pkg.dev/$PROJECT_ID/my-docker-repo/nginx-image:latest

docker push $REGION-docker.pkg.dev/$PROJECT_ID/my-docker-repo/nginx-image:latest
