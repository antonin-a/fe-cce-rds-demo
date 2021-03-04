# Flexible Engine RDS demo using Terraform and Kubernetes

## Repo architecture

├── open.rc                       // not included here, this file contain your env variable to acces FE ([cf Online Doc](https://docs.prod-cloud-ocb.orange-business.com/devg/sdk/en-us_topic_0070637155.html))
├── kubernetes-manifests
│   ├── etherpad-deployment.yaml
│   ├── etherpad-secret.yaml
│   └── etherpad-service.yaml
└── terraform-plans
    ├── main.tf
    ├── outputs.tf
    ├── variables.tf
    └── versions.tf
