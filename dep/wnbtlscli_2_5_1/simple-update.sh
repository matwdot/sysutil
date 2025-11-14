#!/bin/bash
#set -x

echo " Parando Serviços "
systemctl stop wnbmonitor
systemctl stop wnbtlscli

echo " Atualizando Arquivos "
tar -xfo installer-2_5_1.tar -C /

echo " Removendo Arquivos Antigos"
rm -rf /etc/wnbtlscli/*.crt
rm -rf /etc/wnbtlscli/*.key


echo " Configurando Serviços"
systemctl enable wnbmonitor
systemctl enable wnbtlscli


if [ -f "/etc/wnbtlscli/registry" ]; then
	oldver=`cat /etc/wnbtlscli/registry | grep -c systemd`
		if [ $oldver = 0 ]; then
			echo "systemd: true" >> /etc/wnbtlscli/registry
			echo "log_level: 3" >> /etc/wnbtlscli/registry
		else
			echo 1 > /dev/null
		fi			
	echo "Iniciando Serviços"
	systemctl start wnbmonitor
else
	echo "Execute wnbupdate -k XXXX para registrar "
fi


exit 0