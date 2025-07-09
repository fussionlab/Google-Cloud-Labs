read -p "REGION: " REGION
read -p "Email: " EMAIL
PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud services enable artifactregistry.googleapis.com
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud artifacts repositories create my-go-repo \
    --repository-format=go \
    --location=$REGION \
    --description="Go repository"
gcloud artifacts repositories describe my-go-repo \
    --location=$REGION
go env -w GOPRIVATE=cloud.google.com/$PROJECT_ID
export GONOPROXY=github.com/GoogleCloudPlatform/artifact-registry-go-tools
GOPROXY=proxy.golang.org go run github.com/GoogleCloudPlatform/artifact-registry-go-tools/cmd/auth@latest add-locations --locations=$REGION
mkdir hello
cd hello
go mod init labdemo.app/hello
cat > hello.go<< EOF

package main

import "fmt"

func main() {
	fmt.Println("Hello, Go module from Artifact Registry!")
}
EOF
go build
git config --global user.email $EMAIL
git config --global user.name cls 
git config --global init.defaultBranch main 
git init
git add .
git commit -m "Initial commit"
git tag v1.0.0

gcloud artifacts go upload \
  --repository=my-go-repo \
  --location=$REGION \
  --module-path=labdemo.app/hello \
  --version=v1.0.0 \
  --source=.
gcloud artifacts packages list --repository=my-go-repo --location=$REGION
