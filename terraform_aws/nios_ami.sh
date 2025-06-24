#!/bin/zsh
aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=*Infoblox NIOS*" --region ap-southeast-2 --query 'Images[*].[ImageId,Name]' --output table
