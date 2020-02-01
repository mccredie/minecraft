
variable "access_key" {}
variable "minecraft_bucket" {}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-.*-x86_64-gp2$"
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"
  vars = {
    minecraft_bucket = var.minecraft_bucket
  }
}

resource "aws_launch_template" "mc" {
  description             = "A server that can run minecraft"
  disable_api_termination = false
  image_id                = data.aws_ami.amazon_linux.id
  instance_type           = "c5.large"
  key_name                = var.access_key
  name                    = "minecraft-server"
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.bastion.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = "true"
      encrypted             = "false"
      iops                  = 0
      volume_size           = 8
      volume_type           = "gp2"
    }
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

resource "aws_security_group" "allow_ssh" {
  description = "Allow ssh inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # minecraft
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "bastion_role" {
  name = "bastion_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}



resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = aws_iam_role.bastion_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AccessS3",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
        "Sid": "UpdateDNSRecords",
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource": "arn:aws:route53:::hostedzone/${var.hostedzone_id}"
    }
  ]
}
EOF
}


resource "aws_autoscaling_group" "bar" {
  min_size            = 0
  max_size            = 1
  desired_capacity    = 0
  vpc_zone_identifier = data.aws_subnet_ids.all.ids

  lifecycle {
    create_before_destroy = true
  }


  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.mc.id
        version            = aws_launch_template.mc.latest_version
      }
    }
  }
}


resource "aws_autoscaling_lifecycle_hook" "launchmc" {
  name                   = "MCServerInstanceLaunching"
  autoscaling_group_name = aws_autoscaling_group.bar.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 120
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

resource "aws_autoscaling_lifecycle_hook" "terminatemc" {
  name                   = "MCServerInstanceTerminating"
  autoscaling_group_name = aws_autoscaling_group.bar.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 120
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}



resource "aws_autoscaling_policy" "scaledown" {
  adjustment_type           = "ExactCapacity"
  autoscaling_group_name    = aws_autoscaling_group.bar.name
  cooldown                  = 0
  estimated_instance_warmup = 300
  #    id                        = "ScaleDown"
  metric_aggregation_type = "Average"
  name                    = "ScaleDown"
  policy_type             = "StepScaling"
  #    scaling_adjustment        = 0

  step_adjustment {
    metric_interval_upper_bound = "-1"
    scaling_adjustment          = 0
  }
}


resource "aws_cloudwatch_metric_alarm" "lownetwork" {
  actions_enabled = true
  alarm_actions = [
    aws_autoscaling_policy.scaledown.arn
  ]
  alarm_name          = "lownetwork"
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.bar.name
  }
  evaluation_periods        = 2
  insufficient_data_actions = []
  metric_name               = "NetworkIn"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = 300
  statistic                 = "Average"
  tags                      = {}
  threshold                 = 100000
}


resource "aws_iam_instance_profile" "bastion" {
  name = "bastion"
  role = aws_iam_role.bastion_role.name
}

output "mc_autoscaling_group_name" {
  value = aws_autoscaling_group.bar.name
}

output "mc_autoscaling_group_arn" {
  value = aws_autoscaling_group.bar.arn
}
