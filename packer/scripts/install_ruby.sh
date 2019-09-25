#!/bin/bash
set -e

echo "Ruby installation in progress..."
apt update
apt install ruby-full ruby-bundler build-essential -y
