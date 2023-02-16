# aws-infra
terraform init
terraform apply -var "profile=demo" -var "region=us-east-1" -var 'azs=["us-east-1a","us-east-1b","us-east-1c"]' -var 'private_subnet_cidrs=["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]' -var 'public_subnet_cidrs=["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]' -var 'cdir=10.0.0.0/16'
terraform destroy -var "profile=demo" -var "region=us-east-1" -var 'azs=["us-east-1a","us-east-1b","us-east-1c"]' -var 'private_subnet_cidrs=["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]' -var 'public_subnet_cidrs=["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]' -var 'cdir=10.0.0.0/16'
