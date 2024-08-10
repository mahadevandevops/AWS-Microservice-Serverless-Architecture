# resource "random_id" "bucket_suffix" {
#   byte_length = 6
# }
# resource "aws_s3_bucket" "cmmahadevan_backend_s3" {
#   bucket = "cmmahadevan-backend-s3-${random_id.bucket_suffix.hex}"
# }
