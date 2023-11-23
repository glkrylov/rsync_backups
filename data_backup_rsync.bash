#!/bin/bash

##############################################################################
##IMPORTANT - PATH FORMAT EXAMPLES
#Regular OS-style paths, without trailing slashes, for multiple folders put lists in brackets

#Windows example
#local_paths=("C:\soft\DeltaCopy Raw" "C:\local\plots_for_muniqc")

#Linux example
#local_paths=("/home/gleb/rsfq_lib copy" "/home/gleb/xld2_ic_crosstalk")

##################### NO MODIFICATIONS SHOULD BE NEEDED BELOW ################


#Hostname is used as root folder for data on server
remote_path_prefix="/mnt/data/"$(hostname)/

server_ip="BADWWMI-BACKUPS"  #VM 10.155.18.25 on the data server 10.155.18.24
user_account="serveruser" #may be changed to LRZ auth later, tbd


date


##SSH key setup to automate login for unattended backups
#specified by '-s' flag
#read setup flag for initial SSH key setup (once)
setup_needed="False"
while getopts 's' flag; do
	  case "${flag}" in
		s) setup_needed="True" ;;
	  esac
  done

#basic initial SSH key setup
if [ $setup_needed = 'True' ]
	then
	sshpath="$(pwd -P)/.ssh/id_rsa"
	echo $sshpath
	ssh-keygen -t rsa -f $sshpath -N ""
	ssh-copy-id $user_account@$server_ip
fi




#get local OS, convert local paths to cygwin paths if needed
full_local_paths=()
for i in "${local_paths[@]}"; do
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		full_local_paths+=("$i")
	elif [[ "$OSTYPE" == "cygwin" ]]; then
		full_local_paths+=("$(cygpath -u "$i")"/)
	#else
	#TODO OSX
	fi
done


#sanitize remote path, can append custom paths here
full_remote_path=$(readlink -m $remote_path_prefix)


#rsync
for pth in "${full_local_paths[@]}"; do
	echo "rsync -avz -s --mkpath --progress "$pth" $user_account@$server_ip:$full_remote_path"
	rsync -avz -s --mkpath --progress "$pth" $user_account@$server_ip:$full_remote_path
done


