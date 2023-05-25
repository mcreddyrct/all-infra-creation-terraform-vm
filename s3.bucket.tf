resource "aws_s3_bucket" "tfstatefile" {
  bucket = "devops-remote-tfstatefile-rct"

  tags = {
    Name        = "devops-remote-tfstatefile-rct"
    Environment = "Dev"
  }
}