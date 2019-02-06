
# Route53 Logging Tool

Quick-and-dirty Powershell script to enable/disable Route53 Query Logging.  This PowerShell script performs the following, taking input from a CSV file -

* Creates a CloudWatch Log Group for a Route 53 domain
* Applies a retention policy to the newly-created CloudWatch Log Group
* Points the Route53 Query Logging configuration for the Route53 domain to the CloudWatch Log Group
* Creates a CloudWatch Log Metric to calculate Route 53 domain utilization

## Requirements

* [AWS Tools for PowerShell](https://aws.amazon.com/powershell/)
* A CSV file containing the following Route53 information -
  * The hosted zone ID
  * The domain name