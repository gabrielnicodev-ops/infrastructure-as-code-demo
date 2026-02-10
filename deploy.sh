#!/bin/bash

# --- CONFIGURACIÓN DE COLORES ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para manejar errores
handle_error() {
    echo -e "${RED}❌ Ocurrió un error en la línea $1. El despliegue se detuvo.${NC}"
    exit 1
}

# Si cualquier comando falla, ejecutar handle_error
trap 'handle_error $LINENO' ERR

echo -e "${YELLOW}🚀 Iniciando Despliegue Automático (Infrastructure + App)...${NC}"

# --- PASO 1: TERRAFORM ---
echo -e "${YELLOW}🏗️  [1/4] Aplicando Infraestructura con Terraform...${NC}"
cd terraform

# Inicializar (por si es la primera vez o se borró el caché)
terraform init -input=false

# Aplicar cambios automáticamente (sin pedir "yes")
terraform apply -auto-approve -input=false

# Extraer la IP del servidor nuevo
SERVER_IP=$(terraform output -raw instance_ip)

echo -e "${GREEN}✅ Infraestructura lista. IP del Servidor: ${SERVER_IP}${NC}"

# Volver a la raíz
cd ..

# --- PASO 2: ACTUALIZAR INVENTARIO ANSIBLE ---
echo -e "${YELLOW}📝 [2/4] Actualizando inventario de Ansible...${NC}"
cd ansible

# Crear archivo hosts dinámicamente con la IP nueva
echo "[servidores]" > hosts
echo "$SERVER_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa" >> hosts

echo -e "${GREEN}✅ Inventario actualizado.${NC}"

# --- PASO 3: ESPERAR AL SERVIDOR (Wait loop) ---
echo -e "${YELLOW}⏳ [3/4] Esperando a que el puerto SSH (22) esté disponible...${NC}"
# Intentamos conectar cada 5 segundos hasta que responda
while ! nc -z -v -w 5 $SERVER_IP 22 2>/dev/null; do
  echo "   ... Esperando conexión SSH en $SERVER_IP"
  sleep 5
done

echo -e "${GREEN}✅ Puerto SSH abierto. Esperando 10s extra para estabilización del sistema...${NC}"
sleep 10

# --- PASO 4: EJECUTAR ANSIBLE ---
echo -e "${YELLOW}📦 [4/4] Configurando servidor y desplegando App...${NC}"

# Ejecutar playbook (ignorando el chequeo de host key para evitar preguntas de yes/no)
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts playbook.yml

# --- FINAL ---
echo -e ""
echo -e "${GREEN}🎉 ¡DESPLIEGUE COMPLETADO CON ÉXITO! 🎉${NC}"
echo -e "${GREEN}👉 Tu App está corriendo en: http://${SERVER_IP}${NC}"
echo -e ""
