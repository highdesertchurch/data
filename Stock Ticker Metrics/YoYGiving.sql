DECLARE @Temp TABLE (campus VARCHAR(20), year INT, month INT, monthword VARCHAR(20), current_year_total DECIMAL(18,2))

INSERT INTO @Temp
SELECT c.Name as Campus, DATEPART(Year, ftd.CreatedDateTime) 'Year', DATEPART(Month,ftd.CreatedDateTime) 'Month',FORMAT(ftd.CreatedDateTime, 'MMMM') 'MonthWord' ,SUM(ftd.Amount) 'Current Year Total'
FROM FinancialTransactionDetail ftd
JOIN FinancialAccount as fa on fa.Id = ftd.AccountId
JOIN FinancialTransaction as ft on ft.Id = ftd.TransactionId
JOIN FinancialPaymentDetail as fpd on fpd.Id = ft.FinancialPaymentDetailId
JOIN DefinedValue as dv on dv.Id = fpd.CurrencyTypeValueId
JOIN PersonAlias as pa on pa.Id = ft.AuthorizedPersonAliasId
JOIN Person as p on p.Id = pa.PersonId
JOIN GroupMember as gm on gm.PersonId = p.Id
JOIN [Group] as g on g.Id = gm.GroupId
LEFT JOIN Campus as c on c.Id = g.CampusId
WHERE g.GroupTypeId = 10
AND ftd.AccountId = 7 --General Only
--AND c.Name = 'Apple Valley' -- this would be variable
AND DATEPART(YEAR, ftd.CreatedDateTime) > DATEPART(YEAR, DATEADD(YEAR, -2,GETDATE())) -- limit to pull only two years
--AND DATEPART(MONTH, ftd.CreatedDateTime) = DATEADD(MONTH, -1, DATEPART(MONTH, GETDATE()))
GROUP BY DATEPART(YEAR, ftd.CreatedDateTime), DATEPART(MONTH,ftd.CreatedDateTime),FORMAT(ftd.CreatedDateTime, 'MMMM'),c.Name
ORDER By DATEPART(YEAR, ftd.CreatedDateTime) DESC

--SELECT * FROM @Temp
--ORDER BY year, month


SELECT
 t1.campus 'Campus'
, t1.year 'Year'
, t1.month 'Month'
, t1.monthword 'MonthWord'
, (SELECT current_year_total FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month AND t1.Campus = t2.Campus) 'LastYear'
, t1.current_year_total 'CurrentYear'
, t1.current_year_total - (SELECT t2.current_year_total FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month AND t1.Campus = t2.Campus) 'Difference'
, CONVERT(DECIMAL(18,2),((t1.current_year_total - (SELECT t2.current_year_total FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month AND t1.Campus = t2.Campus)) / (SELECT t2.current_year_total FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month AND t1.Campus = t2.Campus)) * 100)  'Percent'
, CASE WHEN t1.current_year_total < (SELECT t2.current_year_total FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month AND t1.Campus = t2.Campus) THEN 'Down' ELSE 'Up' END 'Direction'
FROM @Temp t1
WHERE t1.year = DATEPART(YEAR, GETDATE())
AND t1.month = DATEPART(MONTH, DATEADD(MONTH, -1,GETDATE()))
AND t1.Campus IS NOT NULL

UNION
SELECT
 'All Campuses' 'Campus'
, t1.year 'Year'
, t1.month 'Month'
, t1.monthword 'MonthWord'
, (SELECT SUM(current_year_total) FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month) 'LastYear'
, SUM(t1.current_year_total) 'CurrentYear'
, SUM(t1.current_year_total) - (SELECT SUM(t2.current_year_total) FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month) 'Difference'
, CONVERT(DECIMAL(18,2),((SUM(t1.current_year_total) - (SELECT SUM(t2.current_year_total) FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month)) / (SELECT SUM(t2.current_year_total) FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month)) * 100)  'Percent'
, CASE WHEN SUM(t1.current_year_total) < (SELECT SUM(t2.current_year_total) FROM @Temp t2 WHERE t2.year = t1.year - 1 AND t2.month = t1.month) THEN 'Down' ELSE 'Up' END 'Direction'
FROM @Temp t1
WHERE t1.year = DATEPART(YEAR, GETDATE())
AND t1.month = DATEPART(MONTH, DATEADD(MONTH, -1,GETDATE()))
GROUP BY t1.year, t1.month, t1.monthword
