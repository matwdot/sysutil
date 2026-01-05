# SysUtil v6.0

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
cd ~/sysutil && ./sysutil.sh
```

## 📋 Funcionalidades

- **SysPDV PDV**: Instalação e atualização
- **VPN Connect**: Configuração de VPN
- **MFe/DocGate**: Drivers e configurações para MFe
- **Periféricos**: Configuração de dispositivos
- **Biométrico**: Configuração de leitores biométricos
- **Limitação de Consumo**: Para sistemas Tec55
- **Transferência SCP**: Transferência segura de arquivos

## 🛠️ Desenvolvimento

### Estrutura do Projeto
```
sysutil/
├── sysutil.sh          # Script principal
├── functions.sh        # Funções auxiliares
├── colors.sh          # Definições de cores
├── install.sh         # Script de instalação
├── run.sh            # Script de execução rápida
├── func/             # Módulos funcionais
│   ├── utils/        # Utilitários
│   └── *.sh         # Scripts específicos
└── dep/             # Dependências
```

### Executar Localmente
```bash
git clone https://github.com/matwdot/sysutil.git
cd sysutil
chmod +x sysutil.sh
./sysutil.sh
```

## 📝 Licença

MIT License - veja o arquivo LICENSE para detalhes.

## 👨‍💻 Autor

**Matheus Wesley**
- GitHub: [@matwdot](https://github.com/matwdot)
- Links: [matheuswesley.github.io/devlinks](https://matheuswesley.github.io/devlinks)