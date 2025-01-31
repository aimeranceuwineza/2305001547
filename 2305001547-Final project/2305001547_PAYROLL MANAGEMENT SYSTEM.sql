-- CREATE DATABASE 
CREATE DATABASE PAYROLLMANAGEMENTSYSTEM;
USE PAYROLLMANAGEMENTSYSTEM;

-- CREATE TBLES
-- CREATE TABLE EMPLOYEES(EMP_ID INT PRIMARY KEY,EMP_Name VARCHAR(100),EMP_Address VARCHAR(100),EMP_Email VARCHAR(100),
-- EMP_Contact VARCHAR(100),Emp_Dept_ID INT,Emp_Join_Date DATE);

CREATE TABLE EMPLOYEES (
    EMP_ID INT PRIMARY KEY,           
    EMP_Name VARCHAR(100),          
    EMP_Address VARCHAR(100),      
    EMP_Email VARCHAR(100),       
    EMP_Contact VARCHAR(100),         
    Emp_Dept_ID INT,              
    Emp_Join_Date DATE      
);

CREATE TABLE SALARY (
    SALARY_ID INT PRIMARY KEY,        
    EMP_ID INT,                       
    BasicSalary INT,                  
    GrossSalary INT,                  
    NetSalary INT,                    
    SalaryDate DATE,           
    FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEES(EMP_ID)  
);

CREATE TABLE DEDUCTIONS (
    DEDUCTION_ID INT PRIMARY KEY,      
    EMP_ID INT,                        
    DeductionType VARCHAR(50),      
    DeductionAmount INT,               
    DeductionDate DATE,          
    FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEES(EMP_ID)  
);

SHOW TABLES;

-- CREATE: Insert a new employee record

INSERT INTO EMPLOYEES (EMP_ID, EMP_Name, EMP_Address, EMP_Email, EMP_Contact, Emp_Dept_ID, Emp_Join_Date) 
VALUES 
(101, 'John Doe', '123 Elm Street', 'johndoe@example.com', '123-456-7890', 1, '2020-06-15'),
(102, 'Jane Smith', '456 Oak Avenue', 'janesmith@example.com', '123-456-7891', 2, '2021-08-10'),
(103, 'Alice Johnson', '789 Pine Road', 'alicej@example.com', '123-456-7892', 1, '2019-03-25'),
(104, 'Bob Brown', '321 Maple Drive', 'bobbrown@example.com', '123-456-7893', 3, '2022-01-05'),
(105, 'Eve White', '654 Cedar Lane', 'evewhite@example.com', '123-456-7894', 2, '2023-07-20');

-- READ: Retrieve all employees
SELECT * FROM EMPLOYEES;

INSERT INTO SALARY (SALARY_ID, EMP_ID, BasicSalary, HRA, OtherAllowances, GrossSalary, NetSalary, SalaryDate) 
VALUES 
(1, 101, 50000, 10000, 5000, 65000, 60000, '2025-01-30'),
(2, 102, 55000, 12000, 7000, 74000, 70000, '2025-01-30'),
(3, 103, 48000, 8000, 4000, 60000, 55000, '2025-01-30'),
(4, 104, 60000, 15000, 8000, 83000, 78000, '2025-01-30'),
(5, 105, 52000, 11000, 6000, 69000, 64000, '2025-01-30');

-- READ: Retrieve all salary
SELECT * FROM SALARY;


-- UPDATE: Update an employee's contact info
UPDATE EMPLOYEES
SET  EMP_Contact= '555-5678'
WHERE Emp_ID = 1;

-- DELETE: Remove an employee record
DELETE FROM EMPLOYEES WHERE EMP_ID = 1;


-- COUNT, AVG, SUM Operations
SELECT COUNT(*) AS TotalSalaryRecords
FROM SALARY;

-- AVG: Calculate the average NetSalary of all employees:
SELECT AVG(NetSalary) AS AverageNetSalary
FROM SALARY;

-- AVG: Average gross salary of all employees
SELECT AVG(GrossSalary) FROM SALARY;

-- SUM: Calculate the total GrossSalary paid to all employees:
SELECT SUM(GrossSalary) AS TotalGrossSalary
FROM SALARY;

--  PL/SQL (Views, Stored Procedures, Triggers)
-- view 
CREATE VIEW EmployeeSalaryView AS
SELECT EMPLOYEES.EMP_Name, SALARY.GrossSalary, SALARY.NetSalary
FROM EMPLOYEES
JOIN SALARY ON EMPLOYEES.EMP_ID = SALARY.EMP_ID;

-- UPDATE SALARY
UPDATE SALARY 
SET BasicSalary = 60000, HRA = 15000 
WHERE EMP_ID = 101;

-- stored procedure
DELIMITER $$
CREATE PROCEDURE AddNewEmployee(
    IN emp_id INT,
    IN emp_name VARCHAR(100),
    IN emp_address VARCHAR(100),
    IN emp_email VARCHAR(100),
    IN emp_contact VARCHAR(100),
    IN emp_dept_id INT,
    IN emp_join_date DATE
)
BEGIN
    INSERT INTO EMPLOYEES (EMP_ID, EMP_Name, EMP_Address, EMP_Email, EMP_Contact, Emp_Dept_ID, Emp_Join_Date) 
    VALUES (emp_id, emp_name, emp_address, emp_email, emp_contact, emp_dept_id, emp_join_date);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE UpdateEmployeeSalary(
    IN emp_id INT,
    IN basic_salary INT,
    IN hra INT,
    IN other_allowances INT,
    IN gross_salary INT,
    IN net_salary INT,
    IN salary_date DATE
)
BEGIN
    UPDATE SALARY 
    SET BasicSalary = basic_salary,
        HRA = hra,
        OtherAllowances = other_allowances,
        GrossSalary = gross_salary,
        NetSalary = net_salary,
        SalaryDate = salary_date
    WHERE EMP_ID = emp_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER AfterSalaryInsert
AFTER INSERT ON SALARY
FOR EACH ROW
BEGIN
    -- Example: Insert a default deduction record for each new salary
    INSERT INTO DEDUCTIONS (EMP_ID, DeductionType, DeductionAmount, DeductionDate) 
    VALUES (NEW.EMP_ID, 'Tax', NEW.NetSalary * 0.1, NEW.SalaryDate);
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER BeforeEmployeeDelete
BEFORE DELETE ON EMPLOYEES
FOR EACH ROW
BEGIN
    DECLARE emp_salary_count INT;
    
    -- Check if the employee has salary records
    SELECT COUNT(*) INTO emp_salary_count
    FROM SALARY
    WHERE EMP_ID = OLD.EMP_ID;
    
    IF emp_salary_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete employee with salary records.';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetEmployeeSalaryInfo(
    IN emp_id INT
)
BEGIN
    SELECT EMPLOYEES.EMP_Name, SALARY.GrossSalary, SALARY.NetSalary, SALARY.SalaryDate
    FROM EMPLOYEES
    JOIN SALARY ON EMPLOYEES.EMP_ID = SALARY.EMP_ID
    WHERE EMPLOYEES.EMP_ID = emp_id;
END $$
DELIMITER ;

CALL AddNewEmployee(106, 'Michael Scott', '1200 Office Ave', 'michael@example.com', '123-456-7895', 3, '2024-09-10');
CALL UpdateEmployeeSalary(101, 65000, 15000, 6000, 82000, 77000, '2025-02-01');
INSERT INTO SALARY (SALARY_ID, EMP_ID, BasicSalary, HRA, OtherAllowances, GrossSalary, NetSalary, SalaryDate)
VALUES (6, 106, 70000, 14000, 8000, 88000, 83000, '2025-02-01');
CALL GetEmployeeSalaryInfo(101);


-- DCL (Create User and Grant Permissions)

-- Create a new user
CREATE USER 'Aimerance'@'127.0.0.1' IDENTIFIED BY 'admin123';

-- Grant permissions to the user
GRANT ALL privileges ON PAYROLLMANAGEMENTSYSTEM .* TO 'Aimerance'@'127.0.0.1';
flush privileges;
