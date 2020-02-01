
variable "files" {
  type = list(string)
  description = <<EOF
A list of files whose contents will be hashed.
This is intended to construct a trigger for use by the local-exec provider.
EOF
}

variable "root" {
  type = string
  description = "Root path that is added to each file followed by a slash"
}


output "trigger" {
  value = sha256(join("", [
    for file in var.files: filesha256("${var.root}/${file}")
  ]))

  description = "Combined sha256 hash of all passed files"
}
