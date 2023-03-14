resource "aws_subnet" "public_subnets" {
 count             = length(var.public_subnet_cidrs)
 vpc_id            = aws_vpc.Guangyu.id
 cidr_block        = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count             = length(var.private_subnet_cidrs)
 vpc_id            = aws_vpc.Guangyu.id
 cidr_block        = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.Guangyu.id
 
 tags = {
   Name = "Project VPC IG"
 }
}

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.Guangyu.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "2nd Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}

resource "aws_route_table" "second_rt_private" {
 vpc_id = aws_vpc.Guangyu.id
 
 
 tags = {
   Name = "2nd Route Table Private"
 }
}

resource "aws_route_table_association" "private_subnet_asso" {
 count = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt_private.id
}

resource "aws_security_group" "example" {
  name= "application"
  description = "appliaction security group"
  vpc_id =aws_vpc.Guangyu.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name="database"
  description = "appliaction security group"
  vpc_id =aws_vpc.Guangyu.id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.example.id]
  }
  egress{
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_uuid" "uuid" {
  
}


resource "aws_s3_bucket" "private_bucket"{
  bucket="example-${random_uuid.uuid.result}"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.private_bucket.id
  acl="private"
}

resource "aws_s3_bucket_lifecycle_configuration" "life" {
  rule{
    id="s3-bucket-life"
    status = "Enabled"
    transition {
      days=30
      storage_class = "STANDARD_IA"
    }
  }
  bucket = aws_s3_bucket.private_bucket.bucket
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encry" {
  bucket = aws_s3_bucket.private_bucket.id
  rule{
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
}

resource "aws_iam_policy" "ec2_policy"{
  name="ec2-csye6225"
  path="/"
  policy= jsonencode(
  {
    Version="2012-10-17"
    Statement=[
      {
        Action=[
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject",
        ],
        Effect="Allow",
        Resource=[
          "arn:aws:s3:::${aws_s3_bucket.private_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.private_bucket.bucket}/*",
        ]
      },
      {
        Effect="Allow",
        Action=["s3:ListBucket","s3:GetBucketLocation","s3:ListAllMyBuckets","s3:GetLifecycleConfiguration"],
        Resource="arn:aws:s3:::${aws_s3_bucket.private_bucket.bucket}"
      }
    ]
  }
  )
}

resource "aws_iam_role_policy_attachment" "ec2_policy_role" {
  //name="iam-instance-profile"
  role=aws_iam_role.ec2_role.name
  policy_arn=aws_iam_policy.ec2_policy.arn
}


resource "aws_iam_role" "ec2_role" {
  name="EC2-CSYE6225"
  assume_role_policy = jsonencode(
  {
    Version="2012-10-17",
    Statement=[
      {
        Action="sts:AssumeRole"
        Effect="Allow"
        Sid=""
        Principal={
          Service="ec2.amazonaws.com"
        }
      },
    ]
  }
  )
}

resource "aws_iam_instance_profile" "webapps3" {
  name="ec2_profile"
  role=aws_iam_role.ec2_role.name
}

resource "aws_db_parameter_group" "my_parameter_group" {
  name_prefix   = "mydb-parameters"
  family        = "mysql8.0"
  description   = "My custom RDS parameter group"
}

resource "aws_instance" "example"{
  ami=var.ami_id//"ami-0c6c41abbb70d840e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnets[0].id
  key_name = var.key_pair
  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination = true
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.example.id]
  root_block_device {
    #device_name = "/dev/xvda"
    volume_size = 50
    volume_type = "gp2"

    delete_on_termination = true
    # other root device settings
  }
  iam_instance_profile = aws_iam_instance_profile.webapps3.name
  user_data = <<EOF
  #!/bin/bash
  touch /home/ec2-user/home/runner/work/webapp/webapp/.env
  echo "DB_USERNAME="csye6225"" >> /home/ec2-user/home/runner/work/webapp/webapp/.env
  echo "DB_PASSWORD=${var.db_password}" >> /home/ec2-user/home/runner/work/webapp/webapp/.env
  echo "DB_HOSTNAME=${aws_db_instance.example.address}">> /home/ec2-user/home/runner/work/webapp/webapp/.env
  echo "S3_BUCKET_NAME=${aws_s3_bucket.private_bucket.bucket}">> /home/ec2-user/home/runner/work/webapp/webapp/.env
  echo "DB_NAME="csye6225"" >>/home/ec2-user/home/runner/work/webapp/webapp/.env
  echo "S3_REGION=${aws_s3_bucket.private_bucket.region}" >>/home/ec2-user/home/runner/work/webapp/webapp/.env
  sudo systemctl enable webapp.service
  sudo systemctl start webapp.service
  EOF
}


resource "aws_db_subnet_group" "example" {
  name       = "example-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnets[0].id,aws_subnet.private_subnets[1].id,aws_subnet.private_subnets[2].id]
}

resource "aws_db_instance" "example" {
  engine="mysql"
  engine_version = "8.0.26"
  allocated_storage = 50
  instance_class = "db.t3.micro"
  multi_az  = false
  vpc_security_group_ids = [aws_security_group.db.id]
  db_name="csye6225"
  username = var.db_username
  password = var.db_password
  publicly_accessible = false
  //final_snapshot_identifier = "foo"
  skip_final_snapshot = true
  db_subnet_group_name  = aws_db_subnet_group.example.name
  parameter_group_name = aws_db_parameter_group.my_parameter_group.name
  tags = {
    Name = "example-db"
    //db_name = "csye6225"
  }
}

resource "aws_route53_record" "aws_a_record" {
  zone_id = var.zone_id
  name="dev.guangyuwang.me"
  type = "A"
  ttl = "60"
  records = [aws_instance.example.public_ip]
}