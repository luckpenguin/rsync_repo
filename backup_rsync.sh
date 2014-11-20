#!/bin/bash
#Script name:rsync_yumrepo.sh
RsyncBin="/usr/bin/rsync"

RsyncPerm=' -avSHL --partial --delete --delete-excluded --delete-after '

#exclude="--exclude=index.html"
Repo="backup"
src='rsync://116.55.230.251/repo/'

dst="/var/www/html/repo/"

LogDir="/var/www/html/repo/log/$Repo"
LogFile="$LogDir/${Repo}.log"
ErrorLogFile="$LogDir/${Repo}_error.log"
StatusLogFile="$LogDir/${Repo}_status.log"
LockDir='/var/run/repo'
LockFile="$LockDir/${Repo}.lock"

if [ ! -d "$LockDir" ];then
    mkdir -p $LockDir
fi

if [ ! -d "$LogDir" ];then
    mkdir -p $LogDir
fi


if [  -f "$LockFile" ];then
        echo "`date +%Y-%m-%d\ %H:%M:%S` Having other process  rsync ${Repo}." >>$LogFile
        exit 0
fi

touch $LockFile

#rsync Centos

#echo "Now start to rsync scientificlinux" >>$LogFile


count=0
while true
do
	start_rync="`date +%Y-%m-%d\ %H:%M:%S` Now start to sync ${Repo}."

	echo  >>$LogFile
	echo $start_rync >>$LogFile

	echo  >>$ErrorLogFile
	echo $start_rync >> $ErrorLogFile

	echo  >>$StatusLogFile
	echo $start_rync >> $StatusLogFile

        $RsyncBin $RsyncPerm \
                $exclude \
                $src \
                $dst \
                >> $LogFile \
                2>> $ErrorLogFile

        if [ $? -eq 0 ];then
                finish_rsync="`date +%Y-%m-%d\ %H:%M:%S` finished."
                echo $finish_rsync >>$LogFile
                echo $finish_rsync >>$StatusLogFile
                echo >>$LogFile
                echo >>StatusLogFile
                break
        else
                echo "`date +%Y-%m-%d\ %H:%M:%S` fail." >>$ErrorLogFile
                if [ $count -eq 2 ];then
                        stop_rsync="`date +%Y-%m-%d\ %H:%M:%S`  retry 3 fail." >>$ErrorLogFile
                        echo $stop_rsync>>$LogFile
                        echo $stop_rsync>>$ErrorLogFile
                        echo $stop_rsync>>$StatusLogFile
                        echo >>$LogFile
                        echo >>$ErrorLogFile
                        echo >>$StatusLogFile
                        break
                fi
                echo '10 seconds after the start sync.' >>$ErrorLogFile
                echo >>$LogFile
                echo >>$StatusLogFile
                echo >>$ErrorLogFile
                sleep 10
                let count=count+1
        fi
done
rm -rf $LockFile
