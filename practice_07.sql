-- =========================================================
-- Практична робота до теми 7
-- «Вкладені запити. Повторне використання коду»
-- База даних: publishing
-- Студент: Saltykov Andrii
-- =========================================================

USE publishing;

-- =========================================================
-- Задача 1. Підзапит для визначення авторів, чиї книги не замовляли
-- =========================================================

-- Додаємо автора без замовлень
INSERT INTO authors (Name, Email, Phone, Country)
VALUES ('Test Author', 'test.author@example.com', '+380501112233', 'Ukraine');

INSERT INTO books (Title, Genre, ISBN, PublishYear)
VALUES ('Book Without Sales', 'Educational', '978-0-TEST-0001', 2026);

INSERT INTO authorbook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM authors a
JOIN books b
WHERE a.Email = 'test.author@example.com'
  AND b.ISBN = '978-0-TEST-0001';

SELECT a.AuthorID, a.Name
FROM Authors a
WHERE NOT EXISTS (
  SELECT 1
  FROM AuthorBook ab
  JOIN OrderItem oi ON oi.BookID = ab.BookID
  WHERE ab.AuthorID = a.AuthorID
);

-- =========================================================
-- Задача 2. Книги з продажами вище середнього
-- =========================================================

SELECT b.Title, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM OrderItem oi
JOIN Books b ON b.BookID = oi.BookID
GROUP BY b.Title
HAVING Revenue > (
  SELECT AVG(Quantity * UnitPrice) FROM OrderItem
);



-- =========================================================
-- Задача 3.  Рейтинг книг у межах жанру 
-- =========================================================

WITH sales AS (
  SELECT b.Title, b.Genre, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
  FROM Books b
  JOIN OrderItem oi ON oi.BookID = b.BookID
  GROUP BY b.Title, b.Genre
)
SELECT Title, Genre, Revenue,
       RANK() OVER (PARTITION BY Genre ORDER BY Revenue DESC) AS GenreRank
FROM sales;



-- =========================================================
-- Задача 4. Повторне використання коду
-- =========================================================

CREATE OR REPLACE VIEW v_book_sales AS
SELECT b.BookID, b.Title, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM Books b
LEFT JOIN OrderItem oi ON oi.BookID = b.BookID
GROUP BY b.BookID, b.Title;

SELECT * FROM v_book_sales ORDER BY Revenue DESC;