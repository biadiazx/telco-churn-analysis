-- ----------------------------------------------------------------------------
-- CORREÇÃO DE TIPOS: TotalCharges
-- Problema: a coluna TotalCharges foi importada como ARRAY de texto (_varchar),
--           e não como número. Por isso não era possível somar nem tirar média.
--           A auditoria inicial (cardinality = 0) retornava 0 vazios, mas
--           11 clientes tinham o valor em branco, guardado como {" "}.
-- Quem são: os 11 têm tenure = 0 e Churn = 'No'. São clientes ativos que
--           acabaram de chegar e ainda não receberam a primeira fatura.
-- Decisão: preencher com 0 em vez de excluir. Eles ainda não pagaram nada e
--          estão justamente na fase de maior risco, sendo alvo de retenção.
-- Base: Telco Customer Churn (IBM) | SGBD: PostgreSQL
-- ----------------------------------------------------------------------------

-- Passo 1: backup da tabela antes de qualquer alteração
CREATE TABLE public.wa_fn_usec_backup AS
SELECT *
FROM public.wa_fn_usec;

-- Passo 2: converte TotalCharges de array de texto para numeric
-- Se o valor estiver em branco, vira 0. Senão, o texto vira número.
ALTER TABLE public.wa_fn_usec
ALTER COLUMN "TotalCharges"
TYPE numeric
USING
    CASE
        WHEN TRIM("TotalCharges"[1]) = '' THEN 0
        ELSE "TotalCharges"[1]::numeric
    END;

-- Passo 3: conferências
-- 3.1 O tipo da coluna deve aparecer como numeric
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'wa_fn_usec'
  AND column_name = 'TotalCharges';

-- 3.2 A soma, que antes dava erro, agora funciona
-- Resultado esperado: 16.056.168,70
SELECT
    SUM("TotalCharges") AS faturamento_total
FROM public.wa_fn_usec;