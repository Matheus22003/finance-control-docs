# Finance Control — Documentação

Documentação central do Finance Control, uma aplicação de controle financeiro
pessoal, dívidas compartilhadas entre pessoas e análise assistida por IA.

## Estado do projeto

A versão estável atual é a `v1.1.0`. O MVP web possui autenticação, finanças,
dívidas, amizades, grupos, notificações in-app, e-mail e Web Push, dashboard e
análise por IA. O ambiente público usa Vercel, ZimaOS, zrok e três PostgreSQL
Neon, com CI, deploy automático, observabilidade e restauração ensaiada.

## Repositórios

| Repositório | Responsabilidade |
|---|---|
| [finance-control-frontend](https://github.com/Matheus22003/finance-control-frontend) | Angular SPA; consome somente o BFF |
| [finance-control-bff](https://github.com/Matheus22003/finance-control-bff) | Autenticação, autorização, agregação, SignalR e IA |
| [finance-control-finance-service](https://github.com/Matheus22003/finance-control-finance-service) | Receitas, despesas, categorias, orçamentos, recorrências e metas |
| [finance-control-debt-service](https://github.com/Matheus22003/finance-control-debt-service) | Pessoas, amizades, grupos, dívidas, pagamentos e liquidação simplificada |
| [finance-control-infra](https://github.com/Matheus22003/finance-control-infra) | Docker Compose, redes, bancos e CI de integração |
| [finance-control-docs](https://github.com/Matheus22003/finance-control-docs) | Arquitetura, operação, qualidade, roadmap e releases |

## Navegação

- [Visão de arquitetura](architecture/overview.md)
- [Decisões e regras arquiteturais](architecture/decisions.md)
- [ADR 0001 — Staging com custo zero](architecture/adr/0001-staging-platform.md)
- [ADR 0002 — Staging público com Vercel e ZimaOS](architecture/adr/0002-zimaos-vercel-staging.md)
- [ADR 0003 — Notificações multicanal](architecture/adr/0003-multichannel-notifications.md)
- [Arquitetura de notificações](architecture/notifications.md)
- [Contratos de API](api/README.md)
- [Execução local](development/local-setup.md)
- [Git Flow e implantação](development/deployment-flow.md)
- [Plano de implantação do staging com custo zero](development/staging-rollout.md)
- [Estratégia de testes](quality/testing.md)
- [Runbook operacional](operations/runbook.md)
- [Guia do servidor ZimaOS](operations/zimaos-guide.md)
- [Observabilidade](operations/observability.md)
- [Backup e restauração](operations/backup-restore.md)
- [Guia para entrevistas e demonstrações](portfolio/interview-guide.md)
- [Checklist da versão 0.1.0](releases/v0.1.0.md)
- [Checklist da versão 1.0.0-mvp](releases/v1.0.0-mvp.md)
- [Release 1.1.0 — Notificações completas](releases/v1.1.0.md)
- [Roadmap](ROADMAP.md)
- [Changelog](CHANGELOG.md)

## Stack do MVP

- Angular `22.1.0`, TypeScript `6.0.2` e Node.js `26.4.0`;
- .NET SDK `10.0.301` e runtime ASP.NET Core `10.0.10`;
- Java `21`, Spring Boot `4.0.3` e Maven `3.9.12`;
- PostgreSQL `17.10` com um banco exclusivo por serviço;
- Docker Compose, OpenAPI `3.1`, Swagger UI, Scalar e Playwright `1.62.1`.

## Início rápido

Com os seis repositórios lado a lado:

```powershell
Set-Location ..\finance-control-infra
Copy-Item .env.example .env
docker compose config --quiet
docker compose up --build --detach --wait
```

A aplicação estará em `http://localhost:4200`, o BFF em
`http://localhost:8080` e o Mailpit em `http://localhost:8025`.

Credenciais demonstrativas:

```text
demo@financecontrol.local
ChangeMe123!
```

Consulte [Execução local](development/local-setup.md) para configuração da IA,
testes e encerramento seguro do ambiente.
