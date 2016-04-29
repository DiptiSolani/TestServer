SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[pricingplan]
as
SELECT BA.company_code,BA.client_id,CONVERT(VARCHAR ,BA.start_date,111) start_date,CONVERT(VARCHAR ,BA.end_date,111) end_date,BA.brokerage_module,
		case when ba.company_code IN ('NSE_CASH','BSE_CASH') then 'CASH'
			 when ba.company_code = 'NSE_FNO' then 'FO'
			 when ba.company_code in ('MCX','NCDEX') then 'COM'
			 when ba.company_code in ('CD_NSE') then 'CUR' end segment
FROM [Capsfo].[dbo].[BROKERAGE_APPLY] BA LEFT OUTER  JOIN brokerage_pricing_plan BP                              
ON BA.COMPANY_CODE = BP.COMPANY_CODE                               
WHERE BA.START_DATE <= dateadd(d,0,datediff(d,0,getdate()))                              
    AND ( BA.END_DATE >= dateadd(d,0,datediff(d,0,getdate()))  OR  BA.END_DATE IS NULL )                            
    AND BA.brokerage_module = BP.PRICE                                     

GO
