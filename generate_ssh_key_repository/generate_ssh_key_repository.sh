#!/bin/bash
# ------------------------------------------------------------------
# [Azulejo Code] auto_generate_ssh_key
# Descripción: Este script tiene como finalidad facilitar la generacion y reemplazo de la llave ssh_key
# Fecha: 01-10-2024
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# CONFIGURATIONS
set -e # Salir del script si cualquier comando falla
set -u # Tratar las variables no declaradas como un error

trap bye_bye EXIT
trap script_intrrupted INT
trap 'handler_error $LINENO' ERR
# Atrapar señales para ejecutar la función cleanup
trap cleanup_os SIGINT SIGTERM
# ------------------------------------------------------------------


# ------------------------------------------------------------------
#GLOBAL VARIABLES
EMAIL_ACCOUNT_REPOSITORY=""
STATUS_OK=0
STATUS_ERROR=1
STATUS_WARNING=2
# ------------------------------------------------------------------

## FUNCTIONS
#@function how_to_use
#@description show helper to user about how to use this script
#@return void
how_to_use() {
  custom_echo "------------------------------------------------------------------"
  custom_echo "---------------------------¿COMO USAR?----------------------------"
  custom_echo "------------------------------------------------------------------"
  custom_echo "Descripción: Este Script tiene como finalidad facilitar la creación "
  custom_echo "             de una nueva llave ssh para el repositorio; sea Github o Bitbucket"
  custom_echo ""
  custom_echo "Uso: $0 [-e <email_account_repository>] [-g] [-b] [-h]"
  custom_echo "Opciones/flags:"
  custom_echo "  -h                    Es opcional. Hace que el script muestra esta ayuda."
  custom_echo "                        Pero NO ejecutará las demás funcionalidades."
  custom_echo "  -g                    Opción sin argumento."
  custom_echo "                        Campo requerido."
  custom_echo "                        Hace que el script genere la llave para Github"
  custom_echo "                        Ejemplo de uso:"
  custom_echo "                        ------------------------------------------------------------------"
  custom_echo '                        generate_ssh_key_repository.sh -e "pepito@gmail.com" -g'
  custom_echo "                        ------------------------------------------------------------------"
  custom_echo "  -b                    Opción sin argumento."
  custom_echo "                        Campo requerido."
  custom_echo "                        Hace que el script genere la llave para bitbucket"
  custom_echo "                        Ejemplo de uso:"
  custom_echo "                        ------------------------------------------------------------------"
  custom_echo '                        generate_ssh_key_repository.sh -e "pepito@gmail.com" -b'
  custom_echo "                        ------------------------------------------------------------------"
  custom_echo "  -e <email_account>    Campo requerido."
  custom_echo "                        Correo electronico del usuario de la cuenta del repositorio"
  custom_echo "                        Ejemplo de usos:"
  custom_echo "                        ------------------------------------------------------------------"
  custom_echo '                        generate_ssh_key_repository.sh -e "pepito@gmail.com" -b'
  custom_echo "                        ------------------------------------------------------------------"
  custom_echo "------------------------------------------------------------------"
  custom_echo "------------------------------------------------------------------"
  custom_echo "------------------------------------------------------------------"

  exit 1
}

#@function handler_error
#@description Handler errors
#@return void
handler_error() {
  custom_echo " 🚨⚠️Error en la línea $1" "$STATUS_ERROR"
  exit 1
}

#@function custom_echo
#@description Print a custom echo message
#@param $1 - message to print.
#@param $2 - type message to print
### Allowed values:
### DANGER - Print message for errors
### WARNING - Print message for wannings
### If none comming, the print message for ok
#@return void
custom_echo() {
  message=$1
  type_message=${2:-""}

  GREEN_COLOR='\033[0;32m'
  YELLOW_COLOR='\033[0;33m'
  RED_COLOR='\033[0;31m'
  RESET='\033[0m'

  PREFIX=">>> "
  if [ "$type_message" == "$STATUS_ERROR" ]; then
    echo -e "${RED_COLOR}${PREFIX}$(date +"%T")   $message${RESET}"
  elif [ "$type_message" == "$STATUS_WARNING" ]; then
    echo -e "${YELLOW_COLOR}${PREFIX}$(date +"%T")   $message${RESET}"
  else
    echo -e "${GREEN_COLOR}${PREFIX}$(date +"%T")   $message${RESET}"
  fi
}

#@function bye_bye
#@description Print a messages saying goodbye
#@return void
bye_bye() {
  custom_echo "Listo, he finalizado, mi trabajo aqui ha terminado👌!!" "$STATUS_WARNING"
}
#@function script_intrrupted
#@description Print a messages saying goodbye when an error occurs
#@return void
script_intrrupted() {
  custom_echo "Ey, pero apenas ibamos empezando😑! tan pronto te vas🖐?" "$STATUS_WARNING"
}

#@function script_intrrupted
#@description Print a messages saying goodbye when an error occurs
#@return void
generate_ssh_key() {
  type_repository=$1
  email_account_repository=${2:-""}

  custom_echo "🏁 Generando llave..." "$STATUS_OK"
  ssh-keygen -t ed25519 -C "$email_account_repository"
  custom_echo "👮🏻‍♂️ Inicia el agente SSH:" "$STATUS_OK"
  eval "$(ssh-agent -s)"
  custom_echo "🔑🗂️️ Añade la llave al archivo de configuración" "$STATUS_OK"
  touch ~/.ssh/config
  echo "Host $type_repository
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519" > ~/.ssh/config
  custom_echo "🔑👮🏻‍♂️ Añade la llave privada al agente" "$STATUS_OK"
  ssh-add ~/.ssh/id_rsa
  custom_echo "🔑🗝️ Copiar la llave pública " "$STATUS_OK"
  pbcopy < ~/.ssh/id_ed25519.pub
  custom_echo "🗝️🧑🏻‍💻 La llave ha sido copiada. Añadala  manualmente a su cuenta de $type_repository" "$STATUS_OK"

  echo "⏸️ Esperando que estes listo. Presiona Enter para continuar..."
  echo "Cuando ya hayas añadido la key a tu cuenta, presiona Enter para continuar..."
  read
  echo "Continuando..."
  custom_echo "🚧🚜 Probar que la conexión a $type_repository con tu llave SSH " "$STATUS_OK"
  ssh -T "git@$type_repository"

}

#@function main
#@description Main function
#@return void
main() {
  custom_echo " BIENVENIDO 🖖🏻"
  custom_echo " ¡Script de generacion de SHH KEY Iniciado!! ✅"
}
#@function validate_flags
#@description Validate flgas user pass to this script
#@return void
validate_flags(){
  if [ $# -eq 0 ]; then
    custom_echo "🚨 No le has pasado los argumentos necesarios a este script!" "$STATUS_ERROR"
    how_to_use
  fi

  if [ $# -eq 1 ]; then
    custom_echo "🚨 No le has pasado los argumentos necesarios a este script!" "$STATUS_ERROR"
    how_to_use
  fi
}

# Bucle para procesar las opciones de línea de comandos
while [[ $# -gt 0 ]]; do
  option="$1"
  case $option in
  -h)
    how_to_use
    ;;
  -g)
    GITHUB_REPO="github.com"
    custom_echo " Se generará la SSH Key para Github 🐧"
    generate_ssh_key "$GITHUB_REPO" "$EMAIL_ACCOUNT_REPOSITORY"
    ;;
  -b)
    BITBUCKET_REPO="bitbucket.org"
    custom_echo " Se generará la SSH Key para Bitbucket 🟦"
    generate_ssh_key "$BITBUCKET_REPO" "$EMAIL_ACCOUNT_REPOSITORY"
    ;;
  -e)
    EMAIL_ACCOUNT_REPOSITORY="$2"
    custom_echo " 🔍 Has pasado el siguiente correo: $EMAIL_ACCOUNT_REPOSITORY"
    shift # Avanzar al siguiente argumento (el valor de la opción)
    ;;
  *)
    custom_echo "  🚨 Has pasado una flag no valida: $option" "$STATUS_ERROR"
    how_to_use
    ;;
  esac
  shift # Avanzar al siguiente argumento
done

# Call to main function
main