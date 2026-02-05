**Purpose**
- **Project**: Simple Terraform configuration to provision a minimal AWS network and EC2 instance in the `eu-west-1` region.
- **Location**: See the Terraform file [AWS/main.tf](AWS/main.tf#L1-L400) for the exact configuration.

**What this configuration creates**
- **VPC**: A single VPC with CIDR block 10.0.0.0/16.
- **Subnet**: One subnet inside the VPC with CIDR 10.0.1.0/24 placed in availability zone eu-west-1a.
- **Network Interface**: A network interface attached to the subnet with the private IP 10.0.1.10.
- **Internet Gateway (IGW)**: An IGW attached to the VPC (allows internet routing when a subnet route table points to it).
- **Elastic IP (EIP)**: A public Elastic IP reserved and associated with the EC2 instance.
- **Ubuntu AMI data**: Looks up the most recent Ubuntu 20.04 (Focal) AMI provided by Canonical.
- **EC2 Instance**: A `t2.micro` EC2 instance using the looked-up Ubuntu AMI and the attached network interface; CPU credits set to `standard`.

**Why these pieces are useful**
- **VPC & Subnet**: Provide isolated networking for resources.
- **Network Interface & Private IP**: Give the instance a predictable internal address.
- **IGW + EIP**: The IGW is created and an EIP is assigned to the instance. To actually reach the internet, the subnet needs a route in a route table that targets the IGW (this configuration currently creates the IGW and the EIP, but does not create a route table or route).
- **AMI data source**: Keeps the instance image selection up-to-date by picking the most recent matching Canonical AMI.

**Notes / Potential follow-ups**
- If you want the instance to have working internet access, add a route table with a route to the IGW and associate it with the subnet.
- The configuration explicitly sets a private IP; change `private_ips` if you need a different internal address or want DHCP assignment.
- Availability zone `eu-west-1a` is an AWS-specific AZ mapping — change it if you require a different AZ in `eu-west-1`.

**Requirements / Prerequisites**
- Install Terraform (compatible with Terraform v1.x and the AWS provider v6.0 as declared).
- Configure AWS credentials (via environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, or the AWS shared credentials file, or an IAM role if running in AWS).

**Quick usage**
1. Initialize Terraform providers and modules:

```bash
terraform init
```

2. See planned changes:

```bash
terraform plan
```

3. Apply the configuration (creates resources):

```bash
terraform apply
```

4. Destroy the resources when finished:

```bash
terraform destroy
```
``