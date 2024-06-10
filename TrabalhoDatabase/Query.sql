-- # Qual o cliente que mais fez pedidos por ano
WITH PedidosPorAno AS (
    SELECT 
        YEAR(m.data_hora_entrada) AS ano,
        c.nome_cliente,
        COUNT(*) AS total_pedidos,
        ROW_NUMBER() OVER(PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(*) DESC) AS ranking
    FROM tb_mesa m
    JOIN tb_cliente c ON m.id_cliente = c.id_cliente
    GROUP BY ano, c.nome_cliente
)
SELECT ano, nome_cliente, total_pedidos
FROM PedidosPorAno
WHERE ranking = 1;

-- # Qual o cliente que mais gastou em todos os anos
SELECT 
    c.nome_cliente,
    SUM(pr.preco_unitario_prato * p.quantidade_pedido) AS total_gasto
FROM tb_pedido p
JOIN tb_prato pr ON p.codigo_prato = pr.codigo_prato
JOIN tb_mesa m ON p.codigo_mesa = m.codigo_mesa
JOIN tb_cliente c ON m.id_cliente = c.id_cliente
GROUP BY c.nome_cliente
ORDER BY total_gasto DESC
LIMIT 1;

-- # Qual(is) o(s) cliente(s) que trouxe(ram) mais pessoas por ano
WITH PessoasPorAno AS (
    SELECT 
        YEAR(data_hora_entrada) AS ano,
        c.nome_cliente,
        SUM(num_pessoa_mesa) AS total_pessoas,
        ROW_NUMBER() OVER(PARTITION BY YEAR(data_hora_entrada) ORDER BY SUM(num_pessoa_mesa) DESC) AS ranking
    FROM tb_mesa m
    JOIN tb_cliente c ON m.id_cliente = c.id_cliente
    GROUP BY YEAR(data_hora_entrada), c.nome_cliente
)
SELECT ano, nome_cliente, total_pessoas
FROM PessoasPorAno
WHERE ranking = 1;

--  Qual a empresa que tem mais funcionarios como clientes do restaurante;
SELECT
    tb_empresa.nome_empresa AS empresa,
    COUNT(DISTINCT tb_beneficio.codigo_funcionario) AS total_funcionarios
FROM
    tb_beneficio
JOIN
    tb_empresa ON tb_beneficio.codigo_empresa = tb_empresa.codigo_empresa
JOIN
    tb_cliente ON tb_beneficio.email_funcionario = tb_cliente.email_cliente
JOIN
    tb_mesa ON tb_cliente.id_cliente = tb_mesa.id_cliente
GROUP BY
    tb_empresa.nome_empresa
ORDER BY
    total_funcionarios DESC
LIMIT 1;

-- Qual empresa que tem mais funcionarios que consomem sobremesas no restaurante por ano;
SELECT subquery.ano, subquery.nome_empresa, subquery.total_funcionarios_sobremesa
FROM (
    SELECT YEAR(m.data_hora_entrada) AS ano,
           e.nome_empresa,
           COUNT(DISTINCT b.codigo_funcionario) AS total_funcionarios_sobremesa,
           RANK() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(DISTINCT b.codigo_funcionario) DESC) AS rank_funcionarios_sobremesa
    FROM tb_pedido AS p
    INNER JOIN tb_mesa AS m ON p.codigo_mesa = m.codigo_mesa
    INNER JOIN tb_beneficio AS b ON m.id_cliente = b.codigo_funcionario
    INNER JOIN tb_prato AS pr ON p.codigo_prato = pr.codigo_prato
    INNER JOIN tb_empresa AS e ON b.codigo_empresa = e.codigo_empresa
    INNER JOIN tb_tipo_prato AS tp ON pr.codigo_tipo_prato = tp.codigo_tipo_prato
    WHERE tp.nome_tipo_prato = 'Sobremesa'
    GROUP BY ano, e.nome_empresa
) AS subquery
WHERE subquery.rank_funcionarios_sobremesa = 1;





