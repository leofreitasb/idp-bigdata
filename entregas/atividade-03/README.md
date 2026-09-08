# Atividade 03 — MongoDB On-Premises

## Objetivo
Executar MongoDB e Mongo Express localmente via Docker e praticar operações CRUD no banco `AulaDemo`.

## Preparação

```bash
cd mongodb
chmod +x wait-for-it.sh
docker compose up -d
docker ps
```

## Acesso ao MongoDB

```bash
docker exec -it mongo_service /bin/bash
mongo -u root -p mongo
```

## Operações MQL

```javascript
use AulaDemo

db.createCollection("Estudantes")

db.Estudantes.insertMany([
  {nome:"João Leite", idade:22, curso:"Engenharia da Computação", email:"joao.leite@email.com"},
  {nome:"Domitila Canto", idade:22, curso:"Letras", email:"domitila.canto@email.com"},
  {nome:"Fernando Campos", idade:22, curso:"Engenharia da Computação", email:"fernando.campos@email.com"}
])

db.Estudantes.find().pretty()
db.Estudantes.find({curso:"Engenharia da Computação"}).pretty()
db.Estudantes.updateOne({nome:"João Leite"}, {$set:{idade:23}})
db.Estudantes.createIndex({nome:1})
db.Estudantes.deleteOne({nome:"Domitila Canto"})
db.Estudantes.find().sort({nome:1}).pretty()
```

## Verificações

```javascript
show dbs
use AulaDemo
show collections
db.Estudantes.countDocuments({})
db.Estudantes.getIndexes()
```

## Status desta entrega
- [x] Comandos Docker preparados
- [x] CRUD MongoDB preparado
- [x] Criação de índice documentada
- [ ] Containers executados localmente
- [ ] Mongo Express validado em `localhost:8081`
- [ ] Saídas reais dos comandos registradas

> A execução depende do Docker local. Não foi simulada saída de terminal.
