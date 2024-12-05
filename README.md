# Automating Helix Core on AWS EC2 for Students

To do:

- [ ] Automate installation and configuration with Ansible or `user_data` script in `main.tf`.

## Perforce Documentation

The Terraform provisioning creates a RHEL9 instance.

- [Download helix-core-p4d](https://www.perforce.com/downloads/helix-core-p4d)
- [Install dependencies](https://help.perforce.com/helix-core/server-apps/p4sag/current/Content/P4SAG/install.linux.packages.install.html)
- [Configure](https://help.perforce.com/helix-core/server-apps/p4sag/current/Content/P4SAG/install.linux.packages.configure.html)
- [Packages information](https://www.perforce.com/perforce-packages)

## Infrastructure Provisioning

The first step is to provision the infrastructure using Terraform.

Make sure you have credentials for at least one profile configured for AWS. Change the `provider` options in `main.tf` accordingly.

You can also set the instance type and volume sizes.

Before running the script, make sure you have a key-pair called `helix-servers` configured in your AWS region (or change script accordingly).

Run:

```sh
terraform init
terraform apply # to provision
terraform destroy # to delete everything
```

## Manual Installation and Configuration of Helix Core

SSH into your instance using your private key. You can find the right query in the "Connect" tab of your newly created EC2 instance.

Execute the following commands to install `helix-p4d`:

```sh
sudo yum update -y
sudo rpm --import https://package.perforce.com/perforce.pubkey
sudo cat > ~/perforce.repo << EOF
[perforce]
name=Perforce
baseurl=https://package.perforce.com/yum/rhel/9/x86_64
enabled=1
gpgcheck=1
EOF
sudo mv ~/perforce.repo /etc/yum.repos.d/perforce.repo
sudo yum install helix-p4d
```

To launch the configuration, run:

```sh
sudo /opt/perforce/sbin/configure-helix-p4d.sh
```

## Change Security Level

```sh
p4 -u super login
p4 configure show security
p4 configure set security=2
```

## Connection and Users Creation

TBD