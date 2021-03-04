output "rds_private_ip" {
  description = "Private IP of the RDS DB"
  value       = flexibleengine_rds_instance_v3.rds.private_ips.*
}

