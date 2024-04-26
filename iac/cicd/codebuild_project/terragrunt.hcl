dependency "iam_assume" {
  config_path  = "../iam_role_assume"
  skip_outputs = true
}

dependency "iam_codebuild" {
  config_path  = "../iam_role_codebuild"
  skip_outputs = true
}
