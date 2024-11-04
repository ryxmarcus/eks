module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"
  
  name = local.name
  cidr = local.vpc_cidr
  
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets
  
  enable_nat_gateway = true
  
  # Enable auto-assign public IP for public subnets
  map_public_ip_on_launch = true
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    # Add this tag for EKS
    "kubernetes.io/cluster/${local.name}" = "shared"
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${local.name}" = "shared"
  }
}
