vpc = {
  name            = "common-sharedservices"
  aws_account     = "hkjc-common-sharedservices"
  region          = "ap-east-1"
  create_vpcs     = true
  
  vpc_cidrs = {
      region = "ap-east-1"
      name   = "common-sharedservices"
      cidr   = "10.128.0.0/22" #private subnets
      secondary_cidrs = [
        "100.72.0.0/16", #public subnets
        "100.73.0.0/16", #pod subnets
        "100.74.0.0/16", #worker subnets
      ]
      subnet = {
        private = {
          cidr = "10.128.0.0/22"
          az = {
            a = "10.128.0.0/24"
            b = "10.128.1.0/24"
            c = "10.128.2.0/24"
          }
        }
        public = {
          cidr = "100.72.0.0/24"
          az = {
            a = "100.72.0.0/26"
            b = "100.72.0.64/26"
            c = "100.72.0.128/26"
          }
        }
        worker = {
          cidr = "100.74.0.0/16"
          az = {
            a = "100.74.0.0/18"
            b = "100.74.64.0/18"
            c = "100.74.128.0/18"
          }
        }
        pod = {
          cidr = "100.73.0.0/16"
          az = {
            a = "100.73.0.0/18"
            b = "100.73.64.0/18"
            c = "100.73.128.0/18"
          }
        }
      }
    }

  gateway_endpoints =  [
      {
        aws_service = "s3"
        route_tables = [
          "common-sharedservices-worker-a",
          "common-sharedservices-worker-b",
          "common-sharedservices-worker-c",
          "common-sharedservices-private-a",
          "common-sharedservices-private-b",
          "common-sharedservices-private-c",
        ]
      },
      {
        aws_service = "dynamodb"
        route_tables = [
          "common-sharedservices-worker-a",
          "common-sharedservices-worker-b",
          "common-sharedservices-worker-c",
          "common-sharedservices-private-a",
          "common-sharedservices-private-b",
          "common-sharedservices-private-c",
        ]
      }
    ]
  

  igw = {
      name = "common-sharedservices"
    }
  

  nat_gws =  [
      {
        name   = "common-sharedservices-a"
        subnet = "common-sharedservices-public-a"
      },
      {
        name   = "common-sharedservices-b"
        subnet = "common-sharedservices-public-b"
      },
      {
        name   = "common-sharedservices-c"
        subnet = "common-sharedservices-public-c"
      },
    ]
  

  nacls = [
      {//public
        name = "common-sharedservices-public"
        rules = {
          egress = [
            {
              id       = 100
              cidr     = "0.0.0.0/0"
              protocol = "all"
            },
          ]
          ingress = [
            { //allow worker subnets
              id       = 100
              cidr     = "subnet.public.cidr"
              protocol = "all"
            },
            { //allow private subnets
              id       = 200
              cidr     = "subnet.private.cidr"
              protocol = "all"
            },
            { //allow worker subnets
              id       = 300
              cidr     = "subnet.worker.cidr"
              protocol = "all"
            },
            { //deny all RDP
              id        = 950
              action    = "deny"
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 3389
              to_port   = 3389
            },
            { //allow returning TCP traffic
              id        = 1000
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 1024
              to_port   = 65535
            },
          ]
        }
        subnets = [
          "common-sharedservices-public-a",
          "common-sharedservices-public-b",
          "common-sharedservices-public-c",
        ]
      },
      {//private
        name = "common-sharedservices-private"
        # tags = local.tags
        rules = {
          egress = [
            {
              id       = 100
              cidr     = "0.0.0.0/0"
              protocol = "all"
            },
          ]
          ingress = [
            {
              id       = 100
              cidr     = "subnet.private.cidr"
              protocol = "all"
            },
            {
              id       = 200
              cidr     = "subnet.public.cidr"
              protocol = "all"
            },
            {
              id       = 300
              cidr     = "subnet.worker.cidr"
              protocol = "all"
            },
            {
              id       = 400
              cidr     = "subnet.pod.cidr"
              protocol = "all"
            },
            {
              id        = 950
              action    = "deny"
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 3389
              to_port   = 3389
            },
            {
              id        = 1000
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 1024
              to_port   = 65535
            },
            {
              id        = 1001
              cidr      = "0.0.0.0/0"
              protocol  = "udp"
              from_port = 1024
              to_port   = 65535
            },
          ]
        }
        subnets = [
          "common-sharedservices-private-a",
          "common-sharedservices-private-b",
          "common-sharedservices-private-c",
        ]
      },
      {//worker
        name = "common-sharedservices-worker"
        rules = {
          egress = [
            {
              id       = 100
              cidr     = "0.0.0.0/0"
              protocol = "all"
            },
          ]
          ingress = [
            {
              id       = 100
              cidr     = "subnet.private.cidr"
              protocol = "all"
            },
            {
              id       = 200
              cidr     = "subnet.public.cidr"
              protocol = "all"
            },
            {
              id       = 300
              cidr     = "subnet.worker.cidr"
              protocol = "all"
            },
            {
              id       = 400
              cidr     = "subnet.pod.cidr"
              protocol = "all"
            },
            {
              id        = 950
              action    = "deny"
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 3389
              to_port   = 3389
            },
            {
              id        = 1000
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 1024
              to_port   = 65535
            },
          ]
        }
        subnets = [
          "common-sharedservices-worker-a",
          "common-sharedservices-worker-b",
          "common-sharedservices-worker-c",
        ]
      },
      {//pod
        name = "common-sharedservices-pod"
        # tags = local.tags
        rules = {
          egress = [
            {
              id       = 100
              cidr     = "0.0.0.0/0"
              protocol = "all"
            },
          ]
          ingress = [
            {
              id       = 100
              cidr     = "subnet.private.cidr"
              protocol = "all"
            },
            {
              id       = 300
              cidr     = "subnet.worker.cidr"
              protocol = "all"
            },
            {
              id       = 400
              cidr     = "subnet.pod.cidr"
              protocol = "all"
            },
            {
              id        = 950
              action    = "deny"
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 3389
              to_port   = 3389
            },
            {
              id        = 1000
              cidr      = "0.0.0.0/0"
              protocol  = "tcp"
              from_port = 1024
              to_port   = 65535
            },
          ]
        }
        subnets = [
          "common-sharedservices-pod-a",
          "common-sharedservices-pod-b",
          "common-sharedservices-pod-c",
        ]
      },
    ]

  route_tables =  [
      {
        name = "common-sharedservices-public"
        routes = [
          {
            cidr = "0.0.0.0/0"
            resource = {
              type = "igw"
              name = "common-sharedservices"
            }
          },
        ]
        subnets = [
          "common-sharedservices-public-a",
          "common-sharedservices-public-b",
          "common-sharedservices-public-c",
        ]
      },
      {
        name = "common-sharedservices-private-a"
        routes = [
          {
            cidr = "0.0.0.0/0"
            resource = {
              type  = "nat_gw"
              name  = "common-sharedservices-a"
            }
          },
        ]
        subnets = [
          "common-sharedservices-private-a",
        ]
      },
      {
        name = "common-sharedservices-private-b"
        routes = [
          {
            cidr = "0.0.0.0/0"
            resource = {
              type  = "nat_gw"
              name  = "common-sharedservices-b"
            }
          },
        ]
        subnets = [
          "common-sharedservices-private-b",
        ]
      },
      {
        name = "common-sharedservices-private-c"
        routes = [
          {
            cidr = "0.0.0.0/0"
            resource = {
              type  = "nat_gw"
              name  = "common-sharedservices-c"
            }
          },
        ]
        subnets = [
          "common-sharedservices-private-c",
        ]
      },
      {
        name = "common-sharedservices-worker-a"
        routes = [
          {
            cidr = "0.0.0.0/0"
            resource = {
              type  = "nat_gw"
              name  = "common-sharedservices-a"
            }
          },
        ]
        subnets = [
          "common-sharedservices-worker-a",
        ]
      },
      {
        name = "common-sharedservices-worker-b"
        routes = [
          {
            cidr = "0.0.0.0/0"
            resource = {
              type  = "nat_gw"
              name  = "common-sharedservices-b"
            }
          },
        ]
        subnets = [
          "common-sharedservices-worker-b",
        ]
      },
      {
        name = "common-sharedservices-worker-c"
        routes = [
          {
            cidr = "0.0.0.0/0"
            resource = {
              type  = "nat_gw"
              name  = "common-sharedservices-c"
            }
          },
        ]
        subnets = [
          "common-sharedservices-worker-c",
        ]
      },
      {
        name = "common-sharedservices-pod"
        subnets = [
          "common-sharedservices-pod-a",
          "common-sharedservices-pod-b",
          "common-sharedservices-pod-c",
        ]
      },
    ]
  
}