module "vpc" {
  source = "./modules/1-vpc"
  providers = {
    aws = aws
  }
}

module "s3sqs" {
  source = "./modules/2-s3sqs"
  providers = {
    aws = aws
  }
  cidr_block = module.vpc.cidr_block
  depends_on = [module.vpc]
}

module "dynamodb" {
  source = "./modules/3-dynamodb"
  providers = {
    aws = aws
  }
  cidr_block = module.vpc.cidr_block
  depends_on = [module.vpc]
}


module "cognito" {
  source = "./modules/5-cognito"
  providers = {
    aws = aws
  }
}

module "ecr" {
  source = "./modules/6-ecr"
  providers = {
    aws = aws
  }
}

# module "eks" {
#   source = "./modules/4-eks"
#   providers = {
#     aws = aws
#   }
#   cidr_block = module.vpc.cidr_block
#   vpc_id = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnet_ids
#   dynamodb_access_policy_arn = module.dynamodb.dynamodb_access_policy_arn
#   depends_on = [module.vpc, module.s3sqs ,module.dynamodb]
# }

# module "lambda" {
#   source = "./modules/7-lambda"
#   providers = {
#     aws = aws
#   }
#   auth_lambda_repo = module.ecr.auth_lambda_repo
#   presigned_lambda_repo = module.ecr.presigned_lambda_repo
#   depends_on = [module.ecr]
# }

# module "api_gtw" {
#   source = "./modules/8-apigtw"
#   providers = {
#     aws = aws
#   }
#   user_pool_id = module.cognito.user_pool_id
#   auth_lambda_arn = module.lambda.auth_lambda_arn
#   presigned_lambda_arn = module.lambda.presigned_lambda_arn
#   dynamodb_table_name = module.dynamodb.table_name
#   dynamodb_table_arn = module.dynamodb.table_arn
#   depends_on = [module.dynamodb, module.lambda, module.cognito]
# }