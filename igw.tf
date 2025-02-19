resource "aws_internet_gateway" "igw" {
  for_each = var.vpcs
  vpc_id   = aws_vpc.main[each.key].id

  tags = {
    Name = "tf-igw-${each.key}"
  }
}

