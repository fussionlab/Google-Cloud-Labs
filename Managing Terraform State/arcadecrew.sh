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

echo "${YELLOW_TEXT}${BOLD_TEXT}🔎 Checking your default region...${RESET_FORMAT}"
echo

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo "${BLUE_TEXT}${BOLD_TEXT}🌍 Default region is set to: ${REGION}${RESET_FORMAT}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}📝 Creating initial Terraform configuration with local backend...${RESET_FORMAT}"
echo

cat > main.tf <<EOF_END

provider "google" {
    project     = "$DEVSHELL_PROJECT_ID"
    region      = "$REGION"
}
resource "google_storage_bucket" "test-bucket-for-state" {
    name        = "$DEVSHELL_PROJECT_ID"
    location    = "US"
    uniform_bucket_level_access = true
}

terraform {
    backend "local" {
        path = "terraform/state/terraform.tfstate"
    }
}
EOF_END

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️  Initializing Terraform...${RESET_FORMAT}"
echo

terraform init

echo "${MAGENTA_TEXT}${BOLD_TEXT}🚧 Applying Terraform configuration to create your GCS bucket...${RESET_FORMAT}"
echo

terraform apply --auto-approve

echo "${GREEN_TEXT}${BOLD_TEXT}🔄 Updating Terraform configuration to use GCS backend...${RESET_FORMAT}"
echo

cat > main.tf <<EOF_END

provider "google" {
    project     = "$DEVSHELL_PROJECT_ID"
    region      = "$REGION"
}
resource "google_storage_bucket" "test-bucket-for-state" {
    name        = "$DEVSHELL_PROJECT_ID"
    location    = "US"
    uniform_bucket_level_access = true
}

terraform {
    backend "gcs" {
        bucket  = "$DEVSHELL_PROJECT_ID"
        prefix  = "terraform/state"
    }
}
EOF_END

echo "${YELLOW_TEXT}${BOLD_TEXT}🔄 Migrating Terraform state to GCS backend...${RESET_FORMAT}"
echo

yes | terraform init -migrate-state

echo "${CYAN_TEXT}${BOLD_TEXT}🏷️  Adding a label to your storage bucket...${RESET_FORMAT}"
echo

gsutil label ch -l "key:value" gs://$DEVSHELL_PROJECT_ID

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 IF YOU FOUND THIS HELPFUL, SUBSCRIBE ARCADE CREW! 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@Arcade61432${RESET_FORMAT}"
echo
