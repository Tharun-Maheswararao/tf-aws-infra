resource "aws_route_table_association" "public_assoc" {
    for_each = aws_subnet.public_subnets

    subnet_id = each.value.id
    route_table_id = aws_route_table.public_rt[split("-", each.key)[0]].id
}

resource "aws_route_table_association" "private_assoc" {
    for_each = aws_subnet.private_subnets

    subnet_id = each.value.id
    route_table_id = aws_route_table.private_rt[split("-", each.key)[0]].id
}