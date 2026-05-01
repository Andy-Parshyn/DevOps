terraform {
  backend "s3" {
    bucket       = "terraform-state-andy-parshyn-devops-study"
    key          = "lesson-10/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile   = true
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}