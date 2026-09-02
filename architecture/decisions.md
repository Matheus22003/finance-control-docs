# Decisões e regras arquiteturais

## Regras permanentes

1. O Angular fala somente com o BFF.
2. O BFF é o único ponto de autenticação, autorização, agregação e acesso à IA.
3. Cada serviço possui seu próprio PostgreSQL e não acessa bancos de outros
   domínios.
4. APIs de negócio usam versionamento por URL em `/api/v1`.
5. Erros HTTP do BFF usam ProblemDetails compatível com RFC 7807.
6. Novos serviços entram com Dockerfile e integração ao Compose desde o início.
7. Contratos OpenAPI versionados são protegidos contra breaking changes no CI.
8. Mudanças de arquitetura exigem decisão explícita antes da implementação.

## Decisões de staging

- [ADR 0001 — Plataforma de staging com custo zero](adr/0001-staging-platform.md):
  substituído depois que não houve capacidade OCI Always Free disponível.
- [ADR 0002 — Staging público com Vercel e ZimaOS](adr/0002-zimaos-vercel-staging.md):
  aprovado em 25 de agosto de 2026. Define Vercel para a SPA, ZimaOS e zrok
  para os backends, três Neon independentes e observabilidade local.

## Decisão de notificações

- [ADR 0003 — Notificações multicanal controladas pelo BFF](adr/0003-multichannel-notifications.md):
  aprovado em 26 de agosto de 2026. Define persistência e preferências no BFF,
  SignalR como dica de atualização, Web Push para navegadores e adaptadores
  futuros para APNs/FCM sem acesso direto dos clientes a provedores.

## Decisão de superfícies de cliente

- [ADR 0004 — Web desktop-first e aplicativo móvel futuro](adr/0004-desktop-first-web-mobile-future.md):
  aprovado em 2 de setembro de 2026. Define a SPA como superfície principal em
  desktop, preserva o navegador móvel como fallback seguro e adia a criação do
  aplicativo até uma decisão explícita de escopo e tecnologia.

## Autenticação e endpoints anônimos

### Decisão aprovada para a v0.1.0

Em 13 de agosto de 2026 foi aprovada uma exceção controlada à regra original,
que declarava apenas `/health` e `/api/v1/auth/login` como anônimos. O ciclo de
conta também permite anonimamente as rotas necessárias para criar a conta,
renovar a sessão, confirmar e-mail e recuperar senha:

- `POST /api/v1/auth/register`;
- `POST /api/v1/auth/refresh`;
- `POST /api/v1/auth/confirm-email`;
- `POST /api/v1/auth/resend-confirmation`;
- `POST /api/v1/auth/forgot-password`;
- `POST /api/v1/auth/reset-password`.

Essas rotas não dão acesso a dados financeiros. Elas usam respostas neutras
contra enumeração de contas, tokens temporários ou refresh token rotativo,
rate limiting e validação de entrada. Todo endpoint de perfil, finanças,
dívidas, amizades, grupos, notificações e IA permanece protegido por JWT.

Essa lista é fechada. Qualquer nova rota anônima exige outra decisão explícita.
Proteger cadastro, refresh, confirmação e recuperação com JWT tornaria esses
fluxos impossíveis; por isso a exceção preserva o ciclo de conta sem ampliar o
acesso a dados de negócio.

## Autenticação entre BFF e microserviços

Finance e Debt não emitem JWT. No ambiente integrado eles recebem o identificador
do usuário somente do BFF e permanecem em rede interna não publicada. Um futuro
deploy deve manter essa topologia e adicionar autenticação de serviço ou rede
privada equivalente antes de expor qualquer microserviço fora do cluster.

## Contratos

O Frontend consome contratos do BFF. Os contratos internos de Finance e Debt são
detalhes de integração e podem evoluir sem expor o microserviço ao cliente. Cada
API mantém um snapshot `openapi/openapi-v1.json`; PRs bloqueiam alterações
incompatíveis.

## Dados e exclusão de conta

O BFF coordena a exclusão: consulta pendências no Debt Service, apaga dados
privados nos serviços de domínio e remove a identidade por último. Dívidas e
pagamentos pendentes, liquidações ativas e grupos administrados bloqueiam a
operação para preservar integridade entre usuários.
