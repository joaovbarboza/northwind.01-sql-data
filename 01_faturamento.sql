-- 1º pergunta: 'Qual é a receita total bruta da empresa, o número total de pedidos realizados e o Ticket Médio por pedido?'

SELECT 
    ROUND(SUM(UnitPrice * Quantity), 2) AS receita_bruta, -- cálculo da receita bruta
    ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS receita_liquida, -- cálculo da receita liquida
    COUNT(DISTINCT OrderID) AS total_pedidos, -- quantidade total de pedidos
    ROUND(SUM(UnitPrice * Quantity * (1 - Discount)) / COUNT(DISTINCT OrderID), 2) AS ticket_medio -- ticket médio por pedido
FROM "Order Details" -- aspas no nome da tabela, o SQL entende o order como comando