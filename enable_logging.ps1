Import-Module AWSPowerShell

# Import Route53 CSV file
$domains = Import-Csv .\domains-test.csv 

# Loop against all objects in CSV
ForEach ($domain in $domains) 
{
    $zone_id = $domain.("Zone")
    $zone_name = $domain.("Domain Name")
    $log_group_name = "/aws/route53/" + $zone_name
    $log_group_arn = "arn:aws:logs:us-east-1:660850536225:log-group:" + $log_group_name
    $metric_name = $zone_name + "_query_count"

    # Create CloudWatch Log Group for zone
    Write-Output "Creating CloudWatch Log Group for $($zone_name)"
    New-CWLLogGroup -LogGroupName $log_group_name -Region us-east-1 -ProfileName colibri-legacy
    
    # Apply retention policy for zone-specific CloudWatch Log Group
    Write-Output "Modifying CloudWatch Log Group retention policy for $($zone_name)"
    Write-CWLRetentionPolicy -LogGroupName $log_group_name -RetentionInDays 14 -Region us-east-1 -ProfileName colibri-legacy
    
    # Set Route53 Logging Config against newly-created CloudWatch Log Group 
    Write-Output "Setting Route53 Query Logging configuration for $($zone_name) at $($log_group_name)"
    New-R53QueryLoggingConfig -HostedZoneId $zone_id -CloudWatchLogsLogGroupArn $log_group_arn -Region us-east-1 -ProfileName colibri-legacy

    # Create new metric for tracking domain requests
    Write-Output "Creating CloudWatch Log Metric filter $($zone_name)"
    $metric_transform = New-Object Amazon.CloudWatchLogs.Model.MetricTransformation
    $metric_transform.MetricName = $metric_name
    $metric_transform.MetricNamespace = "DNS Metrics"
    $metric_transform.MetricValue = 1
    Write-CWLMetricFilter -LogGroupName $log_group_name -FilterPattern "" -FilterName $zone_name -MetricTransformation $metric_transform -Region us-east-1 -ProfileName colibri-legacy
}