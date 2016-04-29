SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[MTF_CLIENTS] AS
SELECT DISTINCT CM.CLIENT_ID,
                DR_INTEREST,
                DELIVERY_TYPE,
                INTEREST_CALC,
                'WEBCLIENT_MTF' CATEGORY
FROM
  ( SELECT DISTINCT CLIENT_ID,
                    DR_INTEREST
   FROM CAPSFO.DBO.CLIENT_MASTER
   WHERE DR_INTEREST IS NOT NULL
     AND DR_INTEREST >= 15 ) CM
JOIN
  ( SELECT DISTINCT CLIENT_ID,
                    DELIVERY_TYPE,
                    INTEREST_CALC
   FROM CAPSFO.DBO.CLIENT_DETAILS
   WHERE DELIVERY_TYPE = 3
     AND INTEREST_CALC = 'D' ) CD ON CM.CLIENT_ID = CD.CLIENT_ID
JOIN
  ( SELECT DISTINCT CLIENT_ID,
                    BROKERAGE_MODULE
   FROM [vns_db].[dbo].[pricingplan_V1]
   WHERE COMPANY_CODE IN ('NSE_CASH',
                          'BSE_CASH')
     AND BROKERAGE_MODULE IN (1005,
                              1500)) PP ON CM.CLIENT_ID = PP.CLIENT_ID
JOIN
  ( SELECT DISTINCT ACCOUNTCODE,
                    VOUCHERDATE
   FROM [capsfo].[dbo].[FA_TRANSACTIONS]
   WHERE VOUCHERNO IN
       ( SELECT DISTINCT VOUCHERNO
        FROM [capsfo].[dbo].[FA_TRANSACTIONS]
        WHERE ACCOUNTCODE = 'MTF_SUBCHARGES'
          AND DATEDIFF(DAY, VOUCHERDATE, GETDATE()) < 365
          AND CR_AMT > 0
          AND TRANS_TYPE IN ('J',
                             'SJ') )
     AND DR_AMT > 0
     AND DATEDIFF(DAY, VOUCHERDATE, GETDATE()) < 365 ) FA ON CM.CLIENT_ID = FA.ACCOUNTCODE
JOIN
  ( SELECT DISTINCT CLIENT_ID
   FROM
     ( SELECT DISTINCT CLIENT_ID
      FROM dbo.NRML_CASH_POSITION_TRADE
      WHERE TRADE_DATE =
          (SELECT MAX(TRADE_DATE)
           FROM CAPSFO.DBO.TRADE1 (NOLOCK)
           WHERE COMPANY_CODE = 'NSE_CASH'
             AND TRADE_TYPE IN ('TN'))
      UNION SELECT DISTINCT CLIENT_ID
      FROM RMSTABLE_V5
      WHERE (NET_WO_MARGIN_DR - mcx - ncdex + DAY_COLL_DERI + HOLING_VALAUTION) > '25000' )U)RM ON CM.CLIENT_ID = RM.CLIENT_ID
GO