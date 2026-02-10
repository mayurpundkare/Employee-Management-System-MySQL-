-- create database Employee;

-- drop database Employee;

use Employee;

-- Job Department
create table JobDepartment (
Job_ID int primary key,
JobDept varchar (100),
Name varchar (100),
Description Text,
SalaryRange varchar (100)); 

select * from Jobdepartment;

-- Salary/Bonus
CREATE TABLE SalaryBonus (
salary_ID INT PRIMARY KEY,
Job_ID INT,
Amount DECIMAL(10,2),
Annual DECIMAL(10,2),
Bonus DECIMAL(10,2),
CONSTRAINT fk_salary_job FOREIGN KEY (Job_ID) REFERENCES Jobdepartment (Job_ID)
ON DELETE CASCADE ON UPDATE CASCADE);

select * from SalaryBonus;  
    
    -- Employee
CREATE TABLE Employee (
emp_ID INT PRIMARY KEY,
firstname VARCHAR(50),
lastname VARCHAR(50),
gender VARCHAR(10),
age INT,
contact_add VARCHAR(100),
emp_email VARCHAR(100) UNIQUE,
emp_pass VARCHAR(50),
Job_ID INT,
CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
REFERENCES JobDepartment(Job_ID)
ON DELETE SET NULL ON UPDATE CASCADE);
        
select * from Employee;
        
-- Qualification

CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

select * from Qualification;

--  Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from Leaves;

-- Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from Payroll;
select * from Jobdepartment;
select * from Leaves;
select * from Qualification;


-- 1. EMPLOYEE INSIGHTS
-- Q. How Many Unique Employees are currently in the system?

select count(*) unique_employee
from Employee;

-- Q. Which departments have the highest number of employees?

select jd.jobdept as department,
       COUNT(e.emp_ID) as total_employees
from Employee e
join JobDepartment jd ON e.Job_ID = jd.Job_ID
group by jd.jobdept
order by total_employees desc
limit 1;


-- Q. What is the average salary per department?

select jd.jobdept as department,avg(sb.amount) as avg_salary
from JobDepartment jd
join SalaryBonus sb on jd.Job_ID = sb.Job_ID
group by jd.JobDept
order by avg_salary desc
limit 1;


-- Q. Who are the top 5 highest-paid employees?

select e.emp_ID, concat(e.firstname, ' ', e.lastname) as employee_name,p.total_amount
from Payroll p
join Employee e on p.emp_ID = e.emp_ID
order by p.total_amount desc
limit 5;

-- Q. What is the total salary expenditure across the company?

select sum(total_amount) as total_salary_expenditure
from Payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- Q. How many different job roles exist in each department?

select  jd.jobdept as department,count(jd.Job_ID) as total_job_role
from JobDepartment jd
group by jd.jobdept;

-- What is the average salary range per department?

select jd.jobdept as department,avg(sb.amount) as avg_salary
from JobDepartment jd
join SalaryBonus sb on jd.Job_ID = sb.Job_ID
group by jd.jobdept;

-- Which job roles offer the highest salary?

select jd.name as job_role,sb.amount as salary
from SalaryBonus sb
join JobDepartment jd on sb.Job_ID = jd.Job_ID
order by sb.amount desc
limit 1;


-- Which departments have the highest total salary allocation?

select jd.jobdept as department,SUM(sb.amount) as total_salary_allocation
from JobDepartment jd
join SalaryBonus sb on jd.Job_ID = sb.Job_ID
group by jd.jobdept
order by total_salary_allocation desc
limit 1;


-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?

select count(distinct emp_ID) as Total_employee
from Qualification;

-- Which positions require the most qualifications?

select Position, count(*) as total_qualification 
from qualification
group by Position 
order by total_qualification desc
limit 1;


-- Which employees have the highest number of qualifications?




select e.emp_ID, e.firstname, e.lastname,
       COUNT(q.QualID) AS total_qualifications
from Employee e
join Qualification q ON e.emp_ID = q.emp_ID
group by  e.emp_ID, e.firstname
order by total_qualifications DESC
limit 1;


-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
select extract(year from date) as leave_year,count(distinct emp_ID) as distinct_employee
from Leaves
group by extract(year from Date)
order by distinct_employee desc 
limit 1;

-- What is the average number of leave days taken by its employees per department?
select jd.jobdept as department,avg(leave_count) as avg_leave_days
from (select e.emp_ID,e.Job_ID,COUNT(l.leave_ID) as leave_count
    from Employee e
    left join Leaves l on e.emp_ID = l.emp_ID
    group by e.emp_ID, e.Job_ID) as emp_leaves
join JobDepartment jd on emp_leaves.Job_ID = jd.Job_ID
group by jd.jobdept;


-- Which employees have taken the most leaves?
select emp_ID, total_leaves
from (select emp_ID, COUNT(*) AS total_leaves
    from Leaves
    group by emp_ID) as x
order by total_leaves desc
limit 1;

-- What is the total number of leave days taken company-wide?
select count(*) as total_leave_days
from Leaves;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
 -- What is the total monthly payroll processed?
select DATE_FORMAT(date, '%Y-%m') as month,SUM(total_amount) AS total_monthly_payroll
from Payroll
group by DATE_FORMAT(date, '%Y-%m')
order by month;

-- What is the average bonus given per department?
select jd.jobdept as department,avg(sb.bonus) as avg_bonus
from JobDepartment jd
join SalaryBonus sb on jd.Job_ID = sb.Job_ID
group by jd.jobdept;

-- Which department receives the highest total bonuses?
select jd.jobdept as department,sum(sb.bonus) as total_bonus
from JobDepartment jd
join SalaryBonus sb on jd.Job_ID = sb.Job_ID
group by jd.jobdept
order by total_bonus Desc
Limit 1;

-- What is the average value of total_amount after considering leave deductions?
select avg(total_amount) as avg_pay
from Payroll;

-- How do leave days correlate with payroll amounts?
select e.emp_ID,count(l.leave_ID) as total_leave_days,avg( p.total_amount) as avg_payroll_am
from Employee e
left join Leaves l on e.emp_ID = l.emp_ID
left join Payroll p on e.emp_ID = p.emp_ID
group by e.emp_ID;

-- Challenges
-- 1. Defining correct table relationships and ensuring accurate use of foreign keys.
-- Ans:- It is challenging to correctly link tables like Employee, JobDepartment, Payroll, and Leaves using foreign keys. 
--       Any mismatch in column names or data types can cause foreign key errors and prevent data insertion.


-- 2. Maintaining data consistency with cascading updates and deletes.
--  Ans:- Using ON DELETE CASCADE and ON UPDATE CASCADE requires careful planning. 
--        If a parent record is deleted or updated, related child records are automatically affected, 
--        which can sometimes lead to unintended data loss if not handled properly.

-- 3. Writing complex joins for reports involving employee roles, leaves, and payroll.
-- Ans:- Generating reports that combine employee details, job roles, leave records, and payroll data requires multiple joins. 
--       Writing correct joins without duplicating or missing data is complex and needs a good understanding of table relationships.

-- 4. Ensuring all date fields follow the YYYY-MM-DD format for reliable time-based analysis.
-- Ans:-  Date fields must follow the standard YYYY-MM-DD format. 
--        Incorrect formats can cause errors in queries and make time-based analysis like monthly payroll or yearly leave trends inaccurate.


-- 5. Preventing duplicate entries using unique constraints, especially on email fields.
-- Ans:- Applying unique constraints, especially on fields like employee email IDs, is necessary to avoid duplicate records. 
--       However, this can also cause insertion errors if duplicate data exists in CSV files, requiring data cleaning before import.



