variable "subnet_ids" {
  description = "The ids of the VPC subnets at which the eks cluster will be created."
}

variable "eks_worker_nodes_key_name" {
  description = "The name of the ssh key used to connect to the worker nodes of the eks cluster."
}

variable "eks_worker_nodes_key_path" {
  description = "The path to the file containing the public ssh key for the worker nodes."
}

variable "eks_node_groups" {
  description = "A map variable containing the definition of the node groups to be created in the eks cluster."
}

variable "kubectl_allowed_security_group" {
  description = "An optional security group to be allowed access to the kubernetes API."
  default     = ""
}

variable "kubectl_allowed_cidr_blocks" {
  description = "An optional list of CIDR blocks to be allowed access to the kubernetes API."
  default     = []
}

variable "ssh_allowed_security_groups" {
  description = "An optional list of security groups to be allowed access to kubernetes worker nodes via ssh."
  default     = []
}