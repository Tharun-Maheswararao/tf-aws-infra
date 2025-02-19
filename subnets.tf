resource "aws_subnet" "public_subnets" {
  for_each = { for pair in flatten([
    for k, v in var.vpcs : [
      for cidr_index, cidr in v.public_subnet_cidrs : {
        vpc_key = k
        index   = cidr_index
        cidr    = cidr
      }
    ]
  ]) : "${pair.vpc_key}-${pair.index}" => pair }

  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.cidr
  availability_zone = var.availability_zones[each.value.index % length(var.availability_zones)]

  tags = {
    Name = "tf-public-subnet-${each.value.vpc_key}-${each.value.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = { for pair in flatten([
    for k, v in var.vpcs : [
      for cidr_index, cidr in v.private_subnet_cidrs : {
        vpc_key = k
        index   = cidr_index
        cidr    = cidr
      }
    ]
  ]) : "${pair.vpc_key}-${pair.index}" => pair }

  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.cidr
  availability_zone = var.availability_zones[each.value.index % length(var.availability_zones)]

  tags = {
    Name = "tf-private-subnet-${each.value.vpc_key}-${each.value.index + 1}"
  }
}
