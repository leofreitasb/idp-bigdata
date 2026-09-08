# Execucao rapida - Big Data e NoSQL - Atividades 01 a 07
# Requisitos: Windows PowerShell + Docker Desktop em execucao
# Execute a partir da raiz do repositorio.

$ErrorActionPreference = "Stop"
$evid = Join-Path $PSScriptRoot "evidencias"
New-Item -ItemType Directory -Force -Path $evid | Out-Null

function Log($msg) {
  Write-Host "`n=== $msg ===" -ForegroundColor Cyan
}

function Save($name, $content) {
  $path = Join-Path $evid $name
  $content | Out-File -FilePath $path -Encoding utf8
  Write-Host "Evidencia salva: $path"
}

Log "Atividade 01 - validando Docker"
$dockerVersion = docker version --format '{{.Server.Version}}'
$dockerInfo = docker info --format 'Docker={{.ServerVersion}} | Containers={{.Containers}} | Images={{.Images}}'
Save "atividade-01-docker.txt" @("Docker operacional", "Versao: $dockerVersion", $dockerInfo)

Log "Preparando rede Docker compartilhada"
$networkExists = docker network ls --format '{{.Name}}' | Select-String -SimpleMatch 'mybridge'
if (-not $networkExists) {
  docker network create --driver bridge mybridge | Out-Null
}

Log "Atividade 03 - MongoDB local"
$mongoExists = docker ps -a --format '{{.Names}}' | Select-String -SimpleMatch 'mongo_service'
if (-not $mongoExists) {
  docker run -d --name mongo_service --network mybridge -p 27017:27017 `
    -e MONGO_INITDB_ROOT_USERNAME=root `
    -e MONGO_INITDB_ROOT_PASSWORD=mongo `
    -v idp_mongo_data:/data/db mongo:4.4-bionic | Out-Null
} else {
  docker start mongo_service 2>$null | Out-Null
  try { docker network connect mybridge mongo_service 2>$null | Out-Null } catch {}
}

Write-Host "Aguardando MongoDB ficar disponivel..."
for ($i=0; $i -lt 30; $i++) {
  try {
    docker exec mongo_service mongo -u root -p mongo --authenticationDatabase admin --quiet --eval "db.adminCommand('ping').ok" 2>$null | Out-Null
    break
  } catch { Start-Sleep -Seconds 2 }
}

$mongoScript = @'
use AulaDemo
try { db.Estudantes.drop() } catch(e) {}
db.createCollection('Estudantes')
db.Estudantes.insertMany([
 {nome:'Joao Leite',idade:22,curso:'Engenharia da Computacao',email:'joao.leite@email.com'},
 {nome:'Domitila Canto',idade:22,curso:'Letras',email:'domitila.canto@email.com'},
 {nome:'Fernando Campos',idade:22,curso:'Engenharia da Computacao',email:'fernando.campos@email.com'},
 {nome:'Roberta Lara',idade:23,curso:'Ciencia da Computacao',email:'roberta.lara@email.com'}
])
db.Estudantes.updateOne({nome:'Joao Leite'},{$set:{idade:23}})
db.Estudantes.createIndex({nome:1})
print('TOTAL='+db.Estudantes.countDocuments({}))
print('ENG='+db.Estudantes.countDocuments({curso:'Engenharia da Computacao'}))
printjson(db.Estudantes.find().sort({nome:1}).toArray())
printjson(db.Estudantes.getIndexes())
'@
$mongoOut = docker exec mongo_service mongo -u root -p mongo --authenticationDatabase admin --quiet --eval $mongoScript 2>&1
Save "atividade-03-mongodb.txt" $mongoOut

Log "Atividade 04 - Jupyter + MongoDB"
$jupyterExists = docker ps -a --format '{{.Names}}' | Select-String -SimpleMatch 'jupyter_idp'
if (-not $jupyterExists) {
  docker run -d --name jupyter_idp --network mybridge -p 8888:8888 jupyter/base-notebook:latest start-notebook.py --ServerApp.token='' --ServerApp.password='' | Out-Null
} else {
  docker start jupyter_idp 2>$null | Out-Null
  try { docker network connect mybridge jupyter_idp 2>$null | Out-Null } catch {}
}

$netOut = docker network inspect mybridge --format '{{range .Containers}}{{.Name}} {{end}}'
$pingMongo = docker exec jupyter_idp python -c "import socket; print('mongo_service ->', socket.gethostbyname('mongo_service'))" 2>&1
Save "atividade-04-jupyter-mongodb.txt" @($netOut, $pingMongo, 'Jupyter: http://localhost:8888')

Log "Atividade 05 - MongoDB + Python"
$pythonCode = @'
from pymongo import MongoClient
client=MongoClient('mongodb://root:mongo@mongo_service:27017/?authSource=admin')
db=client['AulaDemo']
c=db['Estudantes']
print('TOTAL', c.count_documents({}))
print('IDADE>=22', c.count_documents({'idade':{'$gte':22}}))
for d in c.aggregate([{'$group':{'_id':'$curso','total':{'$sum':1}}},{'$sort':{'total':-1}}]): print(d)
'@
$pyOut = docker exec jupyter_idp bash -lc "pip -q install pymongo >/dev/null 2>&1; python - <<'PY'
$pythonCode
PY" 2>&1
Save "atividade-05-mongodb-python.txt" $pyOut

Log "Atividade 07 - Cassandra"
$cassandraExists = docker ps -a --format '{{.Names}}' | Select-String -SimpleMatch 'cassandra-container'
if (-not $cassandraExists) {
  docker run -d --name cassandra-container --network mybridge -p 9042:9042 -v idp_cassandra_data:/var/lib/cassandra cassandra:latest | Out-Null
} else {
  docker start cassandra-container 2>$null | Out-Null
  try { docker network connect mybridge cassandra-container 2>$null | Out-Null } catch {}
}

Write-Host "Aguardando Cassandra ficar disponivel..."
for ($i=0; $i -lt 60; $i++) {
  try {
    $ok = docker exec cassandra-container cqlsh -e "DESCRIBE KEYSPACES" 2>$null
    if ($LASTEXITCODE -eq 0) { break }
  } catch {}
  Start-Sleep -Seconds 3
}

$cql = @'
CREATE KEYSPACE IF NOT EXISTS AulaDemo WITH replication = {'class':'SimpleStrategy','replication_factor':1};
USE AulaDemo;
DROP TABLE IF EXISTS Estudantes;
CREATE TABLE Estudantes (id UUID PRIMARY KEY, nome TEXT, idade INT, curso TEXT, email TEXT);
INSERT INTO Estudantes (id,nome,idade,curso,email) VALUES (uuid(),'Joao Leite',22,'Engenharia da Computacao','joao.leite@email.com');
INSERT INTO Estudantes (id,nome,idade,curso,email) VALUES (uuid(),'Domitila Canto',22,'Letras','domitila.canto@email.com');
INSERT INTO Estudantes (id,nome,idade,curso,email) VALUES (uuid(),'Fernando Campos',22,'Engenharia da Computacao','fernando.campos@email.com');
SELECT * FROM Estudantes;
CREATE KEYSPACE IF NOT EXISTS TestePersistencia WITH replication = {'class':'SimpleStrategy','replication_factor':1};
USE TestePersistencia;
DROP TABLE IF EXISTS usuarios;
CREATE TABLE usuarios (id UUID PRIMARY KEY,nome TEXT,idade INT);
INSERT INTO usuarios (id,nome,idade) VALUES (uuid(),'Carlos Silva',30);
INSERT INTO usuarios (id,nome,idade) VALUES (uuid(),'Ana Souza',25);
SELECT * FROM usuarios;
'@
$cass1 = $cql | docker exec -i cassandra-container cqlsh 2>&1
Save "atividade-07-cassandra-inicial.txt" $cass1

Log "Atividade 07 - teste de persistencia"
docker restart cassandra-container | Out-Null
Start-Sleep -Seconds 20
for ($i=0; $i -lt 30; $i++) {
  try {
    $persist = docker exec cassandra-container cqlsh -e "SELECT * FROM TestePersistencia.usuarios;" 2>&1
    if ($LASTEXITCODE -eq 0) { break }
  } catch {}
  Start-Sleep -Seconds 3
}
Save "atividade-07-persistencia.txt" $persist

Log "Atividade 06 - Censo IES"
$atividade06 = @'
A estrutura, os comandos de limpeza/importacao e as consultas do Censo IES estao documentados na PR da Atividade 06.
A execucao completa exige o download do conjunto de microdados do INEP, que e grande e nao e necessario repetir para validar as atividades antigas rapidamente.
Para uma entrega com evidencia real do dataset, execute posteriormente o roteiro da PR 06.
'@
Save "atividade-06-censo-ies.txt" $atividade06

Log "Atividade 02 - MongoDB Atlas"
$atividade02 = @'
A Atividade 02 e baseada em MongoDB Atlas (servico externo) e Google Colab. Nao pode ser comprovada apenas pelo Docker local.
O codigo e o roteiro reproduzivel estao prontos na PR 02. Para evidencia real e necessario criar/usar um cluster Atlas e executar o notebook.
'@
Save "atividade-02-atlas.txt" $atividade02

Log "Resumo"
$resumo = @(
  'Atividade 01: Docker validado localmente',
  'Atividade 02: roteiro/codigo pronto; Atlas externo pendente',
  'Atividade 03: MongoDB local executado',
  'Atividade 04: rede Jupyter + MongoDB executada',
  'Atividade 05: Python + MongoDB executado localmente',
  'Atividade 06: roteiro Censo IES pronto; dataset completo opcional para evidencia',
  'Atividade 07: Cassandra + persistencia executados',
  '',
  'Arquivos de evidencia gerados em entregas/evidencias/'
)
Save "RESUMO.txt" $resumo
Write-Host "`nConcluido. Envie para o chat o conteudo de entregas/evidencias/RESUMO.txt e, se houver erro, copie apenas a mensagem de erro." -ForegroundColor Green
