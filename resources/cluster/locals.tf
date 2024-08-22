locals {
  vpc_tags = {
    Name                                       = var.env,
    managed = "terraform"
  }
  subnet_tags = {
    Name                                       = var.env,
    "kubernetes.io/cluster/${var.env}-cluster" = "shared",
    "kubernetes.io/role/elb"                   = "1",
    managed = "terraform"
  }  
  security_group_tags = {
    Name = "${var.env}-security-group"
    cluster = "${var.env}-cluster"
    managed = "terraform"
  }
  internet_gateway_tags = {
    Name = "${var.env}-internet-gateway"
    cluster = "${var.env}-cluster"
    managed = "terraform"
  }

  route_table_tags = {
    Name = "${var.env}-route-table"
    cluster = "${var.env}-cluster"
    managed = "terraform"
  }

  cluster_tags = {
    Name = "${var.env}-cluster"
    managed = "terraform"
  }
  node_group_tags = {
    cluster = "${var.env}-cluster"
    managed = "terraform"
  }

  policy_tags = {
    cluster = "${var.env}-cluster"
    managed = "terraform"
  }

  role_tags = {
    cluster = "${var.env}-cluster"
    managed = "terraform"
  }
}