# Guia para apresentar o Finance Control

## Pitch de 90 segundos

> O Finance Control é uma aplicação full stack de finanças pessoais e dívidas
> compartilhadas. A SPA Angular fala exclusivamente com um BFF em .NET, que
> concentra autenticação, autorização, agregação, notificações e acesso seguro
> à IA. Os domínios Finance, em Java com Spring Boot, e Debt, em .NET, têm APIs e
> bancos PostgreSQL próprios. O sistema trata casos reais de rateio: o pagador
> não precisa participar e os participantes podem ter valores diferentes. Uma
> camada social de amizades e grupos impede adicionar qualquer usuário sem
> autorização. O deploy custa zero: frontend na Vercel, backends Docker num
> ZimaOS ligado 24 horas, túnel zrok e três bancos Neon isolados. O projeto tem
> CI, OpenAPI protegido, E2E, backup com restauração ensaiada, Beszel, Uptime
> Kuma, correlation ID e notificações in-app, e-mail e Web Push.

## Decisões que demonstram engenharia

### Por que BFF?

O cliente recebe contratos adequados à interface, sem conhecer topologia,
credenciais ou detalhes dos microserviços. O BFF coordena dashboard, identidade,
sanitização da IA e canais de notificação. Isso também prepara os futuros apps
móveis para reutilizar a mesma API.

### Por que dois microserviços e três bancos?

Finance e Debt têm regras e ciclos diferentes. Cada um é proprietário de seu
schema; o BFF também tem banco próprio para identidade, sessões, preferências e
notificações. Não existe join entre bancos nem acesso cruzado.

### Por que Java e .NET?

A escolha é deliberadamente poliglota e mostra que o contrato HTTP/OpenAPI
separa os serviços da tecnologia. Java 21/Spring Boot modela Finance; .NET 10
modela BFF e Debt. A diversidade só é aceitável porque CI, containers, logs e
contratos mantêm um padrão operacional comum.

### Como a divisão de dívidas funciona?

Pagador e participantes são conceitos independentes. Assim, alguém pode pagar
por um grupo sem participar, ou participar sem ter pago. O Debt Service registra
histórico e pagamentos; a liquidação simplificada calcula saldos líquidos para
reduzir transferências desnecessárias.

### Como a segurança social funciona?

Um usuário só entra numa dívida quando há relação autorizada por amizade ou
grupo. Convites, aceites e remoções são auditáveis. Isso evita que alguém crie
obrigações para contas aleatórias apenas conhecendo um e-mail.

### Como a IA acessa dados?

Somente pelo BFF. Perguntas factuais são resolvidas deterministicamente quando
possível. Para perguntas abertas, o BFF sanitiza identificadores e troca nomes
por aliases antes de chamar o Groq por uma interface compatível com OpenAI. O
mapa real nunca sai do BFF.

### Como as notificações funcionam?

O BFF persiste o evento e aplica preferências por tipo e canal. SignalR é apenas
um aviso para o cliente reler o REST. Web Push funciona mesmo com a página
fechada; e-mail usa um adaptador do BFF. A arquitetura já prevê APNs e FCM sem
permitir acesso direto dos futuros aplicativos aos provedores.

## Infraestrutura explicada

- **Vercel:** hospeda a SPA; `main` é produção e PRs/`develop` são previews;
- **zrok:** cria o endpoint HTTPS sem abrir portas residenciais;
- **Caddy:** permite somente a entrada necessária no BFF;
- **ZimaOS:** executa Docker 24/7 e elimina custo de compute em nuvem;
- **Neon:** mantém um PostgreSQL separado por serviço;
- **GHCR + timer:** distribui imagens e faz atualização com health check,
  rollback e quarentena;
- **Beszel:** recursos do host e containers;
- **Uptime Kuma:** disponibilidade pública;
- **backups:** dumps e volumes com ensaio automático de restauração.

Terraform foi estudado e preparado para OCI, mas a capacidade Always Free não
estava disponível. A decisão foi substituída conscientemente pelo ZimaOS, e o
ADR histórico preserva o motivo. Isso demonstra adaptação baseada em custo e
restrições reais, não abandono sem registro.

## Demonstração sugerida

1. faça login na aplicação pública;
2. mostre dashboard, finanças e uma categoria personalizada;
3. crie uma dívida entre duas contas e explique pagador versus participantes;
4. mostre amizade/grupo e liquidação simplificada;
5. abra a central e gere uma notificação real;
6. faça uma pergunta contextual à IA;
7. na LAN, mostre Kuma para disponibilidade e Beszel para containers;
8. mostre um PR com CI, contrato OpenAPI e E2E;
9. abra este repositório de documentação e os ADRs.

Nunca exiba arquivos `.env`, connection strings, chaves, tokens ou logs sem
revisão durante a demonstração.

## Perguntas comuns

### “Isso já é produção?”

É um ambiente público de portfólio funcional, com práticas de produção, mas
operado em hardware residencial e serviços gratuitos. Para uso comercial seria
necessário redundância, cópia externa de backup, alertas externos, SLOs e uma
política formal de privacidade.

### “Qual é o maior ponto único de falha?”

O host ZimaOS e sua conexão residencial. Os dados principais ficam no Neon, mas
edge, serviços e backups locais dependem do host. Essa limitação está documentada
e a resiliência externa foi conscientemente deixada para uma fase posterior.

### “Por que não Kubernetes?”

O tamanho atual não justifica a complexidade operacional. Docker Compose,
health checks, redes isoladas e atualização controlada entregam o necessário no
MVP. Kubernetes seria considerado diante de escala, múltiplos nós ou requisitos
fortes de alta disponibilidade.

### “Como evita breaking changes?”

Cada API versiona o snapshot OpenAPI. O CI gera o contrato atual e compara com a
base, bloqueando incompatibilidades. O frontend só consome o BFF; os contratos
internos podem evoluir sem expor os microserviços ao cliente.

### “O que você faria em seguida?”

Prioridades possíveis: relatórios exportáveis, acessibilidade multi-viewport,
aplicativo móvel com APNs/FCM, cópia criptografada de backup fora do host e
alertas externos. A escolha depende do objetivo do próximo ciclo.

## Documentos para aprofundar

- [visão de arquitetura](../architecture/overview.md);
- [decisões arquiteturais](../architecture/decisions.md);
- [notificações](../architecture/notifications.md);
- [Git Flow e deploy](../development/deployment-flow.md);
- [guia do ZimaOS](../operations/zimaos-guide.md);
- [observabilidade](../operations/observability.md);
- [estratégia de qualidade](../quality/testing.md).
