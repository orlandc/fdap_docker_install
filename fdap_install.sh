#!/bin/bash
# ****************************************************************************************************************
# *                         Script que Crea el contenedor de la aplicacion nlp-u                                 *
# *                                                                                                              *
# *                                                                        Desarrollado por: Orlando Montenegro  *
# *                                                                       Fecha de Creacion: 19/01/2019          *
# *--------------------------------------------------------------------------------------------------------------*
# *   Modificado por   | Fecha de Modificacion |                         Modificacion                            *
# *--------------------------------------------------------------------------------------------------------------*
# * orlando.montenegro |      19/01/2019       |                                                                 *
# *--------------------------------------------------------------------------------------------------------------*
# *                                            |                                                                 *
# *--------------------------------------------------------------------------------------------------------------*
# *                                            |                                                                 *
# *--------------------------------------------------------------------------------------------------------------*
# ****************************************************************************************************************
# Salir de la ehjecucion ante un Error.
# set -e

# el nombre del contenedor debe estar en minuscula
HOME=sudo pwd
DIR=nlp-univalle
DOCFILE=Dokerfile
REPROT=docimages

# se captura el sistema operativo huesped
SISOP=sudo cat /etc/*-release | grep "^\ID_LIKE=" | sed 's/ID_LIKE=//g' | sed 's/["]//g' | awk '{print $1}'
echo $SISOP

# Se establece la variable que contiene el nombre del archivo que se esta ejecutando
currentscript="$0"

# Esta funcion se ejecuta en la sentencia de salida de ejecucion del Script
function finish 
{
    echo "Eliminacion Segura de ${currentscript}"
    sudo shred -u ${currentscript}
}

# Marquesina de ejecucion del Script
cat << "EOF"

*******************************************************
*      Instalador de Freeling Api Rest Django         *
*               Universidad del Valle                 *
*                            by: Orlando Montenegro   *
*******************************************************
EOF

# Se revisa si el usuario que ejecuta es root.
if [ $EUID -ne 0 ]; then
	echo "Este script Se debe ejecutar como root."
	exit 1
fi

# se revisa si el repositorio de la aplicacion esta creado
if [ ! -d "$HOME/$REPROT/$DIR" ]; then
	# si ekl repositorio no esta creado, se procede a crearlo
	sudo mkdir -p $HOME/$REPROT/$DIR
	echo "Se crea el repositorio $DIR"
fi

# se verifica si docker esta instalado en la maquina
if [ ! -x "$(command -v docker)" ]; then
    echo 'docker no esta instalado. se procede a la instalacion...' >&2
	if [ "$SISOP" == "debian" ]; then
		sudo apt-get update
	else
		sudo yum check-update
	fi

	curl -fsSL https://get.docker.com/ | sh
	sudo systemctl start docker
	sudo systemctl enable docker
fi

# se revisa si el archivo de creacion de la imagen del docker existe
if [ ! -f "$HOME/$REPROT/$DIR/$DOCFILE" ]; then
	# si el archivo no esta creado, se procede a crearlo
	sudo touch "$HOME/$REPROT/$DIR/$DOCFILE"
else
	# si el archivo ya existe, se procede a limpiarlo
	cp /dev/null $HOME/$REPROT/$DIR/$DOCFILE
fi

#
# se escribe el archivo Dockerfile con los comandos de creacion
# de la imagen del servidor web
#
cat >> $HOME/$REPROT/$DIR/$DOCFILE << "EOF"

# Descarga la imagen Base de Ubuntu 14
FROM ubuntu:18.04
MAINTAINER orlando.montenegro@correounivalle.edu.co

ENV DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update -q && apt-get install -y locales --no-install-recommends apt-utils && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

# Instalacion de Python3 y otras librerias
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
	git \
	python3 \
	python3-dev \
	python3-setuptools \
	python3-pip \
	apt-utils vim curl apache2 apache2-utils \
	libapache2-mod-wsgi-py3 \
	sqlite3 && \
	pip3 install -U pip setuptools && \
    rm -rf /var/lib/apt/lists/*ls

RUN ln /usr/bin/python3 /usr/bin/python
RUN ln /usr/bin/pip3 /usr/bin/pip
RUN pip install --upgrade pip

# instalacion de uwsgi django y otras tools 
RUN pip3 install django djangorestframework decorator appnope Markdown coreapi ptvsd

WORKDIR /var/www/html
RUN git clone https://github.com/orlandc/fdap.git django

RUN mv /var/www/html/django/demo_site.conf /etc/apache2/sites-available/

RUN a2ensite demo_site.conf 

EXPOSE 80 3500
CMD ["apache2ctl", "-D", "FOREGROUND"]
EOF

cd $HOME/$REPROT/$DIR
#
# Se ejecuta la construccion de la imagen docker a partir del archivo de construccion
#
docker build -f $HOME/$REPROT/$DIR/$DOCFILE -t omontenegro/$DIR:v1 .

#
# Se desarrolla la construccion del contenedor a partir de la imagen creada, adicionalemnte
# se expone el puerto se especifica como debe iniciar ante un reinicio del servidor fisico
# se establecen directivas de ejecucion del servicio
#
docker run --name $DIR --privileged -it -d -p 8080:80 -p 2222:22 --restart=always omontenegro/$DIR:v1

#
# Se desarrolla la limpieza de imagens y contenedores huerfanos o no iniciados en docker
#
# docker system prune -af

#
# Se eliminan los volumenes logicos de contenedores huerfanos o no iiciados en docker
#
# docker volume rm $(docker volumlse ls -qf dangling=true)

#
# Se eliminan las fuentes del contendor creado
#
# rm -rf  $HOME/$REPROT

#
# Cuando el Scrip Finaliza, sale y llama a la funcion "finish"
#
trap finish EXIT