-- =========================================================
-- Практична робота до теми 6: Складні SQL вирази
-- База даних: publishing
-- Студент: Saltykov Andrii
-- =========================================================

USE publishing;

-- Задача 1. Створення тригерів BEFORE INSERT і BEFORE UPDATE

-- Видалення старих тригерів перед повторним запуском
DROP TRIGGER IF EXISTS trg_contracts_bi;
DROP TRIGGER IF EXISTS trg_contracts_bu;

DELIMITER $$

CREATE TRIGGER trg_contracts_bi
BEFORE INSERT ON contracts
FOR EACH ROW
BEGIN
  IF (NEW.AuthorID IS NULL AND NEW.EmployeeID IS NULL)
     OR (NEW.AuthorID IS NOT NULL AND NEW.EmployeeID IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Exactly one of AuthorID or EmployeeID must be set';
  END IF;

  IF (NEW.AuthorID IS NOT NULL AND NEW.ContractType <> 'Author')
     OR (NEW.EmployeeID IS NOT NULL AND NEW.ContractType <> 'Employee') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ContractType must match owner Author or Employee';
  END IF;

  IF NEW.EndDate IS NOT NULL AND NEW.EndDate < NEW.StartDate THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'EndDate must be greater than or equal to StartDate';
  END IF;
END$$

CREATE TRIGGER trg_contracts_bu
BEFORE UPDATE ON contracts
FOR EACH ROW
BEGIN
  IF (NEW.AuthorID IS NULL AND NEW.EmployeeID IS NULL)
     OR (NEW.AuthorID IS NOT NULL AND NEW.EmployeeID IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Exactly one of AuthorID or EmployeeID must be set';
  END IF;

  IF (NEW.AuthorID IS NOT NULL AND NEW.ContractType <> 'Author')
     OR (NEW.EmployeeID IS NOT NULL AND NEW.ContractType <> 'Employee') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ContractType must match owner Author or Employee';
  END IF;

  IF NEW.EndDate IS NOT NULL AND NEW.EndDate < NEW.StartDate THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'EndDate must be greater than or equal to StartDate';
  END IF;
END$$

DELIMITER ;

-- Задача 2. Тригери BEFORE INSERT і BEFORE UPDATE

-- Видалення старих тригерів перед повторним запуском
DROP TRIGGER IF EXISTS trg_contracts_bi;

DELIMITER $$

CREATE TRIGGER trg_contracts_bi
BEFORE INSERT ON Contracts
FOR EACH ROW
BEGIN

IF (NEW.AuthorID IS NULL AND NEW.EmployeeID IS NULL)
     OR (NEW.AuthorID IS NOT NULL AND NEW.EmployeeID IS NOT NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Exactly one of AuthorID or EmployeeID must be set';
  END IF;

  IF (NEW.AuthorID IS NOT NULL AND NEW.ContractType <> 'Author')
     OR (NEW.EmployeeID IS NOT NULL AND NEW.ContractType <> 'Employee') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'ContractType must match owner (Author/Employee)';
  END IF;

  IF NEW.EndDate IS NOT NULL AND NEW.EndDate < NEW.StartDate THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'EndDate must be >= StartDate';
  END IF;


END$$

DELIMITER ;

-- Задача 3. Перевірка роботи тригерів

-- коректна вставка
INSERT INTO Contracts (AuthorID, ContractType, StartDate, EndDate)
VALUES (1, 'Author', '2025-06-01', '2025-12-31');


-- помилка 1: два власники
INSERT INTO Contracts (AuthorID, EmployeeID, ContractType, StartDate)
VALUES (1, 1, 'Author', '2025-06-01');


-- помилка 2: неправильний тип
INSERT INTO Contracts (AuthorID, ContractType, StartDate)
VALUES (1, 'Employee', '2025-06-01');


-- помилка 3: неправильні дати
INSERT INTO Contracts (AuthorID, ContractType, StartDate, EndDate)
VALUES (1, 'Author', '2025-12-01', '2025-01-01');


-- Задача 4. Аналітична перевірка

SELECT ContractID, ContractType, StartDate, EndDate
FROM Contracts
WHERE EndDate > CURRENT_DATE()
OR EndDate IS NULL
ORDER BY StartDate DESC;