# Backup e restauração

## Objetivo

Preservar os três domínios PostgreSQL e a configuração operacional do ZimaOS,
além de comprovar continuamente que os artefatos podem ser restaurados.

## Conteúdo de cada conjunto

| Artefato | Origem | Formato |
|---|---|---|
| `bff.dump` | PostgreSQL exclusivo do BFF | `pg_dump` custom, sem owner ou ACL |
| `finance.dump` | PostgreSQL exclusivo do Finance | `pg_dump` custom, sem owner ou ACL |
| `debt.dump` | PostgreSQL exclusivo do Debt | `pg_dump` custom, sem owner ou ACL |
| `zrok-environment.tar.gz` | identidade persistente do zrok | tar gzip |
| `beszel-data.tar.gz` | configuração e histórico do Hub | tar gzip |
| `beszel-agent-data.tar.gz` | identidade do Agent | tar gzip |
| `uptime-kuma-data.tar.gz` | monitores e histórico do Kuma | tar gzip |

O conjunto também contém `MANIFEST`, `SHA256SUMS`, `VERIFIED` e `COMPLETE`.
Diretórios e arquivos são criados com acesso exclusivo de `root`.

## Agendamento e retenção

O timer `finance-control-backup.timer` executa aos domingos às `03:30`, com
atraso aleatório de até vinte minutos. `Persistent=true` recupera uma execução
perdida depois que o servidor volta. São mantidos sete conjuntos completos.

```powershell
pwsh -File ..\finance-control-infra\tools\Invoke-ZimaOsFinanceControl.ps1 -Action BackupStatus
pwsh -File ..\finance-control-infra\tools\Invoke-ZimaOsFinanceControl.ps1 -Action BackupLogs -Tail 200
```

## Ensaio automático de restauração

Após gerar checksums, a rotina:

1. inicia um PostgreSQL `17.10` temporário sem porta publicada;
2. cria três bancos descartáveis;
3. executa `pg_restore --exit-on-error` em cada dump;
4. exige ao menos uma tabela pública em cada banco restaurado;
5. extrai cada arquivo de volume em um volume Docker temporário;
6. exige conteúdo em cada volume restaurado;
7. remove containers e volumes de verificação;
8. grava `VERIFIED` somente após todas as etapas passarem.

Esse ensaio não acessa o destino de produção. Para repeti-lo:

```powershell
pwsh -File ..\finance-control-infra\tools\Invoke-ZimaOsFinanceControl.ps1 -Action VerifyLatestBackup
```

## Executar antes de uma manutenção

```powershell
pwsh -File ..\finance-control-infra\tools\Invoke-ZimaOsFinanceControl.ps1 -Action RunBackup
pwsh -File ..\finance-control-infra\tools\Invoke-ZimaOsFinanceControl.ps1 -Action BackupStatus
```

Continue somente se `last_result=success` e
`latest_restore_verification=ok` forem exibidos.

## Recuperação de um banco

Uma recuperação real é deliberadamente manual porque troca dados persistentes.
Ela deve ser feita primeiro em um banco novo, nunca diretamente sobre o banco
afetado.

1. pare apenas as alterações do domínio afetado ou coloque o staging em janela
   de manutenção;
2. crie um banco de recuperação no projeto Neon correto;
3. copie o dump escolhido para uma estação administrativa protegida;
4. restaure com PostgreSQL `17.10`, substituindo somente placeholders:

```powershell
$env:PGPASSWORD = '<SENHA_DO_BANCO_DE_RECUPERACAO>'
pg_restore `
  --exit-on-error `
  --no-owner `
  --no-acl `
  --host '<HOST_DO_PROJETO_CORRETO>' `
  --port 5432 `
  --username '<USUARIO_DO_PROJETO_CORRETO>' `
  --dbname '<BANCO_NOVO_DE_RECUPERACAO>' `
  '<CAMINHO_DO_DUMP>'
Remove-Item Env:PGPASSWORD
```

5. aponte temporariamente somente o serviço proprietário ao banco recuperado;
6. reinicie esse serviço, aguarde migrations e valide health e fluxos do
   domínio;
7. promova o banco recuperado apenas depois da validação;
8. mantenha o banco anterior intacto até encerrar o incidente.

Nunca restaure o dump de um domínio no projeto de outro serviço.

## Recuperação de um volume

Antes de substituir um volume, pare o serviço proprietário e arquive o estado
atual. O exemplo abaixo usa placeholders intencionais:

```bash
docker stop '<CONTAINER_PROPRIETARIO>'
docker run --rm \
  --volume '<VOLUME_DESTINO>:/restore' \
  --volume '<DIRETORIO_DO_BACKUP>/volumes:/backup:ro' \
  docker.io/library/busybox:1.37.0 \
  sh -eu -c 'rm -rf /restore/*; tar -xzf "/backup/$1" -C /restore' \
  sh '<ARQUIVO_DO_VOLUME>.tar.gz'
docker start '<CONTAINER_PROPRIETARIO>'
```

Depois valide `ObservabilityHealth` ou `PublicStatus`, conforme o volume. A
identidade do zrok só deve ser substituída se a atual tiver sido perdida.

## Limite de proteção atual

O backup local cobre exclusão acidental e regressões de configuração. Como
permanece no mesmo host, não cobre falha física, roubo ou perda total do disco.
A próxima evolução de resiliência é copiar os conjuntos para mídia ou provedor
externo com criptografia antes do envio. Isso não bloqueia o MVP de portfólio,
mas é obrigatório antes de tratar o ambiente como produção comercial.
