resource "yandex_vpc_security_group" "k8s_security_group" {
  name        = local.name
  description = "Security group for Kubernetes cluster"
  network_id  = module.network.vpc_id

  # IPv6 ICMP from anywhere
  ingress {
    protocol       = "IPV6_ICMP"
    description    = "IPv6 ICMP from anywhere"
    v4_cidr_blocks = []
    v6_cidr_blocks = ["::/0"]
  }

  # Allow all traffic between instances in this security group
  ingress {
    protocol          = "ANY"
    description       = "Allow all traffic between instances in this security group"
    predefined_target = "self_security_group"
  }

  # ICMP from anywhere
  ingress {
    protocol       = "ICMP"
    description    = "ICMP from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from anywhere
  ingress {
    protocol       = "TCP"
    description    = "SSH access from anywhere"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # UDP port 22 from anywhere
  ingress {
    protocol       = "UDP"
    description    = "UDP port 22 from anywhere"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API from anywhere
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API access"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic from load balancer
  ingress {
    protocol          = "ANY"
    description       = "Allow all traffic from load balancer"
    port              = 6443
    predefined_target = "loadbalancer_healthchecks"
  }

  # Allow all outgoing traffic
  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    v6_cidr_blocks = ["::/0"]
  }
}
