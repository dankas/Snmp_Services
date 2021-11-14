# Snmp Services 

[TOC]

Scripts(powershell) para aquisição de dados das impressoras do parque de impressão através do protocolo SNMP, formatação do JSON e carregamento na API de dados de impressoras.   

### Premissas do script:

- Rodar periodicamente através do task scheduler(Windows).
- Buscar informações do e especificidades dos modelos através da API.
- Organizar e formatar para enviar os dados no padrão da api.
- Um script para cada conjunto de dados.

### Conjuntos de dados:

|        | Contadores                                                   | Suprimentos                     | Erros                                         | Uso                                    | Estado do Equipamento                |      |
| ------ | :----------------------------------------------------------- | :------------------------------ | :-------------------------------------------- | -------------------------------------- | ------------------------------------ | ---- |
| RICOH: | ✅ Copier Mono ✅Copier Color  ✅Printer Mono ✅Printer Color ✅Total Mono ✅Total Color ⬜Total | ✅Nível ✅Estado ✅Erro            | ⬜Tampa aberta ⬜Atolamento ⬜Falta Papel ⬜Falha | ⬜Nome arquivo ⬜Nº pág ⬜Estado trabalho | ⬜Em espera/uso ⬜consumo ⬜tempo ativo |      |
| EPSON: | ⬜ Copier Mono ⬜Copier Color  ⬜Printer Mono ⬜Printer Color ⬜Total Mono ⬜Total Color ⬜Total | ⬜Nível ⬜Estado ⬜Erro            | ⬜Tampa aberta ⬜Atolamento ⬜Falta Papel ⬜Falha | ⬜Nome arquivo ⬜Nº pág ⬜Estado trabalho | ⬜Em espera/uso ⬜consumo ⬜tempo ativo |      |
|        | [script](coletaCounter.ps1)                                  | [script](coletaSuprimentos.ps1) | --                                            | --                                     | --                                   |      |

### Como usar

Com a API rodando no mesmo host(provisoriamente), chame o script passando pelos argumentos u usuário e senha de autenticação na api, por exemplo:

```
./coletaCounter.ps1 <user> <password>
```

### Próximos passos:

- [ ] Refatorar e implementar a busca do padrão de códigos de suprimentos RICOH
- [ ] Refatorar e implementar a busca do padrão de códigos de suprimentos EPSON
- [ ] Organizar código e acertar as convenções de nomes
- [ ] Criar script de erros.
- [ ] Adaptar os scripts para carregar os dados somente com as mudanças de estados

