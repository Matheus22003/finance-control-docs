# Plano de implantação do staging com custo zero

Este plano implementa o [ADR 0001](../architecture/adr/0001-staging-platform.md).

> **Documento histórico:** a OCI Always Free não apresentou capacidade para a
> shape planejada. O ADR 0001 foi substituído pelo
> [ADR 0002](../architecture/adr/0002-zimaos-vercel-staging.md). O ambiente atual
> usa Vercel, ZimaOS, zrok e Neon; consulte o
> [guia do ZimaOS](../operations/zimaos-guide.md) e o
> [fluxo de implantação](deployment-flow.md). Os marcos abaixo permanecem para
> registrar o plano avaliado, não como instrução operacional vigente.

## Marco 0 — Contas e trava de custo

- criar a conta Cloudflare Free e conectar o repositório do frontend;
- criar uma conta OCI Free Tier sem promovê-la para Pay As You Go;
- escolher a home region somente após confirmar capacidade A1;
- criar três projetos Neon Free: BFF, Finance e Debt;
- criar conta Brevo Free e validar o remetente;
- criar ou rotacionar a chave Groq usada somente pelo staging;
- não cadastrar forma de pagamento nos provedores que não a exigem.

## Marco 1 — Aplicações prontas

- persistir Data Protection no PostgreSQL do BFF;
- adicionar o transporte Brevo por API HTTPS mantendo SMTP no ambiente local;
- produzir imagens multiarch para BFF, Finance e Debt;
- validar `linux/arm64` no CI;
- manter o frontend usando exclusivamente caminhos relativos `/api/v1`;
- validar que o Worker encaminha REST e SignalR.

## Marco 2 — Infraestrutura OCI

- preencher variáveis Terraform com tenancy, compartment, subnet e image OCIDs;
- criar VCN, subnet pública, regras 80/443 e SSH restrito;
- criar uma VM `VM.Standard.A1.Flex` com 2 OCPUs e 12 GB;
- instalar Docker Engine e Compose pelo cloud-init;
- criar usuário operacional sem senha e sem login root;
- configurar hostname gratuito e TLS no Caddy;
- apontar manualmente um subdomínio DuckDNS ao IPv4 da VM;
- criar `.env.oci` diretamente na VM com permissão `0600`.

## Marco 3 — Neon

- copiar separadamente host, database, user e password de cada projeto;
- exigir TLS nas três conexões;
- testar cada credencial apenas no serviço proprietário;
- executar migrations BFF, Finance e Debt;
- confirmar que nenhuma aplicação consegue acessar o banco de outro domínio.

## Marco 4 — Cloudflare

- criar o Pages project conectado ao GitHub;
- usar `npm run build` e `dist/finance-control-frontend/browser`;
- configurar `BFF_ORIGIN` como URL HTTPS do Caddy;
- criar `ORIGIN_VERIFY_TOKEN` como secret do Worker;
- configurar o mesmo token na VM;
- testar fallback da SPA, assets, REST, cookie de refresh e WebSocket.

## Marco 5 — Publicação

- publicar imagens versionadas no GHCR;
- tornar públicos os três packages GHCR depois da primeira publicação;
- informar as referências exatas das três imagens em `.env.oci`;
- executar `docker compose config --quiet`;
- subir Caddy, BFF, Finance e Debt;
- validar `/health` e o fluxo completo pelo endereço do Pages;
- registrar os digests e a versão implantada.

## Marco 6 — Smoke test

- cadastro e confirmação de e-mail;
- login, refresh, logout e recuperação de senha;
- receitas, despesas, categorias, orçamento, metas e recorrências;
- amizades, grupos, dívidas, participantes e pagamento simplificado;
- atualização dinâmica por SignalR;
- análise resumida e perguntas à IA;
- correlação de logs entre BFF, Finance e Debt.

## Marco 7 — Recuperação

- documentar recriação da VM pelo Terraform;
- recriar containers somente pelas imagens versionadas;
- validar que usuários, sessões e Data Protection permanecem no Neon;
- rotacionar origin secret e credenciais se a VM for comprometida;
- ensaiar a recuperação antes de divulgar o staging no portfólio.

## Critérios de conclusão

O staging estará pronto quando:

- todas as contas continuarem nos planos gratuitos;
- não houver método de cobrança automática habilitado;
- o Angular acessar somente `/api/v1` no próprio domínio;
- somente Caddy possuir portas públicas na VM;
- Finance e Debt aceitarem apenas JWT encaminhado pelo BFF;
- os três projetos Neon estiverem isolados e com migrations aplicadas;
- refresh e links de segurança sobreviverem ao reinício do BFF;
- SignalR funcionar através do Worker e do Caddy;
- os smoke tests passarem sem secrets em repositórios, imagens ou logs.
