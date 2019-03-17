# Instalador Docker Freeling 4.1 Django API Rest

Este es el primer instalador para principiantes, de Docker Freeling 4.1 Django y el API Rest para Freeling.

## Requerimientos

1. Tener Docker CE instalado (Para sistemas Linux revisar el siguiente [LINK](https://gist.github.com/subfuzion/90e8498a26c206ae393b66804c032b79))

3. Acceso a Internet en la maquina donde ese ejecutara el Script

3. Si la instalación se desarrolla sobre una máquina virtual, se recomienda la configuración del adaptador de red de la máquina virtual en modo Bridge o Puente [LINK](https://geek-university.com/oracle-virtualbox/configure-bridged-networks/)


## Proceso de Instalación

Se debe descargar la imagen del contenedor usando el docker-ce usando el siguiente comando en el Terminal:

    sudo docker pull orlandc/freeling-django-rest-api

Una vez terminado el proceso Procedemos a la Creación y ejecución del contenedor:

    sudo docker run --name fdap --privileged -it -d -p 5080:80 -p 2222:22 -p 3500:3500 --restart=always orlandc/freeling-django-rest-api

## Ejemplos

## Identificación de idioma `langdetect`

Argumentos de entrada: `texto`: *texto de entrada* 

Salida: *lista de elementos* `lang`:`es|ca|en|fr|gl|it|pt|ru|de|none`

    curl http://127.0.0.1:5080/langdetect/ -H "Content-Type:application/json" -d '{"texto":"Mira que cosa más linda."}' -X POST -s
    [{"texto": "es"}]

Ejemplo de Uso en Python

    import requests
    url = 'http://127.0.0.1:5080/langdetect/'
    data = '{"texto":"Mira que cosa más linda."}'
    response = requests.post(url, data=data,headers={"Content-Type": "application/json"})
    print(response)

## Segmentador de oraciones y tokenizador `tokenizer`

Argumentos: `texto`: *texto de entrada*

Salida: *lista de elementos* `oracion`: *lista de tokens*

    curl http://127.0.0.1:5080/tokenizer/ -H "Content-Type:application/json" -d '{"texto":"La tarjeta SIM es una tarjeta pequeña que se coloca en el teléfono. Contiene información sobre la red móvil utilizada y servicios adicionales como SMS y MMS."}' -X POST -s
    [{"texto": "['La', 'La', 'tarjeta', 'SIM', 'es', 'una', 'tarjeta', 'pequeña', 'que', 'se', 'coloca', 'en', 'el', 'teléfono', '.', 'Contiene', 'información', 'sobre', 'la', 'red', 'móvil', 'utilizada', 'y', 'servicios', 'adicionales', 'como', 'SMS', 'y', 'MMS', '.']" }]

Ejemplo de Uso en Python

    import requests
    url = 'http://127.0.0.1:5080/tokenizer/'
    data = '{"texto":"La tarjeta SIM es una tarjeta pequeña que se coloca en el teléfono. Contiene información sobre la red móvil utilizada y servicios adicionales como SMS y MMS."}'
    response = requests.post(url, data=data,headers={"Content-Type": "application/json"})
    print(response)

## Segmentador de oraciones `sentenceSplitting`

Argumentos: `texto`: *texto de entrada*

Salida: *lista de elementos* `oracion`: *texto de la oración*

    curl http://127.0.0.1:5080/sentenceSplitting/-H "Content-Type:application/json" -d '{"texto":"La ONU dice que I.B.M. no tiene sede en Francia sino en EEUU. Te espero el lunes a las tres menos cuarto."}' -X POST -s
    [{"texto": "[{'La ONU dice que I.B.M. no tiene sede en Francia sino en EEUU .} {'Te espero el lunes a las tres menos cuarto .}]" }]

Ejemplo de Uso en Python

    import requests
    url = 'http://127.0.0.1:5080/sentenceSplitting/'
    data = '{"texto":"La ONU dice que I.B.M. no tiene sede en Francia sino en EEUU. Te espero el lunes a las tres menos cuarto."}'
    response = requests.post(url, data=data,headers={"Content-Type": "application/json"})
    print(response)

## Etiquetador `postagging`

Argumentos: `texto`: *texto de entrada*

Salida: *lista de hashes* `palabra`: *palabra*, `lemas`: *lista de hashes* `categoria`: *etiqueta gramatical*, `lema`: *lema*

    curl http://127.0.0.1:5080/ostagging/ -H "Content-Type:application/json" \
-d '{"texto": "{\"1\":\"El\", \"2\":\"presidente\", \"3\":\"de\", \"4\":\"el\", \"5\":\"Barcelona\"}" }' -X POST -s
    [{"texto ": [{"palabra": "El", "lemas": [{"categoria": "DA0MS0", "lema": "el"}]}, {"palabra": "presidente", "lemas": [{"categoria": "NCMS000", "lema":
    "presidente"}]}, {"palabra": "de", "lemas": [{"categoria": "SP", "lema": "de"}, {"categoria": "NCFS000", "lema": "de"}]}, {"palabra": "el", "lemas": [{"categoria": "DA0MS0", "lema": "el"}]}, {"palabra": "Barcelona", "lemas": [{"categoria": "NP00000", "lema": "barcelona"}]}]}]

Ejemplo de Uso en Python

    import requests
    url = 'http://127.0.0.1:5080/postagging/'
    data = '{"1":"El", "2":"presidente", "3":"de", "4":"el", "5":"Barcelona"}'
    response = requests.post(url, data=data,headers={"Content-Type": "application/json"})
    print(response)
