# Terraform module for EKS cluster

This modules creates an EKS cluster on AWS. Nodes of the cluster are placed on a configured set of subnets within a VPC. The cluster consists of multiple nodegroups each of which corresponds to an autoscaling group in AWS. Each nodegroup can formed of different EC2 instance types that may either be "ON_DEMAND" or "SPOT" instances.

The module creates the necessary IAM roles for the kubernetes cluster controplane and worker nodes and configures the security group attached to the worker nodes. It also creates an OpenID connect provider for the cluster that can be used for attaching IAM roles to service accounts.

## Module input parameters

| Parameter                      | Type     | Description                                                                        |
| ------------------------------ |--------- | ---------------------------------------------------------------------------------- |
| subnet_ids                     | Required | The ids of the VPC subnets at which the eks cluster will be created                |
| eks_worker_nodes_key_path      | Required | The path to the file containing the public ssh key for the worker nodes            |
| eks_node_groups                | Required | A map containing the definition of the node groups to be created in the eks cluster |
| ssh_allowed_security_groups    | Optional | An optional list of security groups to be allowed access to kubernetes worker nodes via ssh |
| kubectl_allowed_security_group | Optional | An optional security group to be allowed access to the kubernetes API              |
| kubectl_allowed_cidr_blocks    | Optional | An optional list of CIDR blocks to be allowed access to the kubernetes API         |

The structure of the map variable eks_node_groups is as follows:

```
eks_node_groups = {
  node_group1 = {
      min_size       = <minimum number of EC2 instances in group1>
      desired_size   = <maximum number of EC2 instances in group1>
      max_size       = <desired number of EC2 instances in group1>
      instance_types = <list of EC2 instance types to be used in group1> 
      disk_size      = <root volume capacity for EC2 instances in group1>
      capacity_type  = <"ON_DEMAND" or "SPOT">
  }    
  node_group2 = {
      min_size       = <minimum number of EC2 instances in group2>
      desired_size   = <maximum number of EC2 instances in group2>
      max_size       = <desired number of EC2 instances in group2>
      instance_types = <list of EC2 instance types to be used in group2> 
      disk_size      = <root volume capacity for EC2 instances in group2>
      capacity_type  = <"ON_DEMAND" or "SPOT">
  }    
  ...
}
```

## Module output parameters

| Parameter                   | Description                                                               |
| --------------------------- | ------------------------------------------------------------------------- |
| eks_cluster_properties      | A map output variable containing properties of the created EKS cluster    |

The structure of the output variable "eks_cluster_properties" is as follows:

```

eks_cluster_properties = {
  eks_cluster_name            = <The name of the EKS cluster>
  eks_endpoint                = <The endpoint for connecting to the cluster>
  eks_cluster_ca_cert         = <The certificate of the internal certificate authority of the EKS cluster>
  openid_connect_provider_arn = <ARN of OpenID connect provider of EKS cluster>
  openid_connect_provider_url = <URL of OpenID connect provider of EKS cluster>
  subnet_ids                  = <IDs of the VPC subnets on which the EKS cluster is installed>
  eks_cluster_sg_id           = <ID of the security group created for the worker nodes of the EKS cluster>
  vpc_id                      = <ID of the VPC on which the EKS cluster is deployed>  
}
```