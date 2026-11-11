#!/bin/bash
#
# smoke.sh - Testes rápidos do SysUtil
#
# Roda sem hardware, sem rede e sem mexer no sistema: comandos perigosos
# (sudo, curl, dpkg, wine...) são trocados por versões falsas.
#
# Uso:
#   bash tests/smoke.sh            # na pasta do projeto
#   bash tests/run_docker.sh       # nos dois Ubuntu (18.04 i386 e 22.04 amd64)
#
# *************************************************************

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/sysutil-smoke.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

PASS=0
FAIL=0

ok() {
  PASS=$((PASS + 1))
  echo "  ok   - $1"
}

fail() {
  FAIL=$((FAIL + 1))
  echo "  FAIL - $1"
  [[ -n "${2:-}" ]] && echo "         $2"
}

# check "descrição" valor_obtido valor_esperado
check() {
  if [[ "$2" == "$3" ]]; then ok "$1"; else fail "$1" "obtido: '$2' | esperado: '$3'"; fi
}

# Roda um comando com limite de tempo (sem depender de 'timeout', que não existe no macOS)
run_limited() {
  local secs=$1
  shift
  "$@" &
  local pid=$!
  ( sleep "$secs" && kill "$pid" 2>/dev/null ) &
  local watcher=$!
  wait "$pid"
  local rc=$?
  kill "$watcher" 2>/dev/null
  wait "$watcher" 2>/dev/null
  return $rc
}

# Comandos falsos: registram a chamada em $WORK/calls e não fazem nada
FAKEBIN="$WORK/bin"
mkdir -p "$FAKEBIN"
for cmd in sudo curl dpkg apt apt-get wine wnbmonitor wnbupdate scp; do
  cat >"$FAKEBIN/$cmd" <<EOF
#!/bin/bash
echo "$cmd \$*" >> "$WORK/calls"
[[ "$cmd" == "sudo" ]] && exit 0
exit 0
EOF
  chmod +x "$FAKEBIN/$cmd"
done
# id falso: diz que é root (para não pedir sudo de verdade)
cat >"$FAKEBIN/id" <<'EOF'
#!/bin/bash
if [[ "$1" == "-u" ]]; then echo 0; else exec /usr/bin/id "$@"; fi
EOF
chmod +x "$FAKEBIN/id"

echo "SysUtil smoke test"
echo "  bash: $BASH_VERSION | arch: $(uname -m)"
[[ -r /etc/os-release ]] && echo "  sistema: $(. /etc/os-release && echo "$PRETTY_NAME")"
echo

# ---------------------------------------------------------------
echo "1. Sintaxe"
cd "$ROOT" || exit 1
for f in sysutil functions.sh colors.sh install.sh update.sh config/*.sh func/*.sh func/utils/*.sh scripts/*.sh; do
  if bash -n "$f" 2>"$WORK/err"; then ok "$f"; else fail "$f" "$(cat "$WORK/err")"; fi
done

# ---------------------------------------------------------------
echo "2. Menu (teclas)"
menu_idx() {
  printf "$1" | TERM=dumb bash -c '
    cd "'"$ROOT"'" && . ./colors.sh && clear(){ :; }
    . func/utils/menu_system.sh
    select_menu "Teste" "Um" "Dois" "Tres" "Voltar" >/dev/null
    echo $?' 2>/dev/null | tail -1
}
check "Enter escolhe o primeiro"      "$(menu_idx '\n')" 0
check "seta baixo + Enter"            "$(menu_idx '\033[B\n')" 1
check "baixo, baixo, cima + Enter"    "$(menu_idx '\033[B\033[B\033[A\n')" 1
check "j j + Enter"                   "$(menu_idx 'jj\n')" 2
check "tecla 3"                       "$(menu_idx '3')" 2
check "número fora da lista ignorado" "$(menu_idx '9\n')" 0
check "q escolhe Voltar"              "$(menu_idx 'q')" 3
check "ESC sozinho escolhe Voltar"    "$(menu_idx '\033')" 3

# ---------------------------------------------------------------
echo "3. Menu principal (sem executar ações)"
: >"$WORK/calls"
(cd / && PATH="$FAKEBIN:$PATH" TERM=dumb run_limited 10 "$ROOT/sysutil" </dev/null >"$WORK/out" 2>&1)
check "fecha sozinho quando não há teclado" "$?" 0
if [[ -s "$WORK/calls" ]]; then
  fail "nenhuma ação executada sem teclado" "$(cat "$WORK/calls")"
else
  ok "nenhuma ação executada sem teclado"
fi
grep -q "Executando como root" "$WORK/out" && ok "aviso de root aparece" || fail "aviso de root aparece"
printf 'q' | (cd / && PATH="$FAKEBIN:$PATH" TERM=dumb run_limited 10 "$ROOT/sysutil" >/dev/null 2>&1)
check "q sai do menu principal" "$?" 0

# ---------------------------------------------------------------
echo "4. Verificação de root"
NOROOT="$WORK/noroot"
mkdir -p "$NOROOT"
cat >"$NOROOT/id" <<'EOF'
#!/bin/bash
if [[ "$1" == "-u" ]]; then echo 1000; else exec /usr/bin/id "$@"; fi
EOF
cat >"$NOROOT/sudo" <<EOF
#!/bin/bash
echo "sudo \$*" > "$WORK/sudo_call"
EOF
chmod +x "$NOROOT/id" "$NOROOT/sudo"
rm -f "$WORK/sudo_call"
PATH="$NOROOT:$PATH" bash "$ROOT/sysutil" </dev/null >/dev/null 2>&1
grep -q "sysutil" "$WORK/sudo_call" 2>/dev/null && ok "não root reabre com sudo" || fail "não root reabre com sudo"

# ---------------------------------------------------------------
echo "5. Funções"
stubs='confirm_action(){ return 0; }; info_msg(){ :; }; warning_msg(){ :; }; success_msg(){ :; }; error_msg(){ echo "erro: $*"; }; sleep(){ :; }'

# Backup do banco
PDV="$WORK/pdv"
mkdir -p "$PDV"
echo dados >"$PDV/syspdv_cad.fdb"
rc=$(cd "$ROOT" && PATH="$FAKEBIN:$PATH" bash -c "$stubs; sudo(){ \"\$@\"; }; . func/fazer_backup_fdb.sh; DIR_SYSPDV=$PDV; fazer_backup_fdb >/dev/null 2>&1; echo \$?")
check "backup falha se faltar o MOV" "$rc" 1
echo dados >"$PDV/syspdv_mov.fdb"
rc=$(cd "$ROOT" && PATH="$FAKEBIN:$PATH" bash -c "$stubs; sudo(){ \"\$@\"; }; . func/fazer_backup_fdb.sh; DIR_SYSPDV=$PDV; cd /; fazer_backup_fdb >/dev/null; echo \$?:\$(pwd)")
check "backup ok e não muda a pasta atual" "$rc" "0:/"
backups=("$PDV"/backup_fdbs/*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].fdb)
check "backup gera 2 arquivos com data" "${#backups[@]}" 2

# limitar_consumo: cpulimit é instalado e arquivos copiados
: >"$WORK/calls"
(cd "$ROOT" && PATH="$FAKEBIN:$PATH" bash -c ". ./colors.sh; . func/utils/utilities.sh; $stubs; . func/limitar_consumo.sh; limitar_consumo" >/dev/null)
grep -q "install -y cpulimit" "$WORK/calls" && ok "limitar_consumo instala o cpulimit" || fail "limitar_consumo instala o cpulimit"
grep -q "cp -R" "$WORK/calls" && ok "limitar_consumo copia os arquivos" || fail "limitar_consumo copia os arquivos"

# VPN (v8.0): roda o simple-update.sh, que escolhe o .deb pela arquitetura
: >"$WORK/calls"
printf 'CHAVE\n' >"$WORK/key"
(cd "$ROOT" && PATH="$FAKEBIN:$PATH" bash -c "$stubs; . func/instalar_vpn.sh; instalar_vpn" <"$WORK/key" >/dev/null 2>&1)
grep -q "sudo bash $ROOT/dep/wnbtlscli_2_5_1/simple-update.sh $ROOT/dep/wnbtlscli_2_5_1" "$WORK/calls" \
  && ok "VPN chama o simple-update.sh com a pasta dos pacotes" || fail "VPN chama o simple-update.sh com a pasta dos pacotes" "$(cat "$WORK/calls")"
if [[ ! -f /etc/wnbtlscli/registry ]]; then
  grep -q "wnbupdate -k CHAVE" "$WORK/calls" && ok "VPN registra a chave com wnbupdate" || fail "VPN registra a chave com wnbupdate"
fi
# Registro falhou: não pode dizer "sucesso"
if [[ ! -f /etc/wnbtlscli/registry ]]; then
  out=$(cd "$ROOT" && PATH="$FAKEBIN:$PATH" bash -c "$stubs; success_msg(){ echo SUCESSO; }; sudo(){ [[ \$1 == wnbupdate ]] && return 1; return 0; }; . func/instalar_vpn.sh; instalar_vpn; echo rc=\$?" <"$WORK/key" 2>/dev/null)
  [[ "$out" != *SUCESSO* && "$out" == *rc=1* ]] && ok "VPN não diz sucesso se o registro falhar" || fail "VPN não diz sucesso se o registro falhar" "$out"
fi

# ---------------------------------------------------------------
echo "6. Instalador (em pastas de teste)"
if command -v git >/dev/null 2>&1; then
  # Repositório com o estado atual dos arquivos (inclui mudanças não commitadas)
  REPO="$WORK/repo"
  mkdir -p "$REPO"
  (cd "$ROOT" && tar --exclude=.git --exclude=assets -cf - .) | (cd "$REPO" && tar -xf -)
  git -C "$REPO" init -q
  # nome do branch fixo (o padrão do git varia); "symbolic-ref" funciona no git 2.17 do 18.04
  git -C "$REPO" symbolic-ref HEAD refs/heads/master
  git -C "$REPO" add -A
  git -C "$REPO" -c user.name=t -c user.email=t@t commit -qm teste
  git -C "$REPO" branch dev

  H="$WORK/home/pdv"
  mkdir -p "$H/sysutil"
  printf 'export A=1\n# SysUtil\nexport PATH="%s/sysutil:$PATH"\nalias sysutil='"'"'cd x && ./sysutil'"'"'\nexport B=2\n' "$H" >"$H/.bashrc"

  inst() {
    local repo=$1
    shift
    PATH="$FAKEBIN:$PATH" TERM=dumb \
      SYSUTIL_INSTALL_DIR="$WORK/opt/sysutil" SYSUTIL_BIN_LINK="$WORK/usr/bin/sysutil" \
      SYSUTIL_REPO="$repo" SYSUTIL_HOMES="$H" bash "$ROOT/install.sh" "$@" >"$WORK/inst.out" 2>&1
  }
  inst "$REPO" --dev
  check "--dev instala sem erro" "$?" 0
  check "--dev instala o branch dev" "$(git -C "$WORK/opt/sysutil" rev-parse --abbrev-ref HEAD)" dev
  inst "$REPO" --xyz
  [[ $? -ne 0 ]] && ok "opção desconhecida é recusada" || fail "opção desconhecida é recusada"
  inst "$REPO"
  check "instala sem erro" "$?" 0
  check "sem opção instala o branch master" "$(git -C "$WORK/opt/sysutil" rev-parse --abbrev-ref HEAD)" master
  [[ -x "$WORK/opt/sysutil/sysutil" ]] && ok "arquivos em /opt/sysutil" || fail "arquivos em /opt/sysutil"
  [[ -L "$WORK/usr/bin/sysutil" ]] && ok "comando sysutil criado" || fail "comando sysutil criado"
  grep -q sysutil "$H/.bashrc" && fail "alias antigo removido do .bashrc" "$(cat "$H/.bashrc")" || ok "alias antigo removido do .bashrc"
  [[ -f "$H/.bashrc.sysutil.bak" ]] && ok "cópia .bashrc.sysutil.bak criada" || fail "cópia .bashrc.sysutil.bak criada"
  grep -q "$H/sysutil" "$WORK/inst.out" && ok "avisa sobre a pasta antiga" || fail "avisa sobre a pasta antiga"

  echo marca >"$WORK/opt/sysutil/MARCA"
  inst "$WORK/nao-existe"
  [[ $? -ne 0 && -f "$WORK/opt/sysutil/MARCA" ]] && ok "falha no download mantém a instalação" || fail "falha no download mantém a instalação"
  rm -f "$WORK/opt/sysutil/MARCA"

  PATH="$FAKEBIN:$PATH" SYSUTIL_INSTALL_DIR="$WORK/opt/sysutil" SYSUTIL_BIN_LINK="$WORK/usr/bin/sysutil" \
    bash "$ROOT/update.sh" >/dev/null 2>&1
  check "update.sh roda sem erro" "$?" 0

  printf 'q' | (cd / && PATH="$FAKEBIN:$PATH" TERM=dumb run_limited 10 "$WORK/usr/bin/sysutil" >/dev/null 2>&1)
  check "comando instalado abre e sai com q" "$?" 0
else
  echo "  skip - git não instalado"
fi

# ---------------------------------------------------------------
# 7. Caminhos reais do PDV: só na imagem de teste (tests/docker), que cria
#    /opt/Syspdv, /opt/Gertec55, /opt/sefaz, /etc/wnbtlscli etc.
#    Aqui o sudo é o de verdade (o contêiner já roda como root).
# ---------------------------------------------------------------
if [[ -f /etc/sysutil-test-image && "$(id -u)" -eq 0 ]]; then
  echo "7. Caminhos reais do PDV (imagem de teste)"
  CALLS=/var/log/sysutil-test/calls

  # Ambiente esperado
  if [[ -n "${SYSUTIL_EXPECT_UBUNTU:-}" ]]; then
    check "Ubuntu da máquina" "$(. /etc/os-release && echo "$VERSION_ID")" "$SYSUTIL_EXPECT_UBUNTU"
    case "$SYSUTIL_EXPECT_UBUNTU" in
      18.04) check "arquitetura 32 bits" "$(uname -m)" i686 ;;
      22.04) check "arquitetura 64 bits" "$(uname -m)" x86_64 ;;
    esac
  fi
  # O simple-update.sh escolhe wnbtlscli_2.5.1_<arch>.deb pelo uname -m
  case "$(uname -m)" in
    i386 | i686) deb_arch=i386 ;;
    x86_64) deb_arch=amd64 ;;
    *) deb_arch="?" ;;
  esac
  [[ -f "$ROOT/dep/wnbtlscli_2_5_1/wnbtlscli_2.5.1_${deb_arch}.deb" ]] \
    && ok "pacote VPN ${deb_arch} presente em dep/" || fail "pacote VPN ${deb_arch} presente em dep/"

  # apt falso só durante estes testes. O sudo usa o secure_path, que olha
  # /usr/local/sbin antes de /usr/bin, então o falso precisa ficar lá.
  for cmd in apt apt-get; do
    printf '#!/bin/bash\necho "%s $*" >> %s\nexit 0\n' "$cmd" "$CALLS" >"/usr/local/sbin/$cmd"
    chmod +x "/usr/local/sbin/$cmd"
  done

  # Backup em /opt/Syspdv
  rc=$(cd "$ROOT" && bash -c "$stubs; . func/fazer_backup_fdb.sh; cd /tmp; fazer_backup_fdb >/dev/null 2>&1; echo \$?:\$(pwd)")
  check "backup em /opt/Syspdv" "$rc" "0:/tmp"
  backups=(/opt/Syspdv/backup_fdbs/syspdv_*_[0-9]*.fdb)
  check "2 cópias em /opt/Syspdv/backup_fdbs" "${#backups[@]}" 2

  # Tec55
  : >"$CALLS"
  (cd "$ROOT" && bash -c ". ./colors.sh; . func/utils/utilities.sh; $stubs; . func/limitar_consumo.sh; limitar_consumo" >/dev/null 2>&1)
  check "limitar_consumo termina sem erro" "$?" 0
  grep -q "apt-get install -y cpulimit\|apt install -y cpulimit" "$CALLS" && ok "cpulimit pedido ao apt" || fail "cpulimit pedido ao apt"
  [[ -x /usr/local/bin/limit.sh ]] && ok "limit.sh copiado para /usr/local/bin" || fail "limit.sh copiado para /usr/local/bin"
  check "/opt/Gertec55 com permissão 777" "$(stat -c %a /opt/Gertec55)" 777

  # Biometria
  : >"$CALLS"
  (cd "$ROOT" && printf '\n' | bash -c "$stubs; . func/configurar_biometria.sh; configurar_biometria" >/dev/null 2>&1)
  grep -q "^biometria" "$CALLS" && ok "biometria chamada" || fail "biometria chamada"
  grep -q "^iniciaBiometriaFH80.sh" "$CALLS" && ok "servidor biométrico iniciado" || fail "servidor biométrico iniciado"
  check "/opt/ServidorBiometrico com permissão 777" "$(stat -c %a /opt/ServidorBiometrico)" 777

  # Periféricos (editor falso: só registra quais arquivos abriria)
  EDBIN="$WORK/edbin"
  mkdir -p "$EDBIN"
  printf '#!/bin/bash\necho "nano $*" >> %s\n' "$CALLS" >"$EDBIN/nano"
  chmod +x "$EDBIN/nano"
  : >"$CALLS"
  (cd "$ROOT" && printf '\n' | PATH="$EDBIN:$PATH" bash -c "$stubs; . ./colors.sh; . func/utils/utilities.sh; $stubs; . func/configurar_perifericos.sh; editar_regras_manualmente" >/dev/null 2>&1)
  grep -q "nano /usr/local/bin/setty" "$CALLS" && ok "abre /usr/local/bin/setty" || fail "abre /usr/local/bin/setty"
  grep -q "nano /etc/udev/rules.d/90-dispositivos-usb.rules" "$CALLS" && ok "abre a regra udev" || fail "abre a regra udev"
  grep -q "^setty" "$CALLS" && ok "setty executado" || fail "setty executado"

  # Remover VPN: guarda a chave antes de apagar /etc/wnbtlscli
  rm -f "$HOME"/.sysutil/chave_vpn_*.txt
  (cd "$ROOT" && bash -c "$stubs; . func/remover_vpn.sh; cd /tmp; remover_vpn" >/dev/null 2>&1)
  check "remover_vpn termina sem erro" "$?" 0
  chaves=("$HOME"/.sysutil/chave_vpn_*.txt)
  if [[ -f "${chaves[0]}" ]]; then
    check "chave salva com o conteúdo certo" "$(cat "${chaves[0]}")" "CHAVE-DE-TESTE-123"
    check "chave com permissão 600" "$(stat -c %a "${chaves[0]}")" 600
  else
    fail "chave salva em $HOME"
  fi
  [[ ! -d /etc/wnbtlscli ]] && ok "/etc/wnbtlscli apagada depois do backup" || fail "/etc/wnbtlscli apagada depois do backup"

  # Remover driver MFe
  rc=$(cd "$ROOT" && bash -c "$stubs; . func/remover_drive_mfe.sh; cd /tmp; remover_drive_mfe >/dev/null 2>&1; echo \$(pwd)")
  check "remover MFe não muda a pasta atual" "$rc" /tmp
  [[ ! -d /opt/sefaz ]] && ok "/opt/sefaz removida" || fail "/opt/sefaz removida"

  # Remover DocGate
  rc=$(cd "$ROOT" && printf '\n\n' | bash -c "$stubs; . func/remover_docgate.sh; remover_docgate >/dev/null 2>&1; echo \$?")
  check "remover DocGate termina sem erro" "$rc" 0
  [[ ! -d /opt/docgate ]] && ok "/opt/docgate removida" || fail "/opt/docgate removida"

  rm -f /usr/local/sbin/apt /usr/local/sbin/apt-get
fi

# ---------------------------------------------------------------
echo
echo "Resultado: $PASS ok, $FAIL falha(s)"
[[ $FAIL -eq 0 ]]
