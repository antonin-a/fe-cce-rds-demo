# Flexible Engine - Relational Database Service (RDS) demo using Terraform and Kubernetes

## Repo architecture
```
├── open.rc                       // not included here, this file contains your env variables to acces Flexible Engine Cloud ([cf Online Doc](https://docs.prod-cloud-ocb.orange-business.com/devg/sdk/en-us_topic_0070637155.html))
├── kubernetes-manifests
│   ├── etherpad-deployment.yaml
│   ├── etherpad-secret.yaml
│   └── etherpad-service.yaml
└── terraform-plans
    ├── main.tf
    ├── outputs.tf
    ├── variables.tf
    └── versions.tf
```

## How it works
### Terraform 
Will be used to deploy several ressources:
- The Relation Database Service instance using postgreSQL 
- The associated security groups (to allow access from a bastion and a CCE cluster)
- A database using the postgreSQL Provider
- A private DNS entry on the DNS FE service (to avoid hardcoding of the DB private IP)

### Kubernetes
Will be used to deploy a basic application, here it is an [Etherpad](https://github.com/ether/etherpad-lite) 
- it will rely on the RDS DB for data persistence 
- it will automatically create a FE Elastic Loadbalancer to expose our application on internet(using k8s service)

## Architecture diagram
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │                                                     │ │
│ │                  ┌─────────┐            ┌─────────┐ │ │
│ │                  │         │            │         │ │ │
│ │                  │ Bastion │            │ ELB     ├─┼─┼───── EIP
│ │                  └─────────┘            └────┬────┘ │ │
│ │                                              │      │ │
│ └─Subnet┼Front─────────────────────────────────┼──────┘ │
│                                                │        │
│                  ┌─────────────┬───────────────┤        │         
│                  │             │               │        │
│ ┌────────────────┼─────────────┼───────────────┼──────┐ │
│ │                │             │               │      │ │
│ │             ┌──┴─────┐   ┌───┴────┐    ┌─────┴──┐   │ │
│ │             │ k8s    │   │ k8s    │    │ k8s    │   │ │
│ │             │ Node1  │   │ Node2  │    │ Node n │   │ │
│ │             └──┬─────┘   └───┬────┘    └─────┬──┘   │ │
│ │                │             │               │      │ │
│ └─Subnet┼CCE─────┼─────────────┼───────────────┼──────┘ │
│                  │             │               │        │
│                  └─────────────┴───────────────┤        │
│                                                │        |
│                                            ┌───┴───┐    |
|                                            |       |    |
|                                            | DNSaaS│    |
|                                            └───────┘    |
│                                                │        │
│ ┌──────────────────────────────────────────────┼──────┐ │
│ │                                              │      │ │
│ │ ┌──────────────┐ ┌──────────────┐            |      │ │
│ │ │              │ │              │            │      │ │
│ │ │ RDS Standby  │ │RDS Primary   ├────────────┘      | |
│ │ └──────────────┘ └──────────────┘                   │ │
│ │                                                     │ │
│ └─Subnet┼DB───────────────────────────────────────────┘ │
│                                                         │
└─VPC─────────────────────────────────────────────────────┘
```

## Step by step
Create your open.rc file and source it (https://docs.prod-cloud-ocb.orange-business.com/devg/sdk/en-us_topic_0070637155.html)
### Terraform deployment
Move to terraform-plan directory, then
```
terraform init
terraform plan
terraform apply
```
### Kubernetes deployment
#### Create the secrets containing DB and Etherpad Admin passwords
- Move to kubernetes manifests directory and change the passwords values on ``` etherpad-secret.yaml```
- Then create the secrets
```
kubectl apply -f etherpad-secret.yaml
```
#### Deploy Etherpad application
``` 
kubectl apply -f etherpad-deployment.yaml
```
Check that pod is up and runing 
```kubectl get pod
```
#### Create the service 
```
kubectl apply -f etherpad-service.yaml
kubectl get services 

```

Now you can access your application using Elastic Load Balancer public IP
