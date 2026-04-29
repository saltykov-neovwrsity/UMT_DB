-- =========================================================
-- Практична робота до теми 4: DDL та DML команди
-- База даних: publishing
-- Студент: Saltykov Andrii
-- =========================================================

DROP DATABASE IF EXISTS publishing;
CREATE DATABASE publishing
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE publishing;

-- =========================================================
-- 1. DDL: створення базових таблиць
-- =========================================================

CREATE TABLE authors (
  AuthorID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(200) NOT NULL,
  Email VARCHAR(255) UNIQUE,
  Phone VARCHAR(50),
  Country VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE employees (
  EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(200) NOT NULL,
  Role ENUM('Editor','Proofreader','Translator','Designer') NOT NULL,
  Email VARCHAR(255) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE books (
  BookID INT AUTO_INCREMENT PRIMARY KEY,
  Title VARCHAR(300) NOT NULL,
  Genre VARCHAR(100),
  ISBN VARCHAR(32) NOT NULL,
  PublishYear YEAR,
  CONSTRAINT uq_books_isbn UNIQUE (ISBN)
) ENGINE=InnoDB;

CREATE TABLE orders (
  OrderID INT AUTO_INCREMENT PRIMARY KEY,
  OrderDate DATE NOT NULL,
  ClientName VARCHAR(200) NOT NULL,
  Status ENUM('New','InProgress','Completed','Canceled') NOT NULL DEFAULT 'New'
) ENGINE=InnoDB;

CREATE TABLE contracts (
  ContractID INT AUTO_INCREMENT PRIMARY KEY,
  AuthorID INT NULL,
  EmployeeID INT NULL,
  ContractType ENUM('Author','Employee') NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE NULL,
  CONSTRAINT fk_contract_author FOREIGN KEY (AuthorID) REFERENCES authors(AuthorID)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_contract_employee FOREIGN KEY (EmployeeID) REFERENCES employees(EmployeeID)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX ix_contract_author (AuthorID),
  INDEX ix_contract_employee (EmployeeID)
) ENGINE=InnoDB;

-- =========================================================
-- 2. DDL: асоціативні таблиці для зв'язків M:N
-- =========================================================

CREATE TABLE authorbook (
  AuthorID INT NOT NULL,
  BookID INT NOT NULL,
  AuthorOrder INT NULL,
  PRIMARY KEY (AuthorID, BookID),
  CONSTRAINT fk_ab_author FOREIGN KEY (AuthorID) REFERENCES authors(AuthorID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ab_book FOREIGN KEY (BookID) REFERENCES books(BookID)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE employeebook (
  EmployeeID INT NOT NULL,
  BookID INT NOT NULL,
  Task ENUM('Edit','Proofread','Translate','Design') NOT NULL,
  PRIMARY KEY (EmployeeID, BookID),
  CONSTRAINT fk_eb_employee FOREIGN KEY (EmployeeID) REFERENCES employees(EmployeeID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_eb_book FOREIGN KEY (BookID) REFERENCES books(BookID)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE orderitem (
  OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT NOT NULL,
  BookID INT NOT NULL,
  Quantity INT NOT NULL,
  UnitPrice DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_oi_order FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_oi_book FOREIGN KEY (BookID) REFERENCES books(BookID)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX ix_oi_order (OrderID),
  INDEX ix_oi_book (BookID),
  CONSTRAINT chk_oi_qty CHECK (Quantity >= 1),
  CONSTRAINT chk_oi_price CHECK (UnitPrice >= 0)
) ENGINE=InnoDB;

-- Мінімальні тестові дані
INSERT INTO Authors (Name, Email, Country) VALUES
('Іван Карпенко','ivan@example.com','Switzerland'),
('Олена Руденко','olena@example.com','Switzerland');


INSERT INTO Employees (Name, Role, Email) VALUES
('Марк Дюпон','Editor','m.dupont@pub.ch'),
('Анна Мюллер','Proofreader','a.mueller@pub.ch');


INSERT INTO Books (Title, Genre, ISBN, PublishYear) VALUES
('Основи Python','Навчальна','978-1-234-56789-7',2025),
('Бази даних просто','Навчальна','978-1-987-65432-1',2025);


INSERT INTO AuthorBook (AuthorID, BookID, AuthorOrder) VALUES
(1,1,1),(2,2,1);


INSERT INTO EmployeeBook (EmployeeID, BookID, Task) VALUES
(1,1,'Edit'),(2,2,'Proofread');


INSERT INTO Orders (OrderDate, ClientName, Status) VALUES
('2025-10-30','TechEdu SA','New');


INSERT INTO OrderItem (OrderID, BookID, Quantity, UnitPrice) VALUES
(1,1,50,19.90),
(1,2,30,24.90);


INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate) VALUES
(1,NULL,'Author','2025-01-01','2025-12-31'),
(NULL,1,'Employee','2025-02-01',NULL);


-- =========================================================
-- 3. DML: вставка тестових даних
-- =========================================================

START TRANSACTION;

INSERT INTO authors (Name, Email, Phone, Country) VALUES
 ('Ірина Савчук','iryna.savchuk@ex.com','+380501111111','Ukraine'),
 ('Олег Петренко','oleg.petrenko@ex.com','+380671111112','Ukraine'),
 ('Maria Rossi','m.rossi@ex.com','+39061111111','Italy'),
 ('Jean Martin','jean.martin@ex.com','+33111111111','France'),
 ('Anna Müller','anna.mueller@ex.com','+41441111111','Switzerland'),
 ('Lukas Steiner','lukas.steiner@ex.com','+41441111112','Switzerland'),
 ('Sofia Garcia','sofia.garcia@ex.com','+34911111111','Spain'),
 ('Noah Johnson','noah.johnson@ex.com','+12025550111','USA'),
 ('Akira Tanaka','akira.tanaka@ex.com','+81311111111','Japan'),
 ('Eva Novak','eva.novak@ex.com','+42021111111','Czechia');

INSERT INTO employees (Name, Role, Email) VALUES
 ('Alice Novak','Editor','alice@pub.ch'),
 ('Bohdan Petrenko','Proofreader','bohdan@pub.ch'),
 ('Chloe Martin','Translator','chloe@pub.ch'),
 ('Dmytro Savchuk','Designer','dmytro@pub.ch'),
 ('Emma Rossi','Editor','emma@pub.ch'),
 ('Felix Weber','Proofreader','felix@pub.ch'),
 ('Hanna Kovalenko','Translator','hanna@pub.ch'),
 ('Ivan Horak','Designer','ivan@pub.ch'),
 ('Julia Novakova','Editor','julia@pub.ch'),
 ('Karl Meier','Proofreader','karl@pub.ch');

INSERT INTO books (Title, Genre, ISBN, PublishYear) VALUES
 ('Python для початківців','Навчальна','978-0-100000-001',2023),
 ('SQL на практиці','Навчальна','978-0-100000-002',2024),
 ('Data Analytics 101','Навчальна','978-0-100000-003',2025),
 ('Story Craft','Fiction','978-0-100000-004',2022),
 ('Mountains & Lakes','Travel','978-0-100000-005',2021),
 ('AI for Editors','Technology','978-0-100000-006',2025),
 ('Clean Data','Non-Fiction','978-0-100000-007',2020),
 ('Sci-Fi Tales','Sci-Fi','978-0-100000-008',2019),
 ('Business Blue','Business','978-0-100000-009',2024),
 ('Creative SQL','Technology','978-0-100000-010',2023);

INSERT INTO orders (OrderDate, ClientName, Status) VALUES
 (DATE '2025-01-10','TechBooks GmbH','New'),
 (DATE '2025-01-15','EduLab SA','Completed'),
 (DATE '2025-02-01','DataWorks AG','InProgress'),
 (DATE '2025-02-18','Libra LLC','Completed'),
 (DATE '2025-03-03','Orion Labs','New'),
 (DATE '2025-03-20','Pixel Media','InProgress'),
 (DATE '2025-04-05','QuickLearn','Completed'),
 (DATE '2025-04-22','Read&Co','New'),
 (DATE '2025-05-09','Star Books','Completed'),
 (DATE '2025-05-25','Nova Print','Canceled');

COMMIT;

-- =========================================================
-- 4. DML: наповнення асоціативних таблиць
-- =========================================================

START TRANSACTION;

INSERT INTO authorbook (AuthorID, BookID, AuthorOrder)
SELECT a.AuthorID, b.BookID, 1
FROM authors a
JOIN books b
WHERE (a.Email, b.ISBN) IN (
 ('iryna.savchuk@ex.com','978-0-100000-001'),
 ('oleg.petrenko@ex.com','978-0-100000-002'),
 ('m.rossi@ex.com','978-0-100000-003'),
 ('jean.martin@ex.com','978-0-100000-004'),
 ('anna.mueller@ex.com','978-0-100000-005'),
 ('lukas.steiner@ex.com','978-0-100000-006'),
 ('sofia.garcia@ex.com','978-0-100000-007'),
 ('noah.johnson@ex.com','978-0-100000-008'),
 ('akira.tanaka@ex.com','978-0-100000-009'),
 ('eva.novak@ex.com','978-0-100000-010')
);

INSERT INTO employeebook (EmployeeID, BookID, Task)
SELECT e.EmployeeID, b.BookID,
CASE e.Email
 WHEN 'alice@pub.ch' THEN 'Edit'
 WHEN 'bohdan@pub.ch' THEN 'Proofread'
 WHEN 'chloe@pub.ch' THEN 'Translate'
 WHEN 'dmytro@pub.ch' THEN 'Design'
 WHEN 'emma@pub.ch' THEN 'Edit'
 WHEN 'felix@pub.ch' THEN 'Proofread'
 WHEN 'hanna@pub.ch' THEN 'Translate'
 WHEN 'ivan@pub.ch' THEN 'Design'
 WHEN 'julia@pub.ch' THEN 'Edit'
 WHEN 'karl@pub.ch' THEN 'Proofread'
END AS Task
FROM employees e
JOIN books b
WHERE (e.Email, b.ISBN) IN (
 ('alice@pub.ch','978-0-100000-001'),
 ('bohdan@pub.ch','978-0-100000-002'),
 ('chloe@pub.ch','978-0-100000-003'),
 ('dmytro@pub.ch','978-0-100000-004'),
 ('emma@pub.ch','978-0-100000-005'),
 ('felix@pub.ch','978-0-100000-006'),
 ('hanna@pub.ch','978-0-100000-007'),
 ('ivan@pub.ch','978-0-100000-008'),
 ('julia@pub.ch','978-0-100000-009'),
 ('karl@pub.ch','978-0-100000-010')
);

COMMIT;

-- =========================================================
-- 5. DML: контракти
-- =========================================================

START TRANSACTION;

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', DATE '2025-01-01', DATE '2025-12-31'
FROM authors a WHERE a.Email='iryna.savchuk@ex.com';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', DATE '2025-02-01', NULL
FROM authors a WHERE a.Email='m.rossi@ex.com';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', DATE '2025-03-01', NULL
FROM authors a WHERE a.Email='anna.mueller@ex.com';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', DATE '2025-03-15', DATE '2026-03-15'
FROM authors a WHERE a.Email='akira.tanaka@ex.com';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT a.AuthorID, NULL, 'Author', DATE '2025-04-01', NULL
FROM authors a WHERE a.Email='eva.novak@ex.com';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', DATE '2025-01-10', NULL
FROM employees e WHERE e.Email='alice@pub.ch';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', DATE '2025-02-10', DATE '2025-12-31'
FROM employees e WHERE e.Email='bohdan@pub.ch';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', DATE '2025-03-05', NULL
FROM employees e WHERE e.Email='chloe@pub.ch';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', DATE '2025-03-20', NULL
FROM employees e WHERE e.Email='emma@pub.ch';

INSERT INTO contracts (AuthorID, EmployeeID, ContractType, StartDate, EndDate)
SELECT NULL, e.EmployeeID, 'Employee', DATE '2025-04-15', NULL
FROM employees e WHERE e.Email='karl@pub.ch';

COMMIT;

-- =========================================================
-- 6. DML: позиції замовлень
-- =========================================================

START TRANSACTION;

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 3, 49.90
FROM orders o JOIN books b
WHERE o.ClientName='TechBooks GmbH' AND o.OrderDate=DATE '2025-01-10'
  AND b.ISBN='978-0-100000-001';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 2, 59.00
FROM orders o JOIN books b
WHERE o.ClientName='EduLab SA' AND o.OrderDate=DATE '2025-01-15'
  AND b.ISBN='978-0-100000-002';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 1, 39.50
FROM orders o JOIN books b
WHERE o.ClientName='DataWorks AG' AND o.OrderDate=DATE '2025-02-01'
  AND b.ISBN='978-0-100000-003';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 5, 29.90
FROM orders o JOIN books b
WHERE o.ClientName='Libra LLC' AND o.OrderDate=DATE '2025-02-18'
  AND b.ISBN='978-0-100000-004';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 4, 54.00
FROM orders o JOIN books b
WHERE o.ClientName='Orion Labs' AND o.OrderDate=DATE '2025-03-03'
  AND b.ISBN='978-0-100000-005';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 3, 46.00
FROM orders o JOIN books b
WHERE o.ClientName='Pixel Media' AND o.OrderDate=DATE '2025-03-20'
  AND b.ISBN='978-0-100000-006';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 2, 32.00
FROM orders o JOIN books b
WHERE o.ClientName='QuickLearn' AND o.OrderDate=DATE '2025-04-05'
  AND b.ISBN='978-0-100000-007';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 6, 52.50
FROM orders o JOIN books b
WHERE o.ClientName='Read&Co' AND o.OrderDate=DATE '2025-04-22'
  AND b.ISBN='978-0-100000-008';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 2, 28.90
FROM orders o JOIN books b
WHERE o.ClientName='Star Books' AND o.OrderDate=DATE '2025-05-09'
  AND b.ISBN='978-0-100000-009';

INSERT INTO orderitem (OrderID, BookID, Quantity, UnitPrice)
SELECT o.OrderID, b.BookID, 7, 44.00
FROM orders o JOIN books b
WHERE o.ClientName='Nova Print' AND o.OrderDate=DATE '2025-05-25'
  AND b.ISBN='978-0-100000-010';

COMMIT;  

-- =========================================================
-- 7. SELECT: перевірка вмісту таблиць
-- =========================================================

SELECT 'authors' AS tbl, COUNT(*) AS cnt FROM authors
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'authorbook', COUNT(*) FROM authorbook
UNION ALL SELECT 'employeebook', COUNT(*) FROM employeebook
UNION ALL SELECT 'contracts', COUNT(*) FROM contracts
UNION ALL SELECT 'orderitem', COUNT(*) FROM orderitem;

-- =========================================================
-- Перевіримо вміст таблиць
-- =========================================================

SELECT * FROM authors LIMIT 0, 1000;
SELECT * FROM employees;
SELECT * FROM books;
SELECT * FROM authorbook;
SELECT * FROM employeebook;
SELECT * FROM contracts;
SELECT * FROM orders;
SELECT * FROM orderitem;