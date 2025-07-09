read -p "REGION: " REGION

PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud services enable artifactregistry.googleapis.com
gcloud config set project $PROJECT_ID

gcloud config set compute/region $REGION

gcloud artifacts repositories create my-maven-repo \
    --repository-format=maven \
    --location=$REGION \
    --description="Maven repository"
	
gcloud artifacts repositories list --location=$REGION

gcloud artifacts print-settings mvn --repository=my-maven-repo --project=$PROJECT_ID --location=$REGION

mvn archetype:generate \
    -DgroupId=com.example \
    -DartifactId=my-app \
    -Dversion=1.0-SNAPSHOT \
    -DarchetypeArtifactId=maven-archetype-quickstart \
    -DinteractiveMode=false
cd my-app

echo "" > pom.xml

cat > pom.xml <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/maven-v4_0_0.xsd">
  
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>my-app</artifactId>
  <packaging>jar</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>my-app</name>
  <url>http://maven.apache.org</url>

  <!-- Build section with Artifact Registry Authentication -->
  <build>
    <extensions>
      <extension>
        <groupId>com.google.cloud.artifactregistry</groupId>
        <artifactId>artifactregistry-maven-wagon</artifactId>
        <version>2.2.0</version>
      </extension>
    </extensions>
  </build>

  <!-- Distribution Management for Artifact Registry -->
  <distributionManagement>
    <repository>
      <id>artifact-registry</id>
      <url>artifactregistry://us-central1-maven.pkg.dev/qwiklabs-gcp-03-a3e2d173559d/my-maven-repo</url>
    </repository>
    <snapshotRepository>
      <id>artifact-registry</id>
      <url>artifactregistry://us-central1-maven.pkg.dev/qwiklabs-gcp-03-a3e2d173559d/my-maven-repo</url>
    </snapshotRepository>
  </distributionManagement>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>

EOF
gcloud artifacts print-settings mvn --repository=my-maven-repo --project=$PROJECT_ID --location=$REGION > example.pom

mvn deploy

gcloud artifacts versions list --repository=my-maven-repo --package=com.example:my-app --location=$REGION
