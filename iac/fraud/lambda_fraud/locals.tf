locals {
  spf_gid = data.terraform_remote_state.s3.outputs.spf_gid
  region = (
    data.aws_region.this.name == element(keys(var.backend_bucket), 0)
    ? element(keys(var.backend_bucket), 1) : element(keys(var.backend_bucket), 0)
  )
}
