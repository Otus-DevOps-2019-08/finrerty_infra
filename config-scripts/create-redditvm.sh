
#!/bin/bash
set -e

echo "Creating new instance..."
gcloud compute instances create reddit-app-test \
 --image=reddit-full-1569413083 \
 --restart-on-failure
