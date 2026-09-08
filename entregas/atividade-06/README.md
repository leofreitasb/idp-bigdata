# Atividade 06 — Censo IES

## Objetivo
Preparar, importar e analisar os microdados do Censo da Educação Superior de 2022 do INEP utilizando MongoDB e Jupyter.

## Preparação do dataset

```bash
cd mongodb/datasets
wget https://download.inep.gov.br/microdados/microdados_censo_da_educacao_superior_2022.zip --no-check-certificate
unzip microdados_censo_da_educacao_superior_2022.zip
```

## Limpeza e conversão do arquivo de IES

```bash
sed 's/\"//g; s/;/,/g' MICRODADOS_ED_SUP_IES_2022.CSV > MICRODADOS_ED_SUP_IES_2022_corrigido.csv
iconv -f ISO-8859-1 -t UTF-8 MICRODADOS_ED_SUP_IES_2022_corrigido.csv > MICRODADOS_ED_SUP_IES_2022_corrigido_UTF8.csv
```

## Importação no MongoDB

```bash
docker exec -it mongo_service mongoimport \
  --db inep \
  --collection ies \
  --type csv \
  --file /datasets/inep/MICRODADOS_ED_SUP_IES_2022_corrigido_UTF8.csv \
  --headerline \
  --ignoreBlanks \
  --username root \
  --password mongo \
  --authenticationDatabase admin
```

## Análises solicitadas

### Instituições por região

```python
result = collection.aggregate([
    {'$group': {'_id': '$NO_REGIAO_IES', 'count': {'$sum': 1}}}
])
```

### Instituições por estado

```python
result = collection.aggregate([
    {'$group': {'_id': '$NO_UF_IES', 'count': {'$sum': 1}}}
])
```

### Docentes por gênero

```python
result = collection.aggregate([
    {'$group': {
        '_id': None,
        'total_fem': {'$sum': '$QT_DOC_EX_FEMI'},
        'total_masc': {'$sum': '$QT_DOC_EX_MASC'}
    }}
])
```

### Docentes por grau acadêmico

```python
result = collection.aggregate([
    {'$group': {
        '_id': None,
        'Graduacao': {'$sum': '$QT_DOC_EX_GRAD'},
        'Especializacao': {'$sum': '$QT_DOC_EX_ESP'},
        'Mestrado': {'$sum': '$QT_DOC_EX_MEST'},
        'Doutorado': {'$sum': '$QT_DOC_EX_DOUT'}
    }}
])
```

## Interpretação esperada
A análise do material da disciplina indica maior concentração de IES na região Sudeste, seguida por Nordeste, Sul, Centro-Oeste e Norte. O roteiro também analisa distribuição de docentes por faixa etária, titulação, raça/cor e gênero, além de uma análise multivariada por região e grau acadêmico.

## Status desta entrega
- [x] Pipeline de preparação documentado
- [x] Importação MongoDB documentada
- [x] Consultas de análise preparadas
- [x] Interpretação alinhada ao roteiro oficial
- [ ] Dataset baixado e processado localmente
- [ ] Importação realmente executada
- [ ] Gráficos e saídas reais gerados no Jupyter

> Os resultados numéricos e gráficos não foram inventados. Para completar a evidência prática, é necessária a execução local com o dataset do INEP.
