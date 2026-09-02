# ADR 0004 — Web desktop-first e aplicativo móvel futuro

- Status: aceito
- Data: 2 de setembro de 2026
- Escopo: produto web atual e evolução mobile futura

## Contexto

O Finance Control é usado como aplicação web de portfólio e operação pessoal.
O produto não pretende oferecer uma experiência web móvel completa: o uso em
celular deve ocorrer por um aplicativo dedicado em uma fase futura. Tratar a
SPA atual como um produto mobile completo dividiria o esforço entre duas
experiências de uso sem uma decisão de tecnologia, distribuição ou suporte para
o aplicativo.

Ao mesmo tempo, bloquear ou degradar deliberadamente o navegador móvel não
aumenta a segurança e prejudica acessos ocasionais, links de recuperação de
conta e a evolução gradual do produto.

## Decisão

- a SPA Angular é o produto web **desktop-first**;
- as prioridades de UX, testes visuais e acessibilidade web concentram-se em
  resoluções de computador, teclado, foco, contraste e leitores de tela;
- o layout responsivo existente permanece como fallback seguro para navegadores
  móveis, sem compromisso de paridade funcional ou evolução de UX mobile;
- não haverá bloqueio por user agent, redirecionamento obrigatório nem coleta
  adicional de dados para distinguir dispositivos;
- um aplicativo iOS/Android será uma frente futura, iniciada somente após uma
  decisão explícita de escopo e tecnologia;
- web e futuro aplicativo consomem exclusivamente o BFF em `/api/v1`; o
  aplicativo não acessará microserviços, bancos ou provedores de notificação
  diretamente.

## Consequências positivas

- a experiência web recebe uma direção clara para o uso principal em desktop;
- o investimento em app nativo não é antecipado sem objetivo e escopo definidos;
- a regra BFF-first e os contratos de negócio permanecem reutilizáveis;
- a página ainda se comporta de forma segura em navegadores móveis ocasionais.

## Consequências negativas

- não há promessa de experiência otimizada para smartphone no navegador;
- a equipe precisará criar e manter um cliente adicional quando a fase mobile
  for aprovada;
- push nativo, armazenamento seguro no dispositivo e distribuição por lojas
  continuam pendentes para essa fase.

## Critérios para abrir a fase mobile

Antes de implementar o aplicativo, registrar uma decisão de tecnologia e
escopo que cubra pelo menos: plataformas iniciais, fluxo mínimo, sessões por
dispositivo, armazenamento seguro de credenciais, contratos do BFF, estratégia
de push APNs/FCM e testes de contrato compartilhados.

## Alternativas rejeitadas

| Alternativa | Motivo |
|---|---|
| Investir agora em paridade de mobile web | conflita com a intenção de oferecer o produto móvel como aplicativo dedicado |
| Bloquear o site em celular | não traz segurança e piora acessos excepcionais e fluxos de conta |
| Criar o app antes de definir escopo e tecnologia | cria uma nova superfície sem necessidade imediata e sem critérios de suporte |
