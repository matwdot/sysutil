#!/bin/bash


#Define Dependencies to upgrade

pkgrpmarray=("bash" "mawk" "procps" "sed" "grep" "coreutils" "net-tools" "wget" "perl" "crontabs" "chkconfig" )
pkgdebarray=("bash" "mawk" "procps" "sed" "grep" "coreutils" "net-tools" "wget" "cron" )
pkgtgzarray=("bash" "mawk" "procps" "sed" "grep" "coreutils" "net-tools" "wget" "dcron" )

#Define Dependencies to install

instarrayrpm=("bash" "mawk" "procps" "sed" "grep" "coreutils" "net-tools" "wget" "perl" "crontabs" "chkconfig" )
instarraydeb=("bash" "mawk" "procps" "sed" "grep" "coreutils" "net-tools" "wget" "cron" )
instarraytgz=("bash" "mawk" "procps" "sed" "grep" "coreutils" "net-tools" "wget" "dcron" )

#find arch and system
cont=0
larch=`arch`
s1=`type -p dpkg | wc -l` 2>/dev/null
s2=`type -p installpkg | wc -l` 2>/dev/null
s3=`type -p rpm | wc -l` 2>/dev/null


define_platform()
{
if [ -d /etc/apt/ ]; then

sysid=deb
rel=`cat /etc/os-release | grep -w "VERSION_ID" | awk -F"=" '{ print $2 }' | sed -e 's/"//g'` 2>/dev/null
did=`cat /etc/os-release | grep -w "ID" | awk -F"=" '{ print $2 }' | sed -e 's/"//g'` 2>/dev/null
didlike=`cat /etc/os-release | grep -w "ID_LIKE" | awk -F"=" '{ print $2 }' | sed -e 's/"//g'` 2>/dev/null
relint=${rel%.*}

	case "$did" in
		debian)
				if [  $relint -ge 7 ]; then
					cont=1
				fi
		;;
		ubuntu)
				if [  $relint -ge 14 ]; then
					cont=2
				fi
		;;
		raspbian)
				if [  $relint -ge 7 ]; then
					cont=3
				fi
		;;
		linuxmint)
				if [  $relint -ge 10 ]; then
					cont=7
				fi
		;;
		*)
			    if [ `echo $didlike | grep -c 'debian\|ubuntu'` -gt 0  ]; then
				cont=9
				fi
		;;
	esac
		
	case "$larch" in
		x86_64)	
			parch=amd64
		;;
		i686)
			parch=i386
		;;
		armv7*)	
			parch=armhf
		;;
		i386)
			parch=$larch
		;;
	esac
	
		sysd=`ls -la /sbin/init | grep -c systemd`
		if [ $sysd -eq 1 ]; then
			svcdown1="systemctl stop wnbmonitor"
			svcdup1="systemctl start wnbmonitor"
			svcdrel1="systemctl restart wnbmonitor"
			svcdown2="systemctl stop wnbtlscli"
			svcdup2="systemctl start wnbtlscli"
			svcdrel2="systemctl restart wnbtlscli"
		else
			svcdown1="service wnbmonitor stop"
			svcdup1="service wnbmonitor start"
			svcdrel1="service wnbmonitor restart"
			svcdown2="service wnbtlscli stop"
			svcdup2="service wnbtlscli start"
			svcdrel2="service wnbtlscli restart"
		fi

elif [ -d /etc/yum.repos.d/ ]; then

sysid=rpm
rel=`cat /etc/os-release | grep -w "VERSION_ID" | awk -F"=" '{ print $2 }' | sed -e 's/"//g' ` 2>/dev/null
did=`cat /etc/os-release | grep -w "ID" | awk -F"=" '{ print $2 }' | sed -e 's/"//g'` 2>/dev/null
relint=${rel%.*}

	if [ $did = "centos" -a $relint -ge 7 ]; then
		cont=4
	fi
	if [ $did = "fedora" -a $relint -gt 16 ]; then
		cont=5
	fi
	case "$larch" in
		i686)
			parch=i386
		;;
		armv7*)	
			echo "Arch not supported"
			exit 0
		;;
		x86_64)
			parch=$larch
		;;
		i386)
			parch=$larch
		;;
	esac
		sysd=`ls -la /sbin/init | grep -c systemd`
		if [ $sysd -eq 1 ]; then
			svcdown1="systemctl stop wnbmonitor"
			svcdup1="systemctl start wnbmonitor"
			svcdrel1="systemctl restart wnbmonitor"
			svcdown2="systemctl stop wnbtlscli"
			svcdup2="systemctl start wnbtlscli"
			svcdrel2="systemctl restart wnbtlscli"
		else
			svcdown1="service wnbmonitor stop"
			svcdup1="service wnbmonitor start"
			svcdrel1="service wnbmonitor restart"
			svcdown2="service wnbtlscli stop"
			svcdup2="service wnbtlscli start"
			svcdrel2="service wnbtlscli restart"
		fi

else

sysid=tgz	
rel=`cat /etc/os-release | grep -w "VERSION_ID" | awk -F"=" '{ print $2 }' | sed -e 's/"//g' ` 2>/dev/null
did=`cat /etc/os-release | grep -w "ID" | awk -F"=" '{ print $2 }' | sed -e 's/"//g'` 2>/dev/null
relint=${rel%.*}

	if [ $did = "slackware" -a $relint -ge 14 ]; then
		cont=6
	fi
	case "$larch" in
		x86_64)	
			echo "Arch not supported"
			exit 0
		;;
		i686)
			parch=i386
		;;
		arm*)	
			echo "Arch not supported"
			exit 0
		;;
		i386)
			parch=$larch
		;;
	esac
		sysd=`ls -la /sbin/init | grep -c systemd`
		if [ $sysd -eq 1 ]; then
			svcdown1="systemctl stop wnbmonitor"
			svcdup1="systemctl start wnbmonitor"
			svcdrel1="systemctl restart wnbmonitor"
			svcdown2="systemctl stop wnbtlscli"
			svcdup2="systemctl start wnbtlscli"
			svcdrel2="systemctl restart wnbtlscli"
		else
			svcdown1="/etc/rc.d/rc.wnbmonitor stop"
			svcdup1="/etc/rc.d/rc.wnbmonitor start"
			svcdrel1="/etc/rc.d/rc.wnbmonitor restart"
			svcdown2="/etc/rc.d/rc.wnbtlscli stop"
			svcdup2="/etc/rc.d/rc.wnbtlscli start"
			svcdrel2="/etc/rc.d/rc.wnbtlscli restart"
		fi
fi
}

# check basic dependencies
check_depend()
{
	echo " Checking Dependencies ... "
	case $sysid in
		deb)
			pkginst=() 
			dep=0
			for p in ${instarraydeb[*]}; do
			s=${#p}
				pok=`dpkg --get-selections | grep -w install | grep -w $p | awk '{ print length($0)==$s}' | wc -l`
				if [ $pok -eq 0 ]; then
					pkginst+=( $p )
				fi
			done
			if [ ${#pkginst[@]} -gt 0 ]; then
				dep=1
				echo  "Install dependencies " 
				echo  "${pkginst[@]}" 
				echo  "wait ..."
				apt-get upgrade
				if [ $? -eq 0 ]; then
					apt-get -f -y install --show-progress "${pkginst[@]}" 
					if [ $? -eq 0 ]; then
						dep=0
					else
						apt --fix-broken install
						echo "Error on run install dependencies process, try again"
					fi
				else
					echo "apt repository error check please"
				fi
			fi
		;;
		rpm)
			pkginst=()
			dep=0
			for p in ${instarrayrpm[*]}; do
				s=${#p}
				pok=`yum list installed | grep -w $p | awk '{ print length($0)==$s}' | wc -l`
				if [ $pok -eq 0 ]; then
					pkginst+=( $p )
				fi
			done
			if [ ${#pkginst[@]} -gt 0 ]; then
				dep=1
				echo  "Install dependencies " 
				echo  "${pkginst[@]}" 
				echo  "wait ..."
				yum upgrade
				if [ $? -eq 0 ]; then
					yum -y install "${pkginst[@]}"
					if [ $? -eq 0 ]; then
						dep=0
					else
						echo "Error on run install dependencies process, try again"
						exit 1
					fi
				else
					echo "apt repository error check please"
					exit 1
				fi
			fi
		;;
		tgz)
		en=`slackpkg update | grep -c uncomment`
		if [ $en -eq 0 ]; then
			pkginst=() 
			dep=0
			for p in ${pkgtgzarray[*]}; do
				echo .
				pok=`slackpkg search $p | grep -w $p | grep -wc installed`
				if [ $pok -eq 0 ]; then
					pkginst+=( $p )
				fi
			done
			if [ ${#pkginst[@]} -gt 0 ]; then
				dep=1
				echo  "Install dependencies " 
				echo  "${pkginst[@]}" 
				echo  "wait ..."
				slackpkg install "${pkginst[@]}" 
					if [ $? -eq 0 ]; then
						dep=0
					else
						echo "Error on run install dependencies process, try again"
						exit 1
					fi
			fi
		else
			echo " Repository error , verify is enable"
			exit 1
		fi
		;;
	esac
}


#MAIN CODE #
echo > /tmp/wnbinstall.log

case $1 in
	-i)
		if [ -d /etc/wnbtlscli/ ]; then
			echo "Software wnbtlscli ja instalado."
		else
		define_platform
			if [ $cont -gt 0 ] && [ $cont -lt 10 ]; then
				echo "Sistema operacional $did ,versao $relint e arquitetura de processador $parch"
			
				echo "validando e instalando as dependencias "
			
				check_depend
				
				if [ $dep -eq 0 ]; then
			
				echo "dependencias instaladas com sucesso"
				
					case "$sysid" in
						deb)
							echo  "Efetuando o download do pacote "
							if [ -d /tmp/wnbtlscli/ ]; then
								echo 1 >/dev/null
							else
								mkdir /tmp/wnbtlscli/
							fi
							wget -P /tmp/wnbtlscli/ -q --no-check-certificate --progress=dot  https://portal.comnect.com.br/downloads/tls/linux/wnbtlscli_$parch.$sysid
							sleep 3				
						
							echo  "Instalando o pacote "
							dpkg -i /tmp/wnbtlscli/wnbtlscli_$parch.$sysid
						;;
						rpm)
							echo  "Efetuando o download do pacote "
							if [ -d /tmp/wnbtlscli/ ]; then
								echo 1 >/dev/null
							else
								mkdir /tmp/wnbtlscli/
							fi
							wget -P /tmp/wnbtlscli/ -q --no-check-certificate --progress=dot  https://portal.comnect.com.br/downloads/tls/linux/wnbtlscli_$parch.$sysid
							sleep 3
							
							echo  "Instalando o pacote "
							rpm -ih /tmp/wnbtlscli/wnbtlscli_$parch.$sysid	
						;;
						tgz)
							echo  "Efetuando o download do pacote "
							if [ -d /tmp/wnbtlscli/ ]; then
								echo 1 >/dev/null
							else
								mkdir /tmp/wnbtlscli/
							fi
							wget -P /tmp/wnbtlscli/ -q --no-check-certificate --progress=dot  https://portal.comnect.com.br/downloads/tls/linux/wnbtlscli_$parch.$sysid
							sleep 3
							
							echo  "Instalando o pacote "
							installpkg /tmp/wnbtlscli/wnbtlscli_$parch.$sysid
						;;
					esac
				else
				echo "dependencias com problema"
				fi	
			else
				echo "Sistema operacional nao suportado $did ,versao $relint e arquitetura de processador $parch"
			fi
		fi
			if [ -d /tmp/wnbtlscli/ ]; then
				rm -rf /tmp/wnbtlscli/
			fi
	;;
	-v)
		echo "wnbinstall-version: 2.1.4"
	;;
	*)
		echo "  wnbinstall options "
		echo " -i to install on-line software"
		echo " -v to version "
		echo " -h to help"
	;;
esac





