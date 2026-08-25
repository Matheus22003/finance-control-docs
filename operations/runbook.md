# Runbook operacional

Este guia indica onde cada componente fica, como verificar o ambiente e como
agir nas ocorrências mais comuns. Os comandos partem do repositório
`finance-control-infra` em um computador já configurado pelo
`Initialize-ZimaOsAccess.ps1`.

## Mapa do ambiente

| Camada | Local | Responsabilidade | Como observar |
|---|---|---|---|
| Frontend | Vercel | SPA Angular e rewrite de `/api/*` | dashboard da Vercel e Uptime Kuma |
| Entrada da API | zrok + Caddy | túnel HTTPS e proxy exclusivo do BFF | `PublicStatus` e logs do `edge` |
| BFF | Docker no ZimaOS | autenticação, agregação, SignalR e IA | Beszel, `Health` e logs do `bff` |
| Finance | Docker no ZimaOS | domínio financeiro | Beszel e logs do `finance-service` |
| Debt | Docker no ZimaOS | domínio de dívidas e social | Beszel e logs do `debt-service` |
| Bancos | três projetos Neon | persistência exclusiva por serviço | console Neon de cada projeto |
| E-mail | Brevo | confirmação e recuperação | logs transacionais do Brevo |
| IA | Groq | respostas abertas sanitizadas pelo BFF | métricas do Groq e logs do BFF |
| Métricas | Beszel no ZimaOS | CPU, RAM, disco, containers e `systemd` | atalho Beszel na Home do ZimaOS |
| Disponibilidade | Uptime Kuma no ZimaOS | frontend, BFF e heartbeat do Beszel | atalho Uptime Kuma na Home |
| Backups | disco do ZimaOS | dumps, volumes e ensaio de restauração | `BackupStatus` e `BackupLogs` |

## Onde ficam os arquivos

| Caminho | Conteúdo |
|---|---|
| `finance-control-infra/compose.zimaos.yml` | aplicação, túnel, redes e limites |
| `finance-control-infra/compose.observability.yml` | Beszel, socket proxy e Uptime Kuma |
| `finance-control-infra/deploy/zimaos/` | Caddy, atualização automática, backup e atalhos |
| `finance-control-infra/tools/Invoke-ZimaOsFinanceControl.ps1` | operações remotas permitidas |
| `%USERPROFILE%/.finance-control/` | chave SSH, known hosts e credencial sudo protegida por DPAPI |
| `/DATA/AppData/finance-control/` no ZimaOS | Compose, ambientes ignorados e scripts instalados |
| `/DATA/AppData/finance-control/backups/` no ZimaOS | sete backups completos mais recentes |

Arquivos `.env*`, chaves, tokens, connection strings e URLs Push nunca entram no
Git. O cofre local DPAPI não deve ser copiado para outro computador.

## Ver os servidores rodando

### Pela interface do ZimaOS

1. abra a Home do ZimaOS pelo endereço LAN;
2. use **Beszel** para CPU, memória, disco, containers e o timer de deploy;
3. use **Uptime Kuma** para disponibilidade do frontend, BFF e heartbeat;
4. abra a área de aplicativos do ZimaOS somente para inspeção geral. Mudanças
   da stack devem ser feitas pelos arquivos versionados e pelo helper.

### Pelo terminal seguro

```powershell
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Status
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Health
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action PublicStatus
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action ObservabilityStatus
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action ObservabilityHealth
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action AutoDeployStatus
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action BackupStatus
```

Um ambiente saudável apresenta containers `healthy`, `edge_health=ok`, túnel
ativo, timers `enabled/active` e o último backup com
`latest_restore_verification=ok`.

## Logs e correlação

```powershell
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Logs -Service bff -Tail 200
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Logs -Service finance-service -Tail 200
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Logs -Service debt-service -Tail 200
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Logs -Service edge -Tail 200
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action AutoDeployLogs -Tail 200
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action ObservabilityLogs -Tail 200
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action BackupLogs -Tail 200
```

Para seguir uma requisição entre serviços, copie o `X-Correlation-ID` da
resposta e procure o mesmo UUID nos logs do BFF, Finance e Debt. Nunca publique
o conteúdo integral dos logs sem revisar dados operacionais.

## Fluxo de deploy

1. uma mudança entra em `develop` por pull request protegido;
2. o CI do serviço executa testes e publica no GHCR a imagem `develop` e a tag
   imutável do commit;
3. o timer do ZimaOS consulta novas imagens a cada cinco minutos;
4. quando há alteração, ele mantém as imagens anteriores, atualiza os três
   serviços e aguarda health checks;
5. falhas causam rollback e quarentena da combinação defeituosa;
6. merges do frontend em `develop` são publicados pela Vercel;
7. uma release estável promove `develop` para `main` e recebe uma tag `v*`.

Verificação ou atualização manual:

```powershell
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action RunAutoDeploy
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action AutoDeployStatus
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Health
```

## Diagnóstico rápido

### Site abre, mas login ou API falha

1. execute `PublicStatus`;
2. execute `Health`;
3. consulte logs de `edge` e `bff`;
4. confirme no Uptime Kuma se o BFF está indisponível;
5. não abra portas no roteador como correção.

### Um domínio retorna erro

1. use o `X-Correlation-ID` para identificar Finance ou Debt;
2. consulte o container correspondente no Beszel;
3. veja os logs do serviço;
4. confirme o projeto Neon exclusivo daquele serviço;
5. não troque connection strings entre serviços.

### Deploy automático falha

1. execute `AutoDeployStatus` e `AutoDeployLogs`;
2. confirme que o rollback deixou `Health` aprovado;
3. corrija o código e publique uma nova imagem por PR;
4. não remova a quarentena nem force tags manualmente sem entender a falha.

### ZimaOS reinicia

Os containers usam `restart: unless-stopped`, o zrok persiste sua identidade e
os timers usam `Persistent=true`. Depois do boot, valide `Health`,
`PublicStatus`, `ObservabilityHealth`, `AutoDeployStatus` e `BackupStatus`.

## Manutenção segura

- nunca execute `docker compose down --volumes` no staging;
- nunca exponha Finance, Debt, bancos, Beszel, Kuma ou a WebUI pelo zrok;
- sincronize arquivos somente pelos helpers previstos;
- mantenha cada serviço conectado ao seu próprio Neon;
- antes de uma mudança de alto risco, execute `RunBackup` e confira
  `latest_restore_verification=ok`;
- atualize este runbook quando nomes, caminhos ou provedores mudarem.
