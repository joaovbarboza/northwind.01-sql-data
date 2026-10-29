-- Como evoluiu o faturamento da Northwind mês a mês ao longo do tempo? 
-- Qual foi a variação percentual de receita de um mês em relação ao mês anterior (MoM)?

-- 'WITH' para gerar a mini tabela com os dados e ficar mais fácil de manusear os resultados
WITH tab_sumario_dados AS (
SELECT        
       strftime('%Y-%m', OrderDate) AS mes_ano, -- separando apenas os meses
       ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receita_liquida -- cálculo da receita líquida
FROM Invoices
GROUP BY mes_ano -- agrupei por mês
ORDER BY mes_ano -- ordeneu por mês
)

SELECT *,
    lag(receita_liquida, 1) OVER (ORDER BY mes_ano) AS evolucao_mes, -- gerei uma coluna nova que têm como função compararmos a linha anterior com a atual
    ROUND(
    ((receita_liquida - lag(receita_liquida, 1) OVER (ORDER BY mes_ano))
    /lag(receita_liquida, 1) OVER (ORDER BY mes_ano)) * 100, 2) AS cres_porcentual_mom, -- cálculo para descobrir a diferença em porcentagem
    ROUND((receita_liquida - lag(receita_liquida, 1) OVER (ORDER BY mes_ano)), 2) AS diff_anterior_atual -- cálculo para descobrir a diferença em valores
FROM tab_sumario_dados
ORDER BY mes_ano