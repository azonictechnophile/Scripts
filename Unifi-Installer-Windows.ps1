function Show-Menu
{
    param (
        [string]$Title = 'Welcome to Unifi Installer for Windows'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to install Unifi Controller."
    Write-Host "2: Press '2' to set firewall rules."
    Write-Host "3: Press '3' to install Java 17."
    Write-Host "4: Press '4' to install Unifi-Service."
    Write-Host "5: Press '5' to start Unifi-Service."
    Write-Host "6: Press '6' to stop Unifi-Service."
    Write-Host "Q: Press 'Q' to quit."
}

do
{
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
        '1' {
            Write-Host "Do not start server after install is completed"
            New-Item -Path "C:\" -Name "temp" -ItemType "directory" | out-null
            Invoke-RestMethod -ContentType "application/octet-stream" -Uri "https://dl.ui.com/unifi/8.0.24/UniFi-installer.exe"  -OutFile "C:\temp\Unifi-installer.exe" 
            Start-Process "C:\temp\Unifi-installer.exe" -Wait
            Move-Item -Path "$env:USERPROFILE\Ubiquiti UniFi" -Destination "C:\Ubiquiti_UniFi"
            Remove-Item -Path "$env:USERPROFILE\Desktop\Unifi.lnk"
            Remove-Item -Recurse -Force -Path "C:\temp"
        } 
        '2' {
            netsh advfirewall firewall add rule name="Unifi Controller 8080 In" dir=in action=allow protocol=TCP localport=8080
            Write-Host "Opened port 8080/TCP"
            netsh advfirewall firewall add rule name="Unifi Controller 8843 In" dir=in action=allow protocol=TCP localport=8843
            Write-Host "Opened port 8843/TCP"
            netsh advfirewall firewall add rule name="Unifi Controller 10001 In" dir=in action=allow protocol=UDP localport=10001
            Write-Host "Opened port 10001/UDP"
            netsh advfirewall firewall add rule name="Unifi Controller 3478 In" dir=in action=allow protocol=UDP localport=3478
            Write-Host "Opened port 3478/UDP"
        } 
        '3' {
            Write-Host "Do a typical install, no customs needed."
            New-Item -Path "C:\" -Name "temp" -ItemType "directory" | out-null
            Invoke-RestMethod -ContentType "application/octet-stream" -Uri "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9.1/OpenJDK17U-jdk_x64_windows_hotspot_17.0.9_9.msi" -OutFile "C:\temp\OpenJDK17U-jre_x64_windows_hotspot_17.0.9_9.msi"  
            Start-Process "C:\temp\OpenJDK17U-jre_x64_windows_hotspot_17.0.9_9.msi" -Wait
            [System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Eclipse Adoptium\jre-17.0.9.9-hotspot")
            [System.Environment]::SetEnvironmentVariable("Path", [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) + ";$($env:JAVA_HOME)\bin")
            Remove-Item -Recurse -Force -Path "C:\temp"
        } 
        '4' {
            New-Item -Path "C:\Ubiquiti_UniFi" -Name "data" -ItemType "directory" | out-null
            Set-Content -Path "C:\Ubiquiti_UniFi\data\system.properties" -Value "unifi.https.port=8843"
            java -jar C:\Ubiquiti_UniFi\lib\ace.jar installsvc
        }
        '5' {
            java -jar C:\Ubiquiti_UniFi\lib\ace.jar startsvc
            Write-Host "Unifi Service Started"
        }
        '6' {
            java -jar C:\Ubiquiti_UniFi\lib\ace.jar stopsvc
            Write-Host "Unifi Service Stopped"
        }
    
    }
    pause
} 
until ($selection -eq 'q')