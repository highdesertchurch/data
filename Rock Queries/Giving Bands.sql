


DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
SET @EndDate = GETDATE()
SET @StartDate = DATEADD(Day, -365, @EndDate)
DECLARE @Data TABLE (GivingId VARCHAR(10), GiftAmount INT, GiftCount INT)

-- Insert all data into the temp table
INSERT INTO @Data
SELECT p.GivingId
, 	(SELECT SUM(ftd.Amount)
    FROM FinancialTransaction ft
	INNER JOIN PersonAlias as pa on pa.Id = ft.AuthorizedPersonAliasId
    JOIN FinancialTransactionDetail ftd on ftd.TransactionId = ft.Id
    WHERE ft.TransactionDateTime >= @StartDate
    AND ft.TransactionDateTime <= @EndDate
	AND pa.PersonId = p.Id
    AND ft.TransactionTypeValueId = 53
    AND ftd.AccountId = 7)
, (SELECT COUNT(ft.Id)
    FROM FinancialTransaction ft
	INNER JOIN PersonAlias as pa on pa.Id = ft.AuthorizedPersonAliasId
    JOIN FinancialTransactionDetail ftd on ftd.TransactionId = ft.Id
    WHERE ft.TransactionDateTime >= @StartDate
    AND ft.TransactionDateTime <= @EndDate
	AND pa.PersonId = p.Id
    AND ft.TransactionTypeValueId = 53
    AND ftd.AccountId = 7)
FROM Person p
GROUP BY p.GivingId, p.Id

DECLARE @GivingSums TABLE (GivingId VARCHAR(10), GivingSum MONEY, GiftCount INT)
-- Insert Sums into @GivingSums
INSERT INTO @GivingSums
SELECT GivingId
, SUM(GiftAmount)
, SUM(GiftCount)
FROM @Data
Where GiftAmount IS NOT NULL
--AND GivingId = 'G41443'
GROUP BY GivingId, GiftAmount

-- Drop all Giving sums that are 0 or under
DELETE @GivingSums
WHERE GivingSum <= 0

-- Giving Bands Display
SELECT [Band], [Families], [Giving], [Average],[% Families], [% Giving]
FROM (
	SELECT  0 AS 'Order',
			'Band 1 - $0 - $199' AS 'Band',
			COUNT(*) AS 'Families',
			'$' + CONVERT(varchar, SUM(gs.GivingSum), 1) AS 'Giving',
			'$' + CONVERT(varchar, AVG(gs.GivingSum), 1) AS 'Average',
			CONVERT(varchar, CAST((CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Families',
			CONVERT(varchar, CAST((SUM(gs.GivingSum) / (SELECT SUM(GivingSum) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Giving'
		FROM @GivingSums AS gs
		WHERE gs.GivingSum BETWEEN 0 AND 199.999
		UNION SELECT 1 AS 'Order',
			'Band 2 - $200 - $999' AS 'Band',
			COUNT(*) AS 'Families',
			'$' + CONVERT(varchar, SUM(gs.GivingSum), 1) AS 'Giving',
			'$' + CONVERT(varchar, AVG(gs.GivingSum), 1) AS 'Average',
			CONVERT(varchar, CAST((CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Families',
			CONVERT(varchar, CAST((SUM(gs.GivingSum) / (SELECT SUM(GivingSum) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Giving'
		FROM @GivingSums AS gs
		WHERE gs.GivingSum BETWEEN 200 AND 999.999
		UNION SELECT 2 AS 'Order',
			'Band 3 - $1000 - $4999' AS 'Band',
			COUNT(*) AS 'Families',
			'$' + CONVERT(varchar, SUM(gs.GivingSum), 1) AS 'Giving',
			'$' + CONVERT(varchar, AVG(gs.GivingSum), 1) AS 'Average',
			CONVERT(varchar, CAST((CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Families',
			CONVERT(varchar, CAST((SUM(gs.GivingSum) / (SELECT SUM(GivingSum) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Giving'
		FROM @GivingSums AS gs
		WHERE gs.GivingSum BETWEEN 1000 AND 4999.999
		UNION SELECT 3 AS 'Order',
			'Band 4 - $5000 - $9999' AS 'Band',
			COUNT(*) AS 'Families',
			'$' + CONVERT(varchar, SUM(gs.GivingSum), 1) AS 'Giving',
			'$' + CONVERT(varchar, AVG(gs.GivingSum), 1) AS 'Average',
			CONVERT(varchar, CAST((CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Families',
			CONVERT(varchar, CAST((SUM(gs.GivingSum) / (SELECT SUM(GivingSum) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Giving'
		FROM @GivingSums AS gs
		WHERE gs.GivingSum BETWEEN 5000 AND 9999.999
		UNION SELECT 4 AS 'Order',
			'Band 5 - $10000+' AS 'Band',
			COUNT(*) AS 'Families',
			'$' + CONVERT(varchar, SUM(gs.GivingSum), 1) AS 'Giving',
			'$' + CONVERT(varchar, AVG(gs.GivingSum), 1) AS 'Average',
			CONVERT(varchar, CAST((CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Families',
			CONVERT(varchar, CAST((SUM(gs.GivingSum) / (SELECT SUM(GivingSum) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Giving'
		FROM @GivingSums AS gs
		WHERE gs.GivingSum >= 10000
			UNION SELECT 5 AS 'Order',
			'Totals' AS 'Band',
			COUNT(*) AS 'Families',
			'$' + CONVERT(varchar, SUM(gs.GivingSum), 1) AS 'Giving',
			'$' + CONVERT(varchar, AVG(gs.GivingSum), 1) AS 'Average',
			CONVERT(varchar, CAST((CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Families',
			CONVERT(varchar, CAST((SUM(gs.GivingSum) / (SELECT SUM(GivingSum) FROM @GivingSums) * 100) AS MONEY), 1) + '%' AS '% Giving'
		FROM @GivingSums AS gs
		--WHERE gs.GivingSum >= 10000
) s ORDER BY [Order]

-- Display the Frequency of each band
SELECT [Band], [1x], [1x %], [4x], [4x %], [6x], [6x %], [12x], [12x %]
FROM (
SELECT  0 AS 'Order'
, 'Band 1' AS [Band]
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 0 AND 199.999) AS [1x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 0 AND 199.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 0 AND 199.999) * 100) AS MONEY), 1) + '%' AS '1x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 0 AND 199.999) AS [4x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 0 AND 199.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 0 AND 199.999) * 100) AS MONEY), 1) + '%' AS '4x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 0 AND 199.999) AS [6x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 0 AND 199.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 0 AND 199.999) * 100) AS MONEY), 1) + '%' AS '6x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 0 AND 199.999) AS [12x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 0 AND 199.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 0 AND 199.999) * 100) AS MONEY), 1) + '%' AS '12x %'
FROM @GivingSums gs
WHERE gs.GivingSum BETWEEN 0 AND 199.999
UNION SELECT  1 AS 'Order'
, 'Band 2' AS [Band]
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 200 AND 999.999) AS [1x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 200 AND 999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 200 AND 999.999) * 100) AS MONEY), 1) + '%' AS '1x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 200 AND 999.999) AS [4x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 200 AND 999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 200 AND 999.999) * 100) AS MONEY), 1) + '%' AS '4x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 200 AND 999.999) AS [6x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 200 AND 999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 200 AND 999.999) * 100) AS MONEY), 1) + '%' AS '6x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 200 AND 999.999) AS [12x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 200 AND 999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 200 AND 999.999) * 100) AS MONEY), 1) + '%' AS '12x %'
FROM @GivingSums gs
WHERE gs.GivingSum BETWEEN 200 AND 999.999

UNION SELECT  2 AS 'Order'
, 'Band 3' AS [Band]
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS [1x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 1000 AND 4999.999) * 100) AS MONEY), 1) + '%' AS '1x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS [4x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 1000 AND 4999.999) * 100) AS MONEY), 1) + '%' AS '4x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS [6x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 1000 AND 4999.999) * 100) AS MONEY), 1) + '%' AS '6x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS [12x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 1000 AND 4999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 1000 AND 4999.999) * 100) AS MONEY), 1) + '%' AS '12x %'
FROM @GivingSums gs
WHERE gs.GivingSum BETWEEN 1000 AND 4999.999

UNION SELECT  3 AS 'Order'
, 'Band 4' AS [Band]
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS [1x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 5000 AND 9999.999) * 100) AS MONEY), 1) + '%' AS '1x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS [4x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 5000 AND 9999.999) * 100) AS MONEY), 1) + '%' AS '4x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS [6x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 5000 AND 9999.999) * 100) AS MONEY), 1) + '%' AS '6x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS [12x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum BETWEEN 5000 AND 9999.999) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum BETWEEN 5000 AND 9999.999) * 100) AS MONEY), 1) + '%' AS '12x %'
FROM @GivingSums gs
WHERE gs.GivingSum BETWEEN 5000 AND 9999.999

UNION SELECT  4 AS 'Order'
, 'Band 5' AS [Band]
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum >= 10000) AS [1x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 AND gs.GivingSum >= 10000) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum >= 10000) * 100) AS MONEY), 1) + '%' AS '1x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum >= 10000) AS [4x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 AND gs.GivingSum >= 10000) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum >= 10000) * 100) AS MONEY), 1) + '%' AS '4x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum >= 10000) AS [6x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 AND gs.GivingSum >= 10000) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum >= 10000) * 100) AS MONEY), 1) + '%' AS '6x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum >= 10000) AS [12x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 12 AND gs.GivingSum >= 10000) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GivingSum >= 10000) * 100) AS MONEY), 1) + '%' AS '12x %'
FROM @GivingSums gs
WHERE gs.GivingSum >= 10000

UNION SELECT  4 AS 'Order'
, 'Totals' AS [Band]
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 ) AS [1x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 1 AND gs.GiftCount < 4 ) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs) * 100) AS MONEY), 1) + '%' AS '1x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 ) AS [4x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GiftCount < 6 ) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs) * 100) AS MONEY), 1) + '%' AS '4x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 ) AS [6x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 6 AND gs.GiftCount < 12 ) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs) * 100) AS MONEY), 1) + '%' AS '6x %'
, (SELECT COUNT(gs.GivingId) FROM @GivingSums gs WHERE gs.GiftCount >= 12 ) AS [12x]
, CONVERT(varchar, CAST((CAST((SELECT COUNT(*) FROM @GivingSums gs WHERE gs.GiftCount >= 12 ) AS FLOAT) / (SELECT COUNT(*) FROM @GivingSums gs) * 100) AS MONEY), 1) + '%' AS '12x %'
FROM @GivingSums gs
WHERE gs.GivingSum > 0

) s ORDER BY [Order]

SELECT COUNT(gs.GivingId) AS [Giving Band 3+ and 4x or more] FROM @GivingSums gs WHERE gs.GiftCount >= 4 AND gs.GivingSum >= 1000
