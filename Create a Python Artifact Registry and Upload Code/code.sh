read -p "REGION: " REGION
PROJECT_ID=$DEVSHELL_PROJECT_ID
gcloud services enable artifactregistry.googleapis.com
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud artifacts repositories create my-python-repo \
    --repository-format=python \
    --location=$REGION \
    --description="Python package repository"
pip install keyrings.google-artifactregistry-auth
pip config set global.extra-index-url https://$REGION-python.pkg.dev/$PROJECT_ID/my-python-repo/simple
mkdir my-package
cd my-package

cat > setup.py <<EOF
from setuptools import setup, find_packages

setup(
    name='my_package',
    version='0.1.0',
    author='cls',
    author_email='"EMAIL"',
    packages=find_packages(exclude=['tests']),
    install_requires=[
        # List your dependencies here
    ],
    description='A sample Python package',
)

EOF

cat > ./__init__.py << EOF
# my_package/__init__.py

EOF

cat >  my_module.py << EOF

def hello_world():
    return 'Hello, world!'
EOF

pip install twine
python setup.py sdist bdist_wheel

python3 -m twine upload --repository-url https://$REGION-python.pkg.dev/$PROJECT_ID/my-python-repo/ dist/*
gcloud artifacts packages list --repository=my-python-repo --location=$REGION
