#!/bin/bash
#
# setup_pdv_paths.sh - Monta, dentro da imagem de teste, os caminhos que existem
# num PDV da Casa Magalhães e não existem num Ubuntu comum.
#
# Tudo aqui é FALSO: só arquivos e scripts que imitam o PDV, para os testes
# poderem rodar as funções do SysUtil nos caminhos reais.
# Usado apenas pelo tests/docker/Dockerfile. Nunca rode isto num PDV.
#
# *************************************************************

set -e

# Script falso: registra a chamada em /var/log/sysutil-test/calls e sai com 0
fake_cmd() {
  local path=$1
  mkdir -p "$(dirname "$path")"
  cat >"$path" <<EOF
#!/bin/bash
echo "$(basename "$path") \$*" >> /var/log/sysutil-test/calls
exit 0
EOF
  chmod +x "$path"
}

mkdir -p /var/log/sysutil-test
: >/var/log/sysutil-test/calls

# Usuário do PDV
id pdv >/dev/null 2>&1 || useradd -m -s /bin/bash pdv
mkdir -p /home/pdv/Downloads
chown -R pdv:pdv /home/pdv

# SysPDV: bancos Firebird (fazer_backup_fdb)
mkdir -p /opt/Syspdv/TefDll
echo "banco cad de teste" >/opt/Syspdv/syspdv_cad.fdb
echo "banco mov de teste" >/opt/Syspdv/syspdv_mov.fdb

# Tec55 (limitar_consumo)
mkdir -p /opt/Gertec55
fake_cmd /opt/Gertec55/tec55usbd

# Servidor biométrico (configurar_biometria)
fake_cmd /opt/ServidorBiometrico/Scanner/iniciaBiometriaFH80.sh
fake_cmd /usr/local/bin/biometria

# Driver MFe (remover_drive_mfe)
fake_cmd /opt/sefaz/cco/remove-driver.sh

# Periféricos (configurar_perifericos)
fake_cmd /usr/local/bin/setty
mkdir -p /etc/udev/rules.d
echo '# regras de teste' >/etc/udev/rules.d/90-dispositivos-usb.rules

# VPN já instalada, com chave (remover_vpn)
mkdir -p /etc/wnbtlscli /var/log/wnb
echo "CHAVE-DE-TESTE-123" >/etc/wnbtlscli/registry
fake_cmd /usr/local/bin/wnbmonitor
fake_cmd /usr/local/bin/wnbupdate

# Marca que estamos na imagem de teste (o smoke.sh liga os testes de caminhos reais)
. /etc/os-release
echo "$VERSION_ID" >/etc/sysutil-test-image

echo "Caminhos do PDV criados (Ubuntu $VERSION_ID, $(uname -m))."
