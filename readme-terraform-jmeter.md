# Terraform Setup for JMeter Performance Test

This project includes Terraform configuration files to set up an environment for running JMeter performance tests on AWS. The setup provisions the necessary infrastructure, including servers for the JMeter master and slaves, and handles the installation and configuration of required software.

## File Descriptions

### main.tf

The `main.tf` file contains the main configuration for the Terraform setup. It defines the resources required for the infrastructure, such as EC2 instances, security groups, and IAM roles.

### variables.tf

The `variables.tf` file defines the input variables used in the Terraform configuration. These variables allow for customization of the setup, such as specifying instance types, key pairs, the number of instances, jmeter configurations.

### output.tf

The `output.tf` file defines the outputs for the Terraform setup. It specifies the information to be displayed after the infrastructure is provisioned, such as the public IP addresses of the EC2 instances.

### server_user_data.sh.tpl

The `server_user_data.sh.tpl` file is a template for the user data script that will be run on the server (JMeter master) instance. This script installs JMeter and any other required software, and sets up the server for running the tests.

### client_user_data.sh.tpl

The `client_user_data.sh.tpl` file is a template for the user data script that will be run on the client (JMeter slave) instances. This script installs JMeter and any other required software, and configures the instances to connect to the JMeter master.

## How to Use

1. **Install Terraform**: Make sure you have Terraform installed on your machine. You can download it from the [Terraform website](https://www.terraform.io/downloads.html).

2. **AWS Credentials**: Ensure that your AWS credentials are configured. You can set them up using the AWS CLI or by setting environment variables.

3. **Configure Variables**: Update the `variables.tf` file with your desired configuration. For example, set the instance types, key pair name, and number of instances.

4. **Initialize Terraform**: Run the following command to initialize Terraform. This will download the necessary provider plugins.

    ```bash
    terraform init
    ```

5. **Plan the Deployment**: Run the following command to see a preview of the resources that will be created by Terraform.

    ```bash
    terraform plan
    ```

6. **Apply the Deployment**: Run the following command to apply the configuration and provision the infrastructure.

    ```bash
    terraform apply
    ```

7. **Access the JMeter Master**: After the infrastructure is provisioned, you can access the JMeter master instance using the public IP address provided in the outputs. Use SSH to connect to the instance.

8. **Run JMeter Tests**: Follow the instructions provided in the JMeter setup to run your performance tests.

## Cleaning Up

To destroy the infrastructure and clean up resources, run the following command:

```bash
terraform destroy
```