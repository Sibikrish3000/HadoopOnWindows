# HadoopOnWindows
```
git clone https://github.com/Sibikrish3000/HadoopOnWindows.git

cd HadoopOnWindows
```
### Run powershell as administrator then navigate HadoopOnWindows/ folder
```
./install.ps1
```

```
start-all.cmd
hdfs secondarynamenode 
```
To Run hadoop-streaming
```
hdfs dfs -mkdir /input   
hdfs dfs -put input.txt /input/ 
#example
hadoop jar $env:HADOOP_HOME\share\hadoop\tools\lib\hadoop-streaming-2.9.2.jar -input /input -output /output -mapper "C:\Program Files\R\R-4.5.1\bin\Rscript.exe D:HadoopOnWindows\R\mapper.R" -reducer "C:\Program Files\R\R-4.5.1\bin\Rscript.exe D:HadoopOnWindows\R\reducer.R"
```

```
hdfs dfs -get /output C:\local\path\output
```
