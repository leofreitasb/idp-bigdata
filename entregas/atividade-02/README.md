# Atividade 02 — MongoDB Atlas

## Objetivo
Configurar um banco MongoDB em nuvem (MongoDB Atlas), conectar via Python/Google Colab e praticar operações CRUD e agregação.

## Etapas
1. Criar cluster gratuito M0 no MongoDB Atlas.
2. Criar usuário de banco com permissão de leitura/escrita.
3. Liberar temporariamente o acesso de rede necessário para o laboratório.
4. Obter a URI de conexão.
5. Executar o notebook abaixo no Google Colab.

## Código-base para o Colab

```python
!pip install pymongo[srv]

from pymongo import MongoClient
import pandas as pd
import matplotlib.pyplot as plt

uri = "mongodb+srv://<USUARIO>:<SENHA>@<CLUSTER>.mongodb.net/?retryWrites=true&w=majority"
client = MongoClient(uri)
client.admin.command("ping")
print("Conectado ao MongoDB Atlas com sucesso")

db = client["AulaDemo"]
colecao = db["Estudantes"]

colecao.delete_many({})
colecao.insert_many([
    {"nome":"Fernando Campos","idade":22,"curso":"Engenharia da Computação","email":"fernando.campos@email.com"},
    {"nome":"Mariano Rodrigues","idade":20,"curso":"Design Gráfico"},
    {"nome":"Roberta Lara","idade":23,"curso":"Ciência da Computação"}
])

print("Todos os estudantes:")
for doc in colecao.find():
    print(doc)

colecao.update_one({"nome":"Fernando Campos"},{"$set":{"idade":23}})
print("Atualizado:", colecao.find_one({"nome":"Fernando Campos"}))

colecao.delete_one({"nome":"Mariano Rodrigues"})
print("Quantidade final:", colecao.count_documents({}))
```

## Resultado esperado
- conexão ao Atlas confirmada por `ping`;
- documentos inseridos na coleção `Estudantes`;
- consulta dos documentos;
- atualização de um documento;
- exclusão de um documento.

## Status desta entrega
- [x] Código da atividade preparado
- [x] Operações CRUD documentadas
- [ ] Cluster Atlas criado na conta do aluno
- [ ] URI real configurada
- [ ] Notebook executado no Colab
- [ ] Evidência real anexada

> Não foram incluídas credenciais no repositório. A etapa final exige acesso à conta MongoDB Atlas do aluno.
