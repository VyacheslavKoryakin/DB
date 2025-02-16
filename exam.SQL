Create table if not exists car_manufacturer(
                                               id bigint generated always as identity primary key,
                                               name varchar(30)
);

insert into car_manufacturer(name)
values('Ваз'),
      ('Audi'),
      ('BMW'),
      ('Volvo'),
      ('Chevrolet'),
      ('Renault'),
      ('Nissan')
;
select * from car_manufacturer;

create table if not exists car(
                                  id bigint generated always as identity primary key,
                                  model varchar(30),
                                  generation int,
                                  manufacturer_id bigint,
                                  constraint FK_manufacturer_id foreign key (manufacturer_id) references public.car_manufacturer(id) on delete set null
);

insert into car (model, generation,manufacturer_id)
values('2109',1,1),
      ('21140',1,1),
      ('A4',3,2),
      ('A4',2,2),
      ('X3',2,3),
      ('X6',1,3),
      ('XC90',2,4),
      ('Cruze',1,5),
      ('Sandero',1,6),
      ('Terrano',2,7)
('2109',1,1)
;

/*select * from car c
full join spare_parts sp on c.id = sp.id;*/


create table if not exists spare_parts(
                                          id bigint generated always as identity primary key,
                                          name varchar(50),
                                          price int
);

insert into spare_parts(name,price)
values('бампер', 2000),
      ('бампер', 2000),
      ('бампер', 10000),
      ('бампер', 25000),
      ('фара правая', 1000),
      ('фара правая', 2000),
      ('фара правая', 20000),
      ('панель приборов', 80000),
      ('панель приборов', 6000),
      ('лобовое стекло', 8000),
      ('лобовое стекло', 28000),
      ('лобовое стекло', 30000),
      ('лампа дальнего света', 300),
      ('лампа дальнего света', 2000),
      ('лампа дальнего света', 1000),
      ('дверь передняя левая', 4000),
      ('дверь передняя левая', 4500),
      ('дверь передняя левая', 90000),
      ('дверь передняя левая', 60000),
      ('колодка тормозная', 900),
      ('колодка тормозная', 7000),
      ('колодка тормозная', 14000),
      ('глушитель', 4500),
      ('глушитель', 16000),
      ('глушитель', 10000),
      ('глушитель', 32000),
      ('глушитель', 80000)
;
select * from spare_parts;

create table if not exists car_parts(
                                        car_id bigint,
                                        spare_part_id bigint,
                                        constraint FK_car_id foreign key (car_id) references car(id),
                                        constraint FK_sp_id foreign key (spare_part_id) references spare_parts(id)
);

select * from car_parts;
insert into car_parts(car_id, spare_part_id)
values(1,1),
      (1,5),
      (1,9),
      (1,13),
      (1,20),
      (1,23),
      (2,2),
      (2,13),
      (2,20),
      (2,23),
      (3,25),
      (4,24),
      (5,7),
      (5,12),
      (5,19),
      (6,27),
      (5,27),
      (6,7),
      (6,15),
      (6,21),
      (7,24),
      (8,9),
      (8,25),
      (8,21),
      (9,10),
      (9,17),
      (9,14),
      (10,24),
      (10,25),
      (10,14),
      (11,5),
      (11,9),
      (11,13),
      (11,20),
      (11,23);

create table if not exists storage(
                                      id bigint generated always as identity primary key,
                                      row int,
                                      place int,
                                      amount int,
                                      spare_part_id bigint,
                                      constraint FK_part_id foreign key(spare_part_id) references spare_parts(id)
);


insert into public.storage(row,place,amount,spare_part_id)
values(1,1,4,1),
      (1,2,8,2),
      (1,3,11,3),
      (1,4,1,4),
      (1,5,3,5),
      (2,1,2,6),
      (2,2,23,7),
      (2,3,1,8),
      (2,4,6,9),
      (2,5,9,10),
      (3,1,0,11),
      (3,2,4,12),
      (3,3,3,13),
      (3,4,1,14),
      (3,5,3,15),
      (4,1,15,16),
      (4,2,5,17),
      (4,3,5,18),
      (4,4,2,19),
      (5,5,11,20),
      (6,1,3,21),
      (6,2,9,22),
      (6,3,6,23),
      (6,4,8,24),
      (6,5,11,25),
      (7,1,8,26),
      (7,2,4,27);


------------------------------------------------------------------------

-- представление модельного ряда, для которого могут быть запчасти, объеденив в один столбец марку и модель авто

create or replace view cars_model  as
select  cm.name||' '||c.model as car,c.generation, c.id from car_manufacturer cm
                                                                 join car c on cm.id = c.manufacturer_id
order by c.model;

-- джоин таблицы и представления

select cm, sp.name, sp.price
from cars_model cm
         join car_parts cp on cm.id = cp.car_id
         join spare_parts sp on cp.spare_part_id = sp.id
order by cm;


-- агрегатная функция + подзапрос + группироввка

select  name, sum(price*(select amount from public.storage where spare_part_id = sp.id )) as sum_total
from spare_parts sp
group by name
order by name;


-- номенклатура запасных частей без дублирования
select  distinct name from spare_parts;



--показывает для каких моделей есть запчасти
select distinct cm.name,sp.name,s.row, s.place,s.amount
from car_manufacturer cm
         join car c on cm.id = c.manufacturer_id
         join car_parts cp on cm.id = cp.car_id
         join spare_parts sp on cp.spare_part_id = sp.id
         join public.storage s on sp.id = s.spare_part_id
where cm.name = 'Ваз' and sp.name IN('бампер','глушитель')
order by cm.name;

--- показывает все запчати на ваз 2109 и Х6 через IN

select cm.name, c.model, sp.name, sp.price, s.row, s.place,s.amount
from car_manufacturer cm
         join car c on cm.id = c.manufacturer_id
         join car_parts cp on cm.id = cp.car_id
         join spare_parts sp on cp.spare_part_id = sp.id
         join public.storage s on sp.id = s.spare_part_id
where c.model in('2109','X6')
order by price;


--- показывает статус материала на складе

select  s.id, sp.name, amount,
        case
            when  amount<3 then 'срочно заказать'
            when  amount between 3 and 10 then 'достаточно'
            when  amount>10 then 'избыточное количество'
            else 'проверить необходимость'
            end as status
from public.storage s
         join spare_parts sp on s.spare_part_id = sp.id;

--- показывает все таблицы
select *
from car_manufacturer cm
         join car c on cm.id = c.manufacturer_id
         join car_parts cp on c.id = cp.car_id
         join spare_parts sp on cp.spare_part_id = sp.id
         join public.storage s on sp.id = s.spare_part_id
order by cm.id;

--- добавление марки автомобиля без модели и поколения
insert into  car_manufacturer(name)
values('Opel');


----- значение NULL меняется на неопределено

select cm.id, cm.name ,
       coalesce(c.model::text,'неопределено') as model,
       coalesce (c.generation:: text,'неопределено')as generation
from car_manufacturer cm
         full join car c on c.manufacturer_id = cm.id
order by cm.id;





create function get_parts_for_car(cm_id bigint) --- функция показывает марку, модель запчасть, стоимость запчасти и расположение на складе по ID марки авто
    returns table ( car_name varchar(30), model varchar(30), part_name varchar(30),
                    price int, stor_row int, stor_place int ,stor_amount int ) as  $$

Begin
    return query
        select cm.name, c.model, sp.name, sp.price, s.row, s.place,s.amount
        from car_manufacturer cm
                 join car c on cm.id = c.manufacturer_id
                 join car_parts cp on c.id = cp.car_id
                 join spare_parts sp on cp.spare_part_id = sp.id
                 join public.storage s on sp.id = s.spare_part_id
        where cm.id = cm_id;

End;
$$ language plpgsql;


select * from get_parts_for_car(1); --- вызов функции


update public.storage
set amount = amount-1
where id =10;

select * from public.storage
order by id;