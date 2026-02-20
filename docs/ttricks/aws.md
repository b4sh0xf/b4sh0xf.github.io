# aws-cli cheatsheet

## setup
```bash
aws configure --profile=test
alias aws='aws --profile=test | jq'
```
## whoami
```bash
aws sts get-caller-identity
aws ec2 describe-regions
```
## iam recon
```bash
aws iam list-users
aws iam list-groups
aws iam list-roles
aws iam list-account-aliases
aws iam list-role-policies --role-name <role>
aws iam get-role-policy --role-name <role> --policy-name <policy name>
aws iam list-groups-for-user --user-name <user>
aws iam list-user-policies --user-name <user>
aws iam list-attached-user-policies --user-name <user>
aws iam get-user-policy --user-name <user> --policy-name <policy name>
aws iam get-policy --policy-arn <policy arn>
aws iam list-policy-versions --policy-arn <policy arn>
aws iam get-policy-version --policy-arn <policy arn> --version-id <policy version>
for i in {1..5}; do aws iam get-policy-version --policy-arn <policy-arn> --version-id v$i; done
aws iam get-account-authorization-details
```
## ec2 recon
```bash
aws ec2 describe-instances
aws ec2 describe-security-groups
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws ec2 describe-network-interfaces
aws ec2 describe-key-pairs
```
## s3 recon
```bash
aws s3 ls
aws s3 ls s3://<bucket name>
aws s3 get-bucket-policy --bucket <bucket-name>
aws s3 get-bucket-acl --bucket <bucket-name>
```
## lambda recon
```
aws lambda list-functions
aws lambda get-function --function-name <function name>
aws lambda update-function-code --function-name <function name> --zip-file=fileb://lambda.zip
aws lambda invoke --function-name <function name> --payload '{}' output.json
aws lambda get-function-configuration --function-name <function name>
aws lambda get-policy --function-name <function name>
```
## cloudtrail recon
```bash
aws cloudtrail describe-trails
aws cloudtrail get-trail-status --name <trail name>
```
## cloudwatch recon
```bash
aws logs describe-log-groups
aws cloudwatch describe-alarms
```
## rollback privesc
## vuln lambda
## cloud breach s3