  1. Создать таблицу с основной информацией о сотрудниках: ФИО, дата рождения, дата начала работы, должность, уровень сотрудника (jun, middle, senior, lead), уровень зарплаты, идентификатор отдела, наличие/отсутствие прав(True/False). При этом в таблице обязательно должен быть уникальный номер для каждого сотрудника.

CREATE TYPE rate AS ENUM ('jun', 'middle', 'senior', 'lead');

CREATE TABLE employers (
   id serial PRIMARY KEY,
   fio CHARACTER VARIYNG(40) NOT NULL,
   birthdate DATE,
   startdate DATE,
   post CHARACTER VARIYNG(20),
   emrate RATE, 
   salary FLOAT,
   sectirid INTEGER,
   driver BOOLEAN
);

COPY employers FROM 'D:\empl.csv' DELIMITER ';' CSV HEADER;

 2. Для будущих отчетов аналитики попросили вас создать еще одну таблицу с информацией по отделам – в таблице должен быть идентификатор для каждого отдела, название отдела (например. Бухгалтерский или IT отдел), ФИО руководителя и количество сотрудников.

CREATE TABLE sectors(
   id serial PRIMARY KEY,
   sectorname CHARACTER VARIYNG(40) NOT NULL,
   head INTEGER,
   emnumber INTEGER
);

COPY sectorsFROM 'D:\sect.csv' DELIMITER ';' CSV HEADER;

3. На кону конец года и необходимо выплачивать сотрудникам премию. Премия будет выплачиваться по совокупным оценкам, которые сотрудники получают в каждом квартале года. Создайте таблицу, в которой для каждого сотрудника будут его оценки за каждый квартал. Диапазон оценок от A – самая высокая, до E – самая низкая.

CREATE TABLE estimates (
   id serial PRIMARY KEY,
   kv1 CHARACTER VARIYNG(1),
   kv2 CHARACTER VARIYNG(1),
   kv3 CHARACTER VARIYNG(1),
   kv4 CHARACTER VARIYNG(1)
);

COPY estimates FROM 'D:\esti.csv' DELIMITER ';' CSV HEADER;

  5. Ваша команда расширяется и руководство запланировало открыть новый отдел – отдел Интеллектуального анализа данных. На начальном этапе в команду наняли одного руководителя отдела и двух сотрудников. Добавьте необходимую информацию в соответствующие таблицы.

INSERT INTO sectors VALUES (6, 'Отдел интеллектуального анализа данных', 101, 3);
INSERT INTO employers VALUES (101, 'Подкопаева Светлана Ивановна', '20.12.1991', '08.11.2022', 'инженер данных', 'senior', 6500, 6, TRUE);
INSERT INTO employers VALUES (102, 'Корепин Вадим Русланович', '08.04.1984', '08.11.2022', 'инженер данных', 'middle', 4700, 6, TRUE);
INSERT INTO employers VALUES (103, 'Сергиенко Мария Викторовна', '25.04.1984', '08.11.2022', 'инженер данных', 'middle', 6300, 6, TRUE)
INSERT INTO estimates (id) VALUES (101);
INSERT INTO estimates (id) VALUES (102);
INSERT INTO estimates (id) VALUES (103);

 6. Теперь пришла пора анализировать наши данные – напишите запросы для получения следующей информации:

Уникальный номер сотрудника, его ФИО и стаж работы – для всех сотрудников компании

SELECT id, fio, age(CURRENT_DATE, StartDate) FROM employers;

Уникальный номер сотрудника, его ФИО и стаж работы – только первых 3-х сотрудников

SELECT id, fio, age(CURRENT_DATE, StartDate) FROM employers LIMIT 3;

 Уникальный номер сотрудников - водителей

SELECT id FROM employers WHERE driver='1';

Выведите номера сотрудников, которые хотя бы за 1 квартал получили оценку D или E

SELECT id FROM estimates WHERE kv1='D' OR kv1='E' OR kv2='D' OR kv2='E' OR kv3='D' OR kv3='E';

 Выведите самую высокую зарплату в компании.

SELECT MAX('salary') FROM employers;

 * Выведите название самого крупного отдела

SELECT sectorname, MAX(emnumber) AS "Highest Quantity" FROM sectors GROUP BY sectorname;

 * Выведите номера сотрудников от самых опытных до вновь прибывших

SELECT * FROM employers ORDER BY StartDate;

* Рассчитайте среднюю зарплату для каждого уровня сотрудников

SELECT ROUND(AVG(salary)) FROM employers GROUP BY emrate;

 * Добавьте столбец с информацией о коэффициенте годовой премии к основной таблице. Коэффициент рассчитывается по такой схеме: базовое значение коэффициента – 1, каждая оценка действует на коэффициент так:

·         Е – минус 20%
·         D – минус 10%
·         С – без изменений
·         B – плюс 10%
·         A – плюс 20%

ALTER TABLE estimates ADD COLUMN koef FLOAT;
UPDATE estimates SET koef=1 WHERE koef IS NULL;
UPDATE estimates SET koef=koef-0.2 WHERE kv1='E' OR kv2='E' OR kv3='E' OR kv4='E';
UPDATE estimates SET koef=koef-0.1 WHERE kv1='D' OR kv2='D' OR kv3='D' OR kv4='D';
UPDATE estimates SET koef=koef+0.2 WHERE kv1='A' OR kv2='A' OR kv3='A' OR kv4='A';
UPDATE estimates SET koef=koef+0.1 WHERE kv1='B' OR kv2='B' OR kv3='B' OR kv4='B';