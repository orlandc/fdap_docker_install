# Instalador Docker Freeling 4.1 Django API Rest

Este es el primer instalador para principiantes, de Docker Freeling 4.1 Django y el API Rest para Freeling.

## Requerimientos

1. Sistema Operativo Linux Basdaos en Debian (Ubuntu Linux Mint, etc.) o RHEL (Centos, Fedora, REDHAT, etc.)

    Si no se cuenta este Sistema Operativo, se recomienda revisar el siguiente acerca de cómo crear máquinas virtuales con VirtualBox paso a paso [LINK](https://www.softzone.es/2014/10/30/como-crear-una-maquina-virtual-con-virtualbox-paso-paso/)

    Para desarrollar este proceso es necesario contar con el ISO que contiene el sistema operativo, se recomienda Ubuntu server, descárgalo en el siguiente enlace [LINK](https://www.ubuntu.com/download/server)

    tambien recomendamos la version de Centos en el siguiente enlace [LINK](https://www.centos.org/download/)

    No es necesario tener instalado Docker en nuestra maquina o en la máquina Virtual, ya que este instalador es capaz de instalarlo por si mismo, pero en caso de tener instalado Docker el instalador del Docker Freeling API Rest lo detecta y continua con el proceso de instalación de los demás productos.

2. Acceso a Internet en la maquina donde ese ejecutara el Script

3. Si la instalación se desarrolla sobre una máquina virtual, se recomienda la configuración del adaptador de red de la máquina virtual en modo Bridge o Puente, si tiene dudas de cómo desarrollar esta configuración por favor consultar el siguiente enlace [LINK](https://geek-university.com/oracle-virtualbox/configure-bridged-networks/)


## Proceso de Instalación

Para lograr ejecutar este Script de Instalación debe ejecutarse como usuario root o como impersonalización del usuario root mediante el uso del comando SUDO

Existen dos métodos para desarrollar el procedimiento de instalación, el primero consiste en copiar y ejecutar el siguiente comando en la consola de tu sistema operativo linux:

    sudo curl -fsSL https://raw.githubusercontent.com/orlandc/fdap_docker_install/master/fdap_install.sh | sh

el segundo método consiste en descargar y ejecutar el script:

    sudo wget https://raw.githubusercontent.com/orlandc/fdap_docker_install/master/fdap_install.sh
    sudo chmod +x fdap_install.sh
    sudo ./fdap_install.sh

## Ejemplos

## Identificación de idioma `langdetect`

Argumentos de entrada: `texto`: *texto de entrada* 

Salida: *lista de elementos* `lang`:`es|ca|en|fr|gl|it|pt|ru|de|none`


    curl http://127.0.0.1:50080/langdetect/ -H "Content-Type:application/json" -d '{"texto":"Mira que cosa más linda."}' -X POST -s
    [{"texto": "es"}]

## Segmentador de oraciones y tokenizador `tokenizer`

Argumentos: `texto`: *texto de entrada*

Salida: *lista de elementos* `oracion`: *lista de tokens*


    curl http://127.0.0.1:50080/tokenizer/ -H "Content-Type:application/json" -d '{"texto":"La tarjeta SIM es una tarjeta pequeña que se coloca en el teléfono. Contiene información sobre la red móvil utilizada y servicios adicionales como SMS y MMS."}' -X POST -s
    [{"texto": "['La', 'La', 'tarjeta', 'SIM', 'es', 'una', 'tarjeta', 'pequeña', 'que', 'se', 'coloca', 'en', 'el', 'teléfono', '.', 'Contiene', 'información', 'sobre', 'la', 'red', 'móvil', 'utilizada', 'y', 'servicios', 'adicionales', 'como', 'SMS', 'y', 'MMS', '.']" }]


## Segmentador de oraciones `sentenceSplitting`

Argumentos: `texto`: *texto de entrada*

Salida: *lista de elementos* `oracion`: *texto de la oración*

    curl http://127.0.0.1:50080/sentenceSplitting/-H "Content-Type:application/json" -d '{"texto":"La ONU dice que I.B.M. no tiene sede en Francia sino en EEUU. Te espero el lunes a las tres menos cuarto."}' -X POST -s
    [{"texto": "[{'La ONU dice que I.B.M. no tiene sede en Francia sino en EEUU .} {'Te espero el lunes a las tres menos cuarto .}]" }]


## Etiquetador morfológico `postagging`

Argumentos: `texto`: *texto de entrada*

Salida: *lista de hashes* `palabra`: *palabra*, `lemas`: *lista de hashes* `categoria`: *etiqueta gramatical*, `lema`: *lema*


    curl http://127.0.0.1:50080/postagging/ -H "Content-Type:application/json" -d '{"1":"El", "2":"presidente", "3":"de", "4":"el", "5":"Barcelona"}' -X POST -s
    [{"texto ": [{"palabra": "El", "lemas": [{"categoria": "DA0MS0", "lema": "el"}]}, {"palabra": "presidente", "lemas": [{"categoria": "NCMS000", "lema":
    "presidente"}]}, {"palabra": "de", "lemas": [{"categoria": "SP", "lema": "de"}, {"categoria": "NCFS000", "lema": "de"}]}, {"palabra": "el", "lemas": [{"categoria": "DA0MS0", "lema": "el"}]}, {"palabra": "Barcelona", "lemas": [{"categoria": "NP00000", "lema": "barcelona"}]}]}]
