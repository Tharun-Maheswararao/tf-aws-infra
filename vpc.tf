resource "aws_vpc" "main" {
    for_each = var.vpcs
    cidr_block = each.value.vpc_cidr

    tags = {
        Name = "tf-vpc-${each.key}"  # Unique Name for Each VPC
    }
}
