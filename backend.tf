terraform {
    backend "s3" {
        bucket      = "marc.gregorio-bucket"
        key         = "shared-nat.tfstate"
        region      = "ap-southeast-1"
    }
}