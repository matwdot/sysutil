# SysUtil - Documentação

Utilitário para instalação e manutenção do SysPDV PDV em Linux.

**Versão:** 7.0  
**Autor:** Matheus Wesley - Casa Magalhães  
**GitHub:** https://github.com/matwdot/sysutil

---

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
source ~/.bashrc
```

## Atualização

```bash
curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/update.sh | bash
```

## Uso

```bash
sysutil
```

Navegue com as setas `↑`/`↓` e selecione com `Enter`. Pressione `q` ou `0` para sair.

---

## Menu Principal

| Opção | Descrição |
|-------|-----------|
| SysPDV PDV | Instalar ou atualizar o sistema |
| VPN Connect | Gerenciar VPN Wanbee |
| MFe/DocGate | Drivers MFe e configuração DocGate |
| Configurar Periféricos | Editar setty e regras USB |
| Configurar Biométrico | Servidor biométrico FH80 |
| Limitar Consumo Tec55 | Limitador CPU para Gertec55 |
| Transferência SCP | Copiar arquivos entre máquinas |

---

## Funcionalidades

### SysPDV PDV

**Instalar SysPDV PDV**
- Baixa o instalador da build informada
- Configura periféricos
- Instala VPN
- Instala driver MFe

**Atualizar SysPDV PDV**
- Faz backup dos arquivos `.fdb`
- Baixa e executa o instalador da nova build

### VPN Connect

**Instalar VPN**
- Ubuntu 18.04: usa pacote `.deb` i386
- Ubuntu 22.04+: usa script `wnbinstall.sh`
- Solicita a chave de ativação

**Remover VPN**
- Salva backup da chave em `chave.txt`
- Remove pacotes e diretórios

### MFe/DocGate

**Instalar Driver MFe**
- Baixa do site da SEFAZ-CE
- Versão padrão: 02.05.18
- Extrai e executa instalador

**Remover Driver MFe**
- Executa script de remoção em `/opt/sefaz/cco/`

**Configurar DocGate**
- Extrai DocGate v5 para `/opt/docgate`
- Faz backup da instalação anterior
- Abre utilitário de configuração

### Configurar Periféricos

Abre para edição:
- `/usr/local/bin/setty` - configuração de portas seriais
- `/etc/udev/rules.d/90-dispositivos-usb.rules` - regras USB

Usa Sublime Text se disponível, senão nano.

### Configurar Biométrico

- Aplica permissões em `/opt/ServidorBiometrico/`
- Abre utilitário `biometria`
- Executa `iniciaBiometriaFH80.sh`

### Limitar Consumo Tec55

- Instala `cpulimit`
- Copia scripts para `/usr/local/bin`
- Aplica permissões em `/opt/Gertec55`

### Transferência SCP

Copia arquivos/pastas de outra máquina via SCP:
- IP do host remoto
- Caminho do arquivo/pasta origem
- Diretório local de destino

---

## Estrutura de Diretórios

```
~/sysutil/
├── sysutil.sh          # Script principal
├── install.sh          # Instalador
├── update.sh           # Atualizador
├── functions.sh        # Importa todas as funções
├── colors.sh           # Definição de cores
├── func/               # Módulos de funcionalidades
│   ├── baixar_build.sh
│   ├── instalar_vpn.sh
│   ├── remover_vpn.sh
│   ├── baixar_drive_mfe.sh
│   ├── remover_drive_mfe.sh
│   ├── configurar_docgate.sh
│   ├── configurar_perifericos.sh
│   ├── configurar_biometria.sh
│   ├── limitar_consumo.sh
│   ├── transferencia.sh
│   ├── fazer_backup_fdb.sh
│   └── utils/
│       ├── utilities.sh
│       └── menu_system.sh
└── dep/                # Dependências
    ├── docgateV5.tar.gz
    ├── wnbinstall.sh
    ├── tec55/
    └── wnbtlscli_2_5_1/
```

---

## Requisitos

- Linux (Ubuntu 18.04, 22.04 ou superior)
- Git
- Curl
- Wine (para executar instalador Windows do SysPDV)
- Acesso root/sudo

---

## Atalhos

| Tecla | Ação |
|-------|------|
| `↑` / `↓` | Navegar menu |
| `Enter` | Selecionar opção |
| `q` ou `0` | Sair |

---

## Suporte

Em caso de problemas, abra uma issue no GitHub:  
https://github.com/matwdot/sysutil/issues
