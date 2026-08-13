# Roadmap

## v0.1.0 — MVP web

- [x] BFF com autenticação, JWT, sessões e ProblemDetails;
- [x] Finance Service com PostgreSQL e CRUD completo;
- [x] Debt Service com PostgreSQL, participantes e pagamentos;
- [x] amizades e grupos como camada de autorização social;
- [x] liquidação simplificada para reduzir transferências;
- [x] frontend Angular responsivo com dark mode;
- [x] notificações persistentes e SignalR;
- [x] análise e perguntas financeiras via BFF;
- [x] OpenAPI versionado e proteção contra breaking changes;
- [x] CI por repositório e E2E integrado com Docker;
- [x] formalizar endpoints anônimos controlados do ciclo de conta;
- [x] promover `develop` para `main`, criar tags e publicar releases.

## v0.2.0 — Staging público

- selecionar hospedagem e provedor PostgreSQL com três bancos isolados;
- configurar domínio, TLS, secrets e variáveis por ambiente;
- executar migrations como etapa controlada do deploy;
- adicionar backup e teste de restauração;
- configurar observabilidade centralizada, retenção e alertas;
- limitar CORS e forwarded headers aos proxies reais;
- realizar smoke tests após deploy.

## v0.3.0 — Produto e experiência

- push notifications para web e futuros aplicativos;
- preferências de notificação por evento e canal;
- relatórios exportáveis e histórico analítico;
- acessibilidade auditada e testes visuais multi-viewport;
- Buy Me a Coffee sem interferir nos fluxos financeiros.

## Futuro — Aplicativos móveis

- definir tecnologia mobile sem alterar o contrato BFF-first;
- reutilizar login, refresh, REST e eventos de notificação do BFF;
- armazenamento seguro de credenciais no dispositivo;
- push notifications via APNs/FCM;
- testes de contrato compartilhados entre web e mobile.
