# ADD OPENID PROVIDER FOR CLUSTER
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}


resource "aws_eks_cluster" "cluster" {
  name     = "${var.env}-cluster"
  role_arn = aws_iam_role.cluster.arn
  tags     = merge(local.cluster_tags,{})
  vpc_config {
    subnet_ids = [aws_subnet.a.id, aws_subnet.b.id, aws_subnet.c.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster,
    aws_iam_role_policy_attachment.amazon_eks_service,
    aws_iam_role_policy_attachment.amazon_eks_worker_node,
    aws_iam_role_policy_attachment.amazon_eks_cni,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_readonly,
    aws_iam_role_policy_attachment.amazon_ebs_csi_driver,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

#======================================[ NODE GROUPS ]=================================================================

resource "aws_eks_node_group" "spot_large" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "spot_large"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [aws_subnet.a.id, aws_subnet.b.id, aws_subnet.c.id]
  capacity_type   = "SPOT"
  instance_types  = ["m5.large"]

  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 0
  }

  tags = merge({},local.node_group_tags)
  labels = {
        capacity = "SPOT"
        NodeGroup = "spot_large"
        Name = "sandox-spot-large"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node,
    aws_iam_role_policy_attachment.amazon_eks_cni,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_readonly,
  ]
}