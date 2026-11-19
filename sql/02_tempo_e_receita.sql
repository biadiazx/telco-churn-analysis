-- ----------------------------------------------------------------------------
-- DOSSIÊ EXECUTIVO: Quando os clientes vão embora e quanto isso custa?
-- Objetivo: Mostrar em que faixa de tempo de casa os cancelamentos se concentram
--           e medir quanto de receita mensal a operadora perde com eles.
-- Pré-requisito: rodar antes o 00_correcao_tipos.sql (TotalCharges como numeric).
-- Base: Telco Customer Churn (IBM) | SGBD: PostgreSQL
-- ----------------------------------------------------------------------------

-- Faixas de tempo de casa:
-- se o tenure for até 6, faixa 1; se for até 12, faixa 2;
-- se for até 24, faixa 3; se for até 48, faixa 4; senão, faixa 5.

-- 1. Conferência das faixas: cada cliente caiu na faixa certa de tempo de casa?
SELECT
	tenure,
	CASE
		WHEN tenure <= 6  THEN '1. 0-6meses'
		WHEN tenure <= 12 THEN '2. 7-12meses'
		WHEN tenure <= 24 THEN '3. 13-24meses'
		WHEN tenure <= 48 THEN '4. 25-48meses'
		ELSE '5. 49-72meses'
	END AS faixa_tenure
FROM public.wa_fn_usec
LIMIT 20;

-- 2. Taxa de cancelamento por faixa de tempo de casa
--    Em que faixa os clientes mais cancelam?
--    CTE: o PARTITION BY não aceita o apelido criado no mesmo SELECT,
--    então a faixa é criada antes (etapa 1) e usada depois (etapa 2).
WITH tabela_temporaria AS (
	-- etapa 1: cada cliente com o status e a faixa
	SELECT
		"Churn" AS status_cliente,
		CASE
			WHEN tenure <= 6  THEN '1. 0-6meses'
			WHEN tenure <= 12 THEN '2. 7-12meses'
			WHEN tenure <= 24 THEN '3. 13-24meses'
			WHEN tenure <= 48 THEN '4. 25-48meses'
			ELSE '5. 49-72meses'
		END AS faixa_tenure
	FROM public.wa_fn_usec
)
-- etapa 2: contagem e taxa por faixa
SELECT 
	faixa_tenure,
	status_cliente,
	COUNT(*) AS total_clientes,
	SUM(COUNT(*)) OVER(PARTITION BY faixa_tenure) AS total_faixa,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY faixa_tenure), 2) AS taxa_pct
FROM tabela_temporaria
GROUP BY
	faixa_tenure,
	status_cliente
ORDER BY
	faixa_tenure,
	status_cliente;
-- Achado: Quanto mais tempo de casa, menos cancelamento. A taxa cai em todas as faixas de 52,94% para 9,51%,
-- sendo mais de 5 vezes maior nos primeiros 6 meses.
