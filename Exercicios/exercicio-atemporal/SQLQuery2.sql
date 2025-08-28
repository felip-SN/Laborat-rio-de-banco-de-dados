create database exHospital;

use exHospital;

create table medico(
	id integer primary key identity,
	nome varchar(60) not null,
	cpf varchar(40) not null,
	dataNascimento date not null,
	endereco varchar(80) not null,
	CRM varchar(40) not null,
	especialidade varchar(60) not null,
	cargo varchar(60) not null,
	salario real,

	SysStartTime datetime2 generated always as row start not null,
	SysEndTime datetime2 generated always as row end not null,
	period for system_time (SysStartTime, SysEndTime)
) with(
	SYSTEM_VERSIONING = ON(history_table = dbo.HistoricoMedicos)
)

create table paciente(
	id integer primary key identity,
	nome varchar(60) not null,
	cpf varchar(40) not null,
	dataNascimento date not null,
	endereco varchar(80) not null
);

create table exame(
	id integer primary key identity,
	idMedico integer,
	idPaciente integer,
	descricao varchar(255),
	FOREIGN KEY (IdMedico) REFERENCES medico(id),
	foreign key (idPaciente) references paciente(id),

	SysStartTime datetime2 generated always as row start not null,
	SysEndTime datetime2 generated always as row end not null,
	period for system_time (SysStartTime, SysEndTime)
) with (
	SYSTEM_VERSIONING = ON
)

alter table exame
set (SYSTEM_VERSIONING = OFF);

alter table medico
set (SYSTEM_VERSIONING = OFF);

drop table exame;
drop table medico, paciente;

insert into medico(nome, cpf, dataNascimento, endereco, CRM, especialidade, cargo, salario) VALUES ('Felipe Santos', '453.707.038-25', '2002-03-25', 'Rua Padre Bassano', '00000001-xrt', 'Cardiaco', 'Cirurgião', 1.500);
insert into paciente(nome, cpf, dataNascimento, endereco) VALUES ('Pedro', '509.309.309.25', '2002-04-15', 'Rua do caralho, 69');
insert into exame(idMedico, idPaciente, descricao) VALUES (1,1,'Cirurgia toraxica');

select * from medico;
select * from paciente;
select * from exame;

update medico set salario = 8000 where id = 1;
update medico set especialidade = 'Pesquisador' where id = 1;

select * from dbo.HistoricoMedicos;

