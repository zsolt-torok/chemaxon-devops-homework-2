# Chemaxon DevOps Homework 2

## Exercise 2

We have an application that stores data on a filesystem, and our backup policy requires that it stores backups for 180 days and no more. You have selected S3 as the backup storage in a different account.

Your goal is to ensure these backups are stored according to best practices. Please implement an S3 bucket with the appropriate configuration you think of as best practices for this task. Recommended ways to approach the problem are security, cost considerations.

Actually uploading the files as a cron job or something is not part of this exercise, but you have to ensure that the following IAM role is able to upload files into the bucket arn:aws:iam::123456789012:role/backup_uploader (its a fake :)).

## Solution

### Security Aspect

* __Server-side Encryption__: Data is protected at rest using AWS KMS (SSE-KMS) to encrypt stored backups, safeguarding sensitive information. For the log bucket, server-side encryption is applied using default AES-256 encryption.

* __Object Lock__: Implemented in Governance mode to prevent unauthorized deletion or modification of data, ensuring compliance with retention policies (applicable to the backup bucket).

* __Access Control__: Access to the S3 buckets is restricted with appropriate ACLs:

  * The backup bucket uses a `private` ACL, ensuring only authorized entities have access to stored data.
  * The log bucket uses the `log-delivery-write` ACL to allow S3 to write access logs.
  * Public access is disabled for both buckets to prevent unauthorized access attempts.

* __Logging__: The log bucket is configured to store access logs from the backup bucket, ensuring that all access to the backup bucket is tracked and auditable. _(In addition to S3 bucket access logs, AWS CloudTrail can be used for comprehensive auditing purposes.)_

### Cost Optimization Aspects

* __Storage Class Selection__: Depending on access frequency and backup size over 180 days, S3 Standard-IA and S3 Glacier Instant Retrieval are the ideal storage classes for cost efficiency and availability across multiple availability zones.

* __Versioning__: Enabled on backup bucket to safeguard against accidental data loss and support auditing, ensuring data integrity and compliance without additional cost.

* __Lifecycle Policies__: Implemented to manage the lifecycle of objects in the buckets:

  * The backup bucket has lifecycle rules to transition objects to more cost-effective storage classes and to expire objects after 180 days.
  * The log bucket has a lifecycle rule to transition objects to Glacier after 90 days and expire them after 180 days, reducing storage costs over time.
