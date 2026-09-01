# Manual operacional

Este é o ponto de partida para operar, demonstrar e dar manutenção no Finance
Control. Ele não substitui os runbooks detalhados: organiza a primeira decisão
e direciona para o procedimento correto, sem expor endereços privados,
credenciais ou segredos.

## Em cinco minutos

1. Abra o frontend público e faça login; confirme dashboard e relatórios.
2. Na rede local, abra o **Uptime Kuma** pela Home do ZimaOS para confirmar a
   disponibilidade do frontend e do BFF.
3. Abra o **Beszel** pela Home para conferir CPU, memória, disco, containers e
   timers do host.
4. Caso algum indicador esteja vermelho, execute no repositório
   `finance-control-infra`:

```powershell
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action Health
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action PublicStatus
pwsh -File .\tools\Invoke-ZimaOsFinanceControl.ps1 -Action ObservabilityHealth
```

Um ambiente saudável tem containers `healthy`, `edge_health=ok`, túnel público
ativo e monitores verdes. Se não for o caso, siga o [diagnóstico por
sintoma](#diagnóstico-por-sintoma) antes de reiniciar ou alterar qualquer coisa.

## Quem faz o quê

| Camada | Hospedagem | Responsabilidade | Primeiro lugar para olhar |
|---|---|---|---|
| Frontend | Vercel | SPA Angular e proxy `/api/*` | Vercel e Uptime Kuma |
| Entrada pública | zrok + Caddy | HTTPS e entrada exclusiva do BFF | `PublicStatus` e logs do `edge` |
| BFF | Docker no ZimaOS | autenticação, agregação, SignalR, IA e notificações | Beszel, `Health` e logs do `bff` |
| Finance e Debt | Docker no ZimaOS | regras de finanças e dívidas/social | Beszel e logs do serviço afetado |
| Dados | Neon | PostgreSQL isolado por serviço | console do projeto correspondente |
| E-mail e IA | Brevo e Groq | entrega transacional e IA sanitizada | BFF e painéis dos provedores |
| Monitoramento | Beszel + Uptime Kuma, na LAN | saúde do host e disponibilidade pública | atalhos na Home do ZimaOS |

O navegador fala somente com o BFF. Finance, Debt, bancos e painéis
administrativos não são públicos.

## Rotina recomendada

| Frequência | Faça | Evidência esperada |
|---|---|---|
| Após deploy | `Health`, smoke test público e console do frontend | serviços saudáveis e nenhum erro novo |
| Semanal | `BackupStatus`, `VerifyLatestBackup`, disco e Kuma | restauração verificada e espaço disponível |
| Mensal | imagens, dependências, acessos e retenção | atualizações planejadas, sem segredo exposto |
| Após reinício do host | status, túnel, observabilidade e backup | timers ativos e frontend acessível |

Os comandos e detalhes de cada rotina estão no [runbook](runbook.md) e no
[guia do ZimaOS](zimaos-guide.md).

## Diagnóstico por sintoma

| Sintoma | Primeiro passo | Próximo documento |
|---|---|---|
| Frontend abre, mas login/API falha | `PublicStatus`, `Health` e logs do `edge`/`bff` | [Runbook](runbook.md#site-abre-mas-login-ou-api-falha) |
| Uma tela mostra erro de domínio | copie `X-Correlation-ID` e veja o serviço correspondente | [Observabilidade](observability.md#correlation-id) |
| Container não está saudável | Beszel, `Status` e logs do container | [Guia ZimaOS](zimaos-guide.md#consultar-logs) |
| Deploy não atualizou | `AutoDeployStatus` e `AutoDeployLogs` | [Runbook](runbook.md#deploy-automático-falha) |
| Notificações não chegam | confira central, preferências, console e BFF | [Notificações](../architecture/notifications.md#diagnóstico-em-produção) |
| Monitor acusa indisponibilidade | Kuma, depois `PublicStatus` e `Health` | [Observabilidade](observability.md#fluxo-de-diagnóstico) |
| Dúvida sobre backup | `BackupStatus` e `VerifyLatestBackup` | [Backup e restauração](backup-restore.md) |

Não corrija incidentes abrindo portas no roteador, expondo um microserviço ou
executando `docker compose down --volumes`.

## Deploy e rollback, em alto nível

```text
feature/* ou fix/* → PR com CI → develop → validação
develop → PR release/* → main → Vercel Production
backends em develop → GHCR → timer ZimaOS → health check/rollback
```

- Use `feature/`, `fix/`, `release/`, `hotfix/`, `docs/` ou `chore/` conforme
  o [Git Flow](../development/deployment-flow.md).
- O frontend é publicado pela Vercel quando `main` recebe a release.
- Os backends acompanham imagens `develop` no ZimaOS, com atualização
  automática a cada cinco minutos, health check, rollback e quarentena.
- Para uma intervenção segura, use somente os helpers versionados. Não altere
  tags, Compose ou variáveis diretamente no host sem registrar a mudança.

## Notificações em produção

O frontend usa SignalR apenas como aviso: a central continua lendo o estado
oficial no REST do BFF. Na Vercel, o cliente usa **Long Polling** pelo caminho
relativo `/api/v1/notifications/hub`; o rewrite `/api/*` encaminha ao BFF por
zrok com o cabeçalho necessário para o túnel. Em desenvolvimento e Nginx, o
hub também permanece relativo, com os transports padrão.

Smoke test manual, sem editar dados reais:

1. abra a aplicação em uma sessão autenticada;
2. confirme que o console não registra falha de negociação do hub;
3. em uma segunda conta, execute uma ação social, ou use uma ação de domínio
   controlada em conta de teste;
4. confirme que o contador e a central atualizam sem recarregar;
5. valide o evento persistido pela central e as preferências em **Minha conta**.

Para testes que criem lançamentos, orçamento ou conta temporária, registre o
que foi criado e remova apenas depois de confirmar que não é dado real.

## Checklist para uma demonstração ou entrevista

1. Abra o frontend e mostre login, dashboard, relatório e central de
   notificações.
2. Explique que Angular acessa somente o BFF e que cada domínio tem banco
   próprio.
3. Na LAN, mostre Kuma para disponibilidade e Beszel para recursos do host.
4. Abra um PR com checks verdes para ilustrar Git Flow, CI e release.
5. Explique zrok, Caddy e ZimaOS: túnel sem porta residencial, proxy controlado
   e computação local 24/7.
6. Mostre esta documentação, um ADR e o [guia de entrevista](../portfolio/interview-guide.md).

Nunca mostre `.env`, dashboards de provedores com segredos, connection strings,
tokens, chaves privadas ou logs sem revisão.

## Limites atuais e próximos investimentos

O ambiente é público e funcional, mas depende de um único host residencial e
de sua conexão. Backups locais com restauração ensaiada não substituem cópia
externa criptografada. Alertas externos, redundância e SLOs continuam como uma
etapa futura deliberada; consulte o [roadmap](../ROADMAP.md) antes de ampliar a
arquitetura.

## Referências detalhadas

- [Runbook operacional](runbook.md)
- [Guia do servidor ZimaOS](zimaos-guide.md)
- [Observabilidade](observability.md)
- [Backup e restauração](backup-restore.md)
- [Git Flow e implantação](../development/deployment-flow.md)
- [Arquitetura de notificações](../architecture/notifications.md)
