-- banco de dados desafio 01 DIO
create database if not exists ecomerce;
use ecomerce;

create table clients(
	
    idClient int auto_increment primary key,
    Fname varchar(10),
    Minit char(3),
    Lname varchar(20),
    CPF char(11) not null,
    Address varchar(30),
    constraint unique_cpf_client unique(CPF)
);
alter table clients auto_increment=1;
create table product(

	idProduct int auto_increment primary key,
    Pname varchar(10) not null,
    classification_kids bool default false,
    category enum('Eletronico','Vestimenta', 'Brinquedos','Alimentos','Moveis') not null,
    avalicao float default 0,
    size varchar(10)
);

create table payements(

	idClient int primary key,
    idPayement int, 
    typePayement enum('Boleto','Cartão','Dois cartões'),
    limitAvailable float,
    primary key (idClient, idPayement) 


);

create table orders(
	idOrder int auto_increment primary key,
    idOrderClient int,
    orderStatus enum('Cancelado', 'Confirmado','Em processamento') default "Em processamento",
    orderDescription varchar(255),
    sendValue float default 10,
    paymentCash bool default false,
    constraint fk_orders_client foreign key(idOrderClient) references clients(idClient)
);

create table productStorage(
	idProdStorage int auto_increment primary key,
	storageLocation varchar(255),
    quantity int default 0
);

create table supplier(
	idSupplier int auto_increment primary key,
    SocialName varchar(255) not null,
    CNPJ char(15) not null,
    contact char(11) default 0,
    constraint unique_supplier unique(CNPJ)
);

create table seller(
	idSeller int auto_increment primary key,
    SocialName varchar(255) not null,
    AbstName varchar(255), 
    CNPJ char(15),
    CPF char(9),
    location varchar(255),
	contact char(11) default 0,
	constraint unique_cnpj_seller unique(CNPJ),
	constraint unique_cpf_seller unique(CPF)
);

create table productSeller(
	idPseller int,
    idPproduct int,
    prodQuantity int default 1,
    primary key(idPseller, idPproduct),
    constraint fk_product_seller foreign key (idPseller) references seller(idSeller),
    constraint fk_product_product foreign key(idPproduct) references product(idProduct)
);

create table productOrder(
	idPOproduct int,
    idPOorder int,
    poQuantity int default 1,
    poStatus enum('Disponivel', 'Sem estoque') default 'Disponivel',
    primary key (idPOproduct, idPOorder),
    constraint fk_productorder_seller foreign key (idPOproduct) references product(idProduct),
    constraint fk_productorder_product foreign key (idPOorder) references orders(idOrder)
);

create table storageLocation(
	idLproduct int,
    idLstorage int, 
    location varchar(255) not null,
    primary key (idLproduct, idLstorage),
    constraint fk_storage_location_product foreign key(idLproduct) references product(idProduct),
    constraint fk_storage_location_storage foreign key (idLstorage) references productStorage(idProdStorage)
);

create table productSupplier(
	idPsSupplier int,
    idPsProduct int,
    quantity int not null,
    primary key (idPsSupplier, idPsProduct),
    constraint fk_product_supplier_seller foreign key (idPsSupplier) references supplier(idSupplier),
    constraint fk_productsupplier_product foreign key (idPsProduct) references product(idProduct)
);

select count(*) from clients;
select * from clients c, orders o where c.idClient=idOrderClient;

select Fname, Lname, idOrder, orderStatus from clients c, orders o where c.idClient = idOrderClient;
select concat(Fname,' ',Lname) as Client, idOrder as Request, orderStatus as Status from clients c, orders o where c.idClient= idOrderClient;

select count(*) from clients c, orders o
				where c.idClient = idOrderClient;

select c.idClient, Fname, count(*) as Number_of_orders from clients c inner join orders o ON c.idClient = o.idOrderClient
						inner join productOrder p on p.idPOorder = o.idOrder
                        group by idClient;
                
show tables;