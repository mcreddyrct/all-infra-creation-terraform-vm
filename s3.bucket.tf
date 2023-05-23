resource "aws_s3_bucket" "tfstatefile" {
  bucket = "devops-remote-tfstatefile"

  tags = {
    Name        = "devops-remote-tfstatefile"
    Environment = "Dev"
  }
}