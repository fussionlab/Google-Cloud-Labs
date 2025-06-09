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

echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Checking your active Google Cloud accounts...${RESET_FORMAT}"
echo

gcloud auth list

echo "${GREEN_TEXT}${BOLD_TEXT}🌍 Fetching your default compute zone...${RESET_FORMAT}"
echo

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo "${BLUE_TEXT}${BOLD_TEXT}🗺️  Your default compute zone is: ${ZONE}${RESET_FORMAT}"

echo "${GREEN_TEXT}${BOLD_TEXT}🌎 Fetching your default compute region...${RESET_FORMAT}"
echo

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo "${BLUE_TEXT}${BOLD_TEXT}🗺️  Your default compute region is: ${REGION}${RESET_FORMAT}"

echo "${BLUE_TEXT}${BOLD_TEXT}🖥️  Creating two VM instances with different network tiers...${RESET_FORMAT}"
echo

gcloud compute instances create vm-premium --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-tier=PREMIUM --image-family=debian-11 --image-project=debian-cloud && gcloud compute instances create vm-standard --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-tier=STANDARD --image-family=debian-11 --image-project=debian-cloud

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 IF YOU FOUND THIS HELPFUL, SUBSCRIBE ARCADE CREW! 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@Arcade61432${RESET_FORMAT}"
echo
