# Atividade 05 — MongoDB & Python

## Objetivo
Praticar integração entre Python e MongoDB, cobrindo conexão, criação de banco/coleção, CRUD e agregações.

## Exemplo reproduzível

```python
from pymongo import MongoClient

client = MongoClient("mongodb://root:mongo@mongo_service:27017/")
db = client["AulaDemo"]
estudantes = db["EstudantesPython"]

estudantes.delete_many({})

estudantes.insert_many([
    {"nome":"Ana","idade":21,"curso":"Computação","media":8.5},
    {"nome":"Bruno","idade":23,"curso":"Computação","media":7.8},
    {"nome":"Carla","idade":22,"curso":"Design","media":9.1},
    {"nome":"Diego","idade":24,"curso":"Design","media":8.2}
])

print("Todos:")
for doc in estudantes.find():
    print(doc)

print("\nComputação:")
for doc in estudantes.find({"curso":"Computação"}):
    print(doc)

estudantes.update_one({"nome":"Ana"},{"$set":{"media":9.0}})
estudantes.delete_one({"nome":"Bruno"})

pipeline = [
    {"$group":{"_id":"$curso","media_turma":{"$avg":"$media"},"total":{"$sum":1}}},
    {"$sort":{"media_turma":-1}}
]

print("\nAgregação:")
for item in estudantes.aggregate(pipeline):
    print(item)
```

## Conceitos exercitados
- conexão via `MongoClient`;
- banco e coleção;
- `insert_many`;
- `find` com filtro;
- `update_one`;
- `delete_one`;
- Aggregation Framework com `$group`, `$avg`, `$sum` e `$sort`.

## Status desta entrega
- [x] Implementação Python preparada
- [x] CRUD contemplado
- [x] Agregação contemplada
- [ ] Exercício externo do Kaggle executado na conta do aluno
- [ ] Saídas reais registradas

> O cronograma oficial referencia um notebook externo do Kaggle. O código acima cobre os mesmos fundamentos técnicos, mas a comprovação específica no Kaggle depende da conta e da execução do aluno.
