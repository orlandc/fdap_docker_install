#!/bin/bash
# ****************************************************************************************************************
# *                         Script que Crea el contenedor de la aplicacion nlp-u                                 *
# *                                                                                                              *
# *                                                                        Desarrollado por: Orlando Montenegro  *
# *                                                                       Fecha de Creacion: 27/10/2017          *
# *--------------------------------------------------------------------------------------------------------------*
# *   Modificado por   | Fecha de Modificacion |                         Modificacion                            *
# *--------------------------------------------------------------------------------------------------------------*
# * orlando.montenegro |      27/10/2017       |           *
# *--------------------------------------------------------------------------------------------------------------*
# *                                            |                      *
# *--------------------------------------------------------------------------------------------------------------*
# *                                            |         *
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

# Se establece la variable que contiene el nombre del archivo que se esta ejecutando
currentscript="$0"

# Esta funcion se ejecuta en la sentencia de salida de ejecucion del Script
function finish {
    echo "Eliminacion Segura de ${currentscript}"
    sudo shred -u ${currentscript}
}

# Marquesina de ejecucion del Script
cat << "EOF"

*******************************************************
*          Script que Crea el contenedor de           *
*                 la aplicacion nlp-u                 *
*******************************************************
EOF

# Se revisa si el usuario que ejecuta es root.
if [[ $EUID -ne 0 ]]
then
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
	
	# curl -fsSL https://get.docker.com/ | sh
	curl -fsSL https://raw.githubusercontent.com/orlandc/fdap_docker_install/master/docker.sh | sh
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

# Descraga la imagen Base de Ubuntu 14
FROM ubuntu:16.04
MAINTAINER orlando.montenegro@correounivalle.edu.co

# ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true
# RUN locale-gen en_US.UTF-8 && \
#    locale-gen es_ES.UTF-8 && \
#    sudo dpkg-reconfigure locales && \

RUN apt-get clean -y
RUN rm -r /var/lib/apt/lists/*

RUN apt-get update -q && apt-get install -y locales --no-install-recommends apt-utils && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8 

RUN apt-get update -q && \
    apt-get install -y build-essential automake autoconf libtool wget \
                       libicu55 libboost-regex1.58.0 \
                       libboost-system1.58.0 libboost-program-options1.58.0 \
                       libboost-thread1.58.0 && \
    apt-get install -y libicu-dev libboost-regex-dev libboost-system-dev \
                       libboost-program-options-dev libboost-thread-dev \
                       zlib1g-dev &&\
    cd /tmp && \
    #wget --progress=dot:giga https://github.com/TALP-UPC/FreeLing/releases/download/4.0/FreeLing-4.0.tar.gz && \
    wget --quiet https://github.com/TALP-UPC/FreeLing/releases/download/4.0/FreeLing-4.0.tar.gz && \
    tar -xzf FreeLing-4.0.tar.gz && \
    rm -rf FreeLing-4.0.tar.gz && \
    cd /tmp/FreeLing-4.0 && \
    autoreconf --install && \
    ./configure && \
    make -s && \
    make install -s && \
    rm -rf /tmp/FreeLing-4.0 && \
    apt-get --purge -y remove build-essential libicu-dev \
            libboost-regex-dev libboost-system-dev \
            libboost-program-options-dev libboost-thread-dev zlib1g-dev\
            automake autoconf libtool wget && \
    apt-get autoremove -y && \
    apt-get clean -y && \
	apt-get install -y \
	git \
	python3 \
	openssh-server \
	python3-dev \
	python3-setuptools \
	python3-pip \
	apt-utils vim curl apache2 apache2-utils \
	libapache2-mod-wsgi-py3 \
	sqlite3 && \
	pip3 install -U pip setuptools && \
    rm -rf /usr/local/share/freeling/as && \
    rm -rf /usr/local/share/freeling/ca && \
    rm -rf /usr/local/share/freeling/cy && \
    rm -rf /usr/local/share/freeling/de && \
    rm -rf /usr/local/share/freeling/fr && \
    rm -rf /usr/local/share/freeling/gl && \
    rm -rf /usr/local/share/freeling/hr && \
    rm -rf /usr/local/share/freeling/it && \
    rm -rf /usr/local/share/freeling/nb && \
    rm -rf /usr/local/share/freeling/pt && \
    rm -rf /usr/local/share/freeling/ru && \
    rm -rf /usr/local/share/freeling/sl && \
    rm -rf /var/lib/apt/lists/*

# Instalacion de Python3 y otras librerias
# RUN apt-get update && \
#    apt-get upgrade -y && \
#    rm -rf /var/lib/apt/lists/*ls

RUN ln /usr/bin/python3 /usr/bin/python
RUN ln /usr/bin/pip3 /usr/bin/pip
RUN pip install --upgrade pip

# instalacion de uwsgi django y otras tools
RUN pip3 install django djangorestframework decorator appnope Markdown coreapi ptvsd

WORKDIR /var/www/html
RUN git clone https://github.com/orlandc/fdap.git django

RUN rm /etc/apache2/sites-available/000-default.conf
RUN mv /var/www/html/django/000-default.conf /etc/apache2/sites-available/

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 80 3500
CMD ["apache2ctl", "-D", "FOREGROUND"]
EOF

#cd $HOME/$REPROT/$DIR
#
# Se ejecuta la construccion de la imagen docker a partir del archivo de construccion
#
docker build -f $HOME/$REPROT/$DIR/$DOCFILE -t omontenegro/$DIR:v1 . 

#
# Se desarrolla la construccion del contenedor a partir de la imagen creada, adicionalemnte
# se expone el puerto se especifica como debe iniciar ante un reinicio del servidor fisico
# se establecen directivas de ejecucion del servicio
#
#docker run --name $DIR --privileged -ti -d -p 80:80 --restart=always -v /sys/fs/cgroup:/sys/fs/cgroup omontenegro/$DIR:v1 /usr/sbin/init
docker run --name $DIR --privileged -it -d -p 50005:50005 --restart=always omontenegro/$DIR:v1 analyze -f es.cfg --server -p 50005

#
# Se desarrolla la limpieza de imagens y contenedores huerfanos o no iniciados en docker
#
docker system prune -af

#
# Se eliminan los volumenes logicos de contenedores huerfanos o no iiciados en docker
#
docker volume rm $(docker volumlse ls -qf dangling=true)

#
# Se eliminan las fuentes del contendor creado
#
rm -rf  $HOME/$REPROT 

#
# Cuando el Scrip Finaliza, sale y llama a la funcion "finish"
#
trap finish EXIT