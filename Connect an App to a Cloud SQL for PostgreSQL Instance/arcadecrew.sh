#!/bin/bash
# ============================================================
#  Copyright © 2025 Arcade Crew
#  This script is a proprietary work of Arcade Crew.
#  All rights reserved.
#
#  This script is intended solely for execution via "curl" command only.
#
#  You are NOT permitted to:
#    ❌ Copy
#    ❌ Modify
#    ❌ Redistribute
#    ❌ Host or mirror this script elsewhere
#
#  Unauthorized use constitutes copyright infringement and may
#  result in a DMCA takedown or legal action.
# ============================================================

COLOR_BLACK=$'\033[0;90m'
COLOR_RED=$'\033[0;91m'
COLOR_GREEN=$'\033[0;92m'
COLOR_YELLOW=$'\033[0;93m'
COLOR_BLUE=$'\033[0;94m'
COLOR_MAGENTA=$'\033[0;95m'
COLOR_CYAN=$'\033[0;96m'
COLOR_WHITE=$'\033[0;97m'
STYLE_DIM=$'\033[2m'
STYLE_STRIKE=$'\033[9m'
STYLE_BOLD=$'\033[1m'
FORMAT_RESET=$'\033[0m'
BG_BLUE=$'\033[44m'
BG_YELLOW=$'\033[43m'
FG_BLACK=$'\033[30m'
FG_WHITE=$'\033[97m'

clear

echo -e "                     ${COLOR_CYAN}▲${FORMAT_RESET}"
echo -e "                    ${COLOR_CYAN}▲ ▲${FORMAT_RESET}"
echo -e "   ${COLOR_WHITE}${STYLE_BOLD}🚀  LET'S GET STARTED WITH THIS LAB!  🚀${FORMAT_RESET}"
echo -e "${COLOR_BLUE}${STYLE_BOLD}▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃${FORMAT_RESET}"
echo

echo
echo -e "${COLOR_RED}${STYLE_BOLD} >>-- This lab will take 12-15 minutes --<< ${FORMAT_RESET}"
echo

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🗺️ Checking your default compute zone... --<< ${FORMAT_RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

if [[ -z "$ZONE" ]]; then
    echo -en "${COLOR_YELLOW}${STYLE_BOLD}Enter your zone: ${FORMAT_RESET}"
    read ZONE
fi

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🌍 Determining your compute region... --<< ${FORMAT_RESET}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

if [[ -z "$REGION" ]]; then
    REGION="${ZONE%-*}"
fi

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🛠️ Enabling Artifact Registry API for your project... --<< ${FORMAT_RESET}"
gcloud services enable artifactregistry.googleapis.com

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 🏷️ Fetching your GCP Project ID... --<< ${FORMAT_RESET}"
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export CLOUDSQL_SERVICE_ACCOUNT=cloudsql-service-account

echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 👤 Creating a dedicated Cloud SQL service account... --<< ${FORMAT_RESET}"
gcloud iam service-accounts create $CLOUDSQL_SERVICE_ACCOUNT --project=$PROJECT_ID

echo -e "${COLOR_BLUE}${STYLE_BOLD} >>-- 🔑 Assigning Cloud SQL Admin role to the service account... --<< ${FORMAT_RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$CLOUDSQL_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/cloudsql.admin" 

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🗝️ Generating service account key for authentication... --<< ${FORMAT_RESET}"
gcloud iam service-accounts keys create $CLOUDSQL_SERVICE_ACCOUNT.json \
    --iam-account=$CLOUDSQL_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --project=$PROJECT_ID

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- ☁️ Spinning up a GKE cluster for PostgreSQL... --<< ${FORMAT_RESET}"
gcloud container clusters create postgres-cluster \
--zone=$ZONE --num-nodes=2

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 🔒 Creating Kubernetes secret for Cloud SQL credentials... --<< ${FORMAT_RESET}"
kubectl create secret generic cloudsql-instance-credentials \
--from-file=credentials.json=$CLOUDSQL_SERVICE_ACCOUNT.json
    
echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 🔐 Storing database credentials securely in Kubernetes... --<< ${FORMAT_RESET}"
kubectl create secret generic cloudsql-db-credentials \
--from-literal=username=postgres \
--from-literal=password=supersecret! \
--from-literal=dbname=gmemegen_db

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 📦 Downloading gMemegen application files from Cloud Storage... --<< ${FORMAT_RESET}"
gsutil -m cp -r gs://spls/gsp919/gmemegen .
cd gmemegen

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🌎 Setting up region, project, and repository variables... --<< ${FORMAT_RESET}"
export REGION=${ZONE%-*}
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export REPO=gmemegen

echo -e "${COLOR_BLUE}${STYLE_BOLD} >>-- 🐳 Configuring Docker authentication for Artifact Registry... --<< ${FORMAT_RESET}"
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 🏗️ Creating a Docker repository for your app... --<< ${FORMAT_RESET}"
gcloud artifacts repositories create $REPO \
    --repository-format=docker --location=$REGION

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🔨 Building your gMemegen Docker image... --<< ${FORMAT_RESET}"
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/gmemegen/gmemegen-app:v1 .

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🚀 Pushing Docker image to Artifact Registry... --<< ${FORMAT_RESET}"
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/gmemegen/gmemegen-app:v1

echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 📝 Updating deployment YAML with image and instance details... --<< ${FORMAT_RESET}"
sed -i "33c\          image: $REGION-docker.pkg.dev/$PROJECT_ID/gmemegen/gmemegen-app:v1" gmemegen_deployment.yaml

sed -i "60c\                    "-instances=$PROJECT_ID:$REGION:postgres-gmemegen=tcp:5432"," gmemegen_deployment.yaml

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 📦 Deploying gMemegen app to Kubernetes... --<< ${FORMAT_RESET}"
kubectl create -f gmemegen_deployment.yaml

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- ⏳ Waiting for pods to be created... --<< ${FORMAT_RESET}"
kubectl get pods

echo "Awaiting system response..."
tput civis
trap 'tput cnorm; exit' SIGINT
duration=20
pulse_chars=("○" "◌" "●" "◌")
for i in $(seq $duration -1 1); do
    index=$(( (duration - i) % 4 ))
    echo -ne "${COLOR_CYAN}${STYLE_BOLD}${pulse_chars[$index]}${FORMAT_RESET} Synchronizing... ${i}s remaining \r"
    sleep 1
done
tput cnorm
echo -e "\n✔️ System synchronized."

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🌐 Exposing your app with a LoadBalancer service... --<< ${FORMAT_RESET}"
kubectl expose deployment gmemegen \
    --type "LoadBalancer" \
    --port 80 --target-port 8080

echo "Awaiting system response..."
tput civis
trap 'tput cnorm; exit' SIGINT
duration=20
pulse_chars=("○" "◌" "●" "◌")
for i in $(seq $duration -1 1); do
    index=$(( (duration - i) % 4 ))
    echo -ne "${COLOR_CYAN}${STYLE_BOLD}${pulse_chars[$index]}${FORMAT_RESET} Synchronizing... ${i}s remaining \r"
    sleep 1
done
tput cnorm
echo -e "\n✔️ System synchronized."

echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 🔎 Fetching the external IP of your Load Balancer... --<< ${FORMAT_RESET}"
export LOAD_BALANCER_IP=$(kubectl get svc gmemegen \
-o=jsonpath='{.status.loadBalancer.ingress[0].ip}' -n default)
echo gMemegen Load Balancer Ingress IP: http://$LOAD_BALANCER_IP

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 📄 Viewing logs from your running pod... --<< ${FORMAT_RESET}"
POD_NAME=$(kubectl get pods --output=json | jq -r ".items[0].metadata.name")
kubectl logs $POD_NAME gmemegen | grep "INFO"

kubectl describe service gmemegen

echo
echo "${BG_YELLOW}${STYLE_BOLD}${FG_WHITE}  * * .         .         * *   * * .         .         * * ${FORMAT_RESET}"
echo "${BG_YELLOW}${STYLE_BOLD}${FG_WHITE}      ${STYLE_BOLD}   KINDLY FOLLOW VIDEO INSTRUCTIONS CAREFULLY         ${FORMAT_RESET}"
echo "${BG_YELLOW}${STYLE_BOLD}${FG_WHITE} .       .      * * .           .  .       .      * * .   . ${FORMAT_RESET}"

echo
echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 💖 Enjoyed this? Subscribe to Arcade Crew for more! --<< ${FORMAT_RESET}"
echo "${COLOR_BLUE}${STYLE_BOLD}https://www.youtube.com/@arcade_creww${FORMAT_RESET}"
echo
