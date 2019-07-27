# Docker in Production using AWS - Packer Build for ECS Images

This repository provides a Packer build script for creating Amazon Machine Images (AMIs) for running custom AWS EC2 Container Service (ECS) Container Instance images, as described in the Pluralsight course Docker in Production using AWS.

## Current AIM
ami-0dbe036377e7192d3

### Get latest AMI
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
g CloudWatch logs](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html)




### Login
```bash
export AWS_PROFILE=orcas
aws sts assume-role --role-arn  --role-session-name oc.next

```
```bash
eval $( aws ecr get-login --no-include-email --region us-west-2 )
```

## Run
Make sure you have packed installed `brew install packer`

```bash
make build
```
or
```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=M+TH4oW1k1cCoHbOYNOvGP4jjcMJazW/+uiLiXXa
export AWS_SESSION_TOKEN=FQoGZXIvYXdzEGQaDGPf7fkecuowDfVLpCLrAZoidn5wzL9EeUpCsqlpWjR2okUewv25KxCUp4G7CDVDwDVT5L43xGhe40dJc6wt6q8kIZxLStfUFL+NgEXJWdUXNDVFGT35Va4B0PCF1pKe6C9jVZGmRNrwdkaWuL84IoKtjR5YnN+NGeBqfdoH5a2BSMwRfkvPb/qf2ns9IZxmVtY0vI9x+zOIMaB5LRCFwpuHUhWt9/vbl15sMn1QYwTmQ47gR1CBSudEjSiGAm2/lCP2PMxWMHMhSmwBbwoabgvRbaKLDt5cusTNSF8B6U7iAHfogLnHdN5UdEomLRiFmpRoPO4HD3oXrqIovsvr5AU=
packer build packer.json 

```

## Further Reading

- [Latest Amazon ECS-Optimized AMI](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)
- [Packer AMI Builder reference](https://www.packer.io/docs/builders/amazon-ebs.html)
- [Configuring CloudWatch logs](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html)
