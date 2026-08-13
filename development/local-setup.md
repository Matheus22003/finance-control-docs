# Execução local

## Pré-requisitos

- Docker Desktop com Docker Compose;
- Git;
- Node.js `26.4.0` e npm `11.17.0` para executar o Angular fora do container;
- .NET SDK `10.0.301` para executar ou testar BFF e Debt fora do container;
- Java `21` e Maven `3.9.12` para executar ou testar Finance fora do container.

## Estrutura de diretórios

Os repositórios devem ficar lado a lado:

```text
finance-control-docs/
finance-control-frontend/
finance-control-bff/
finance-control-finance-service/
finance-control-debt-service/
finance-control-infra/
```

## Subir o stack completo

```powershell
Set-Location finance-control-infra
Copy-Item .env.example .env
docker compose config --quiet
docker compose up --build --detach --wait
docker compose ps
```

Serviços publicados:

| Recurso | URL |
|---|---|
| Aplicação | `http://localhost:4200` |
| Health do frontend | `http://localhost:4200/health` |
| Health do BFF | `http://localhost:8080/health` |
| Mailpit | `http://localhost:8025` |

Finance, Debt e os três PostgreSQL não publicam portas no host.

## Contas demonstrativas

```text
demo@financecontrol.local / ChangeMe123!
friend@financecontrol.local / ChangeMe123!
```

A segunda conta permite testar amizade, grupos, dívidas compartilhadas e
confirmação de pagamentos.

## IA

O padrão local é determinístico e não exige chave:

```text
AI_PROVIDER=Mock
```

Para usar Groq, altere somente o `.env` local, nunca o `.env.example`:

```text
AI_PROVIDER=OpenAiCompatible
AI_BASE_URL=https://api.groq.com/openai/v1/
AI_API_KEY=sua-chave
AI_MODEL=llama-3.1-8b-instant
```

Depois reconstrua o BFF:

```powershell
docker compose up --detach --build --wait bff
```

## Logs correlacionados

```powershell
docker compose logs --follow frontend bff finance-service debt-service
docker compose logs bff finance-service debt-service |
  Select-String "UUID_RETORNADO_EM_X_CORRELATION_ID"
```

## Testes integrados isolados

```powershell
Set-Location ..\finance-control-frontend
npm ci --ignore-scripts
npm exec playwright install chromium
npm run test:e2e:isolated
```

O comando usa portas `4280`, `8180` e `8125`, bancos próprios e provider de IA
Mock. Containers, redes e volumes temporários são removidos ao final.

## Encerrar

Preservar dados:

```powershell
Set-Location ..\finance-control-infra
docker compose down
```

Apagar também os bancos locais:

```powershell
docker compose down --volumes
```

O segundo comando é destrutivo e deve ser usado apenas quando a perda dos dados
locais for intencional.
