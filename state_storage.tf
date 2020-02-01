

terraform {
  backend "s3" {
    key    = "tf.state"
  }
}
