resource "aws_eks_cluster" "EksCluster" {
 name = "${var.infra_env}-EksCluster"
 role_arn = aws_iam_role.EksClusterRole.arn
 version = var.eks_version

 vpc_config {
    subnet_ids = [var.private_subnet-1-id, var.private_subnet-2-id]
    #endpoint_private_access   = true
    #endpoint_public_access    = false
    security_group_ids = [var.eks_sg_id, var.bastion_sg_id ]
  }

 depends_on = [
  aws_iam_role.EksClusterRole,
 ]
  tags = {
    Name = "${var.infra_env}-EksClusterRole"
    env = var.infra_env
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.EksCluster.name
  addon_name   = "aws-ebs-csi-driver"

  depends_on = [
    aws_iam_openid_connect_provider.EksOidc
  ]
}

resource "aws_eks_node_group" "EksNode" {
  cluster_name    = aws_eks_cluster.EksCluster.name
  node_group_name = "${var.infra_env}-EksNodes"
  node_role_arn   = aws_iam_role.EksNodeRole.arn
  subnet_ids      = [var.private_subnet-1-id, var.private_subnet-2-id]
  disk_size = var.disk_size
  instance_types = [var.instance_types]
  

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

    depends_on = [
      aws_iam_role.EksNodeRole,
      aws_iam_role_policy_attachment.EksNodePolicyAttachment,
      aws_iam_role_policy_attachment.EksNodeEcrPolicyAttachment,
      aws_iam_role_policy_attachment.EksNodeCNIPolicyAttachment,
      aws_iam_role_policy_attachment.EksNodeEBSPolicyAttachment,
    ]
  
}

