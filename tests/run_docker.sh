#!/bin/bash
#
# run_docker.sh - Roda tests/smoke.sh e o shellcheck nos dois ambientes suportados:
#   - Ubuntu 18.04 i386 (32 bits)  -> imagem i386/ubuntu:18.04, plataforma linux/386
#   - Ubuntu 22.04 amd64 (64 bits) -> imagem ubuntu:22.04,      plataforma linux/amd64
#
# A imagem (tests/docker/Dockerfile) já vem com os caminhos de um PDV
# (/opt/Syspdv, /opt/Gertec55, /opt/sefaz, /etc/wnbtlscli...), criados por
# tests/docker/setup_pdv_paths.sh. Assim as funções rodam nos caminhos reais.
#
# Precisa de Docker rodando. Em Mac com Apple Silicon as duas imagens rodam
# por emulação (mais lento, mas funciona).
#
# Uso: bash tests/run_docker.sh [18.04|22.04]
#
# *************************************************************

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! docker info >/dev/null 2>&1; then
  echo "ERRO: Docker não está rodando. Abra o Docker Desktop (ou 'colima start') e tente de novo."
  exit 1
fi

run_env() {
  local version=$1 base=$2 platform=$3
  local tag="sysutil-test:${version}"

  echo "=================================================="
  echo " Ubuntu $version ($base, $platform)"
  echo "=================================================="

    if ! docker build -q --platform "$platform" --build-arg BASE="$base" \
    -t "$tag" "$ROOT/tests/docker" >/dev/null; then
    echo "ERRO: falha ao montar a imagem $tag"
    return 1
  fi

  # Projeto entra só para leitura; o teste trabalha numa cópia (/work).
  # --rm: o contêiner é apagado no fim, então os caminhos do PDV voltam ao
  # estado original a cada execução.
  docker run --rm --platform "$platform" -v "$ROOT:/src:ro" \
    -e SYSUTIL_EXPECT_UBUNTU="$version" "$tag" bash -c '
      cp -r /src/. /work/ && cd /work
      if command -v shellcheck >/dev/null 2>&1 && shellcheck -s bash -S warning /dev/null >/dev/null 2>&1; then
        echo "--- shellcheck $(shellcheck --version | sed -n 2p)"
        shellcheck -s bash -S warning -x sysutil functions.sh colors.sh install.sh update.sh config/*.sh \
          func/*.sh func/utils/*.sh scripts/*.sh tests/*.sh tests/docker/*.sh dep/wnbtlscli_2_5_1/simple-update.sh && echo "shellcheck: sem avisos"
      else
        echo "--- shellcheck: versão deste Ubuntu é antiga demais, pulando (roda no 22.04)"
      fi
      echo "--- smoke"
      bash tests/smoke.sh
    '
}

rc=0
case "${1:-all}" in
  18.04) run_env 18.04 i386/ubuntu:18.04 linux/386 || rc=1 ;;
  22.04) run_env 22.04 ubuntu:22.04 linux/amd64 || rc=1 ;;
  *)
    run_env 18.04 i386/ubuntu:18.04 linux/386 || rc=1
    run_env 22.04 ubuntu:22.04 linux/amd64 || rc=1
    ;;
esac

echo
[[ $rc -eq 0 ]] && echo "TUDO OK nos ambientes testados." || echo "HOUVE FALHAS. Veja acima."
exit $rc
