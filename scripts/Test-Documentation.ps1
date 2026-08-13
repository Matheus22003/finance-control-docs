$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath(
  (Join-Path $PSScriptRoot '..')
)
$markdownFiles = Get-ChildItem -LiteralPath $repositoryRoot -Recurse -File -Filter '*.md' |
  Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
$errors = [System.Collections.Generic.List[string]]::new()
$linkPattern = '\[[^\]]+\]\((?<target>[^)]+)\)'

foreach ($file in $markdownFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Raw
  if ([string]::IsNullOrWhiteSpace($content)) {
    $errors.Add("Arquivo vazio: $($file.FullName)")
    continue
  }

  foreach ($match in [regex]::Matches($content, $linkPattern)) {
    $target = $match.Groups['target'].Value.Trim().Trim('<', '>')
    if ($target.StartsWith('#') -or
        $target.StartsWith('http://') -or
        $target.StartsWith('https://') -or
        $target.StartsWith('mailto:')) {
      continue
    }

    $pathWithoutAnchor = $target.Split('#', 2)[0]
    if ([string]::IsNullOrWhiteSpace($pathWithoutAnchor)) {
      continue
    }

    $decodedPath = [System.Uri]::UnescapeDataString($pathWithoutAnchor)
    $resolvedPath = [System.IO.Path]::GetFullPath(
      (Join-Path $file.DirectoryName $decodedPath)
    )
    if (-not $resolvedPath.StartsWith($repositoryRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
      $errors.Add("Link escapa do repositório em $($file.FullName): $target")
      continue
    }

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
      $errors.Add("Link local inexistente em $($file.FullName): $target")
    }
  }
}

if ($errors.Count -gt 0) {
  $errors | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Output "Documentação válida: $($markdownFiles.Count) arquivo(s) Markdown."
