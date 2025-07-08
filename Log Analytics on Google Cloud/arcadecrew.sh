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

echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 👤 Checking your active Google Cloud accounts... --<< ${FORMAT_RESET}"
gcloud auth list

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🌍 Fetching your default compute zone and region... --<< ${FORMAT_RESET}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🏷️  Retrieving your current GCP project ID... --<< ${FORMAT_RESET}"
export PROJECT_ID=$(gcloud config get-value project)

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 📍 Setting your compute zone and region... --<< ${FORMAT_RESET}"
gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"

echo -e "${COLOR_BLUE}${STYLE_BOLD} >>-- 🔑 Getting Kubernetes cluster credentials... --<< ${FORMAT_RESET}"
gcloud container clusters get-credentials day2-ops --region $REGION

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🛠️  Cloning the microservices demo repository... --<< ${FORMAT_RESET}"
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git

echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 📂 Moving into the project directory... --<< ${FORMAT_RESET}"
cd microservices-demo

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🚢 Deploying Kubernetes manifests... --<< ${FORMAT_RESET}"
kubectl apply -f release/kubernetes-manifests.yaml

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- ⏳ Waiting for pods to initialize (45 seconds)... --<< ${FORMAT_RESET}"

tput civis
trap 'tput cnorm; exit' SIGINT

duration=45
pulse_chars=("○" "◌" "●" "◌")

for ((i=duration; i>0; i--)); do
    index=$(( (duration - i) % 4 ))
    echo -ne "${COLOR_MAGENTA}${STYLE_BOLD}${pulse_chars[$index]}${FORMAT_RESET} Synchronizing... ${i}s remaining \r"
    sleep 1
done

tput cnorm
echo -e "\n${COLOR_GREEN}${STYLE_BOLD}✔️ System synchronized.${FORMAT_RESET}\n"

echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🔍 Listing all running pods... --<< ${FORMAT_RESET}"
kubectl get pods

echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 🌐 Fetching the external IP of the frontend service... --<< ${FORMAT_RESET}"
export EXTERNAL_IP=$(kubectl get service frontend-external -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo $EXTERNAL_IP

echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🕵️  Testing the frontend service endpoint... --<< ${FORMAT_RESET}"
curl -o /dev/null -s -w "%{http_code}\n"  http://${EXTERNAL_IP}

echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 📊 Enabling analytics on the default logging bucket... --<< ${FORMAT_RESET}"
gcloud logging buckets update _Default --project=$DEVSHELL_PROJECT_ID --location=global --enable-analytics

echo -e "${COLOR_BLUE}${STYLE_BOLD} >>-- 📤 Creating a new logging sink for Kubernetes logs... --<< ${FORMAT_RESET}"
gcloud logging sinks create day2ops-sink \
    logging.googleapis.com/projects/$DEVSHELL_PROJECT_ID/locations/global/buckets/day2ops-log \
    --log-filter='resource.type="k8s_container"' \
    --include-children --format='json'

echo ""

echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 🪣 Create a new Log bucket in the Cloud Console: --<< ${FORMAT_RESET} \033[1;34mhttps://console.cloud.google.com/logs/storage/bucket?inv=1&invt=Ab2LhA&project=$DEVSHELL_PROJECT_ID\033[0m"

echo ""

echo
echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 💖 Enjoyed this? Subscribe to Arcade Crew for more! --<< ${FORMAT_RESET}"
echo "${COLOR_BLUE}${STYLE_BOLD}https://www.youtube.com/@arcade_creww${FORMAT_RESET}"
echo
