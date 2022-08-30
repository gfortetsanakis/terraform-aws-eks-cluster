locals {
  eks_remote_access = {
    ssh_access = {
      security_groups = var.ssh_allowed_security_groups
    }
  }
}