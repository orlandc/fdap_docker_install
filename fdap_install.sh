#!/bin/bash
# ****************************************************************************************************************
# *                         Script que Crea el contenedor de la aplicacion nlp-u                                 *
# *                                                                                                              *
# *                                                                        Desarrollado por: Orlando Montenegro  *
# *                                                                       Fecha de Creacion: 27/10/2017          *
# *--------------------------------------------------------------------------------------------------------------*
# *   Modificado por   | Fecha de Modificacion |                         Modificacion                            *
# *--------------------------------------------------------------------------------------------------------------*
# * orlando.montenegro |      27/10/2017       | Creación del primer Instalador Docker Freeling 4.0              *
# *--------------------------------------------------------------------------------------------------------------*
# * orlando.montenegro |      13/02/2019       | Creacion de instalador Freeling 4.1 Django Rest API             *
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
SISOP="$(cat /etc/*-release | grep "^\ID_LIKE=" | sed 's/ID_LIKE=//g' | sed 's/["]//g' | awk '{print $1}')"

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
*                  la aplicacion fdap                 *
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

		dist_version="$(cat /etc/debian_version | sed 's/\/.*//' | sed 's/\..*//')"

		if ["dist_version" == "9"] || ["dist_version" == "stretch"] || ["dist_version" == "8"] || ["dist_version" == "jessie"] || ["dist_version" == "7"] || ["dist_version" == "wheezy"]; then
		
			curl -fsSL https://raw.githubusercontent.com/orlandc/fdap_docker_install/master/docker.sh | sh
			sudo systemctl start docker
			sudo systemctl enable docker
		else
			curl -fsSL https://get.docker.com/ | sh
		fi
	else
		sudo yum check-update

		curl -fsSL https://raw.githubusercontent.com/orlandc/fdap_docker_install/master/docker.sh | sh
		sudo systemctl start docker
		sudo systemctl enable docker
	fi
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
# Descarga la imagen Base de Ubuntu 18
FROM ubuntu:18.10
MAINTAINER orlando.montenegro@correounivalle.edu.co 

ENV DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true

ENV APACHE_RUN_USER=www-data \
	APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
	FREELINGDIR=/usr/local/

#ENV HTTP_PROXY "http://user:password@host:port/"
#ENV HTTPS_PROXY "http://user:password@host:port/"

#RUN echo "Acquire::http::Proxy \"http://user:password@host:port/\"; " >> /etc/apt/apt.conf
#RUN echo "Acquire::https::Proxy \"http://user:password@host:port/\"; " >> /etc/apt/apt.conf

RUN touch /etc/apt/apt.conf.d/99fixbadproxy \
	&& echo "Acquire::http::Pipeline-Depth 0;" >> /etc/apt/apt.conf.d/99fixbadproxy \
	&& echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99fixbadproxy \
	&& echo "Acquire::BrokenProxy true;" >> /etc/apt/apt.conf.d/99fixbadproxy \
	&& apt-get update -o Acquire::CompressionTypes::Order::=gz \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get update -y

RUN apt-get update && apt-get install -y apt-transport-https

RUN apt-get update -q && \
    apt-get install -y wget cmake && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update -q && apt-get install -y locales --no-install-recommends apt-utils && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get clean -y && apt-get -f install && dpkg --configure -a

RUN apt-get update -q && \
    apt-get install -y build-essential automake autoconf libtool wget \
                       libicu60 libboost-regex1.67.0 \
                       libboost-system1.67.0 libboost-program-options1.67.0 \
                       libboost-thread1.67.0 && \
                       rm -rf /var/lib/apt/lists/*

RUN apt-get clean -y && apt-get -f install && dpkg --configure -a 

RUN apt-get update -q && \
    apt-get install -y libicu-dev libboost-regex-dev libboost-system-dev \
                       libboost-program-options-dev libboost-thread-dev \
					   libboost-all-dev dh-autoreconf \
					   wget \
					   git \
                       zlib1g-dev && \
                       rm -rf /var/lib/apt/lists/*

RUN apt-get clean -y && apt-get -f install && dpkg --configure -a

RUN apt-get update -q && \
    apt-get install -y \
	openssh-server \
	swig \
	nano \
	python3-dev \
	python3-setuptools \
	python3-pip \
	apt-utils vim curl apache2 apache2-utils \
	libapache2-mod-wsgi-py3 \
	sqlite3 && \
	pip3 install -U pip setuptools && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

#RUN git clone https://github.com/orlandc/Fda-fork.git FreeLing-4.0
#RUN git clone https://github.com/TALP-UPC/FreeLing.git FreeLing-4.1
RUN wget --progress=dot:giga https://github.com/TALP-UPC/FreeLing/releases/download/4.1/FreeLing-4.1.tar.gz && \
	tar -xzf FreeLing-4.1.tar.gz && \
	rm -rf FreeLing-4.1.tar.gz

WORKDIR /tmp/FreeLing-4.1

RUN mkdir build
WORKDIR /tmp/FreeLing-4.1/build
RUN cmake -DPYTHON3_API=ON .. 
RUN make install

RUN apt-get --purge -y remove build-essential libicu-dev \
            libboost-regex-dev libboost-system-dev \
            libboost-program-options-dev libboost-thread-dev zlib1g-dev\
            automake autoconf libtool wget && \
    apt-get autoremove -y && \
	rm -rf /usr/local/share/freeling/as && \
	rm -rf /usr/local/share/freeling/ca && \
	rm -rf /usr/local/share/freeling/cs && \
	rm -rf /usr/local/share/freeling/cy && \
	rm -rf /usr/local/share/freeling/de && \
	rm -rf /usr/local/share/freeling/en && \
	rm -rf /usr/local/share/freeling/fr && \
	rm -rf /usr/local/share/freeling/gl && \
	rm -rf /usr/local/share/freeling/hr && \
	rm -rf /usr/local/share/freeling/it && \
	rm -rf /usr/local/share/freeling/nb && \
	rm -rf /usr/local/share/freeling/pt && \
	rm -rf /usr/local/share/freeling/ru && \
	rm -rf /usr/local/share/freeling/sl && \
	rm -rf /usr/local/share/freeling/APIs && \
	rm -rf /usr/local/share/freeling/config/as.cfg && \
	rm -rf /usr/local/share/freeling/config/ca-valencia.cfg && \
	rm -rf /usr/local/share/freeling/config/cs.cfg && \
	rm -rf /usr/local/share/freeling/config/de.cfg && \
	rm -rf /usr/local/share/freeling/config/es-ar.cfg && \
	rm -rf /usr/local/share/freeling/config/es-old.cfg && \
	rm -rf /usr/local/share/freeling/config/fr.cfg && \
	rm -rf /usr/local/share/freeling/config/nb.cfg && \
	rm -rf /usr/local/share/freeling/config/ru.cfg && \
	rm -rf /usr/local/share/freeling/config/ca-balear.cfg && \
	rm -rf /usr/local/share/freeling/config/ca.cfg && \
	rm -rf /usr/local/share/freeling/config/cy.cfg && \
	rm -rf /usr/local/share/freeling/config/en.cfg && \
	rm -rf /usr/local/share/freeling/config/es-cl.cfg && \
	rm -rf /usr/local/share/freeling/config/gl.cfg && \
	rm -rf /usr/local/share/freeling/config/it.cfg && \
	rm -rf /usr/local/share/freeling/config/pt.cfg && \
	rm -rf /usr/local/share/freeling/config/sl.cfg && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get clean -y && apt-get -f install && dpkg --configure -a

WORKDIR /tmp/FreeLing-4.1/build/APIs/python3

RUN cp _pyfreeling.so pyfreeling.py /usr/lib/python3.6

WORKDIR /tmp
RUN rm -rf FreeLing-4.1

RUN rm -rf /usr/bin/python && ln /usr/bin/python3 /usr/bin/python && \
    rm -rf /usr/bin/pip && ln /usr/bin/pip3 /usr/bin/pip
	
RUN pip install --upgrade pip

# instalacion de django y otras tools
RUN pip3 install django djangorestframework decorator appnope Markdown coreapi ptvsd

WORKDIR /var/www/html
RUN git clone https://github.com/orlandc/fdap.git django

RUN rm -rf /etc/apache2/sites-available/000-default.conf && \
	mv /var/www/html/django/000-default.conf /etc/apache2/sites-available/ && \
	mkdir /scripts && \
	mv /var/www/html/django/boot.sh /scripts/ && \
	chmod +x /scripts/*

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	echo "ServerName " $(hostname --ip-address) >> /etc/apache2/apache2.conf && \
	sed -i "s/#ServerName www.example.com/ServerName $(hostname --ip-address)/g" /etc/apache2/sites-available/000-default.conf && \
	apache2ctl graceful && apache2ctl configtest && \
	service apache2 reload && \
	service apache2 restart && \
	systemctl enable apache2

EXPOSE 80 22 3500
#  CMD ["apache2ctl", "-D", "FOREGROUND"]
CMD ["/scripts/boot.sh"]
EOF

#cd $HOME/$REPROT/$DIR
#
# Se ejecuta la construccion de la imagen docker a partir del archivo de construccion
#
docker build -f $HOME/$REPROT/$DIR/$DOCFILE -t omontenegro/$DIR:v1.1 . 

#
# Se desarrolla la construccion del contenedor a partir de la imagen creada, adicionalemnte
# se expone el puerto se especifica como debe iniciar ante un reinicio del servidor fisico
# se establecen directivas de ejecucion del servicio
#
docker run --name $DIR --privileged -it -d -p 5080:80 -p 2222:22 -p 3500:3500 --restart=always omontenegro/$DIR:v1.1
#docker run --name $DIR --privileged -it -d -p 50005:50005 --restart=always omontenegro/$DIR:v1 analyze -f es.cfg --server -p 50005

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
