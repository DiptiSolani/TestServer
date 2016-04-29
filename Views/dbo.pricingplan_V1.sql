SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[pricingplan_V1]
AS
SELECT	distinct BA.company_code,BA.client_id,CONVERT(VARCHAR ,BA.start_date,111) start_date,CONVERT(VARCHAR ,BA.end_date,111) end_date,BA.brokerage_module,
		case when ba.company_code IN ('NSE_CASH','BSE_CASH') then 'CASH'
			 when ba.company_code = 'NSE_FNO' then 'FO'
			 when ba.company_code in ('MCX','NCDEX') then 'COM'
			 when ba.company_code in ('CD_NSE') then 'CUR' end segment
FROM	CAPSFO.DBO.BROKERAGE_APPLY BA inner hash JOIN CAPSFO.DBO.BROKERAGE_MASTER B
ON		BROKERAGE_MODULE=MODULE_NO AND BA.COMPANY_CODE=B.COMPANY_CODE
WHERE	END_DATE IS NULL  and brokerage_module  in (1005,1500,1999,2999,3999,1899,999) and client_id in (select client_id from rmstable_v5)

GO
