###Execute as Administrator
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$testadmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($testadmin -eq $false) {
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
exit $LASTEXITCODE
}

###Install Unifi Software
function Install-Unifi
{
    Write-Host "Do not start server after install is completed"
    New-Item -Path "C:\" -Name "temp" -ItemType "directory" | out-null
    Invoke-RestMethod -ContentType "application/octet-stream" -Uri "https://dl.ui.com/unifi/8.0.24/UniFi-installer.exe"  -OutFile "C:\temp\Unifi-installer.exe" 
    Start-Process "C:\temp\Unifi-installer.exe" -Wait
    Move-Item -Path "$env:USERPROFILE\Ubiquiti UniFi" -Destination "C:\Ubiquiti_UniFi"
    Remove-Item -Path "$env:USERPROFILE\Desktop\Unifi.lnk"
    Remove-Item -Recurse -Force -Path "C:\temp"    
}

###Open Ports on Firewall for Unifi to use
function Open-Firewall
{
    netsh advfirewall firewall add rule name="Unifi Controller 8080 In" dir=in action=allow protocol=TCP localport=8080 | out-null
    Write-Host "Opened port 8080/TCP"
    netsh advfirewall firewall add rule name="Unifi Controller 8843 In" dir=in action=allow protocol=TCP localport=8843 | out-null
    Write-Host "Opened port 8843/TCP"
    netsh advfirewall firewall add rule name="Unifi Controller 10001 In" dir=in action=allow protocol=UDP localport=10001 | out-null
    Write-Host "Opened port 10001/UDP"
    netsh advfirewall firewall add rule name="Unifi Controller 3478 In" dir=in action=allow protocol=UDP localport=3478 | out-null
    Write-Host "Opened port 3478/UDP"   
}

###Install Jave 17
function Install-Java
{
    Write-Host "Do a typical install, no customs needed."
    New-Item -Path "C:\" -Name "temp" -ItemType "directory" | out-null
    Invoke-RestMethod -ContentType "application/octet-stream" -Uri "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9.1/OpenJDK17U-jdk_x64_windows_hotspot_17.0.9_9.msi" -OutFile "C:\temp\OpenJDK17U-jre_x64_windows_hotspot_17.0.9_9.msi"  
    Start-Process "C:\temp\OpenJDK17U-jre_x64_windows_hotspot_17.0.9_9.msi" -Wait
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Eclipse Adoptium\jre-17.0.9.9-hotspot")
    [System.Environment]::SetEnvironmentVariable("Path", [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) + ";$($env:JAVA_HOME)\bin")
    Remove-Item -Recurse -Force -Path "C:\temp"    
}

###Install the Unifi Service
function Install-Service
{
    New-Item -Path "C:\Ubiquiti_UniFi" -Name "data" -ItemType "directory" | out-null
    Set-Content -Path "C:\Ubiquiti_UniFi\data\system.properties" -Value "unifi.https.port=8843"
    java -jar C:\Ubiquiti_UniFi\lib\ace.jar installsvc    
}

###Start the Unifi Service
function Start-Service
{
    java -jar C:\Ubiquiti_UniFi\lib\ace.jar startsvc
    Write-Host "Unifi Service Started"
}


###Stop the Unifi Service
function Stop-Service
{
    java -jar C:\Ubiquiti_UniFi\lib\ace.jar stopsvc
    Write-Host "Unifi Service Stopped"    
}


###User Menu
function Show-Menu
{
    param (
        [string]$Title = 'Welcome to Unifi Installer for Windows'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to Install Unifi Controller."
    Write-Host "2: Press '2' to Start the Unifi-Service."
    Write-Host "3: Press '3' to Stop the Unifi-Service."
    Write-Host "Q: Press 'Q' to quit."
}

###Menu
do
{
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
        '1' {
            Install-Unifi
            Open-Firewall
            Install-Java
            Install-Service
            Start-Service
        } 
        '2' {
            Start-Service
        }
        '3' {
            Stop-Service
        }   
    }
    pause
} 
until ($selection -eq 'q')