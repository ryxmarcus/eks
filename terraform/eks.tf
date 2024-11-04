module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true
  
  # Enable public access for worker nodes
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  # Changed from private_subnets to public_subnets
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]
    attach_cluster_primary_security_group = true
    
    # Enable public IP assignment
    create_launch_template = true
    launch_template_name   = "${local.name}-lt"
    enable_public_ip      = true
  }

  eks_managed_node_groups = {
    amc-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      
      # Additional network configuration for public IP
      subnet_ids    = module.vpc.public_subnets
      
      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

  tags = local.tags
}
