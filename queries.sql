-- ============================================================
-- Laboratory Database: Business Questions Answered in SQL
-- Run schema.sql first (MySQL 8+), then these queries.
-- ============================================================
USE laboratory;

-- 1. Workload: how many tests has each employee handled?
SELECT e.EmployeeID,
       CONCAT(e.First, ' ', e.Last) AS Employee,
       COUNT(*)                     AS TestsHandled
FROM EMPLOYEE e
JOIN HANDLES h ON h.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.First, e.Last
ORDER BY TestsHandled DESC;

-- 2. Top clients: which clients order the most tests?
SELECT c.ClientID, c.CompanyName, c.State,
       COUNT(o.TestID) AS TestsOrdered
FROM CLIENT c
JOIN ORDERS o ON o.ClientID = c.ClientID
GROUP BY c.ClientID, c.CompanyName, c.State
ORDER BY TestsOrdered DESC, c.CompanyName;

-- 3. Contamination traceability: which tests and clients were exposed to a
--    fume hood that FAILED its most recent inspection?
SELECT DISTINCT i.HoodID, i.DateRecentInspect, u.TestID, o.ClientID, c.CompanyName
FROM INSPECT i
JOIN USES    u ON u.HoodID   = i.HoodID
JOIN ORDERS  o ON o.TestID   = u.TestID
JOIN CLIENT  c ON c.ClientID = o.ClientID
WHERE i.Result = 'Fail'
ORDER BY u.TestID, c.CompanyName;

-- 4. Inventory risk: materials expiring within the next 12 months
SELECT LotNumber, Name, ExpDate,
       DATEDIFF(ExpDate, CURDATE()) AS DaysToExpiry
FROM MATERIAL
WHERE ExpDate <= DATE_ADD(CURDATE(), INTERVAL 12 MONTH)
ORDER BY ExpDate;

-- 5. Test recipe: which materials, hoods, and departments does each test use?
SELECT u.TestID, u.HoodID, f.DepName, m.LotNumber, m.Name AS Material
FROM USES u
JOIN FUMEHOOD f ON f.HoodID    = u.HoodID
JOIN MATERIAL m ON m.LotNumber = u.LotNumber
ORDER BY u.TestID, u.HoodID;

-- 6. Equipment utilization: how often is each fume hood used, by department?
SELECT f.DepName, f.HoodID, COUNT(u.TestID) AS TimesUsed
FROM FUMEHOOD f
LEFT JOIN USES u ON u.HoodID = f.HoodID
GROUP BY f.DepName, f.HoodID
ORDER BY f.DepName, TimesUsed DESC;

-- 7. Service gaps: test orders with no employee assigned yet
SELECT o.TestID, o.ClientID, c.CompanyName
FROM ORDERS o
JOIN CLIENT c ON c.ClientID = o.ClientID
LEFT JOIN HANDLES h ON h.TestID = o.TestID AND h.ClientID = o.ClientID
WHERE h.EmployeeID IS NULL;

-- 8. Workforce: headcount and average salary by hire year
SELECT YEAR(HireDate)        AS HireYear,
       COUNT(*)              AS Headcount,
       ROUND(AVG(Salary), 0) AS AvgSalary
FROM EMPLOYEE
GROUP BY YEAR(HireDate)
ORDER BY HireYear;
