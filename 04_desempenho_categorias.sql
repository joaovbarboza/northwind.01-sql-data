-- Quais são as categorias de produtos de alta performance que geraram mais de $ 50.000,00 em receita líquida
-- considerando apenas pedidos confirmados/enviados (desconsiderando pedidos sem data de envio)?

SELECT ROUND(SUM(t2.UnitPrice * t2.Quantity * (1- t2.Discount)),2) AS total, -- cálculo receita líquida
       t4.CategoryName
FROM "Orders" AS t1
LEFT JOIN "Order Details" AS t2 -- join interligando a tabela de ordens
ON t1.OrderID = t2.OrderID
JOIN Products AS t3 -- join interligando a tabela com os produtos
ON t2.ProductID = t3.ProductID
JOIN Categories AS t4 -- join interligando a tabela com as categorias
ON t3.CategoryID = t4.CategoryID

WHERE ShippedDate IS NOT NULL -- filtrando apenas as vendas que teve data de saída

GROUP BY t4.CategoryName -- agrupando por nome de categoria

HAVING SUM(t2.UnitPrice * t2.Quantity * (1- t2.Discount)) > 50000 -- filtrando na receita liquida apenas as vendas que teve mais de 50.000

ORDER BY total DESC -- ordenando para fácil vizualização