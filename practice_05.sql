-- =========================================================
-- Практична робота до теми 5: DQL команди
-- База даних: publishing
-- Студент: Saltykov Andrii
--
-- Усі назви таблиць наведені в lowercase.
-- =========================================================

USE publishing;

-- Задача 1. Прості вибірки
SELECT * FROM authors;

SELECT Name, Country
FROM authors
WHERE Country = 'Ukraine';

SELECT Title, Genre, PublishYear
FROM books
ORDER BY PublishYear DESC;

-- Задача 2. JOIN: автори і книги
SELECT a.Name AS Author, b.Title AS Book
FROM authors a
JOIN authorbook ab ON a.AuthorID = ab.AuthorID
JOIN books b ON b.BookID = ab.BookID;

-- Задача 3. Фільтрація і сортування
SELECT Title, Genre, PublishYear
FROM books
WHERE Genre = 'Technology'
ORDER BY PublishYear DESC;

-- Задача 4. Агрегація і групування
SELECT b.Genre, COUNT(*) AS BooksCount
FROM books b
GROUP BY b.Genre
ORDER BY BooksCount DESC;

-- Задача 5. HAVING
SELECT b.Title, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.Title
HAVING Revenue > 300
ORDER BY Revenue DESC;

-- Задача 6. Вкладені запити
SELECT b.Title
FROM books b
WHERE b.BookID IN (
    SELECT BookID
    FROM orderitem
);

-- Задача 7. EXISTS
SELECT a.Name
FROM authors a
WHERE EXISTS (
    SELECT 1
    FROM authorbook ab
    JOIN orderitem oi ON oi.BookID = ab.BookID
    WHERE ab.AuthorID = a.AuthorID
);

-- Задача 8. Віконні функції
WITH sales AS (
    SELECT b.Title, b.Genre,
           SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM orderitem oi
    JOIN books b ON b.BookID = oi.BookID
    GROUP BY b.Title, b.Genre
)
SELECT *,
       RANK() OVER (PARTITION BY Genre ORDER BY Revenue DESC) AS GenreRank
FROM sales;

-- Задача 9. Базові вибірки
SELECT EmployeeID, Name, Role, Email
FROM employees;

SELECT AuthorID, Name, Email, Country
FROM authors;

SELECT BookID, Title, Genre, ISBN, PublishYear
FROM books;

-- Задача 10. WHERE + ORDER BY
SELECT Title, Genre, PublishYear
FROM books
WHERE Genre = 'Technology'
ORDER BY PublishYear DESC;

SELECT Name, Email
FROM authors
WHERE Country = 'Ukraine'
ORDER BY Name;

-- Задача 11. JOIN: головний автор кожної книги
SELECT b.BookID, b.Title, a.AuthorID, a.Name AS Author
FROM authorbook ab
JOIN authors a ON a.AuthorID = ab.AuthorID
JOIN books b ON b.BookID = ab.BookID
WHERE ab.AuthorOrder = 1
ORDER BY b.Title;

-- Задача 12. JOIN: співробітники і книги
SELECT e.Name AS Employee,
       b.Title AS Book,
       eb.Task
FROM employeebook eb
JOIN employees e ON e.EmployeeID = eb.EmployeeID
JOIN books b ON b.BookID = eb.BookID
ORDER BY e.Name, b.Title;

-- Задача 13. Замовлення з позиціями та сумами
SELECT o.OrderID, o.OrderDate, o.ClientName,
       b.Title,
       oi.Quantity, oi.UnitPrice,
       (oi.Quantity * oi.UnitPrice) AS LineTotal
FROM orders o
JOIN orderitem oi ON oi.OrderID = o.OrderID
JOIN books b ON b.BookID = oi.BookID
ORDER BY o.OrderDate DESC, o.OrderID;

SELECT o.OrderID, o.OrderDate, o.ClientName,
       SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
FROM orders o
JOIN orderitem oi ON oi.OrderID = o.OrderID
GROUP BY o.OrderID, o.OrderDate, o.ClientName
ORDER BY o.OrderDate DESC;

-- Задача 14. Агрегації та рейтинги
SELECT a.AuthorID, a.Name, COUNT(*) AS BooksCount
FROM authorbook ab
JOIN authors a ON a.AuthorID = ab.AuthorID
GROUP BY a.AuthorID, a.Name
ORDER BY BooksCount DESC, a.Name;

SELECT b.BookID, b.Title,
       SUM(oi.Quantity) AS QtySold,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.BookID, b.Title
ORDER BY Revenue DESC;

-- Задача 15. HAVING: книги з виручкою понад 300
SELECT b.Title,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM orderitem oi
JOIN books b ON b.BookID = oi.BookID
GROUP BY b.Title
HAVING Revenue > 300
ORDER BY Revenue DESC;

-- Задача 16. NOT EXISTS: автори, чиї книги не замовляли
SELECT a.AuthorID, a.Name
FROM authors a
WHERE NOT EXISTS (
  SELECT 1
  FROM authorbook ab
  JOIN orderitem oi ON oi.BookID = ab.BookID
  WHERE ab.AuthorID = a.AuthorID
);

-- Задача 17. Дати, статуси, фільтри по періоду
SELECT OrderID, OrderDate, ClientName, Status
FROM orders
WHERE OrderDate BETWEEN DATE '2025-05-01' AND DATE '2025-05-31'
  AND Status IN ('New','Completed')
ORDER BY OrderDate DESC;

-- Задача 18. Контроль зв'язків у контрактах
SELECT c.ContractID,
       a.Name AS Author,
       e.Name AS Employee,
       c.ContractType,
       c.StartDate,
       c.EndDate
FROM contracts c
LEFT JOIN authors a ON a.AuthorID = c.AuthorID
LEFT JOIN employees e ON e.EmployeeID = c.EmployeeID
ORDER BY c.StartDate DESC, c.ContractID;

-- Задача 19. Віконні функції: ранжування продажів у межах жанру
WITH sales AS (
  SELECT b.BookID, b.Title, b.Genre,
         SUM(oi.Quantity * oi.UnitPrice) AS Revenue
  FROM orderitem oi
  JOIN books b ON b.BookID = oi.BookID
  GROUP BY b.BookID, b.Title, b.Genre
)
SELECT *,
       DENSE_RANK() OVER (PARTITION BY Genre ORDER BY Revenue DESC) AS GenreRank
FROM sales
ORDER BY Genre, GenreRank;

-- Додаткове 1. Книги з продажами вище середніх по всіх книгах
SELECT b.BookID,
       b.Title,
       b.Genre,
       SUM(oi.Quantity) AS TotalSold
FROM books b
JOIN orderitem oi ON b.BookID = oi.BookID
JOIN orders o ON oi.OrderID = o.OrderID
WHERE o.Status = 'Completed'
GROUP BY b.BookID, b.Title, b.Genre
HAVING SUM(oi.Quantity) > (
    SELECT AVG(BookSales.TotalSold)
    FROM (
        SELECT oi2.BookID,
               SUM(oi2.Quantity) AS TotalSold
        FROM orderitem oi2
        JOIN orders o2 ON oi2.OrderID = o2.OrderID
        WHERE o2.Status = 'Completed'
        GROUP BY oi2.BookID
    ) AS BookSales
);

-- Додаткове 2. Автор з найбільшим сумарним доходом від продажів
SELECT a.AuthorID,
       a.Name AS AuthorName,
       SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM authors a
JOIN authorbook ab ON a.AuthorID = ab.AuthorID
JOIN books b ON ab.BookID = b.BookID
JOIN orderitem oi ON b.BookID = oi.BookID
JOIN orders o ON oi.OrderID = o.OrderID
WHERE o.Status = 'Completed'
GROUP BY a.AuthorID, a.Name
ORDER BY TotalRevenue DESC
LIMIT 1;

-- Додаткове 3. Кількість замовлень у кожного клієнта
SELECT ClientName,
       COUNT(OrderID) AS OrdersCount
FROM orders
GROUP BY ClientName
ORDER BY OrdersCount DESC;

-- Додаткове 4. Активні контракти
SELECT c.ContractID,
       c.ContractType,
       c.StartDate,
       c.EndDate,
       a.Name AS AuthorName,
       e.Name AS EmployeeName
FROM contracts c
LEFT JOIN authors a ON c.AuthorID = a.AuthorID
LEFT JOIN employees e ON c.EmployeeID = e.EmployeeID
WHERE c.EndDate IS NULL
   OR c.EndDate > CURDATE()
ORDER BY c.StartDate;

-- Додаткове 5. 5 найпопулярніших жанрів
SELECT b.Genre,
       SUM(oi.Quantity) AS TotalSold
FROM books b
JOIN orderitem oi ON b.BookID = oi.BookID
JOIN orders o ON oi.OrderID = o.OrderID
WHERE o.Status = 'Completed'
  AND b.Genre IS NOT NULL
GROUP BY b.Genre
ORDER BY TotalSold DESC
LIMIT 5;
