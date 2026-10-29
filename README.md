# Análise Financeira e Estratégica de Vendas — Banco de Dados Northwind

##  Contexto e Desafio de Negócio

> "Objetivo Executivo: Avaliar a saúde financeira da Northwind Traders, mapeando desde o volume geral de vendas e o perfil dos melhores clientes até a eficiência das estratégias comerciais e de precificação. O intuito é entregar à diretoria um diagnóstico completo para otimização de margem e expansão de mercado"

##  Abordagem e Estrutura do Repositório

Para responder a este desafio, a análise foi estruturada de forma progressiva, partindo de agregações fundamentais até consultas avançadas com **CTEs** e **Window Functions**.

* **Foco do README:** Apresentação dos resultados, gráficos mentais e recomendações de negócio geradas por cada consulta.
* **Códigos Completos:** Os scripts `.sql` comentados passo a passo estão organizados na pasta `/Northwind` para rápida consulta e auditoria.

---

## 1º pergunta: 'Qual é a receita total bruta da empresa, o número total de pedidos realizados e o Ticket Médio por pedido?'
* Objetivo: Mapear as vendas da empresa.

```sql
SELECT 
    ROUND(SUM(UnitPrice * Quantity), 2) AS receita_bruta, 
    ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receita_liquida, 
    COUNT(DISTINCT OrderID) AS total_pedidos, -- quantidade total de pedidos
    ROUND(SUM(UnitPrice * Quantity * (1 - Discount)) / COUNT(DISTINCT OrderID), 2) AS ticket_medio 
FROM "Order Details" 
```
### Resultado:

| Métricas Principais | Valor ($) / Qtd |
| :--- | :--- |
| **Receita Bruta** | $ 448.475.298,72 |
| **Receita Líquida (pós-descontos)** | $ 448.386.633,17 |
| **Total de Pedidos Únicos** | 16.282 |
| **Ticket Médio por Pedido** | $ 27.538,79 |

### Insights Executivos e Leitura de Negócio

* **Preservação Extrema de Margem**: A diferença entre a Receita Bruta ($ 448.475.298,72) e a Receita Líquida ($ 448.386.633,17) é de apenas $ 88.665,55. Isso representa uma renúncia de receita via descontos de impressionantes 0,02% sobre o faturamento total. A política comercial da Northwind é extremamente conservadora quanto à concessão de abatimentos

* **Perfil de Vendas B2B de Grande Porte**: Com um Ticket Médio de $ 27.538,79 por pedido distribuído ao longo de 16.282 transações, fica claro que a empresa opera em um modelo estritamente B2B (Business-to-Business) focado em clientes corporativos e grandes distribuidores regionais.

## 2º pergunta: 'Quais são os 10 clientes mais valiosos da Northwind e quanto cada um representa em receita acumulada??'
* Objetivo: Classificar os melhores clientes

``` sql
WITH tab_sumario AS (
SELECT t1.OrderID,
       t2.CompanyName,
       t3.UnitPrice,
       t3.Quantity,
       t3.Discount
FROM Orders AS t1
LEFT JOIN Customers AS t2 
ON t1.CustomerID = t2.CustomerID
JOIN "Order Details" AS t3 
ON t1.OrderID = t3.OrderID
)

SELECT CompanyName,
       ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receitaliquida, 
       ROUND(SUM(UnitPrice * Quantity * (1 - Discount)) / (448386633.17) * 100, 2) AS porcentagem 
FROM tab_sumario
GROUP BY CompanyName 
ORDER BY receitaliquida DESC 
LIMIT 10 
```

### Resultado:

| Empresa (CompanyName) | Receita Líquida ($) | Representatividade (%) |
| :--- | :--- | :--- |
| **IT** | $ 9.745.371,29 | 2,17% |
| **B's Beverages** | $ 6.154.115,34 | 1,37% |
| **Hungry Coyote Import Store** | $ 5.698.023,67 | 1,27% |
| **Rancho grande** | $ 5.559.110,08 | 1,24% |
| **Gourmet Lanchonetes** | $ 5.552.309,81 | 1,24% |
| **Ana Trujillo Emparedados y helados** | $ 5.534.356,65 | 1,23% |
| **Ricardo Adocicados** | $ 5.524.517,31 | 1,23% |
| **Folies gourmandes** | $ 5.505.502,85 | 1,23% |
| **Let's Stop N Shop** | $ 5.462.198,02 | 1,22% |
| **LILA-Supermercado** | $ 5.437.438,34 | 1,21% |

### Insights Executivos e Leitura de Negócio

* O cliente **IT**  é o mais valioso da **Northwind**, possuindo uma larga vantagem em relação ao segundo colocado. Compreender o mix de produtos e o perfil de consumo desse cliente pode servir de benchmark para estratégias de expansão de vendas com outros clientes.

* Os 10 clientes mais valiosos da **NorthWind** contém ao total **12,29%** de toda a receita da empresa. Esse indicador revela uma carteira de clientes saudável e bem distribuída, eliminando riscos de depender apenas de alguns clientes.

## 3º pergunta: Os descontos oferecidos nas vendas estão realmente gerando maior volume financeiro ou apenas reduzindo a margem da empresa? Qual o volume de vendas e ticket médio dos pedidos com desconto versus sem desconto?
* Objetivo: Identificar se o desconto está a funcionar como uma alavanca para vender mais (aumentar o volume e o Ticket Médio) ou se está apenas a "queimar margem".

```sql
SELECT 
CASE WHEN Discount > 0 THEN 'comdesconto' ELSE 'semdesconto' END AS categoriadesconto, 
ROUND(SUM(UnitPrice * Quantity), 2) AS receitabruta,
ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receitaliquida,
COUNT(DISTINCT OrderID) AS totalpedidos, -- total pedidos
ROUND(SUM(UnitPrice * Quantity * (1 - Discount)) / COUNT(DISTINCT OrderID), 2) AS ticket_medio 
FROM "Order details"
GROUP BY categoriadesconto 
```
### Resultado:

| Categoria do desconto | Receita Bruta ($) | Receita Líquida ($) | Total Pedidos | Ticket Médio ($) |
| :--- | :--- | :--- | :--- | :--- |
| **Com Desconto** | $ 603.759,98 | $ 515.094,43 | 380 | $ 1.355,51 |
| **Sem Desconto** | $ 447.871.538,74 | $ 447.871.538,74 | 16.065 | $ 27.878,71 |

### Insights Executivos e Leitura de Negócio

* A diferença do ticket médio com os pedidos sem desconto para os que possuem desconto é enorme. Os clientes são bem consolidados, os descontos não têm atraido tantos pedidos, oq pode ser reavaliados para serem aplicados em grandes volumes, para impulsionar aqueles que ja compram e os que ainda não são consolidados.

## 4º pergunta: Quais são as categorias de produtos de alta performance que geraram mais de $ 50.000,00 em receita líquida considerando apenas pedidos confirmados/enviados (desconsiderando pedidos sem data de envio)?
* Objetivo: O objetivo de responder a essa pergunta é identificar os carros-chefes do negócio e garantir a confiabilidade dos dados ao analisar apenas vendas concluídas/enviadas.

```sql
SELECT ROUND(SUM(t2.UnitPrice * t2.Quantity * (1- t2.Discount)),2) AS total, 
       t4.CategoryName
FROM "Orders" AS t1
LEFT JOIN "Order Details" AS t2 
ON t1.OrderID = t2.OrderID
JOIN Products AS t3 
ON t2.ProductID = t3.ProductID
JOIN Categories AS t4
ON t3.CategoryID = t4.CategoryID

WHERE ShippedDate IS NOT NULL 
GROUP BY t4.CategoryName 
HAVING SUM(t2.UnitPrice * t2.Quantity * (1- t2.Discount)) > 50000 
ORDER BY total DESC 
```
### Resultado:

|Nome da Categoria | Receita líquida ($) |
| :--- | :--- | 
| **Beverages** | $ 92.157.888,48 |
| **Confections** | $ 66.335.117,89 |
| **Meat/Poultry** | $ 64.880.257,82 |
| **Dairy Products** | $ 58.014.560,67 |
| **Condiments** | $ 55.794.126,88 |
| **Seafood** | $ 49.920.412,57 |
| **Produce** | $ 32.694.766,10 |
| **Grains/Cereals** | $ 28.563.565,33 |

### Insights Executivos e Leitura de Negócio
* A categoria 'Beverages' que é a categoria mais valiosa da Northwild possui uma larga diferença do segundo colocado, ou seja, os produtos dessa categoria são os mais vendidos, logo, vale a pena o investimento para que esse produto melhore.
* Com esse resultado, a empresa pode alinhar e criar novas estratégias para reestruturas as suas categorias mais fracas, entender o motivo para que esses produtos não estejam vendendo muito bem e reavaliar se vale a pena continuar produzindo ou investir nos outros que ja têm uma prospecção maior

## 5º pergunta: Como evoluiu o faturamento da Northwind mês a mês ao longo do tempo? Qual foi a variação percentual de receita de um mês em relação ao mês anterior (MoM)?
* Objetivo: Realizar uma comparação mês após mês, para termos uma real vizualização do faturamento da Northwind. Com isso podemos identificar as tendências de crescimento e os meses que as vendas foram baixas.

```sql
WITH tab_sumario_dados AS (
SELECT        
       strftime('%Y-%m', OrderDate) AS mes_ano, 
       ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receita_liquida 
FROM Invoices
GROUP BY mes_ano 
ORDER BY mes_ano 
)

SELECT *,
    lag(receita_liquida, 1) OVER (ORDER BY mes_ano) AS evolucao_mes, 
    ROUND(
    ((receita_liquida - lag(receita_liquida, 1) OVER (ORDER BY mes_ano))
    /lag(receita_liquida, 1) OVER (ORDER BY mes_ano)) * 100, 2) AS cres_porcentual_mom, 
    ROUND((receita_liquida - lag(receita_liquida, 1) OVER (ORDER BY mes_ano)), 2) AS diff_anterior_atual 
FROM tab_sumario_dados
ORDER BY mes_ano
```

###  Resultado: Evolução Mensal e Variação MoM (Amostra Inicial)

> ! *Abaixo apresentamos uma amostra dos primeiros meses da série temporal analisada.*

| mes_ano | receita_liquida ($) | evolucao_mes ($) | cres_porcentual_mom (%) | diff_anterior_atual ($) |
| :--- | :--- | :--- | :--- | :--- |
| **2012-07** | $ 2.066.219,40 | - | - | - |
| **2012-08** | $ 3.556.875,79 | $ 2.066.219,40 | +72,14% | +$ 1.490.656,39 |
| **2012-09** | $ 3.440.144,98 | $ 3.556.875,79 | -3,28% | -$ 116.730,81 |
| **2012-10** | $ 3.201.529,96 | $ 3.440.144,98 | -6,94% | -$ 238.615,02 |
| **2012-11** | $ 2.980.494,74 | $ 3.201.529,96 | -6,90% | -$ 221.035,22 |
| **2012-12** | $ 3.577.936,85 | $ 2.980.494,74 | +20,05% | +$ 597.442,11 |
| **2013-02** |	$ 2.964.192,86 | $ 3.075.418,29 | -3.62% |	-$ 111.225,43 |
| **2013-03** |	$ 3.471.361,21 | $ 2.964.192,86 | +17.11% |	+$ 507.168,35 |
| **2013-04** |	$ 3.262.893,52 | $ 3.471.361,21 | -6.01% |	-$ 208.467,69 |
| **2013-05** |	$ 3.593.528,01 | $ 3.262.893,52 | +10.13% |	+$ 330.634,49 |

### Insights Executivos e Leitura de Negócio
* Do recorte acima, a Northwind teve mais meses que foram abaixos comparado aos outros do que meses que foram melhores, porém a taxa de aumento quando teve foi bem alta, o que sugere que nesses meses houve uma forte campanha no marketing ou nos preços que atraiu a clientela.
* O mês_ano 12-2012 foi o melhor, vale a pena analisar e montar uma nova estratégia para entender o crescimento nesse mês e se consegue reaplicar.


## Conclusão Geral e Impacto de Negócio

Este projeto de análise exploratória e estratégica sobre a base de dados da **Northwind** permitiu mapear os principais direcionadores de receita, eficiência operacional e comportamento de vendas da empresa:

1. **Concentração de Receita:** A categoria de *Beverages* consolida-se como o principal carro-chefe de faturamento, exigindo atenção prioritária em gestão de estoque e relacionamento com fornecedores.
2. **Saúde das Margens:** A análise de descontos revelou a necessidade de estabelecer travas operacionais em pedidos de menor volume para evitar a erosão da margem líquida.
3. **Padrões Temporais (MoM):** Identificaram-se picos sazonais expressivos em meses específicos (com destaques para agosto e dezembro), fornecendo uma base sólida para previsões de fluxo de caixa (*forecasting*) e planeamento de campanhas de marketing.
