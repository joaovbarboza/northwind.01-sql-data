-- Os descontos oferecidos nas vendas estão realmente gerando maior volume financeiro ou apenas reduzindo a margem da empresa?
-- Qual o volume de vendas e ticket médio dos pedidos com desconto versus sem desconto?

SELECT 
CASE WHEN Discount > 0 THEN 'comdesconto' ELSE 'semdesconto' END AS categoriadesconto, -- 'CASE WHEN' para criar a categoria de desconto e sem desconto
ROUND(SUM(UnitPrice * Quantity), 2) AS receitabruta, -- cálculo receita bruta
ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receitaliquida, -- cálculo receita líquida
COUNT(DISTINCT OrderID) AS totalpedidos, -- total pedidos
ROUND(SUM(UnitPrice * Quantity * (1 - Discount)) / COUNT(DISTINCT OrderID), 2) AS ticket_medio -- ticket médio 
FROM "Order details"

GROUP BY categoriadesconto -- agrupar por categoria dos descontos