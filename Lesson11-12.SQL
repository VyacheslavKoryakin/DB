create table if not exists author(
                                     id bigint generated always as identity primary key,
                                     name varchar (20),
                                     second_name varchar(20),
                                     category varchar(20)
);


create table if not exists book(
                                   id bigint generated always as identity primary key ,
                                   title varchar (50),
                                   category varchar(50),
                                   publishing_id bigint, constraint fk_publishing foreign key (publishing_id) references publishing_house(id),
                                   year int
);


create table if not exists publishing_house(
                                               id bigint generated always as identity primary key,
                                               name varchar (20),
                                               city varchar(20)
);

create table if not exists author_book(
                                          author_id bigint, constraint fk_author foreign key (author_id) references author(id),
                                          book_id bigint, constraint fk_book foreign key (book_id) references book(id)
);



insert into publishing_house (name, city)
values('Вильямс','Москва'),
      ('АСТ','Самара'),
      ('Центрполиграф','Москва')
;


insert into author
(name, second_name, category)
values('Айзек','Азимов','Фантаст'),
      ('Константин','Паустовкий', 'детский'),
      ('Герберт','Шилд','программист'),
      ('Роберт','Сэджвик','программист'),
      ('Кевин','Уэйн','программист')
;

select * from author;

select * from book;

select * from publishing_house;

insert into book
(title ,category, publishing_id, year)
values('Алгоритмы джава','программирование',1,'2019'),
      ('Java.Полное руководство','программирование',1,'2018'),
      ('Ближний восток','фантастика',2,'2024'),
      ('Золотая роза','детское',3,'2022')
;

select * from book b
                  join publishing_house ph
                       on b.publishing_id = ph.id;



alter table book
    add column price bigint;

select * from book
order by id;

update book
set price= 1050 where id =2;
update book
set price = 900 where id=1;
update book
set price= 300 where id=4;
update book
set price= 650 where id=3;

select avg (price) as avg_price , max(price) as max_price, min(price) as min_price
from book;

select id, name, second_name, count(*) as book_cont
from author a join author_book ab on a.id = ab.author_id
group by id
order by id;

select  a.name, a.second_name,b.title,b.price, ab.book_id, count(*) as book_cont, avg(price) as avg_price
from author a join author_book ab on a.id = ab.author_id join book b on b.id = ab.book_id
group by a.second_name, a.name,b.title, b.price, ab.book_id
order by a.second_name, a.name,b.title, b.price, ab.book_id;

insert into author(name, second_name, category)
values('Александр','Пушкин', 'поэт'),
      ('Сергей','Есенин', 'поэт'),
      ('Рэй','Бредбери', 'фантаст');

select * from author a
                  left outer join author_book ab on a.id = ab.author_id
                  left outer join book b on ab.book_id = b.id
where b.title is null;


select  a.name, a.second_name,b.title,b.price, ab.book_id, count(*) as book_count
from author a
         left outer join author_book ab on a.id = ab.author_id
         left outer join book b on b.id = ab.book_id
group by a.second_name, a.name,b.title, b.price, ab.book_id
having count(*)=0
order by a.name, a.second_name, b.title, b.price, ab.book_id;

--9-10--

alter table author
    alter column name set not null;

alter table  book
    add constraint fk_publishing foreign key (publishing_id) references publishing_house(id) on delete set null;


alter table author_book
    add constraint fk_author foreign key (author_id) references author(id) on delete cascade,
    add constraint fk_book foreign key (book_id) references book(id) on delete cascade;

insert into author (second_name, category)
values('Гоголь','писатель');
--ERROR:  Ошибочная строка содержит (9, null, Гоголь, писатель).значение NULL в столбце "name" отношения "author" нарушает ограничение NOT NULL --



create table employee(
                         id bigint generated always as identity  primary key,
                         name varchar(30) not null,
                         parent_id bigint,
                         constraint FK_parent_id foreign key(parent_id) references employee(id)
);

insert into employee(name, parent_id)
values('Рабочий',null),
      ('Специалист',null),
      ('Электрик','1'),
      ('Сварщик','1'),
      ('Инженер','2'),
      ('Программист','2'),
      ('Руководитель',null);

select * from employee;

insert into employee(name, parent_id)
values('Оператор','1'),
      ('Слесарь','1'),
      ('Бухгалтер','2'),
      ('Начльник',7),
      ('Главный инженер',7),
      ('Директор',7);

Select * from employee
where parent_id =(select id from employee where name = 'Руководитель');



--11-12----

alter table book
    add column page_count int;

select * from book;

update book
set page_count = 432 where id =1;
update book
set page_count = 300 where id =2;
update book
set page_count = 211 where id =3;
update book
set page_count = 80 where id =4;

select * from book
where page_count>(select avg(page_count)from book);

alter table book
    add column book_count int;


update book
set book_count = 3000 where id =1;
update book
set  book_count = 1000 where id =2;
update book
set  book_count = 800 where id =3;
update book
set  book_count = 400 where id =4;


select * from book
where year =(select MAX(year)from book);

SELECT *
FROM	(SELECT title, SUM(book_count * price) AS total
         FROM book
         GROUP BY title)
WHERE total > 300000
ORDER BY total;

select (b.title,b.year, a.name, a.second_name) as full,
       case
           when  b.year>2020 then 'достаточно новая'
           else 'устаревшая'
           end as status

from book b join author_book ab on b.id = ab.book_id
            join author a on ab.author_id = a.id;

