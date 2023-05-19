#!/bin/bash

#Colores que usaremos para los echo por pantall 
verde='\e[32m'
rojo='\e[33m'
sinC='\e[0m'
Dirregistro=/KMs.Script
registro=/KMs.Script/registro
clear

#creamos el directorio registros
if [ -d "$Dirregistro" ]; then
	echo "Informacion direccionada al fichero registro"
else 
	mkdir /KMs.Script/
fi

#Creamos el fichero registro
if [ -f "$registro" ]; then
	echo "Informacion direccionada al fichero registro"
else 
	touch /KMs.Script/registro.txt
fi

#Comprobamos si estamos en usuario root: 
echo -e "Compronbando si estas en root"
if [ $(whoami) == "root" ]; then 
	echo -e "${verde}Eres root${sinC}" 
	echo -e "${verde}Eres root${sinC}" >/KMs.Script/registre.txt
else
	echo -e "${rojo}No eres root${rojo}"
	exit
fi

#Actualizamos repositorios:

apt-get update >/dev/null
apt-get upgrade -y >/dev/null
echo  -e "actualizando, espere..."

#Nos situamos en el directorio de descarga por defecto
cd /opt/

#Descargamos el wget
apt-get install wget -y >/dev/null

#Descargamos el fichero de instalacion KMS:
echo -e "${verde}Descargando fichero .zip${sinC}"

wget https://github.com/SystemRage/py-kms/archive/refs/heads/master.zip >/dev/null 2>&1 


#Instalando desconpresor zip y descomprimiendo
apt-get install unzip -y >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo -e "${verde}Se ha instalado correctamente el unzip${sinC}" 
	echo -e "${verde}Se ha instalado correctamente el unzip${sinC}" >>/KMs.Script/registre.txt
else
	echo -e "${rojo}No se ha podido instalar el unzip${sinC}"
fi


unzip master.zip >/dev/null

#Salimos de la carpeta /opt
#Creamos carpeta de KMS

mkdir /srv/KMS/

cd /opt/

#Movemos  la carpeta KMS al directorio de descargas. 
mv * /srv/KMS/

cd /srv/KMS/py-kms-master/

#Instalamos el net-tools para comprovar mas adelante el estado
apt-get install net-tools -y >/dev/null 2>&1
echo -e "instalando net-tools"

#Instalamos python: 
apt-get install python3-tk python3-pip -y >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo -e "${verde}Se ha instalado correctamente el python3-tk y python3-pip${sinC}"
	echo -e "${verde}Se ha instalado correctamente el python3-tk y python3-pip${sinC}" >>/KMs.Script/registre.txt
else
	echo -e "${rojo}No se ha podido instalar el python3-tk y python3-pip${sinC}"
fi

#nos movemos al la carpeta del servidor

cd /srv/KMS/py-kms-master/

#instalamos el tzlocal y pysqlite3
pip3 install tzlocal pysqlite3
if [ $? -eq 0 ]; then
	echo -e "${verde}Se ha instalado correctamente el tzlocal y pysqlite3${sinC}"
	echo -e "${verde}Se ha instalado correctamente el tzlocal y pysqlite3${sinC}" >>/KMs.Script/registre.txt
else
	echo -e "${rojo}Ha surgido un error pero se continua con el proceso${sinC}"
fi

cd /srv/KMS//py-kms-master/py-kms/


echo "#!/bin/bash" >/etc/systemd/system/kms.service
echo "[Unit]" >>/etc/systemd/system/kms.service
echo "After=multi-user.target" >>/etc/systemd/system/kms.service
echo "[Service]">>/etc/systemd/system/kms.service
echo "ExecStart=/usr/bin/python3 /srv/KMS/py-kms-master/py-kms/pykms_Server.py" >>/etc/systemd/system/kms.service
echo "[Install]"  >>/etc/systemd/system/kms.service
echo "WantedBy=multi-user.target" >>/etc/systemd/system/kms.service


#Activar el servicio del KMS.
systemctl daemon-reload
systemctl enable kms.service
systemctl start kms.service
systemctl status kms.service
