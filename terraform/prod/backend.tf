terraform {
  backend "gcs" {
    bucket = "reddit-app-storage-bucket"
    prefix = "terraform/state/prod"
  }
}
