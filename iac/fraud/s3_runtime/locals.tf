locals {
  region = (
    data.aws_region.this.name == element(keys(var.backend_bucket), 0)
    ? element(keys(var.backend_bucket), 1) : element(keys(var.backend_bucket), 0)
  )
  spf_gid = (var.spf_gid == null ? (
    data.aws_region.this.name == element(keys(var.backend_bucket), 0)
    ? random_id.this.hex : data.terraform_remote_state.s3.0.outputs.spf_gid
  ) : var.spf_gid)
}
