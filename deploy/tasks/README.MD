## Deploying a Kubernetes cluster

Included in these deployment scripts are the ability to fully bootstrap an AWS EC2 based K8s cluster to deploy your workload against. This example uses the powerful kops deployment tool but there are others included for you to test out as well (some of which also simply use kops).

### Bootstrapping kops

To bootstrap a kubernetes cluster with kops and aws tasksets enabled:

```bash
make deploy-kops-route53 deploy-kops-statestore deploy-kops-aws-group deploy-kops-aws-user deploy-kops-cluster-config deploy-kops-cluster
```

To destroy the cluster

```bash
make delete-kops-cluster
```

## Deploying to ECS

Here are the tasks required for deploying to ECS.
- Bootstrap an ECR image repository.
- Create AWS EC2 key pair for accessing hosts.
- Create EC2 Security Group for Project.
- Create Application Load Balancer for scaled services
- Create task definitions for the containers to run on the cluster

### Bootstraping ECS

To bootstrap the initial image repository first validate if one already exists. Then create one if required (Names are all defined or extrapolated within deploy.env)

```bash
make sso-login aws-describe-repo

make deploy-aws

```

```bash
make \ 
    sso-login \
    deploy-aws-ecs-iam
    deploy-aws-aws-keypair \
    deploy-aws-ecs-sg \
    deploy-aws-alg \

```