
CREATE INDEX idx_employees_department_id ON employees(department_id);

CREATE INDEX idx_departments_city ON departments(city);

CREATE INDEX idx_departments_id_name ON departments(id, name);

ALTER TABLE employees ADD UNIQUE INDEX idx_employees_email_unique(email);

CREATE INDEX idx_employees_name_department ON employees(name, department_id);

SELECT 
    d.name as departamento,
    COUNT(e.id) as total_funcionarios
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
ORDER BY total_funcionarios DESC
LIMIT 1;

SELECT 
    city,
    GROUP_CONCAT(name ORDER BY name) as departamentos
FROM departments
GROUP BY city
ORDER BY city;

SELECT 
    d.name as departamento,
    d.city as cidade,
    e.name as funcionario,
    e.email
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
ORDER BY d.name, e.name;

SHOW INDEX FROM employees;

SHOW INDEX FROM departments;

