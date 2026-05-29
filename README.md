# SysUtil v8.0

Script de utilitários para configuração e manutenção do SysPDV PDV em sistemas Linux.

## 🚀 Instalação e Uso

### Uma Linha - Instala, Configura e Executa
```bash
curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
```

**O que faz:**
- ✅ Remove instalação anterior (se existir)
- ✅ Baixa a versão mais recente
- ✅ Configura permissões
- ✅ Adiciona ao PATH do sistema
- ✅ Cria alias `sysutil`
- ✅ Aplica configurações (source)
- ✅ Executa automaticamente

### Atualizar Instalação Existente
```bash
curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/update.sh | bash
```

### Executar Após Instalação
Após a instalação, você pode executar de qualquer lugar:
```bash
sysutil
```

Ou diretamente:
```bash
cd ~/sysutil && ./sysutil
```

## 📋 Funcionalidades

- **SysPDV PDV**: Instalação e atualização
- **VPN Connect**: Configuração de VPN
- **MFe**: Remoção de drivers MFe
- **Periféricos**: Configuração de dispositivos
- **Biométrico**: Configuração de leitores biométricos
- **Limitação de Consumo**: Para sistemas Tec55
- **Transferência SCP**: Transferência segura de arquivos

## 🛠️ Desenvolvimento

### Estrutura do Projeto
```
sysutil/
├── sysutil              # Script principal (entrypoint único)
├── functions.sh          # Agregador de funções
├── colors.sh             # Definições de cores
├── install.sh            # Instalador
├── update.sh             # Atualizador
├── config/
│   ├── version.sh        # Versão centralizada
│   └── downloads.conf    # URLs de dependências
├── func/                 # Módulos funcionais
│   ├── utils/            # Utilitários (menu, mensagens, download)
│   └── *.sh              # Scripts de funcionalidades
├── scripts/              # Scripts auxiliares
└── dep/                  # Dependências leves (Tec55)
```

### Executar Localmente
```bash
git clone https://github.com/matwdot/sysutil.git
cd sysutil
chmod +x sysutil
./sysutil
```

## 📝 Licença

MIT License - veja o arquivo LICENSE para detalhes.

## 👨‍💻 Autor

**Matheus Wesley**
- GitHub: [@matwdot](https://github.com/matwdot)
- Links: [matheuswesley.github.io/devlinks](https://matheuswesley.github.io/devlinks)