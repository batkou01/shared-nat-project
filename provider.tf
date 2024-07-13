terraform {
  required_providers {
    aws = {
        source                      = "hashicorp/aws"
        configuration_aliases       = [ aws.hongkong ]
    }
  }
}

provider "aws" {
    region                          = "ap-southeast-1"
}

provider "aws" {
    region                          = "ap-east-1"
    alias                           = "hongkong"
}