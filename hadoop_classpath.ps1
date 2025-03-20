function Set-Classpath {
   # Set HADOOP_CLASSPATH
    $hadoopClasspath = & hadoop classpath  # Get classpath
    [System.Environment]::SetEnvironmentVariable("HADOOP_CLASSPATH", $hadoopClasspath, "Machine")
    # Format the NameNode
    Write-Host "HADOOP_CLASSPATH environmental variable added successfully"
    Write-Host "Formatting Hadoop NameNode..."
    Start-Process -NoNewWindow -Wait -FilePath "hdfs" -ArgumentList "namenode -format"

    Write-Host "NameNode formatted successfully!"
    
}
Set-Classpath