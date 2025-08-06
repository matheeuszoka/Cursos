create database if not exists first_example;

use first_example;

create table person(
	person_id smallint unsigned,
	fname varchar(20),
	lname varchar(20),
	gender enum('M', 'F'),
	birth_date date,
	street varchar(20),
	city varchar(20),
	state varchar(20),
	country varchar(20),
	postal_code varchar(20),
    constraint pk_person primary key(person_id)
);
desc person;

create table favorite_food(
	person_id smallint unsigned, 
    food varchar(20),
    constraint pk_favorite_food primary key(person_id, food),
    constraint fk_favorite_food_person_id foreign key(person_id) 
    references person(person_id)
);
desc favorite_food;

show databases;

select * from information_schema.table_constraints
where constraint_schema = 'first_example';

insert into person values ('3','João', 'Silva', 'M', '2006-09-05',
'rua tal', 'Cidade J', 'RJ', 'Brasil', '87910000'), 
						  ('2','Matheus', 'Gabriel', 'M', '2000-11-28',
'rua X', 'Cidade J', 'RJ', 'Brasil', '87910000');

select * from person;

delete from person where person_id=1;

insert into favorite_food values ('2', 'Pizza'),
								 ('3', 'Macarrão');

select * from favorite_food;
