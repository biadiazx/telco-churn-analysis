-- ----------------------------------------------------------------------------
-- DOSSIÊ EXECUTIVO: Diagnóstico de Churn
-- Objetivo: Medir o volume e a taxa de cancelamentos e investigar os fatores
--           que mais influenciam quem cancela (contrato e tipo de internet).
-- Pré-requisito: rodar antes o 00_correcao_tipos.sql (TotalCharges como numeric).
-- Base: Telco Customer Churn (IBM) | SGBD: PostgreSQL
-- ----------------------------------------------------------------------------

---------------------------------------------------
-- FASE 1: VOLUME E TAXA DE CANCELAMENTO
---------------------------------------------------

-- 1. Validação do volume total de clientes na base
SELECT
	COUNT(*) AS total_clientes
FROM public.wa_fn_usec;

-- 2. Volume e taxa de cancelamento: quantos clientes saíram e quanto isso representa da base
SELECT
	"Churn" AS status_cliente,
	COUNT(*) AS total_clientes,
	SUM(COUNT(*)) OVER() AS total_geral,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS taxa_pct
FROM public.wa_fn_usec
GROUP BY "Churn"
ORDER BY "Churn";

-- 3. Clientes com faturamento total igual a zero
--    (clientes novos, tenure 0, corrigidos no 00_correcao_tipos.sql)
SELECT
	COUNT(*) AS faturas_zeradas
FROM public.wa_fn_usec
WHERE "TotalCharges" = 0;

---------------------------------------------------
-- FASE 2: COMPORTAMENTO (FATURA E TEMPO DE CASA)
---------------------------------------------------

-- 4. Fatura média (MonthlyCharges) de clientes ativos e cancelados
SELECT
	"Churn" AS status_cliente,
	ROUND(AVG("MonthlyCharges")::numeric, 2) AS fatura_media
FROM public.wa_fn_usec
GROUP BY "Churn"
ORDER BY "Churn";

-- 5. Tempo médio de casa (tenure, em meses) de clientes ativos e cancelados
SELECT
	"Churn" AS status_cliente,
	ROUND(AVG(tenure)::numeric, 2) AS meses_retencao
FROM public.wa_fn_usec
GROUP BY "Churn"
ORDER BY "Churn";

---------------------------------------------------
-- FASE 3: FATORES DE CANCELAMENTO
---------------------------------------------------

-- 6. Taxa de cancelamento por contrato: o tipo de contrato influencia quem cancela?
--    (taxa calculada dentro de cada contrato com PARTITION BY "Contract")
SELECT
	"Contract" AS tipo_contrato,
	"Churn" AS status_cliente,
	COUNT(*) AS total_clientes,
	SUM(COUNT(*)) OVER(PARTITION BY "Contract") AS total_contrato,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY "Contract"), 2) AS taxa_pct
FROM public.wa_fn_usec
GROUP BY
	"Contract",
	"Churn"
ORDER BY
	"Contract",
	"Churn";

-- 7. Taxa de cancelamento por tipo de internet: o tipo de internet influencia quem cancela?
--    (taxa calculada dentro de cada tipo com PARTITION BY "InternetService")
--    Atenção: em InternetService, "No" significa sem serviço de internet.
SELECT
	"InternetService" AS tipo_internet,
	"Churn" AS status_cliente,
	COUNT(*) AS total_clientes,
	SUM(COUNT(*)) OVER(PARTITION BY "InternetService") AS total_internet,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY "InternetService"), 2) AS taxa_pct
FROM public.wa_fn_usec
GROUP BY
	"InternetService",
	"Churn"
ORDER BY
	"InternetService",
	"Churn";

