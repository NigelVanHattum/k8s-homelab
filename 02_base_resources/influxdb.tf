resource "minio_s3_bucket" "influxdb_bucket" {
  bucket  = "influxdb-data"
  acl     = "private"
}