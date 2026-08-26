# Contratos de API

## Regra de consumo

Clientes web e mobile consomem somente o BFF. Finance Service e Debt Service são
APIs internas, acessíveis apenas pelo BFF na rede de serviços.

## OpenAPI versionado

| API | Snapshot | Escopo atual |
|---|---|---:|
| BFF | [openapi-v1.json](https://github.com/Matheus22003/finance-control-bff/blob/develop/openapi/openapi-v1.json) | 79 caminhos |
| Finance Service | [openapi-v1.json](https://github.com/Matheus22003/finance-control-finance-service/blob/develop/openapi/openapi-v1.json) | 19 caminhos |
| Debt Service | [openapi-v1.json](https://github.com/Matheus22003/finance-control-debt-service/blob/develop/openapi/openapi-v1.json) | 32 caminhos |

Os snapshots são validados sintaticamente e comparados com a branch base pelo
CI. Remoção de operação, redução de contrato ou outra quebra incompatível falha
antes do merge.

## Grupos do BFF

| Grupo | Prefixo |
|---|---|
| Autenticação e sessões | `/api/v1/auth` |
| Conta e perfil | `/api/v1/users` |
| Dashboard | `/api/v1/dashboard` |
| Finanças | `/api/v1/finance` |
| Pessoas e dívidas | `/api/v1/people`, `/api/v1/debts` |
| Amigos e grupos | `/api/v1/friends`, `/api/v1/groups` |
| Notificações | `/api/v1/notifications` |
| IA | `/api/v1/ai` |

## Documentação interativa

Em `Development`, as três APIs disponibilizam documento OpenAPI e viewers. No
BFF essas rotas exigem autenticação:

- BFF: `/openapi/v1.json`, `/scalar/v1` e `/swagger`;
- Finance Service: `/openapi/v1.json` e `/swagger`;
- Debt Service: `/openapi/v1.json`, `/scalar/v1` e `/swagger`.

No Compose integrado os viewers dos microserviços não são publicados no host.
Isso mantém a regra de que o BFF é a única API externa.

## Erros e rastreabilidade

O BFF converte falhas próprias e dos serviços em ProblemDetails. Respostas
incluem `correlationId` e `traceId`; o header `X-Correlation-ID` permite buscar a
operação nos logs do BFF, Finance e Debt.

Mapeamento de integração:

- `400`, `404`, `409` e `422`: erro de entrada ou regra de negócio;
- `502`: resposta inválida do serviço ou provider;
- `503`: dependência indisponível ou rate limit externo;
- `504`: timeout de dependência.
