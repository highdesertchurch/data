DECLARE @GroupType INT
DECLARE @AllGiving TABLE (GiftDate DATE, GivingAmount MONEY, AccountName VARCHAR(256), Campus_Id INT, Method VARCHAR(256))
SET @GroupType = 10 --FAMILY GROUPS
-- Gather all Giving
INSERT INTO @AllGiving
SELECT
ft.TransactionDateTime
, ftd.Amount GivingAmount
, fa.Name AccountName
, g.CampusId
, dv.Value
FROM FinancialTransactionDetail ftd
JOIN FinancialTransaction ft on ft.Id = ftd.TransactionId
JOIN FinancialAccount fa on fa.Id = ftd.AccountId
INNER JOIN [FinancialPaymentDetail] fpd ON fpd.[Id] = ft.[FinancialPaymentDetailId]
JOIN [DefinedValue] dv ON dv.[Id] = fpd.[CurrencyTypeValueId]
JOIN PersonAlias pa on pa.Id = ft.AuthorizedPersonAliasId
JOIN Person p on p.id = pa.PersonId
JOIN GroupMember gm on gm.PersonId = p.Id
JOIN [Group] g on g.Id = gm.GroupId
--GROUP By DatePart(WEEK, ft.TransactionDateTime), DATEPART(YEAR, ft.TransactionDateTime), DATEPART(MONTH, ft.TransactionDateTime), fa.Name, c.Name
WHERE g.grouptypeid = @GroupType
ORDER BY DATEPART(YEAR, ft.TransactionDateTime), DatePart(WEEK, ft.TransactionDateTime)

SELECT *
FROM @AllGiving
