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
	END  AS faixa_tenure
FROM public.wa_fn_usec
LIMIT 20;

-- 2. Taxa de cancelamento por faixa de tempo de casa: em que fase o cliente mais cancela?
--    (taxa calculada dentro de cada faixa com PARTITION BY)

SELECT 
	"Churn",
CASE 
		WHEN tenure <= 6  THEN '1. 0-6meses'
		WHEN tenure <= 12 THEN '2. 7-12meses'
		WHEN tenure <= 24 THEN '3. 13-24meses'
		WHEN tenure <= 48 THEN '4. 25-48meses'
		ELSE '5. 49-72meses'
	END AS faixa_tenure,
	COUNT(*) AS total_clientes
FROM public.wa_fn_usec
GROUP BY 
	faixa_tenure,
	"Churn"
ORDER BY
	faixa_tenure,
	"Churn"


