# Atividade 04 — Jupyter & MongoDB

## Objetivo
Integrar os containers Jupyter e MongoDB na mesma rede Docker e executar consultas MongoDB a partir de um notebook Python.

## Rede compartilhada

```bash
docker network create --driver bridge mybridge
```

## Subir MongoDB

```bash
cd mongodb
docker compose up -d
```

## Subir Jupyter

```bash
cd ../jupyter
docker compose build
docker compose up -d
```

## Verificar a rede

```bash
docker network inspect mybridge
```

## Código Python para teste de conexão

```python
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

try:
    client = MongoClient(
        "mongodb://root:mongo@mongo_service:27017/",
        serverSelectionTimeoutMS=5000
    )
    client.server_info()
    print("Conexão estabelecida com sucesso!")
except ConnectionFailure as e:
    print("Falha na conexão ao servidor MongoDB:", e)
```

## Teste de manipulação de dados

```python
db = client["AulaDemo"]
collection = db["Estudantes"]

collection.insert_one({
    "nome": "Aluno Teste",
    "idade": 21,
    "curso": "Ciência da Computação"
})

for doc in collection.find():
    print(doc)
```

## Status desta entrega
- [x] Integração de rede documentada
- [x] Código Python preparado
- [x] Uso do hostname Docker em vez de IP fixo
- [ ] Containers executados localmente
- [ ] Token/senha do Jupyter configurados
- [ ] Notebook executado com saída real

> O uso do hostname do container evita depender de IPs dinâmicos atribuídos pela rede Docker.
