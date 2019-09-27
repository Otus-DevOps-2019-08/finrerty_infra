
#!/bin/bash
set -e

echo "Creating new instance..."
gcloud compute instances create reddit-app-test \
 --image=reddit-full-1569483021 \
 --zone=europe-west1-b \
 --machine-type=f1-micro \
 --tags=puma-server \
 --boot-disk-size=10GB \
 --restart-on-failure
