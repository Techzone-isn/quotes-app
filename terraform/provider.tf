provider "aws" {
  alias                  = "custom"  # Defining an alias for this provider configuration
  skip_credentials_validation = true  # Skipping credentials validation initially

  # Defining variables for access key, secret key, and region
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
