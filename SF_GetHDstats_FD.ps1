<#
.SYNOPSIS
  
.DESCRIPTION
   Get Helpdesk stats for Sensor Factory Portal.
.PARAMETER Message
    NA.
.NOTES       
    1.0
        support@sensorfactory.eu
        01/02/2017
.EXAMPLE
  SF_GetHDstats_FD.ps1
#>
#Create temporary console
ping localhost -n 1 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$output=""

# API Key
$FDApiKey="ozGnKxQTFSJoexwOlPGq"
#################################################

# Force TLS1.2 as Powershell defaults to TLS 1.0 and Freshdesk will fail connections
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

# Prep
$pair = "$($FDApiKey):$($FDApiKey)"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$FDHeaders = @{ Authorization = $basicAuthValue }

# Status tab
$statuses = @("all","open","overdue","due_today","on_hold","new")
$statuts = @("Tous","Ouvert","En retard","Attendu aujourd'hui","En attente","Nouveau")

##################################################
$output+="<?xml version=`"1.0`" encoding=`"UTF-8`" ?>"
$output+="<prtg>"

$Count = 0
foreach ($status in $statuses)
{
    # The Doing part
    $FDBaseEndpointSummary =  "https://support.sensorfactory.eu/helpdesk/tickets/summary.xml?view_name=" + $status
    $FDContactData = Invoke-WebRequest -uri $FDBaseEndpointSummary -Method GET -Headers $FDHeaders -UseBasicParsing

     # The Display part
    $FDOutput = $FDContactData -replace ".*integer" -replace "</view.*" -replace ".*?>" -replace "</count.*"
    $FDOutput = $FDOutput.Trim()

    $output+="    <result>
    <channel>$($statuts[$Count])</channel>
    <value>$FDOutput</value>
    </result>"
    
    $Count++

}

$output+="</prtg>"

[Console]::WriteLine($output)
# Script ends