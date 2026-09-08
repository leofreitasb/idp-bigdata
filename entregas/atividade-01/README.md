# Atividade 01 — WSL & Docker Desktop

## Objetivo
Preparar o ambiente de virtualização utilizado nos laboratórios de Big Data e NoSQL, com WSL 2, Ubuntu e Docker Desktop.

## Procedimento proposto

### 1. Habilitar WSL 2 no Windows
Executar o PowerShell como administrador:

```powershell
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --install
wsl --set-default-version 2
```

### 2. Instalar Ubuntu 24.04

```powershell
wsl --install -d Ubuntu-24.04
wsl --setdefault Ubuntu-24.04
```

Após a instalação, reiniciar o computador e criar usuário/senha no Ubuntu.

### 3. Instalar Docker Desktop
Instalar o Docker Desktop for Windows e habilitar a integração com WSL 2.

### 4. Validação
Executar:

```bash
wsl --status
docker --version
docker compose version
docker run --rm hello-world
```

## Critério de conclusão
A atividade estará concluída quando os comandos acima forem executados com sucesso e o container `hello-world` finalizar normalmente.

## Status desta entrega
- [x] Procedimento documentado
- [x] Comandos de validação preparados
- [ ] WSL executado no computador do aluno
- [ ] Docker Desktop instalado no computador do aluno
- [ ] Evidência real de `docker run --rm hello-world`

> Observação: a instalação e a evidência final dependem de execução local no computador do aluno e não podem ser simuladas pelo repositório.
