
/*
data "aws_eks_cluster" "default" {
  name = aws_eks_cluster.EksCluster.name

  depends_on = [
    aws_eks_cluster.EksCluster,
    aws_eks_node_group.EksNode
  ]
}

data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.EksCluster.name

  depends_on = [
    aws_eks_cluster.EksCluster,
    aws_eks_node_group.EksNode
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token

}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token

  }
}

resource "local_file" "kubeconfig" {
  sensitive_content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name = aws_eks_cluster.EksCluster.name,
    clusterca    = data.aws_eks_cluster.default.certificate_authority[0].data,
    endpoint     = data.aws_eks_cluster.default.endpoint,
  })
  filename = "./kubeconfig-${aws_eks_cluster.EksCluster.name}"

  depends_on = [
    aws_eks_cluster.EksCluster,
    aws_eks_node_group.EksNode
  ]
}

resource "kubernetes_service_account_v1" "ebs-sa" {
  metadata {
    name = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" : "${aws_iam_role.ebs-sa-role.arn}"
    }
  }
  
   automount_service_account_token = false
}

resource "kubernetes_secret_v1" "ebs-sa-token" {
  metadata {
    annotations = {
      name = "ebs-sa-token"
      namespace = "kube-system"
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.ebs-sa.metadata.0.name
  }
  }
  type = "kubernetes.io/service-account-token"
}
*/