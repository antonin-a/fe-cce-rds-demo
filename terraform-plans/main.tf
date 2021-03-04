provider "flexibleengine" {
  auth_url    = "https://iam.eu-west-0.prod-cloud-ocb.orange-business.com/v3"
  region      = "eu-west-0"
}

# Create a database security group
module "sg_db" {
  source  = "FlexibleEngineCloud/secgroup/flexibleengine"
  version = "2.0.1"

  name        = "database"
  description = "Security group for databases"

  ingress_with_source_security_group_id = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      ethertype   = "IPv4"
      source_security_group_id= var.cce_sg_id
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      ethertype   = "IPv4"
      source_security_group_id = var.bastion_sg_id
 
    }
  ]
}

# Create the RDS database
resource "flexibleengine_rds_instance_v3" "rds" {
  availability_zone = ["eu-west-0a", "eu-west-0b"]
  db {
    password = var.rds_password
    type = "PostgreSQL"
    version = "11"
    port = "5432"
  }
  name = "rds-tooling"
  security_group_id = module.sg_db.id
  subnet_id = var.subnet_id
  vpc_id = var.vpc_id
  volume {
    type = "COMMON"
    size = 100
  }
  flavor = "rds.pg.s1.large.ha"
  ha_replication_mode = "async"
  backup_strategy {
    start_time = "08:00-09:00"
    keep_days = 1
  }
}

# Configure the PostgreSQL provider
provider "postgresql" {
  host            = flexibleengine_rds_instance_v3.rds.private_ips[0]
  username        = "root"
  password        = var.rds_password
  connect_timeout = 15
  expected_version= 11
}

# Create a Database
resource "postgresql_database" "my_db" {
  name              = "etherpad"
}

# Create a DNS zone for tools
resource "flexibleengine_dns_zone_v2" "services_zone" {
  email ="hostmaster@example.com"
  name = "tooling.services"
  description = "Zone for tooling services"
  zone_type = "private"
  router {
      router_region = "eu-west-0"
      router_id = var.vpc_id
    }
}
# Create a private DNS record for RDS DB
resource "flexibleengine_dns_recordset_v2" "rds_private" {
  zone_id = flexibleengine_dns_zone_v2.services_zone.id
  name = "postgre.tooling.services"
  description = "An example record set"
  type = "A"
  records = ["${flexibleengine_rds_instance_v3.rds.private_ips[0]}"]
}
