# Section 2 Instructions

## AWS EKS cluster

We're going to spin up the necessary infrastructure via Terraform script that describes the following:

| File | Resource Description | 
| :---------------------- | :---------------------- |
| [versions.tf](./eks-terraform/versions.tf) | We specify what providers our terraform setup requires in order to operate and their versions. In our case it's **terraform** itself, **kubernetes** and **helm**, allwing terraform to run kubernetes commands across our EKS cluster and install helm charts. Last two resource blocks are needed in order to authorize terraform to run kubectl and helm commans on our behalf. They are the same because helm under the hood runs the same kubectl commands. |
| [variables.tf](./eks-terraform/variables.tf) | We parametrize our terraform script and reuse certain variables across multiple files. |
| [vpc.tf](./eks-terraform/vpc.tf) | We're going to spinup a dedicated VPC for our ClickHouse installation. It's gonna have 3 private and 3 public subnets spreaded across 3 AZs within a region. It'll have a single NAT Gateway and lastly we specify a dedicated tags for private and public subnets separately. This is necessary for the ALB Ingress to discover our subnets. |
| [main.tf](./eks-terraform/main.tf) | That's where we describe our main components of the infrastructure - EKS cluster, which is consists of 2 things: fully managed control plane in a different AWS account (in our we are only gonna have ENIs representing it) and a worker group, which is a fleet of EC2 instances preconfigured for EKS. Here, we have 4 dedicated nodes for clickhouse and 3 for zookeeper (7 in total). Each group will be spreaded across multiple private subnets and hence AZs (except for the clickhouse, 2 nodes endup in the same AZ). We'll create a Security Group that allow communication on any protocol and on any port between Worker Nodes. Each node needs to have a service IAM role for proper functioning. Control plane will be accessible publicly from any IP if you have a properly configured kubeconfig's context. Commented section is for the access entries, which is a convenient way to manage access to EKS cluster. It's not necessary for this course as I assume student will be the only person to play around it and as creator will have all the permissions. |
| [iam.tf](./eks-terraform/iam.tf) | Our EKS control plane and Worker Nodes need to interact within the AWS ecosystem with other services. Thus, we need to create separate IAM roles and policies so that they could assume them for the temporary access. |
| [acm_certificate.tf](./eks-terraform/acm_certificate.tf) | We want to create the Certificate in order to enable SSL on our ALB's endpoint. For simplicity, certificate should include any prefix for you domain: *.yourdomain.net |
| [addons.tf](./eks-terraform/addons.tf) | EKS Addons is a convenient way to install different HELM charts. That's why in providers we specified helm as well and how it can be authorized to our EKS cluster. Here we need 3 HELM releases: **EBS controller** to make sure our ClickHouse on Kubernetes can interact with the EBS volume of the worker node, **Load Balancer controller** will be resposible for creating the ALB on AWS once we apply the Ingress definition, **External DNS controller** responsible for interacting with Route53 service in order to add the ingress' dynamically genrated endpoint as a CNAME record to our hosted zone to make the ALB accessible with the same name on every deployement. |

## Steps to spin up the infrastructure

Note: make sure that you AWS CLI is configured properly with the default profile pointing to the required environment. Otherwise, set the AWS_DEFAULT_PROFILE environmental variable with the profile name of your choice.

```
cd eks-terraform

# initialize the directory as terraform project and download all the mentioned providers
terraform init

terraform apply --auto-approve
```

As the result, you should see that 82 Resources were created.

## Steps to spin up all the kubernetes resources

```
cd .. & cd k8s-objects

# configure your local kubeconfig file to access newly created EKS cluster
aws eks --region eu-west-1 update-kubeconfig --name clickhouse

# CH runs as a KubernetesOperator, which is liek a custom k8s resource. We need to install it
kubectl apply -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-bundle.yaml

# now apply everything
kubectl apply -f .
```

Created resources:

| File | Resource Description | 
| :---------------------- | :---------------------- |
| [storage-class](./k8s-objects/01-storage-class.yaml) | In kubernetes world for pods in order to get access to the persistent storage of the underlying node we usually need to create 2 additional resources: Persistent Volume and Persistent Volume Claim. Instead, we use a more dynamic approach with the single storage class representing the whole disk and separate PVCs that claim a part of its volume. |
| [zookeeper](./k8s-objects/02-zookeeper.yaml) | We define the ZooKeeper setup with StatefulSet that'll spin up 3 pods that are forced to be spreaded across multiple nodes and hence multiple AZs, making it HA deployment. Wee also place them on a slightly less powerful nodes than ClickHouse, because ZK process requires way less resources. |
| [clickhouse](./k8s-objects/03-clickhouse.yaml) | Here we define our ClickHouse cluster with 2 shards and 2 replicas layout, requiring the 4 Worker Nodes. Setup is also gonna be spreaded across all of these nodes evenly, preventing the several pods to be scheduled on the same host. |
| [ingress](./k8s-objects/05-ingress.yaml) | Without ALB our CH won't be accessible by outside world as it runs in a private subnets. We're going to have a single Ingress object that'll forward traffic to different shards and replicas within our cluster by having a dedicated hostnames. ALB will listen on both ports HTTP and HTTPS, but would always redirect to HTTPS. There's no need to refer to the created earlier Certificate ARN, because AWS is smart enough to discover it based on the hosted zone used in the Ingress definition and the hosted zone mentioned in the certificate itself.  |
