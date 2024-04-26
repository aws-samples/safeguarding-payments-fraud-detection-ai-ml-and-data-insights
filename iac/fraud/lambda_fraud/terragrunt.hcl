dependency "ecr" {
  config_path  = "../ecr_fraud"
  skip_outputs = true
}

dependency "iam" {
  config_path  = "../iam_role_lambda_fraud"
  skip_outputs = true
}
