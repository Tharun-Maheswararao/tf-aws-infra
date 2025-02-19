resource "aws_route_table" "public_rt" {
  for_each = var.vpcs
  vpc_id   = aws_vpc.main[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[each.key].id
  }

  tags = {
    Name = "tf-public-route-table-${each.key}"
  }
}

resource "aws_route_table" "private_rt" {
  for_each = var.vpcs
  vpc_id   = aws_vpc.main[each.key].id

  tags = {
    Name = "tf-priavte-route-table-${each.key}"
  }
}
