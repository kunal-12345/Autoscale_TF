Terraform AWS Auto Scaling Module

Objective : To use tools Autoscalling and LAunch configuration for EC2 instance and method to determine autoscale cluster size from internal application metrics. Automate the solution using scaling processes.

Terraform

What is Terraform?

Terraform is a tool for building, maintain, and versioning infrastructure (As code) safely and efficiently, it can manage existing and popular service providers as well as custom in-house solutions.

Requirements

In order to follow, you need to create some resources in AWS to have a similar environment to be used by Terraform.

An AWS Account
1 VPC [ eg : vpc-1329f474]
2 Subnets [ eg : "${subnet-0a105447.id}", "${subnet-2fe92f47.id}" ]
1 Key Pair [ example: abednarik ]
Need to install: Terraform 0.8.0 or newer


Steps for Auto-Scaling process :

Create Amazon Machine Image(AMI) on the instance you want to autoscale
Create Load balancer to have a common url for all the instances
Create Launch Configuration
Create Autoscalling group
Create scaling poliicies for scaling up(Cloud alarm -Network in >=300), Scaling down(when CPU utilization <20%)

Terraform Configuration

The first thing we need to do is to create same variables. As you might know, variables store information that we will use everywhere later on, defining a variable is quite simple. In this example, we defined a aws_ami variable, set a description for it and finally a default value.

We need to set some Security Groups:

resource "aws_security_group" "AS_instance_security_group" {
  name        = "AutoScaling-Security-Group-1"
  description = "AutoScaling-Security-Group-1 desc..."


Important things to handle AutoScaling processes:

1. If you have a scale up event, the new instance(s) will get the latest successful Revision, and not the one you are currently deploying. You will end up with a fleet of mixed revisions.
2. If you have a scale down event, instances are going to be terminated, and your deployment will (probably) fail.
3.If your instances are not balanced accross Availability Zones and you are using these scripts, AutoScaling may terminate some instances or create new ones to maintain balance, interfering with your deployment.
4. If you have the health checks of your AutoScaling Group based off the ELB's and you are not using these scripts, then instances will be marked as unhealthy and terminated.

Conclusion: 

Terraform is probably one of the best tools out there to handle resources in the Cloud. It's straightforward to use and understand, well documented and helps to reduce the process duration. You can ask more related to it.

