# Estratégia de qualidade

## Pirâmide de testes

### Testes de serviço

- BFF: xUnit com host ASP.NET Core em memória, autenticação, integrações,
  ProblemDetails, rate limiting e snapshot OpenAPI;
- Debt Service: xUnit com regras de domínio, persistência e endpoints;
- Finance Service: Spring Boot Test, H2 em compatibilidade PostgreSQL e as mesmas
  migrations Flyway usadas no PostgreSQL;
- Frontend: Vitest para componentes, serviços, sessão e estados de interface.

### Contratos

BFF, Finance e Debt versionam `openapi/openapi-v1.json`. O CI:

1. valida o JSON;
2. gera o contrato atual a partir da aplicação;
3. compara o snapshot;
4. bloqueia breaking changes contra a branch base.

### E2E

A suíte Playwright possui 11 cenários no Chromium contra um stack Docker
descartável. A cobertura inclui:

- autenticação, validações e restauração de sessão;
- receitas, despesas e categorias personalizadas;
- orçamento, metas e recorrências;
- dashboard agregado, análise e perguntas à IA Mock;
- amizade e grupos;
- criação de dívida compartilhada e edição dos participantes;
- pagamento simplificado e confirmação entre duas contas;
- regressão visual de espaçamento na tela social.

Em falhas, o CI publica relatório HTML, trace, screenshot, vídeo e logs do Docker
Compose por sete dias.

### Notificações multicanal

A v1.1.0 cobre o catálogo de 24 eventos e as preferências por sistema, push e
e-mail em testes automatizados do BFF e frontend. A validação manual pública
também confirmou:

- permissão e cadastro de um navegador Edge no Windows;
- dispositivo persistido e listado na tela de conta;
- evento social real criado por uma segunda conta;
- atualização da central in-app;
- aceitação HTTP `201` pelo push service;
- recebimento da notificação pelo sistema operacional.

Web Push exige navegador real e permissão do usuário; por isso a confirmação no
sistema operacional complementa, mas não substitui, a suíte determinística.

## Comandos

```powershell
# BFF
dotnet restore FinanceControl.Bff.sln --locked-mode
dotnet test FinanceControl.Bff.sln --configuration Release --no-restore

# Debt Service
dotnet restore FinanceControl.DebtService.sln --locked-mode
dotnet test FinanceControl.DebtService.sln --configuration Release --no-restore

# Finance Service
mvn --batch-mode --no-transfer-progress clean verify

# Frontend
npm ci --ignore-scripts
npm test
npm run build
npm audit
npm run test:e2e:isolated

# Infra
docker compose --env-file .env.example config --quiet
```

## Critérios de merge para `main`

- working tree limpa e commit rastreável;
- CI do repositório concluído com sucesso;
- contrato OpenAPI compatível quando aplicável;
- CI integrado da Infra concluído com os 11 E2E;
- documentação e changelog atualizados;
- decisão arquitetural pendente da release resolvida.

Consulte o [fluxo de implantação](../development/deployment-flow.md) para a
promoção entre `develop`, preview e produção.
