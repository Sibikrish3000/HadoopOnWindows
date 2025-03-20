<#
.SYNOPSIS
	Install hadoop on windows
.DESCRIPTION
	This PowerShell script Install OpenJDK 1.8, Hadoop 2.9.2, Winutils Binaries, Copy hadoop config, and set environment variables.
.EXAMPLE
	PS> ./install.ps1

.LINK
	https://github.com/Sibikrish3000/HadoopOnWindows
.NOTES
	Author: Sibi Krishnamoorthy | License: MIT
#>

# Set execution policy to allow script execution (Run as Administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
# PowerShell Script to Install OpenJDK 1.8, Hadoop 2.9.2, and Winutils Binaries

# Define URLs and Paths
$jdkUrl = "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u442-b06/OpenJDK8U-jdk_x64_windows_hotspot_8u442b06.zip"
$hadoopUrl = "https://archive.apache.org/dist/hadoop/core/hadoop-2.9.2/hadoop-2.9.2.tar.gz"
$winutilsRepo = "https://raw.githubusercontent.com/cdarlint/winutils/master/hadoop-2.9.2/bin"

# Set install paths
$jdkExtractPath = "C:\Program Files\Java"
$jdkFinalPath = "$jdkExtractPath\jdk1.8.0"
$jdkpath = "$jdkExtractPath\jdk1.8.0"
$jdkZip = "$env:TEMP\jdk8.zip"
$hadoopPath = "C:\hadoop"
$hadoopBinPath = "$hadoopPath\bin"
$hadoopConfPath = "$hadoopPath\etc\hadoop"

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "⚠️ Please run this script as Administrator!"
    exit
}

# Function to install JDK
function Install-JDK {
    if (!(Test-Path -Path "$jdkFinalPath")) {
        Write-Output "Downloading OpenJDK 1.8..."
        
        # Ensure download completes successfully
        Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkZip -ErrorAction Stop

        # Check if the file is actually downloaded
        if (Test-Path $jdkZip) {
            Write-Output "Extracting OpenJDK 1.8..."
            Expand-Archive -Path $jdkZip -DestinationPath "$jdkExtractPath" -Force
            Remove-Item -Path $jdkZip -Force

            # Rename extracted folder
            $jdkExtractedFolder = Get-ChildItem -Path $jdkExtractPath -Directory | Where-Object { $_.Name -match "jdk8u" } | Select-Object -ExpandProperty FullName
            if ($jdkExtractedFolder -and (Test-Path -Path $jdkExtractedFolder)) {
                Rename-Item -Path $jdkExtractedFolder -NewName "jdk1.8.0"
                Write-Output "Renamed $jdkExtractedFolder to jdk1.8.0"
            }

            Write-Output "OpenJDK 1.8 Installed at $jdkFinalPath"
        } else {
            Write-Output "Failed to download JDK archive. Check your internet connection and try again."
            exit 1
        }
    } else {
        Write-Output "OpenJDK 1.8 is already installed!"
    }
}
# Function to install Hadoop
function Install-Hadoop {
    if (!(Test-Path -Path "$hadoopPath")) {
        $hadoopArchive = "$env:TEMP\hadoop-2.9.2.tar.gz"

        if (!(Test-Path -Path $hadoopArchive)) {
            Write-Output "Downloading Hadoop 2.9.2..."
            Invoke-WebRequest -Uri $hadoopUrl -OutFile $hadoopArchive
        } else {
            Write-Output "Hadoop 2.9.2 archive already exists at $hadoopArchive!"
        }

        Write-Output "Extracting Hadoop..."
        tar -xvf $hadoopArchive -C "C:\"
        Rename-Item -Path "C:\hadoop-2.9.2" -NewName "C:\hadoop"

        # New-Item -ItemType Directory -Path "C:\hadoop\data\datanode","C:\hadoop\data\namenode" -Force

        Write-Output "Hadoop 2.9.2 Installed!"
    } else {
        Write-Output "Hadoop 2.9.2 is already installed!"
    }
}

# Function to install Winutils
function Install-Winutils {
    if (!(Test-Path -Path "$hadoopBinPath")) {
        New-Item -ItemType Directory -Path "$hadoopBinPath" -Force
    }

    $winutilsFiles = @(
        "hadoop.cmd", "hadoop.dll", "hadoop.exp", "hadoop.lib", "hadoop.pdb",
        "hdfs.cmd", "hdfs.dll", "hdfs.exp", "hdfs.lib", "hdfs.pdb",
        "libwinutils.lib", "mapred.cmd", "winutils.exe", "winutils.pdb",
        "yarn.cmd"
    )

    foreach ($file in $winutilsFiles) {
        $fileUrl = "$winutilsRepo/$file"
        $filePath = "$hadoopBinPath\$file"

        if (!(Test-Path -Path $filePath)) {
            Write-Output "Downloading: $file..."
            Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
        } else {
            Write-Output " $file already exists!"
        }
    }

    Write-Output "Winutils binaries successfully copied to Hadoop bin!"
}

# Function to copy Hadoop XML configuration files
function Copy-HadoopConfig {
    Write-Output "Copying Hadoop configuration files..."


    $configFiles = @(
        "core-site.xml",
        "hdfs-site.xml",
        "mapred-site.xml",
        "yarn-site.xml",
        "hadoop-env.cmd"
    )

    foreach ($file in $configFiles) {
        $sourceFile = ".\hadoop-config\$file"  # Ensure you have config files in `hadoop-config` folder
        $destFile = "$hadoopConfPath\$file"

        if (Test-Path -Path $sourceFile) {
            Copy-Item -Path $sourceFile -Destination $destFile -Force
            Write-Output "Copied: $file"
        } else {
            Write-Output "Warning: $file not found in local hadoop-config folder!"
        }
    }

    Write-Output "Hadoop configuration files copied!"
}

# Function to set environment variables
function Set-EnvVars {
    Write-Output "Setting environment variables..."

    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, "Machine")
    [System.Environment]::SetEnvironmentVariable("HADOOP_HOME", $hadoopPath, "Machine")
    [System.Environment]::SetEnvironmentVariable("hadoop.home.dir", $hadoopPath, "Machine")

    [System.Environment]::SetEnvironmentVariable("Path", "$env:Path;$jdkPath\bin;$hadoopPath\bin;$hadoopPath\sbin", "Machine")

    Write-Output "Environment variables set! Restart your system to apply changes."
}
function DataNode-NameNode {
    # Create necessary directories if they do not exist
    $namenodeDir = "C:\hadoop\data\namenode"
    $datanodeDir = "C:\hadoop\data\datanode"

    if (!(Test-Path $namenodeDir)) {
        New-Item -ItemType Directory -Path $namenodeDir -Force
    }
    if (!(Test-Path $datanodeDir)) {
        New-Item -ItemType Directory -Path $datanodeDir -Force
    }

    Write-Output "DataNode and NameNode directories created"

}
function Set-HadoopEnv {

    Start-Process powershell -ArgumentList "-NoExit", "-Command", "& { .\hadoop_classpath.ps1 }"
    
}
# Run installation steps
Install-JDK
Install-Hadoop
Install-Winutils
Copy-HadoopConfig
Set-EnvVars
DataNode-NameNode
Set-HadoopEnv

Write-Output "Installation complete! Restart your system to apply changes."