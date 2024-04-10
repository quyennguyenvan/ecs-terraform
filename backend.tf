terraform {
  backend "s3" {
    bucket = "ezservices"
    key    = "ezservices/terraform_state.tfstate"
    region = "us-west-2"
  }
}
