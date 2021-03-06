$unit="GB"
$measure = "1$unit"
$SpaceReport = Get-WmiObject -computername "Win7NetBook" -query "
select Name, DriveType, FileSystem, FreeSpace, Capacity, Label
  from Win32_Volume
 where DriveType = 2 or DriveType = 3" `
| select Name `
        , @{Label="SizeIn$unit";Expression={"{0:n2}" -f($_.Capacity/$measure)}} `
        , @{Label="FreeIn$unit";Expression={"{0:n2}" -f($_.freespace/$measure)}} `
        , @{Label="PercentFree";Expression={"{0:n2}" -f(($_.freespace / $_.Capacity) * 100)}} `
        ,  Label | out-string;
Send-MailMessage -To Aaron@SQLvariant.com -Subject "SQL Cluster Free Space Check" -From Aaron@SQLvariant.com -SmtpServer SMTP.SQLvariant.com -Body $SpaceReport