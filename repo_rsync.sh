#!/bin/bash
#Script name:rsync_yumrepo.sh
RsyncBin="/usr/bin/rsync"
#RsyncPerm=' -auvzSP --progress '
#RsyncPerm=' -auvSP '
#RsyncPerm=' -avSPHL --safe-links --delete '
#RsyncPerm=' -avSPHL --delete --delete-excluded --delete-after '
#RsyncPerm=' -avSPH --safe-links --delete '
#RsyncPerm=' -prltvHSLB8192 --progress --timeout 3600 --delay-updates --safe-links --delete-delay --delete-excluded '
#RsyncPerm=' -avSPHL --delete --delete-excluded --delete-after '
#RsyncPerm=' -avSHL --partial --delete --delete-excluded --delete-after '
RsyncPerm=' -avSHLl --copy-unsafe-links  --partial --delete --delete-excluded --delete-after '

case $repo in
"centos")
	exclude="--exclude=HEADER.html"
	Repo="centos"
	#src='rsync://mirrors.ustc.edu.cn/centos/'
	#src='rsync://us-msync.centos.org/CentOS/'
	#src='rsync://mirrors.skyshe.cn/centos/'
	#src='rsync://mirrors.hust.edu.cn/centos/'
	src='rsync://ftp.iij.ad.jp/centos/'
        ;;
"debian")
	#exclude="--exclude=project/trace/"
	Repo="debian"
	src='rsync://mirrors.ustc.edu.cn/debian/'
        ;;
"debian-backports")
	Repo="debian-backports"
	#src='rsync://mirrors.ustc.edu.cn/debian-backports/'
	src='rsync://ftp.at.debian.org/debian-backports/'
        ;;
"debian-cd")
	Repo="debian-cd"
	src='rsync://mirrors.ustc.edu.cn/debian-cd/'
        ;;
"debian-multimedia")
	Repo="debian-multimedia"
	#src='rsync://mirrors.ustc.edu.cn/debian-multimedia/'
	src=' rsync://www.deb-multimedia.org/deb/'
        ;;
"debian-security")
	Repo="debian-security"
	#src='rsync://mirrors.ustc.edu.cn/debian-security/'
	src='rsync://security.debian.org/debian-security'
        ;;
"epel")
	exclude=""
	Repo="epel"
	src='rsync://dl.fedoraproject.org/fedora-epel/'
	#dst="/var/www/html/repo/$Repo/"
        ;;
"scientificlinux")
	exclude='--exclude=5*  --exclude=obsolete/'
	Repo="scientificlinux"
	src='rsync://rsync.scientificlinux.org/scientific/'
	#src='rsync://mirrors.ustc.edu.cn/scientificlinux/'
	#dst="/var/www/html/repo/$Repo/"
        ;;
"mariadb")
	exclude="--exclude=index.html"
	Repo="mariadb"
	src='rsync://rsync.osuosl.org/mariadb/'
	#src='rsync://mirrors.ustc.edu.cn/mariadb/'
	#dst="/var/www/html/repo/$Repo/"
        ;;
"dell")
	Repo="dell"
	src='rsync://linux.dell.com/repo/hardware'
	dst="/var/www/html/repo/$Repo/"
        ;;
"addition-ynnic")
	exclude="--exclude=index.html --exclude=mirror.css"
	Repo="addition-ynnic"
	src='rsync://10.3.1.149/addition-ynnic/'
	#dst="/var/www/html/repo/ynnic/$Repo/"
        ;;
*)
	echo "export repo=centos/epel/scientificlinux;repo_rsync.sh"
        exit 0
        ;;
esac

#exclude="--exclude=5*" #为新repo修改这里

#Repo="scientificlinux" #为新repo修改这里

#src='rsync://rsync.scientificlinux.org/scientific/' #为新repo修改这里
dst="/var/www/html/repo/$Repo/"


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
                echo >>$StatusLogFile
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
