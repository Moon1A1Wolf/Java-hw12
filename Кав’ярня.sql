-- Удалить все таблицы
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS work_schedule CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS menu CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS customers CASCADE;


-- №1
-- напитки и десерты
CREATE TABLE menu (
    id SERIAL PRIMARY KEY,
    name_ua VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    category VARCHAR(50) CHECK (category IN ('Напій', 'Десерт')),
    price DOUBLE PRECISION NOT NULL CHECK (price > 0)
);

-- персонал
CREATE TABLE staff (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    address VARCHAR(255),
    position VARCHAR(50) CHECK (position IN ('Бариста', 'Офіціант', 'Кондитер'))
);

-- клиент
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    address VARCHAR(255),
    discount NUMERIC(5,2) DEFAULT 0 CHECK (discount >= 0 AND discount <= 100)
);

-- график
CREATE TABLE work_schedule (
    id SERIAL PRIMARY KEY,
    staff_id INT REFERENCES staff(id) ON DELETE CASCADE,  -- ссылка на сотрудника
    work_day DATE NOT NULL,
    shift VARCHAR(50) CHECK (shift IN ('Ранок', 'День', 'Вечір')) NOT NULL
);

-- заказ
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id) ON DELETE SET NULL,  -- ссылка на клиента
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_price DOUBLE PRECISION NOT NULL CHECK (total_price > 0)
);

-- связь заказов и товаров
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,  -- ссылка на заказ
    menu_id INT REFERENCES menu(id) ON DELETE CASCADE,  -- ссылка на товар
    quantity INT NOT NULL CHECK (quantity > 0),
    item_price DOUBLE PRECISION NOT NULL CHECK (item_price > 0)
);

ALTER TABLE orders ADD COLUMN staff_id INT REFERENCES staff(id) ON DELETE SET NULL;


-- №2
-- новая позиция
INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Еспресо', 'Espresso', 'Напій', 35.00);

INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Торт Шоколадний', 'Chocolate Cake', 'Десерт', 270.00);

INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Торт Чизкейк', 'Cheesecake Cake', 'Десерт', 150.00);

-- новый официант 1
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Ігор Хмир', '0951234567', 'Харків, вул. Михайлика, 26', 'Офіціант');
-- новый официант 2
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Дмитро Броменко', '0931133559', 'Одеса, вул. Генуезька, 47', 'Офіціант');

-- новый бариста
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Анна Сидоренко', '0739876543', 'Одеса, вул. Дерибасівська, 10', 'Бариста');

-- новый кондитер
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Олександр Килимок', '0677654321', 'Київ, вул. Лесі Українки, 15', 'Кондитер');

-- новый клиент 1
INSERT INTO customers (full_name, birth_date, phone, address, discount)
VALUES ('Олена Іванова', '1990-04-10', '0982345678', 'Львів, вул. Шевченка, 12', 15.00);
-- новый клиент 2
INSERT INTO customers (full_name, birth_date, phone, address, discount)
VALUES ('Богдан Кулін', '2001-10-21', '0631231234', 'Київ, вул. Шевченка, 72', 15.00);

-- новый заказ(кофе)
INSERT INTO orders (customer_id, total_price, staff_id)
VALUES (1, 35.00, 1);  -- клиент ID = 1, официант ID = 1

-- новый заказ(десерт)
INSERT INTO orders (customer_id, total_price, staff_id)
VALUES (1, 270.00, 2);  -- клиент ID = 1, официант ID = 2

-- новый график(понедельник, бариста)
INSERT INTO work_schedule (staff_id, work_day, shift)
VALUES (1, '2025-01-19', 'Ранок');  -- бариста ID = 1

-- новый вид кофе
INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Латте', 'Latte', 'Напій', 60.00);


-- №3
UPDATE menu
SET price = 70.00
WHERE name_ua = 'Латте';

UPDATE staff
SET phone = '0987654321',
    address = 'Одеса, вул. Канатна, 105'
WHERE full_name = 'Олександр Килимок' AND position = 'Кондитер';

UPDATE staff
SET phone = '0932233445'
WHERE full_name = 'Анна Сидоренко' AND position = 'Бариста';

UPDATE customers
SET discount = 10.00
WHERE full_name = 'Олена Іванова';

UPDATE menu
SET name_ua = 'Латте Мокко', name_en = 'Latte Mocha'
WHERE name_ua = 'Латте';

UPDATE menu
SET name_ua = 'Торт Наполеон', name_en = 'Napoleon Cake'
WHERE name_ua = 'Торт Шоколадний';


-- №4
DELETE FROM menu
WHERE name_ua = 'Торт Чизкейк' AND category = 'Десерт';

DELETE FROM staff
WHERE full_name = 'Ігор Хмир' AND position = 'Офіціант';

DELETE FROM staff
WHERE full_name = 'Анна Сидоренко' AND position = 'Бариста';

DELETE FROM customers
WHERE full_name = 'Богдан Кулін';
DELETE FROM orders
WHERE customer_id = 2;

DELETE FROM order_items
WHERE menu_id = (SELECT id FROM menu WHERE name_ua = 'Торт Чизкейк' AND category = 'Десерт');
DELETE FROM menu
WHERE name_ua = 'Торт Чизкейк' AND category = 'Десерт';

DELETE FROM order_items
WHERE order_id = (SELECT id FROM orders WHERE customer_id = 1 AND total_price = 30.00);
DELETE FROM orders
WHERE customer_id = 1 AND total_price = 30.00;

-- №5
SELECT * FROM menu WHERE category = 'Напій';
SELECT * FROM menu WHERE category = 'Десерт';
SELECT * FROM staff WHERE position = 'Бариста';
SELECT * FROM staff WHERE position = 'Офіціант';

SELECT o.*
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu m ON oi.menu_id = m.id
WHERE m.name_ua = 'Торт Наполеон' AND m.category = 'Десерт';

SELECT o.*
FROM orders o
JOIN staff s ON o.staff_id = s.id
WHERE s.full_name = 'Дмитро Броменко' AND s.position = 'Офіціант';

SELECT * FROM orders
WHERE customer_id = (SELECT id FROM customers WHERE full_name = 'Олена Іванова');
