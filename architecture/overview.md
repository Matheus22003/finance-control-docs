# Visão de arquitetura

## Contexto

O Finance Control separa interface, identidade/agregação e domínios de negócio.
O Angular nunca acessa microserviços ou bancos diretamente. O BFF é a única API
exposta à aplicação e o único componente que emite e valida JWT.

```mermaid
flowchart LR
    Web["Angular SPA"] -->|"HTTPS /api/v1"| BFF["BFF .NET 10"]
    Mobile["Futuros apps iOS/Android"] -.->|"HTTPS /api/v1"| BFF
    BFF -->|"HTTP tipado"| Finance["Finance Service\nJava 21"]
    BFF -->|"HTTP tipado"| Debt["Debt Service\n.NET 10"]
    BFF -->|"OpenAI-compatible API"| AI["Groq ou provider configurável"]
    BFF --> BffDb[("PostgreSQL BFF")]
    Finance --> FinanceDb[("PostgreSQL Finance")]
    Debt --> DebtDb[("PostgreSQL Debt")]
```

## Responsabilidades

### Frontend

- login, cadastro e ciclo de conta;
- dashboard, finanças, dívidas, pessoas, amizades, grupos e relatórios;
- central de notificações com atualização via SignalR;
- produto web desktop-first, com dark mode e persistência segura da sessão por
  cookies;
- layout responsivo preservado como fallback seguro em navegador móvel, sem
  compromisso de paridade funcional nessa superfície;
- nenhuma chamada direta aos microserviços ou ao provedor de IA.

Os futuros aplicativos iOS/Android serão clientes separados do BFF. A escolha
de tecnologia, o escopo e as garantias de sessão/push serão decididos quando a
fase mobile for aberta; consulte o [ADR 0004](adr/0004-desktop-first-web-mobile-future.md).

### BFF

- ASP.NET Core Identity, JWT de curta duração e refresh token rotativo em cookie
  HttpOnly;
- autorização, rate limiting e respostas ProblemDetails;
- fachadas tipadas para Finance e Debt;
- agregação paralela do dashboard e dos relatórios históricos;
- persistência de perfil, sessões e notificações;
- sanitização, aliases e rate limiting antes de acessar a IA;
- propagação de `X-Correlation-ID` e hub SignalR autenticado.

### Finance Service

- receitas e despesas;
- categorias padrão e personalizadas;
- recorrências, orçamento mensal e resumo por período;
- metas, ledger de aportes e vínculo auditável com receitas;
- tendências e projeção de fluxo de caixa;
- histórico analítico de lançamentos, categorias e maiores despesas;
- schema controlado por Flyway.

### Debt Service

- pessoas locais e usuários vinculados;
- amizade por convite e grupos autorizados;
- dívidas compartilhadas com pagador e participantes independentes;
- pagamentos com confirmação/rejeição;
- histórico da dívida;
- histórico analítico da posição do usuário e categorias de dívida;
- cálculo de transferências simplificadas;
- schema controlado por Entity Framework Core Migrations.

## Redes e persistência

```mermaid
flowchart TB
    subgraph Edge["edge-network"]
        Frontend --> BFF
    end
    subgraph Services["services-network"]
        BFF --> Finance
        BFF --> Debt
    end
    subgraph BffData["bff-data-network"]
        BFF --> BffDb[("BFF DB")]
    end
    subgraph FinanceData["finance-data-network"]
        Finance --> FinanceDb[("Finance DB")]
    end
    subgraph DebtData["debt-data-network"]
        Debt --> DebtDb[("Debt DB")]
    end
```

Nenhum serviço participa da rede de dados de outro domínio. Finance e Debt não
publicam portas no host no Compose integrado.

## Fluxos principais

### Dashboard

O BFF consulta em paralelo resumo, tendências, orçamento, metas e projeção no
Finance Service e a posição consolidada no Debt Service. O Angular recebe um
contrato próprio do BFF.

### Notificações

Eventos de amizades, grupos, dívidas, pagamentos, liquidações, orçamentos e
metas são persistidos no BFF. Preferências globais e por tipo determinam a
entrega in-app, por Web Push ou e-mail. O SignalR apenas avisa que houve mudança;
o cliente sempre relê o estado oficial pelos endpoints REST. Chaves de
deduplicação evitam alertas repetidos após reconexões. Consulte a
[arquitetura de notificações](notifications.md).

### Relatórios

O BFF consulta Finance e Debt em paralelo para formar um contrato histórico
único. Cada domínio calcula suas métricas no próprio banco e o frontend nunca
acessa os serviços internos. A mesma agregação pode ser exportada em CSV pelo
BFF. Consulte [relatórios e histórico analítico](reports.md).

### Inteligência artificial

O BFF calcula respostas factuais determinísticas quando possível. Para perguntas
abertas, remove identificadores e substitui nomes, grupos e descrições por
aliases antes de chamar um provider compatível com OpenAI. O mapa de aliases
nunca sai do BFF e os números exibidos continuam vindo dos serviços de domínio.

## Observabilidade

Cada requisição recebe um UUID em `X-Correlation-ID`. O BFF propaga esse valor
aos microserviços. Logs estruturados registram método, caminho, status e duração,
sem payloads, tokens ou parâmetros financeiros. ProblemDetails inclui
`correlationId` e `traceId`.

## Implantação pública do MVP

A SPA é publicada pela Vercel. Requisições `/api/*` chegam ao Caddy no ZimaOS
por uma share zrok; o Caddy encaminha somente ao BFF. Finance e Debt não têm
porta pública. Os três serviços usam projetos Neon separados. Beszel e Uptime
Kuma ficam somente na LAN, e o backup semanal valida a restauração em recursos
descartáveis.

Consulte o [ADR 0002](adr/0002-zimaos-vercel-staging.md) para a decisão, o
[guia do ZimaOS](../operations/zimaos-guide.md) para entender o host e o
[runbook operacional](../operations/runbook.md) para manutenção.
