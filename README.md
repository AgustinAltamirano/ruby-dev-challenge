# ruby-dev-challenge
Ruby Backend Dev Challenge - Fudo

Desarrollado por Agustín Altamirano

## Instrucciones para ejecutar
1) Instalar `ruby`, `ruby-rack` y `ruby-bundler`. En distribuciones Linux basadas en Debian o Ubuntu, se puede hacer con:
   
```bash
sudo apt install ruby-full ruby-rack
```

2) Instalar las dependencias del proyecto. Ejecutar en el directorio raíz del proyecto:

```bash
bundle install
```

3) Crear un archivo `.env` en el directorio raíz del proyecto con el siguiente contenido:

```
SECRET_KEY=<secret key>
EXPIRATION_TIME_SECONDS=<tiempo en segundos>
```
Estas variables de entorno están relacionadas con la generación de tokens JWT. Se puede usar cualquier string como `SECRET_KEY`, pero es recomendable utilizar un string generado aleatoriamente (por ejemplo, uno generado con `openssl rand -hex 64`).

4) Ejecutar:
```bash
rackup --host <direccion ip del host> --port <puerto>
```
