resource "aws_iam_role" "EksClusterRole" {
  name = "EksClusterRole-tf"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.infra_env}-EksClusterRole"
    env = var.infra_env
  }
}

resource "aws_iam_role_policy_attachment" "EksClusterPolicyAttachment" {
  role       = aws_iam_role.EksClusterRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.EksClusterRole.name
}


resource "aws_iam_role" "EksNodeRole" {
  name = "EksNodeRole-tf"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.infra_env}-EksNodeRole"
    env = var.infra_env
  }
}

resource "aws_iam_role_policy_attachment" "EksNodePolicyAttachment" {
  role       = aws_iam_role.EksNodeRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "EksNodeEcrPolicyAttachment" {
  role       = aws_iam_role.EksNodeRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "EksNodeCNIPolicyAttachment" {
  role       = aws_iam_role.EksNodeRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "EksNodeEBSPolicyAttachment" {
  role       = aws_iam_role.EksNodeRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

#####OIDC####
data "tls_certificate" "tls_cert" {
  url = aws_eks_cluster.EksCluster.identity[0].oidc[0].issuer

  depends_on = [
    aws_eks_cluster.EksCluster
  ]
}

resource "aws_iam_openid_connect_provider" "EksOidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.tls_cert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.tls_cert.url

  depends_on = [
    data.tls_certificate.tls_cert
  ]
}

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.EksOidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.EksOidc.arn]
      type        = "Federated"
    }
  }

  depends_on = [
    aws_eks_cluster.EksCluster,
    data.tls_certificate.tls_cert
  ]
}

resource "aws_iam_role" "ebs-sa-role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "Ebs-sa-role"
}