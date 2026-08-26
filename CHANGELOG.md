# Changelog

Todas as mudanças relevantes deste repositório são documentadas aqui. O formato
segue Keep a Changelog e o projeto usa versionamento semântico.

## [Unreleased]

### Added

- relatórios históricos agregados de finanças e dívidas;
- exportação CSV pelo BFF e página Angular responsiva em `/reports`;
- métricas por mês e categoria, maiores despesas, maiores dívidas e destaques;
- documentação da arquitetura de relatórios para web e futuros apps móveis.

### Changed

- inventário OpenAPI atualizado para 81 caminhos no BFF, 20 no Finance Service
  e 33 no Debt Service.

## [1.1.0] - 2026-08-26

### Added

- arquitetura e ADR das notificações multicanal;
- catálogo de 24 eventos e preferências por sistema, push e e-mail;
- Web Push com dispositivos, VAPID, limpeza de subscriptions e validação real;
- guia completo do ZimaOS e inventário de operações seguras;
- documentação de Git Flow, preview, produção e rollback;
- guia de observabilidade com Beszel, Uptime Kuma e correlation ID;
- roteiro técnico para entrevistas e demonstrações;
- documento coordenado da release `v1.1.0`.

### Changed

- inventário OpenAPI do BFF atualizado de 74 para 79 caminhos;
- fluxo da Vercel esclarecido: `develop` gera preview e `main` gera produção;
- plano OCI marcado como histórico após adoção do ZimaOS.

## [1.0.0-mvp] - 2026-08-25

### Added

- runbook operacional com mapa de componentes, comandos e diagnóstico;
- documentação de backup, restauração e limitações de resiliência;
- ADR 0002 para Vercel, ZimaOS, zrok, Neon e observabilidade local;
- checklist coordenado da release `v1.0.0-mvp`;
- ADR aceito para staging da v0.2.0 com custo financeiro máximo zero;
- comparação atualizada de provedores, custos e limitações de free tier;
- topologia Cloudflare Pages/Worker, OCI Ampere A1 e três PostgreSQL Neon;
- plano incremental de deploy, migrations e recuperação da VM.

## [0.1.0] - 2026-08-13

### Added

- documentação central de arquitetura, APIs, execução local e qualidade;
- roadmap de staging, produto e aplicativos móveis;
- checklist coordenado da primeira release;
- inventário dos seis repositórios e contratos OpenAPI.

### Changed

- formalização das rotas anônimas controladas necessárias ao ciclo de conta.

### Released

- promoção coordenada de `develop` para `main` concluída nos seis repositórios;
- tags e GitHub Releases `v0.1.0` publicadas;
- pipelines da `main` e smoke test da stack versionada aprovados.

[Unreleased]: https://github.com/Matheus22003/finance-control-docs/compare/v1.1.0...develop
[1.1.0]: https://github.com/Matheus22003/finance-control-docs/releases/tag/v1.1.0
[1.0.0-mvp]: https://github.com/Matheus22003/finance-control-docs/releases/tag/v1.0.0-mvp
[0.1.0]: https://github.com/Matheus22003/finance-control-docs/releases/tag/v0.1.0
