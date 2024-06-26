# Chemaxon DevOps Homework 2

## Exercise 2

We have an application that stores data on a filesystem, and our backup policy requires that it stores backups for 180 days and no more. You have selected S3 as the backup storage in a different account.

Your goal is to ensure these backups are stored according to best practices. Please implement an S3 bucket with the appropriate configuration you think of as best practices for this task. Recommended ways to approach the problem are security, cost considerations.

Actually uploading the files as a cron job or something is not part of this exercise, but you have to ensure that the following IAM role is able to upload files into the bucket arn:aws:iam::123456789012:role/backup_uploader (its a fake :)).

## Solution

### Security Aspect

#### Data Protection and Access Control

* __Server-side Encryption__: Data is protected at rest using AWS KMS (SSE-KMS) to encrypt stored backups, safeguarding sensitive information.

* __Object Lock__: Implemented in Governance mode to prevent unauthorized deletion or modification of data, ensuring compliance with retention policies.

* __Access Control__: Access to the S3 bucket is restricted with a private ACL, ensuring only authorized entities have access to stored data. Public access is disabled to prevent unauthorized access attempts.

### Cost Optimization Aspects

#### Storage and Availability

* __Storage Class Selection__: Depending on access frequency and backup size over 180 days, S3 Standard-IA and S3 Glacier Instant Retrieval are the ideal storage classes for cost efficiency and availability across multiple availability zones.

* __Versioning__: Enabled to safeguard against accidental data loss and support auditing, ensuring data integrity and compliance without additional cost.
