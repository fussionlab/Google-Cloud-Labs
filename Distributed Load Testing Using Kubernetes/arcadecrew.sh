#!/bin/bash
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
DIM_TEXT=$'\033[2m'
STRIKETHROUGH_TEXT=$'\033[9m'
BOLD_TEXT=$'\033[1m'
RESET_FORMAT=$'\033[0m'

clear

echo
echo "${CYAN_TEXT}${BOLD_TEXT}===================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🚀     INITIATING EXECUTION     🚀${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}===================================${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🔎 Fetching your GCP project and zone details...${RESET_FORMAT}"
PROJECT=$(gcloud config get-value project)
ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(echo "$ZONE" | cut -d '-' -f 1-2)
CLUSTER=gke-load-test
TARGET=${PROJECT}.appspot.com

echo "${GREEN_TEXT}${BOLD_TEXT}🌍 Setting your compute region and zone...${RESET_FORMAT}"
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

echo "${BLUE_TEXT}${BOLD_TEXT}☁️ Downloading distributed load testing resources from Cloud Storage...${RESET_FORMAT}"
gsutil -m cp -r gs://spls/gsp182/distributed-load-testing-using-kubernetes .

echo "${CYAN_TEXT}${BOLD_TEXT}📁 Moving into the sample webapp directory...${RESET_FORMAT}"
cd distributed-load-testing-using-kubernetes/sample-webapp/

echo "${MAGENTA_TEXT}${BOLD_TEXT}🛠️ Updating Python runtime version in app.yaml...${RESET_FORMAT}"
sed -i "s/python37/python39/g" app.yaml

cd ..

echo "${YELLOW_TEXT}${BOLD_TEXT}🐳 Building Docker image for Locust tasks...${RESET_FORMAT}"
gcloud builds submit --tag gcr.io/$PROJECT/locust-tasks:latest docker-image/.

echo "${GREEN_TEXT}${BOLD_TEXT}🚦 Creating your App Engine application...${RESET_FORMAT}"
gcloud app create --region=$REGION

echo "${BLUE_TEXT}${BOLD_TEXT}🚀 Deploying the sample web application to App Engine...${RESET_FORMAT}"
gcloud app deploy sample-webapp/app.yaml --quiet

echo "${CYAN_TEXT}${BOLD_TEXT}🔧 Spinning up your Kubernetes cluster for load testing...${RESET_FORMAT}"
gcloud container clusters create $CLUSTER \
  --zone $ZONE \
  --num-nodes=5

echo "${MAGENTA_TEXT}${BOLD_TEXT}🔄 Configuring Locust master and worker YAML files with your project and target host...${RESET_FORMAT}"
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-worker-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-worker-controller.yaml

echo "${YELLOW_TEXT}${BOLD_TEXT}🚦 Deploying Locust master controller to Kubernetes...${RESET_FORMAT}"
kubectl apply -f kubernetes-config/locust-master-controller.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}🔍 Checking status of Locust master pod...${RESET_FORMAT}"
kubectl get pods -l app=locust-master

echo "${CYAN_TEXT}${BOLD_TEXT}🌐 Creating Locust master service...${RESET_FORMAT}"
kubectl apply -f kubernetes-config/locust-master-service.yaml

echo "${GREEN_TEXT}${BOLD_TEXT}🔗 Retrieving Locust master service details...${RESET_FORMAT}"
kubectl get svc locust-master

echo "${MAGENTA_TEXT}${BOLD_TEXT}🚦 Deploying Locust worker controller to Kubernetes...${RESET_FORMAT}"
kubectl apply -f kubernetes-config/locust-worker-controller.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}🔍 Checking status of Locust worker pods...${RESET_FORMAT}"
kubectl get pods -l app=locust-worker

echo "${YELLOW_TEXT}${BOLD_TEXT}⚡ Scaling Locust worker deployment to 20 replicas...${RESET_FORMAT}"
kubectl scale deployment/locust-worker --replicas=20

echo "${GREEN_TEXT}${BOLD_TEXT}🔍 Verifying scaled Locust worker pods...${RESET_FORMAT}"
kubectl get pods -l app=locust-worker

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖  If you enjoyed this setup, don't forget to subscribe to Arcade Crew!${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@Arcade61432${RESET_FORMAT}"
echo
