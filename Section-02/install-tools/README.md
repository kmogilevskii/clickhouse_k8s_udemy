# Terraform & AWS CLI & kubectl Installation

## Terraform Installation

### MAC OS

```
# install brew if you don't have one, otherwise skip this step
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# verify
terraform -v
```

### Linux

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# verify
terraform -v
```

### Windows

```
# install Chocolatey if you don't have
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install terraform
# verify
terraform -v
```

## AWS CLI Installation

### MAC OS

```
$ curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
$ sudo installer -pkg AWSCLIV2.pkg -target /

# verify
$ which aws
/usr/local/bin/aws 

$ aws --version
aws-cli/2.15.30 Python/3.11.6 Darwin/23.3.0 botocore/2.4.5
```

### Linux

```
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

$ unzip awscliv2.zip

# files will be installed /usr/local/aws-cli and symlink /usr/local/aws-cli
$ sudo ./aws/install

$ aws --version
# aws-cli/2.15.30 Python/3.11.6 Linux/5.10.205-195.807.amzn2.x86_64 botocore/2.4.5
```

### Windows

```
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

C:\> aws --version
aws-cli/2.15.30 Python/3.11.6 Windows/10 exe/AMD64 prompt/off
```

### Configure credentials

```
# Configure AWS Credentials in command line
$ aws configure
AWS Access Key ID [None]: AKIASUF7D********
AWS Secret Access Key [None]: WL9G9Tl8lGm**********
Default region name [None]: eu-west-1
Default output format [None]: json

# Verify if we are able list S3 buckets
aws s3 ls

cat $HOME/.aws/credentials 
```

## kubectl Installation

### MAC OS

```
# assume you already have brew

brew install kubectl

kubectl version --client
```

### Linux

```
# installing needed dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# download google cloud signing key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# add k8s apt repo
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get install -y kubectl

# verify
kubectl version --client
```

### Windows

```
# assume that you already have chocolatey

choco install kubernetes-cli

# verify
kubectl version --client
```