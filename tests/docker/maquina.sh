#!/bin/bash
#
# maquina.sh - Máquina Docker para testar o SysUtil à mão
#
# Cria um Ubuntu com os caminhos de um PDV (imagem tests/docker/Dockerfile)
# e instala o SysUtil em /opt/sysutil a partir dos arquivos ATUAIS do projeto
# (inclui mudanças ainda não commitadas).
#
# Uso:
#   bash tests/docker/maquina.sh criar    [22.04|18.04]   # cria e instala
#   bash tests/docker/maquina.sh entrar   [22.04|18.04]   # entra como root (igual a "sudo su")
#   bash tests/docker/maquina.sh pdv      [22.04|18.04]   # entra como usuário pdv (senha: pdv)
#   bash tests/docker/maquina.sh atualizar [22.04|18.04]  # reinstala com os arquivos atuais
#   bash tests/docker/maquina.sh apagar   [22.04|18.04]   # apaga a máquina (mantém a imagem)
#   bash tests/docker/maquina.sh remover  [22.04|18.04|todas]  # remove tudo do Docker:
#                                                          # máquina + imagem sysutil-test
#
# Padrão: 22.04.
#
# *************************************************************

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ACAO="${1:-}"
VERSAO="${2:-22.04}"

# "remover todas": chama o remover para cada versão
if [[ "$ACAO" == "remover" && "$VERSAO" == "todas" ]]; then
  # "bash" na frente: funciona mesmo sem permissão de execução no arquivo
  bash "$0" remover 22.04
  bash "$0" remover 18.04
  exit 0
fi

case "$VERSAO" in
  22.04) BASE=ubuntu:22.04; PLATFORM=linux/amd64 ;;
  18.04) BASE=i386/ubuntu:18.04; PLATFORM=linux/386 ;;
  *) echo "Versão inválida: $VERSAO (use 22.04 ou 18.04)"; exit 1 ;;
esac

NOME="sysutil-${VERSAO}"
TAG="sysutil-test:${VERSAO}"

if ! docker info >/dev/null 2>&1; then
  echo "ERRO: Docker não está rodando. Abra o Docker Desktop e tente de novo."
  exit 1
fi

existe() { docker ps -a --format '{{.Names}}' | grep -qx "$NOME"; }

# Usa o TERM do Mac só se o Ubuntu da máquina conhecer (ex.: xterm-ghostty não conhece)
term_da_maquina() {
  if docker exec "$NOME" tput -T "${TERM:-dumb}" clear >/dev/null 2>&1; then
    echo "$TERM"
  else
    echo xterm-256color
  fi
}

# Instala o SysUtil dentro da máquina com o install.sh de verdade.
# O repositório usado é uma cópia dos arquivos atuais, commitada dentro da máquina.
instalar() {
  docker exec "$NOME" bash -c '
    set -e
    rm -rf /tmp/repo && mkdir -p /tmp/repo
    (cd /src && tar --exclude=.git --exclude=assets -cf - .) | (cd /tmp/repo && tar -xf -)
    git -C /tmp/repo init -q
    git -C /tmp/repo add -A
    git -C /tmp/repo -c user.name=teste -c user.email=teste@local commit -qm "arquivos atuais"
    SYSUTIL_REPO=/tmp/repo bash /tmp/repo/install.sh
  '
}

case "$ACAO" in
  criar)
    if existe; then
      echo "A máquina $NOME já existe. Use: entrar, atualizar ou apagar."
      exit 0
    fi
    echo "Montando a imagem $TAG..."
        docker build -q --platform "$PLATFORM" --build-arg BASE="$BASE" -t "$TAG" "$ROOT/tests/docker" >/dev/null || exit 1
    echo "Criando a máquina $NOME..."
    docker run -d --name "$NOME" --hostname "pdv-${VERSAO//./}" --platform "$PLATFORM" \
      -v "$ROOT:/src:ro" "$TAG" sleep infinity >/dev/null || exit 1
    # Senha do usuário pdv (só nesta máquina de teste), para testar o sudo
    docker exec "$NOME" bash -c 'echo "pdv:pdv" | chpasswd && usermod -aG sudo pdv'
    instalar || exit 1
    echo
    echo "Pronto. Para entrar:  bash tests/docker/maquina.sh entrar $VERSAO"
    ;;
  entrar)
    existe || { echo "Crie antes: bash tests/docker/maquina.sh criar $VERSAO"; exit 1; }
    docker start "$NOME" >/dev/null
    docker exec -it -e TERM="$(term_da_maquina)" -w /root "$NOME" bash -l
    ;;
  pdv)
    existe || { echo "Crie antes: bash tests/docker/maquina.sh criar $VERSAO"; exit 1; }
    docker start "$NOME" >/dev/null
    docker exec -it -e TERM="$(term_da_maquina)" -u pdv -w /home/pdv "$NOME" bash -l
    ;;
  atualizar)
    existe || { echo "Crie antes: bash tests/docker/maquina.sh criar $VERSAO"; exit 1; }
    docker start "$NOME" >/dev/null
    instalar
    ;;
  apagar)
    existe && docker rm -f "$NOME" >/dev/null && echo "Máquina $NOME apagada."
    ;;
  remover)
    # Remove tudo desta versão: máquina (mesmo rodando) e imagem.
    # As imagens base (ubuntu:22.04, i386/ubuntu:18.04) ficam, pois podem
    # ser usadas por outros projetos.
    if existe; then
      docker rm -f "$NOME" >/dev/null && echo "Máquina $NOME removida."
    else
      echo "Máquina $NOME não existe."
    fi
    if docker image inspect "$TAG" >/dev/null 2>&1; then
      docker rmi -f "$TAG" >/dev/null && echo "Imagem $TAG removida."
    else
      echo "Imagem $TAG não existe."
    fi
    # Camadas sem nome que sobraram de builds desta imagem
    docker image prune -f --filter "label=sysutil.test=1" >/dev/null 2>&1 || true
    ;;
  *)
    sed -n '3,20p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
