# Imagem de teste do SysUtil.
#
#   Ubuntu 18.04 32 bits: --platform linux/386   --build-arg BASE=i386/ubuntu:18.04
#   Ubuntu 22.04 64 bits: --platform linux/amd64 --build-arg BASE=ubuntu:22.04
#
# Use pelo tests/run_docker.sh. O projeto entra depois, por volume, só leitura.

ARG BASE=ubuntu:22.04
FROM ${BASE}

# Marca para o "maquina.sh remover" achar as sobras desta imagem
LABEL sysutil.test=1

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# apt com até 3 tentativas (a rede/DNS do Docker às vezes falha).
# Só no 18.04 (bionic): se o espelho normal não responder, usa o
# old-releases.ubuntu.com. O 22.04 nunca troca de espelho.
RUN set -e; \
    . /etc/os-release; \
    # O DNS do Docker Desktop falha no meio do build (responde e depois para).
    # Usa DNS público só durante este passo; o contêiner final volta ao normal.
    printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf; \
    echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99ipv4; \
    # Só conta como ok quando TODAS as listas baixaram (lista parcial deixa
    # versões que não batem) e git/sudo aparecem. Falha de DNS vira só aviso
    # no apt, então o código de saída não basta.
    apt_ready() { \
      ! grep -qE 'Failed to fetch|^E:' /tmp/apt.log && apt-cache show git sudo >/dev/null 2>&1; \
    }; \
    try_update() { \
      for i in 1 2 3 4 5; do \
        apt-get update -o Acquire::Retries=3 >/tmp/apt.log 2>&1 || true; \
        if apt_ready; then return 0; fi; \
        grep -E '^(W|E):' /tmp/apt.log | head -3; \
        echo "Lista de pacotes incompleta (tentativa $i de 5), tentando de novo..."; sleep 5; \
      done; \
      return 1; \
    }; \
    if ! try_update; then \
      if [ "$VERSION_CODENAME" = "bionic" ]; then \
        echo "Usando old-releases.ubuntu.com (18.04)"; \
        sed -i -E 's#https?://(archive|security|ports)\.ubuntu\.com/ubuntu(-ports)?#http://old-releases.ubuntu.com/ubuntu#g' /etc/apt/sources.list; \
        try_update || { echo "ERRO: não foi possível baixar a lista de pacotes"; exit 1; }; \
      else \
        echo "ERRO: não foi possível baixar a lista de pacotes (rede/DNS do Docker)"; exit 1; \
      fi; \
    fi; \
    apt-get install -y --no-install-recommends -o Acquire::Retries=3 git sudo ca-certificates curl nano; \
    apt-get install -y --no-install-recommends -o Acquire::Retries=3 shellcheck || echo "shellcheck indisponível, seguindo sem ele"; \
    rm -rf /var/lib/apt/lists/* /tmp/apt.log

COPY setup_pdv_paths.sh /usr/local/sbin/setup_pdv_paths.sh
RUN bash /usr/local/sbin/setup_pdv_paths.sh

WORKDIR /work
