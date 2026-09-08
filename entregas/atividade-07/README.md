# Atividade 07 — Apache Cassandra

## Objetivo
Praticar modelagem orientada a consultas, operações CQL, impacto da chave primária, persistência em containers e importação de dados no Apache Cassandra.

## 1. Preparação do ambiente

```bash
cd cassandra
chmod +x wait-for-it.sh
docker network create --driver bridge mybridge || true
docker compose up -d
docker ps
```

## 2. Acesso ao CQL Shell

```bash
docker exec -it cassandra-container cqlsh
```

## 3. Keyspace e tabela Estudantes

```sql
CREATE KEYSPACE IF NOT EXISTS AulaDemo
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE AulaDemo;

CREATE TABLE IF NOT EXISTS estudantes (
    id UUID PRIMARY KEY,
    nome TEXT,
    idade INT,
    curso TEXT,
    email TEXT
);
```

## 4. Inserção de dados

```sql
INSERT INTO estudantes (id, nome, idade, curso, email)
VALUES (uuid(), 'João Leite', 22, 'Engenharia da Computação', 'joao.leite@email.com');

INSERT INTO estudantes (id, nome, idade, curso, email)
VALUES (uuid(), 'Domitila Canto', 22, 'Letras', 'domitila.canto@email.com');

SELECT * FROM estudantes;
```

## Desafio 1 — Chave primária

### Foi possível executar todos os comandos do roteiro?
Não. Com a tabela definida como `id UUID PRIMARY KEY`, comandos que tentam atualizar, excluir ou filtrar diretamente por `nome` ou `idade` não são válidos apenas porque esses campos existem na tabela. Cassandra é modelado em torno das consultas e da chave de partição/chave primária.

Exemplos que devem falhar no modelo original:

```sql
UPDATE estudantes SET idade = 23 WHERE nome = 'João Leite';
DELETE FROM estudantes WHERE nome = 'Domitila Canto';
SELECT * FROM estudantes WHERE idade >= 18;
```

### Qual a importância da chave primária?
A chave primária define como o Cassandra identifica e distribui os dados. Ela contém a chave de partição e, quando aplicável, colunas de clustering. Operações eficientes devem ser planejadas a partir dessas chaves.

### Por que não podemos atualizar ou excluir apenas pelo nome?
Porque `nome` não faz parte da chave primária da tabela `estudantes`. Cassandra precisa identificar de forma determinística a partição e a linha a serem modificadas.

### Modelagem correta quando a consulta principal for pelo nome
A chave primária não deve ser alterada com `ALTER TABLE ... ADD PRIMARY KEY`. O correto é criar outra tabela voltada à consulta desejada.

```sql
CREATE TABLE IF NOT EXISTS estudantes_por_nome (
    nome TEXT,
    id UUID,
    idade INT,
    curso TEXT,
    email TEXT,
    PRIMARY KEY (nome, id)
);
```

Para um caso em que `nome` fosse garantidamente único, também poderia ser modelado como chave primária simples em uma tabela específica.

## Desafio 2 — Persistência

```sql
CREATE KEYSPACE IF NOT EXISTS TestePersistencia
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE TestePersistencia;

CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY,
    nome TEXT,
    idade INT
);

INSERT INTO usuarios (id, nome, idade) VALUES (uuid(), 'Carlos Silva', 30);
INSERT INTO usuarios (id, nome, idade) VALUES (uuid(), 'Ana Souza', 25);
SELECT * FROM usuarios;
```

Reiniciar os containers:

```bash
docker compose down
docker compose up -d
```

Depois:

```bash
docker exec -it cassandra-container cqlsh
```

```sql
SELECT * FROM TestePersistencia.usuarios;
```

### Resposta
No `docker-compose.yml` atual existe o volume `cassandra_data:/var/lib/cassandra`. Portanto, um `docker compose down` seguido de `up -d` deve preservar os dados do volume nomeado. A afirmação de que os dados necessariamente seriam perdidos está desatualizada em relação ao Compose atual.

Para remover também os volumes do projeto e testar perda deliberada de persistência:

```bash
docker compose down -v
```

## Desafio 3 — Importação do Censo IES
O exercício pede reproduzir, em Cassandra, a análise anteriormente feita com MongoDB. Como Cassandra é orientado a consultas, não é adequado simplesmente copiar uma única tabela e executar agregações arbitrárias. Uma abordagem acadêmica simples é importar um subconjunto de campos necessários e criar tabelas orientadas às consultas.

Exemplo de keyspace:

```sql
CREATE KEYSPACE IF NOT EXISTS inep
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
```

Exemplo de tabela de IES por região:

```sql
USE inep;

CREATE TABLE IF NOT EXISTS ies_por_regiao (
    regiao TEXT,
    codigo_ies TEXT,
    nome_ies TEXT,
    uf TEXT,
    PRIMARY KEY (regiao, codigo_ies)
);
```

Importação via `COPY`, desde que o CSV esteja com colunas compatíveis com a tabela:

```sql
COPY inep.ies_por_regiao (regiao, codigo_ies, nome_ies, uf)
FROM '/datasets/ies_por_regiao.csv'
WITH HEADER = TRUE AND DELIMITER = ',';
```

Consulta:

```sql
SELECT * FROM inep.ies_por_regiao WHERE regiao = 'Sudeste';
```

## Correções importantes em relação ao roteiro original
1. Um `INSERT` em `estudantes` precisa informar `id` ou usar `uuid()`; Cassandra não gera automaticamente uma UUID por omissão.
2. `ALTER TABLE Estudantes ADD PRIMARY KEY (id, nome)` não é uma forma válida de transformar a chave primária já criada. Deve-se criar uma nova tabela.
3. O Compose atual já define `cassandra_data:/var/lib/cassandra`, portanto `docker compose down` não deveria apagar os dados desse volume.
4. A análise do Censo deve respeitar modelagem orientada às consultas, em vez de replicar diretamente o padrão de agregações livres do MongoDB.

## Status desta entrega
- [x] Respostas dos Desafios 1 e 2 preparadas
- [x] Modelagem correta explicada
- [x] Estrutura do Desafio 3 preparada
- [x] Comandos CQL revisados
- [ ] Docker/Cassandra executados no computador do aluno
- [ ] Saídas reais do `cqlsh` registradas
- [ ] Dataset convertido para o formato específico das tabelas Cassandra
- [ ] Importação real do Censo IES executada

> Não foram fabricados logs ou resultados. As evidências práticas finais dependem da execução do ambiente Docker local.
