# ADR 0003 — Notificações multicanal controladas pelo BFF

- Status: aceito
- Data: 26 de agosto de 2026
- Escopo: v1.1.0

## Contexto

O MVP já possuía notificações persistentes e atualização de tela por SignalR,
mas precisava avisar o usuário com o site fechado e preparar o mesmo contrato
para os futuros aplicativos iOS e Android. Permitir que cada cliente chamasse
Brevo, Web Push, APNs ou FCM diretamente quebraria o BFF-first, duplicaria
regras de preferência e exporia credenciais de provedores.

## Decisão

- o BFF mantém o catálogo único de eventos e as preferências por canal;
- toda notificação é persistida antes das tentativas externas;
- SignalR continua sendo apenas um aviso para reler o estado por REST;
- Web Push usa VAPID e inscrições vinculadas ao usuário autenticado;
- e-mail usa o remetente de aplicação já abstraído pelo BFF;
- falhas externas não desfazem a ação de domínio que originou o evento;
- inscrições expiradas são removidas após respostas `404` ou `410`;
- o frontend recebe somente a chave VAPID pública;
- futuros APNs e FCM serão adaptadores do dispatcher, nunca integrações diretas
  dos aplicativos com regras de negócio.

## Consequências positivas

- preferências consistentes entre web e futuros aplicativos;
- nenhuma credencial de entrega entra nos clientes;
- eventos continuam auditáveis mesmo quando um provedor está indisponível;
- múltiplos dispositivos podem ser gerenciados pela mesma conta;
- a arquitetura permanece compatível com a regra Angular → BFF.

## Consequências negativas

- o BFF passa a coordenar mais integrações externas;
- Web Push depende da permissão e das políticas do navegador e do sistema;
- a rotação do par VAPID exige reinscrição dos dispositivos;
- entrega aceita pelo push service não equivale a leitura pelo usuário.

## Alternativas rejeitadas

| Alternativa | Motivo |
|---|---|
| Push somente pelo SignalR | não funciona com o site fechado |
| Provedor chamado pelo Angular | expõe credenciais e quebra BFF-first |
| E-mail para todos os eventos | produz excesso de mensagens e reduz controle |
| Um único botão global | não atende preferências por tipo de evento |
| FCM para web e mobile desde já | adiciona dependência desnecessária; Web Push nativo cobre o MVP web |

## Evidência

A v1.1.0 foi testada ponta a ponta no ambiente público: cadastro do dispositivo,
persistência, evento real, central in-app, aceitação HTTP `201` pelo push service
do Windows e recebimento confirmado no Edge.
