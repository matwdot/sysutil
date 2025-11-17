# Implementation Plan

- [x] 1. Preparar estrutura base e validar utilities.sh
  - Verificar que utilities.sh está completo e funcional
  - Criar arquivo de log /var/log/sysutil.log com permissões adequadas
  - Documentar padrão de import a ser usado em todos os scripts
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 2. Implementar integração em db.sh (script de teste)
  - [ ] 2.1 Adicionar import de utilities.sh no início do arquivo
    - Implementar padrão de import com verificação de função carregada
    - Adicionar fallback caso utilities.sh não carregue
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 2.2 Implementar função básica db_access com utilities
    - Substituir info_msg existente por versão do utilities
    - Adicionar mensagens de erro e sucesso apropriadas
    - Adicionar log de acesso ao banco
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 6.1, 6.2, 6.3_
  
  - [ ]* 2.3 Testar execução de db.sh
    - Executar script diretamente
    - Executar via menu principal
    - Verificar que mensagens aparecem formatadas
    - Verificar que logs são gravados
    - _Requirements: 8.1, 8.2, 8.3_

- [ ] 3. Implementar integração em fazer_backup_fdb.sh
  - [ ] 3.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 3.2 Substituir mensagens echo por funções utilities
    - Substituir echo com ${RED} por error_msg
    - Substituir echo com ${GREEN} por success_msg
    - Substituir echo com ${YELLOW} por warning_msg
    - Substituir echo com ${BLUE} por info_msg
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 3.3 Implementar uso de backup_file para backups de FDB
    - Substituir lógica manual de backup por backup_file
    - Adicionar tratamento de erro baseado em código de retorno
    - Manter compatibilidade com estrutura de diretório atual
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [ ] 3.4 Implementar uso de ensure_directory
    - Substituir mkdir -p por ensure_directory
    - Adicionar tratamento de erro apropriado
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ] 3.5 Adicionar logging de operações de backup
    - Adicionar log_info quando backup inicia
    - Adicionar log_info quando backup completa com sucesso
    - Adicionar log_error quando backup falha
    - _Requirements: 6.1, 6.2, 6.4_

- [ ] 4. Implementar integração em baixar_build.sh
  - [ ] 4.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 4.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 4.3 Adicionar validação de URL
    - Manter validação existente de URL
    - Adicionar mensagem de erro apropriada usando error_msg
    - _Requirements: 5.2_
  
  - [ ] 4.4 Implementar uso de ensure_directory para diretório de destino
    - Verificar/criar diretório de destino antes do download
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ] 4.5 Adicionar logging de operações de download
    - Log quando download inicia
    - Log quando download completa
    - Log quando instalação inicia
    - Log de erros de download
    - _Requirements: 6.1, 6.2, 6.4_

- [ ] 5. Implementar integração em instalar_vpn.sh
  - [ ] 5.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 5.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 5.3 Adicionar validações com command_exists e package_installed
    - Verificar se dpkg existe antes de usar
    - Verificar se VPN já está instalada antes de instalar
    - _Requirements: 5.2, 5.3_
  
  - [ ] 5.4 Adicionar logging de instalação de VPN
    - Log quando instalação inicia
    - Log quando instalação completa
    - Log de erros de instalação
    - _Requirements: 6.1, 6.2, 6.4_

- [ ] 6. Implementar integração em remover_vpn.sh
  - [ ] 6.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 6.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 6.3 Adicionar validação com command_exists
    - Verificar se wnbmonitor existe antes de tentar remover
    - _Requirements: 5.2_
  
  - [ ] 6.4 Adicionar logging de remoção de VPN
    - Log quando remoção inicia
    - Log quando remoção completa
    - Log de erros de remoção
    - _Requirements: 6.1, 6.2, 6.4_

- [ ] 7. Implementar integração em configurar_perifericos.sh
  - [ ] 7.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 7.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 7.3 Adicionar validação com command_exists para editor
    - Verificar se subl existe antes de usar
    - Verificar se nano existe como fallback
    - _Requirements: 5.2_
  
  - [ ] 7.4 Adicionar logging de configuração de periféricos
    - Log quando configuração inicia
    - Log quando configuração completa
    - _Requirements: 6.1, 6.3_

- [ ] 8. Implementar integração em configurar_biometria.sh
  - [ ] 8.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 8.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 8.3 Implementar uso de ensure_directory para verificar diretório
    - Verificar se diretório de biometria existe antes de chmod
    - _Requirements: 7.1, 7.5_
  
  - [ ] 8.4 Adicionar logging de configuração de biometria
    - Log quando configuração inicia
    - Log quando configuração completa
    - Log de erros
    - _Requirements: 6.1, 6.2, 6.3_

- [ ] 9. Implementar integração em configurar_docgate.sh
  - [ ] 9.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 9.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 9.3 Implementar uso de backup_file para backup do DocGate
    - Substituir mv manual por backup_file
    - Adicionar tratamento de erro apropriado
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [ ] 9.4 Adicionar logging de configuração do DocGate
    - Log quando configuração inicia
    - Log quando backup é criado
    - Log quando extração completa
    - Log de erros
    - _Requirements: 6.1, 6.2, 6.3_

- [ ] 10. Implementar integração em baixar_drive_mfe.sh
  - [ ] 10.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 10.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas nas funções internas
    - Refatorar funções baixar_arquivo, extrair_arquivo, instalar_driver
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 10.3 Implementar uso de ensure_directory
    - Verificar diretório de destino antes de download
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ] 10.4 Adicionar logging de operações de MFe
    - Log de download, extração e instalação
    - Log de erros em cada etapa
    - _Requirements: 6.1, 6.2, 6.4_

- [ ] 11. Implementar integração em remover_drive_mfe.sh
  - [ ] 11.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 11.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 11.3 Adicionar verificação de diretório antes de remover
    - Verificar se /opt/sefaz/cco/ existe antes de cd
    - Usar mensagem de erro apropriada
    - _Requirements: 5.2_
  
  - [ ] 11.4 Adicionar logging de remoção de MFe
    - Log quando remoção inicia
    - Log quando remoção completa
    - Log de erros
    - _Requirements: 6.1, 6.2, 6.4_

- [ ] 12. Implementar integração em limitar_consumo.sh
  - [ ] 12.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 12.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 12.3 Adicionar validação com package_installed
    - Verificar se cpulimit já está instalado antes de instalar
    - _Requirements: 5.3_
  
  - [ ] 12.4 Adicionar logging de configuração de limitador
    - Log quando configuração inicia
    - Log quando instalação de cpulimit completa
    - Log quando permissões são aplicadas
    - Log de erros
    - _Requirements: 6.1, 6.2, 6.3_

- [ ] 13. Implementar integração em transferencia.sh
  - [ ] 13.1 Adicionar import de utilities.sh
    - Implementar padrão de import padronizado
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 13.2 Substituir mensagens echo por funções utilities
    - Substituir todas as mensagens formatadas por funções apropriadas
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 13.3 Adicionar validação de IP com is_valid_ip
    - Validar IP do host antes de tentar conexão
    - Adicionar mensagem de erro se IP inválido
    - _Requirements: 5.1_
  
  - [ ] 13.4 Adicionar logging de transferências
    - Log quando transferência inicia
    - Log quando transferência completa
    - Log de erros de transferência
    - _Requirements: 6.1, 6.2, 6.4_

- [ ] 14. Teste de regressão completo do sistema
  - [ ] 14.1 Testar menu principal
    - Verificar que menu carrega corretamente
    - Verificar navegação entre submenus
    - Verificar que opção Sair funciona
    - _Requirements: 8.1, 8.2, 8.3_
  
  - [ ] 14.2 Testar cada função via menu
    - Executar cada função do menu e verificar comportamento
    - Verificar que mensagens aparecem formatadas
    - Verificar que não há erros de execução
    - _Requirements: 8.1, 8.2, 8.4, 8.5_
  
  - [ ] 14.3 Verificar logs gerados
    - Verificar que arquivo /var/log/sysutil.log existe
    - Verificar que logs têm formato correto
    - Verificar que operações críticas foram logadas
    - _Requirements: 6.4, 6.5_
  
  - [ ] 14.4 Testar execução direta de scripts
    - Executar cada script diretamente (não via menu)
    - Verificar que utilities.sh é carregado corretamente
    - Verificar que não há erros de import
    - _Requirements: 2.4, 8.1, 8.2_

- [ ] 15. Documentação e finalização
  - Atualizar comentários nos scripts modificados
  - Documentar padrão de uso de utilities.sh para futuros desenvolvedores
  - Criar guia de troubleshooting para problemas comuns
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
