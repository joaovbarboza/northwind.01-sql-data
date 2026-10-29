-- Quais são os 10 clientes mais valiosos da Northwind Traders em termos de receita líquida gerada 
-- e quanto cada um representa em compras?

-- 'WITH' para gerar uma 'mini tabela' com os dados que vamos usar na consulta
WITH tab_sumario AS (
SELECT t1.OrderID,
       t2.CompanyName,
       t3.UnitPrice,
       t3.Quantity,
       t3.Discount
FROM Orders AS t1
LEFT JOIN Customers AS t2 -- 'join' para interligar a tabela Orders com a Customer
ON t1.CustomerID = t2.CustomerID
JOIN "Order Details" AS t3 -- 'join' para interligar a tabela  Order Details com a Orders
ON t1.OrderID = t3.OrderID
)

SELECT CompanyName,
       ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receitaliquida, -- Calculo da receita liquida
       ROUND(SUM(UnitPrice * Quantity * (1 - Discount)) / (448386633.17) * 100, 2) AS porcentagem -- Calculo da porcentagem que cada um representa na base total
FROM tab_sumario
GROUP BY CompanyName -- agrupei a receita liquida por empresas
ORDER BY receitaliquida DESC -- ordenei quem fez gastou mais

LIMIT 10 -- limitei apenas os 10 clientes mais valiosos