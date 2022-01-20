
-- Q1
SELECT COUNT(DISTINCT OrderID)
FROM Orders
WHERE ShipperID = (
SELECT ShipperID FROM Shippers
WHERE ShipperName = 'Speedy Express');


-- Q2
SELECT LastName from Employees
WHERE EmployeeID =
(SELECT EmployeeID
FROM (SELECT COUNT(OrderID) AS TotalOrders, EmployeeID
FROM Orders
GROUP BY EmployeeID
ORDER BY TotalOrders DESC
LIMIT 1))





-- Q3
-- Extract ProductName from products table using ProductID
SELECT ProductName FROM Products
WHERE ProductID = (
	-- Extract just the product id for the product with highest qty sold in Germany
	SELECT ProductID
	FROM (
		-- List of ProductID and total Qty of that product ordered in Germany
		-- List limited to one row with the highest Qty ordered
		SELECT ProductID, SUM(Quantity) as QtyOrdered
		FROM (
			SELECT OrderDetails.OrderID, OrderDetails.ProductID, OrderDetails.Quantity
			FROM OrderDetails
			-- Filter out values from OrderDetails only for orders placed by Customers
			-- in Germany
			INNER JOIN
				(
					SELECT Orders.OrderID
					FROM Orders
					-- Filter out all orders from customers in Germany, avoid join here to
					-- potentially reduce computational complexity as future JOIN operation
					-- will only run on Orders that were placed within Germany
					-- instead of Joining entire tables
					WHERE Orders.CustomerID IN (
						-- Create list of all customer ids in Germany
						SELECT Customers.CustomerID
						FROM Customers
						WHERE Country = 'Germany'
					)
				) AS GermanOrders
			ON OrderDetails.OrderID = GermanOrders.OrderID
		)
		GROUP BY ProductID
		ORDER BY QtyOrdered DESC
		LIMIT 1
		)
)
