#ps1_sysnative
$telegrafAgentUrl = "https://dl.influxdata.com/telegraf/releases/telegraf-1.12.1_windows_amd64.zip"
$telegrafziplocation = Join-Path $Env:Programfiles "telegraf-1.12.1_windows_amd64.zip"
$telegrafnonprodconfigUrl = "https://raw.githubusercontent.com/mayankkapoor/statuscheck/master/windows_telegraf_nonprod.conf"
$telegrafprodconfigUrl = "https://raw.githubusercontent.com/mayankkapoor/statuscheck/master/windows_telegraf_prod.conf"
$metadataurl = "http://169.254.169.254/openstack/latest/meta_data.json"
$metadatapath = Join-Path $Env:Programfiles "telegraf\meta_data.json"
$telegrafconfpath = Join-Path $Env:Programfiles "telegraf\telegraf.conf"
$telegrafpath = $Env:Programfiles
$text = "Write-Output `"longrunning,tag=1 ln=2,rcb=1,runq=2 `""
Invoke-WebRequest -Uri $telegrafAgentUrl -OutFile $telegrafziplocation
Add-Type -AssemblyName System.IO.Compression.FileSystem
function unzip {
   param( [string]$ziparchive, [string]$extractpath )
   [System.IO.Compression.ZipFile]::ExtractToDirectory( $ziparchive, $extractpath )
}
unzip  $telegrafziplocation $telegrafpath
Invoke-WebRequest -Uri $telegrafprodconfigUrl -OutFile $telegrafconfpath
New-Item -ItemType directory -Path C:\cfn
function createfile {
    param( [string]$text)
    $text | Set-Content 'c:\cfn\reach.ps1'
}
createfile $text
function configchange {
    param( [string]$metadataurl, [string]$metadatapath, [string]$telegrafconfpath )
    Invoke-WebRequest -Uri $metadataurl -OutFile $metadatapath
    $values = Get-Content $metadatapath | Out-String | ConvertFrom-Json
    $Env:serverid = $values.uuid
    (Get-Content $telegrafconfpath -Raw) -replace 'windowsvmid',"$($Env:serverid)" | Set-Content $telegrafconfpath
}
configchange $metadataurl $metadatapath $telegrafconfpath
			
cd C:\'Program Files'\telegraf
.\telegraf.exe --service install
net start telegraf
