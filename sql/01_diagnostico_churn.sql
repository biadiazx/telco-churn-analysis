-- ----------------------------------------------------------------------------
-- DOSSIÊ EXECUTIVO: Diagnóstico de Churn e Qualidade de Dados
-- Objetivo: Auditar a integridade da base e mapear o volume de cancelamentos.
-- Regra de Negócio: Validação de volumetria e tratamento de faturamentos vazios.
-- Base: Telco Customer Churn (Telecomunicações) | SGBD: PostgreSQL
-- ----------------------------------------------------------------------------

---------------------------------------------------
--FASE 1: INTEGRIDADE DOS DADOS
---------------------------------------------------

-- 1. Validação do volume total de clientes na base
SELECT
	COUNT(*) AS total_clientes
FROM 
	public.wa_fn_usec;

-- 2. Volume e taxa de cancelamento: quantos clientes saíram e quanto isso representa da base

SELECT
	"Churn" AS status_cliente, 
	COUNT(*) AS total_clientes,
	SUM(COUNT(*))OVER() AS total_geral,
	ROUND(COUNT(*)*100.0/SUM(COUNT(*))OVER(),2) AS taxa_pct
FROM public.wa_fn_usec
GROUP BY "Churn";

--3. Clientes com faturamento total igual a zero 
--(clientes novos, tenure 0, corrigidos no 00_correcao_tipos.sql)
SELECT 
	COUNT(*) AS faturas_vazias
FROM public.wa_fn_usec 
WHERE "TotalCharges" = 0;

---------------------------------------------------
-- FASE 2: MINERAÇÃO DE DADOS E COMPORTAMENTO
---------------------------------------------------

-- 4. Comparação da fatura média (MonthlyCharges) entre clientes ativos e cancelados
SELECT
	"Churn" AS status_cliente,
	ROUND(AVG("MonthlyCharges")::numeric,2) AS fatura_media
FROM public.wa_fn_usec
GROUP BY "Churn"; 

-- 5: Média de Permanência (Tenure) por Status de Churn
SELECT
	"Churn" AS status_cliente,
	ROUND(AVG(tenure)::numeric,2) AS meses_retencao
FROM public.wa_fn_usec
GROUP BY "Churn";

---------------------------------------------------
-- FASE 3: INVESTIGAÇÃO DE CAUSAS
---------------------------------------------------

-- 6: Volume de cancelamentos por Tipo de Contrato
 
SELECT
	"Contract" AS tipo_contrato,
	"Churn"    AS status_cliente,
	count(*)	   AS total_cliente
FROM public.wa_fn_usec
GROUP BY "Contract", "Churn"; 

-- Query 7: Impacto do Tipo de Internet no Cancelamento de Clientes (Churn)
