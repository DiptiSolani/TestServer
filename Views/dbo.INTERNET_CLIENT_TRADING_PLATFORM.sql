SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view  [dbo].[INTERNET_CLIENT_TRADING_PLATFORM]
AS



	SELECT	DISTINCT C.CLIENT_ID,[BSE],[NSE],[NSEFO],[CDNSE],[CDMCX],[MCX],[NCDEX],tpf,SERIAL_NO,CASE WHEN SERIAL_NO IS NULL OR LEN(SERIAL_NO)=0 THEN TPF ELSE SERIAL_NO END FINAL_TRADING_PLATFORM 
	FROM
	(	
		SELECT	CLIENT_ID,[BSE],[NSE],[NSEFO],[CDNSE],[CDMCX],[MCX],[NCDEX],
				CASE WHEN [MCX] IS NULL AND [NCDEX] IS NULL THEN 'NOW'
				ELSE 'NEST' END TPF
		FROM
		(
			SELECT	DISTINCT C.CLIENT_ID,
					CASE WHEN C.COMPANY_CODE LIKE 'NSE_CASH' THEN 'NSE'
															  WHEN C.COMPANY_CODE LIKE 'NSE_FNO' THEN 'NSEFO'
															  WHEN C.COMPANY_CODE LIKE 'BSE_CASH' THEN 'BSE'	
															  WHEN C.COMPANY_CODE LIKE 'BSE_FNO' THEN 'BSEFO'
															  WHEN C.COMPANY_CODE LIKE 'CD_MCX' THEN 'CDMCX'	
															  WHEN C.COMPANY_CODE LIKE 'CD_NSE' THEN 'CDNSE'
															  ELSE C.COMPANY_CODE	
									END COMPANY_CODE
					,'Y' FLAG
			FROM	CAPSFO.DBO.CLIENT_MASTER C JOIN  CAPSFO.DBO.BROKERAGE_APPLY BA
			ON		C.COMPANY_CODE=BA.COMPANY_CODE AND C.CLIENT_ID=BA.CLIENT_ID
			WHERE	ACTIVE_INACTIVE='A' 
					AND DATEADD(D,0,DATEDIFF(D,0,C.REGISTRATION_DATE)) = DATEADD(D,0,DATEDIFF(D,0,GETDATE())) 
				/*	OR C.LAST_MODIFIED_DATE > DATEADD(D,0,DATEDIFF(D,0,GETDATE()-2))*/
			GROUP BY C.CLIENT_ID,C.COMPANY_CODE,BRANCH_CODE 
			HAVING BRANCH_CODE='INTERNET'
		)X
		PIVOT	(MIN(FLAG) FOR COMPANY_CODE IN ([BSE],[NSE],[NSEFO],[CDNSE],[CDMCX],[MCX],[NCDEX]))AS AV
	)C LEFT OUTER JOIN CAPSFO.DBO.CLIENT_DETAILS CD ON C.CLIENT_ID=CD.CLIENT_ID

GO
