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

echo "${BLUE_TEXT}${BOLD_TEXT}🔍 Detecting your GCP zone configuration...${RESET_FORMAT}"
echo

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

if [ -z "$ZONE" ]; then
  echo "${YELLOW_TEXT}${BOLD_TEXT}⚠️  Zone not found.${RESET_FORMAT}"
  echo "${MAGENTA_TEXT}${BOLD_TEXT}📝 Please provide your preferred GCP zone for deployment${RESET_FORMAT}"
  read -p "${CYAN_TEXT}${BOLD_TEXT}Please enter the zone: ${RESET_FORMAT}" ZONE
  export ZONE
fi

echo "${BLUE_TEXT}${BOLD_TEXT}🌍 Configuring regional settings for your deployment...${RESET_FORMAT}"
echo

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

if [ -z "$REGION" ]; then
  export REGION="${ZONE%-*}"
  echo "${GREEN_TEXT}${BOLD_TEXT}✅ Region derived from zone: ${REGION}${RESET_FORMAT}"
fi

echo "${BLUE_TEXT}${BOLD_TEXT}🔧 Activating Data Catalog API service...${RESET_FORMAT}"
echo

gcloud services enable datacatalog.googleapis.com

echo "${BLUE_TEXT}${BOLD_TEXT}🆔 Retrieving your current GCP project identifier...${RESET_FORMAT}"
echo

export PROJECT_ID=$(gcloud config get-value project)

echo "${BLUE_TEXT}${BOLD_TEXT}📦 Downloading SQL Server connector toolkit...${RESET_FORMAT}"
echo

gsutil cp gs://spls/gsp814/cloudsql-sqlserver-tooling.zip .
unzip cloudsql-sqlserver-tooling.zip

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️  Customizing Terraform configuration for your region...${RESET_FORMAT}"
echo

cd cloudsql-sqlserver-tooling/infrastructure/terraform

sed -i "s/us-central1/$REGION/g" variables.tf

sed -i "s/$REGION-a/$ZONE/g" variables.tf

echo "${BLUE_TEXT}${BOLD_TEXT}🏗️  Initializing SQL Server database infrastructure...${RESET_FORMAT}"
echo

cd ~/cloudsql-sqlserver-tooling
bash init-db.sh

echo "${BLUE_TEXT}${BOLD_TEXT}🔐 Creating dedicated service account for SQL Server connector...${RESET_FORMAT}"
echo

gcloud iam service-accounts create sqlserver2dc-credentials \
--display-name  "Service Account for SQL Server to Data Catalog connector" \
--project $PROJECT_ID

echo "${BLUE_TEXT}${BOLD_TEXT}🔑 Generating authentication credentials...${RESET_FORMAT}"
echo

gcloud iam service-accounts keys create "sqlserver2dc-credentials.json" \
--iam-account "sqlserver2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com"

echo "${BLUE_TEXT}${BOLD_TEXT}👥 Assigning administrative permissions...${RESET_FORMAT}"
echo

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:sqlserver2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com" \
--quiet \
--project $PROJECT_ID \
--role "roles/datacatalog.admin"

echo "${BLUE_TEXT}${BOLD_TEXT}📊 Extracting deployment configuration details...${RESET_FORMAT}"
echo

cd infrastructure/terraform/

public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)

echo "${BLUE_TEXT}${BOLD_TEXT}🐳 Executing SQL Server to Data Catalog connector...${RESET_FORMAT}"
echo

cd ~/cloudsql-sqlserver-tooling

docker run --rm --tty -v \
"$PWD":/data mesmacosta/sqlserver2datacatalog:stable \
--datacatalog-project-id=$PROJECT_ID \
--datacatalog-location-id=$REGION \
--sqlserver-host=$public_ip_address \
--sqlserver-user=$username \
--sqlserver-pass=$password \
--sqlserver-database=$database


echo "${BLUE_TEXT}${BOLD_TEXT}📦 Downloading PostgreSQL connector toolkit...${RESET_FORMAT}"
echo

cd

gsutil cp gs://spls/gsp814/cloudsql-postgresql-tooling.zip .
unzip cloudsql-postgresql-tooling.zip

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️  Adapting PostgreSQL configuration for your environment...${RESET_FORMAT}"
echo

cd cloudsql-postgresql-tooling/infrastructure/terraform

sed -i "s/us-central1/$REGION/g" variables.tf

echo "${BLUE_TEXT}${BOLD_TEXT}🐘 Establishing PostgreSQL database foundation...${RESET_FORMAT}"
echo

cd ~/cloudsql-postgresql-tooling
bash init-db.sh

echo "${BLUE_TEXT}${BOLD_TEXT}🔐 Provisioning PostgreSQL service account...${RESET_FORMAT}"
echo

gcloud iam service-accounts create postgresql2dc-credentials \
--display-name  "Service Account for PostgreSQL to Data Catalog connector" \
--project $PROJECT_ID

echo "${BLUE_TEXT}${BOLD_TEXT}🔑 Issuing PostgreSQL authentication keys...${RESET_FORMAT}"
echo

gcloud iam service-accounts keys create "postgresql2dc-credentials.json" \
--iam-account "postgresql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com"

echo "${BLUE_TEXT}${BOLD_TEXT}👥 Configuring PostgreSQL access permissions...${RESET_FORMAT}"
echo

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:postgresql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com" \
--quiet \
--project $PROJECT_ID \
--role "roles/datacatalog.admin"

echo "${BLUE_TEXT}${BOLD_TEXT}📊 Collecting PostgreSQL deployment information...${RESET_FORMAT}"
echo

cd infrastructure/terraform/

public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)

echo "${BLUE_TEXT}${BOLD_TEXT}🐳 Running PostgreSQL to Data Catalog synchronization...${RESET_FORMAT}"
echo

cd ~/cloudsql-postgresql-tooling

docker run --rm --tty -v \
"$PWD":/data mesmacosta/postgresql2datacatalog:stable \
--datacatalog-project-id=$PROJECT_ID \
--datacatalog-location-id=$REGION \
--postgresql-host=$public_ip_address \
--postgresql-user=$username \
--postgresql-pass=$password \
--postgresql-database=$database


echo "${BLUE_TEXT}${BOLD_TEXT}📦 Acquiring MySQL connector resources...${RESET_FORMAT}"
echo

cd

gsutil cp gs://spls/gsp814/cloudsql-mysql-tooling.zip .
unzip cloudsql-mysql-tooling.zip

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️  Tailoring MySQL configuration parameters...${RESET_FORMAT}"
echo

cd cloudsql-mysql-tooling/infrastructure/terraform

sed -i "s/us-central1/$REGION/g" variables.tf

echo "${BLUE_TEXT}${BOLD_TEXT}🐬 Building MySQL database infrastructure...${RESET_FORMAT}"
echo

cd ~/cloudsql-mysql-tooling
bash init-db.sh

echo "${BLUE_TEXT}${BOLD_TEXT}🔐 Establishing MySQL service credentials...${RESET_FORMAT}"
echo

gcloud iam service-accounts create mysql2dc-credentials \
--display-name  "Service Account for MySQL to Data Catalog connector" \
--project $PROJECT_ID

echo "${BLUE_TEXT}${BOLD_TEXT}🔑 Creating MySQL access credentials...${RESET_FORMAT}"
echo

gcloud iam service-accounts keys create "mysql2dc-credentials.json" \
--iam-account "mysql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com"

echo "${BLUE_TEXT}${BOLD_TEXT}👥 Authorizing MySQL catalog permissions...${RESET_FORMAT}"
echo

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:mysql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com" \
--quiet \
--project $PROJECT_ID \
--role "roles/datacatalog.admin"

echo "${BLUE_TEXT}${BOLD_TEXT}📊 Harvesting MySQL configuration data...${RESET_FORMAT}"
echo

cd infrastructure/terraform/

public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)

echo "${BLUE_TEXT}${BOLD_TEXT}🐳 Initiating MySQL to Data Catalog migration...${RESET_FORMAT}"
echo

cd ~/cloudsql-mysql-tooling

docker run --rm --tty -v \
"$PWD":/data mesmacosta/mysql2datacatalog:stable \
--datacatalog-project-id=$PROJECT_ID \
--datacatalog-location-id=$REGION \
--mysql-host=$public_ip_address \
--mysql-user=$username \
--mysql-pass=$password \
--mysql-database=$database

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 IF YOU FOUND THIS HELPFUL, SUBSCRIBE ARCADE CREW! 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@Arcade61432${RESET_FORMAT}"
echo
