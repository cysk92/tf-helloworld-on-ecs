# tf-helloworld-on-ecs
Terraform IaC for a simple ECS cluster running a hello-world application (Flask) 

## Requirements
You need the following tools installed on your machine in order to build and run this project.

1. Amazon Web Services CLI ([awscli][1]).
1. [Terraform v1.0.4][2] or greater.  (you might want to check out [tfenv][3])
1. An S3 bucket to set terraform's backend. (Although you can modify it to run locally, I personally don't like it)
1. Your own set of AWS credentials with RW access to said S3 bucket.

## What does this module do?
Creates the following resources:

* A brand new VPC with public and private subnets.
* An internet gateway.
* All necesary security groups.
* A NAT Gateway.
* A load balancer.
* An ECS cluster, service and Task Definition.
* An ACM certificate.
* A DNS record to validate the certificate.
* A DNS record that points to the load balancer.


Our ECS cluser will be running on FARGATE, since at low utilizations it's failry cheaper than EC2 (with the latest price drop). Note that running your cluster at high utilization makes FARGATE about 15~35% more expensive than EC2.

Although the creation of a new VPC is not fully needed for a test of this sized I preferred to keep it as isolated as possible and as bundled as possible. That being said it is a good idea to define one VPC per product/app you're running to reduce risk (if not separate AWS accounts) and to avoid having to manage multiple VPCs in the same account.


## Configuring 
Configure your awscli properly with the keys that belong to the account you're working on:

    > aws configure

## Initializing and deploying
This module Creates most of the resources it needs to work properly except for the domain, which has to be managed in Route53 for it to work seamlesly (you can set it up without that, but you'll have to manually create a record there).
Since I already had a Route53 domain created in my AWS account, and I'm guessing you do too, before doing anything else, Fill in the following variables and settings:
* Tell terraform the [domain you will be using][4], as well as the [hosted zone id][5].
* Once you get that done, you can build the container provided [here][7], and once you have it uploaded to your repository of choice, you can tell [terraform the image address][6]
* In the terraform [config.tf][8] file, fill in your bucket and the key of your `.tfstate` file.


With that out of the way, go the base directory of this module and initialize terraform:

    > terraform init

Once initialized, a plan, so terraform can create and show you a catalog of what resources will be created. Take 5 minutes to read through this and check there's nothing out of place.

    > terraform plan

When you're confident that terraform is picking up your changes (if you did any) and the change catalog does what you want it to do. You can create this infra (or modify your already existing infra) by running

    > terraform apply

Once finished, your domain should be ready to use.

## CI/CD
Terraform plan/apply jobs are run on Github Actions, you can check them out and run them manually.
For these to work, you need to create two Github Secrets (it's recommended that you create those at a repository level). If you wish to have this module deployed on two environments you could create the following secrets respectively:

* `TERRABOT_KEY_PROD` (Access Key for the IAM user that will create the infrastructure on PROD)
* `TERRABOT_SECRET_PROD` (Secret Key for the IAM user that will create the infrastructure on PROD)

* `TERRABOT_KEY_STAGING` (Access Key for the IAM user that will create the infrastructure on STAGING)
* `TERRABOT_SECRET_STAGING` (Secret Key for the IAM user that will create the infrastructure on STAGING)


### Or...
If you don't want it to be a multi stage-deployment, just configure one of them (PRDO) and trigger the Actions manually, note that the Staging build for `tfplan` will run on pull-request creation (and fail if credentials don't exist, don't panic)

You can also ignore this and run it locally from your machine, I added it cause I already had them built for other projects.


[1]: https://aws.amazon.com/cli/
[2]: https://www.terraform.io/downloads.html
[3]: https://github.com/tfutils/tfenv
[4]: https://github.com/pablojabase/tf-helloworld-on-ecs/blob/master/variables.tf#L3
[5]: https://github.com/pablojabase/tf-helloworld-on-ecs/blob/master/variables.tf#L8
[6]: https://github.com/pablojabase/tf-helloworld-on-ecs/blob/master/variables.tf#L13
[7]: https://github.com/pablojabase/tf-helloworld-on-ecs/tree/master/container
[8]: https://github.com/pablojabase/tf-helloworld-on-ecs/blob/master/config.tf#L3
