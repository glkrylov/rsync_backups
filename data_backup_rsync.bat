@echo off

IF "%1"=="-s" (
	c:\cygwin64\bin\bash.exe --login -i -c "data_backup_rsync.bash -s"
) ELSE (
	c:\cygwin64\bin\bash.exe --login -i -c "data_backup_rsync.bash"
)
