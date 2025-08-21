create database aula;

--create table pessoa(
--	id integer primary key identity,
--	nome varchar(200),
--	idade integer not null,
--	maioridade varchar(3)
--);

--create trigger triggerpessoa
--on pessoa
--after insert
--as
--begin
--	declare @idade integer
--	select @idade = (select inserted.idade from inserted)

--	if @idade > 17
--		begin
--			update pessoa set maioridade = 'sim'
--			where pessoa.id = (select inserted.id from inserted join pessoa on inserted.id = pessoa.id)
--		end
--	else
--		begin
--			update pessoa set maioridade = 'não'
--			where pessoa.id = (select inserted.id from inserted join pessoa on inserted.id = pessoa.id)
--		end
--end

--insert into pessoa(nome, idade, maioridade) values('felipe santos', 23, 'sim');
--insert into pessoa(nome, idade, maioridade) values('kaiky wilson', 15, 'não');

--select * from pessoa;

create table produtos(
	id integer primary key identity,
	nomeProduto varchar(200) not null,
	estoque integer
);

create table vendas(
	id integer primary key identity,
	valorVenda integer not null,
	idProduto integer foreign key references produtos(id)
);

create table contabancaria(
	id integer primary key identity,
	titular varchar(200) not null,
	saldo float not null
);

create table transferenciaBancaria(
	id integer primary key identity,
	idConta integer foreign key references contabancaria(id),
	valorCompra float not null,
	tipoTransferencia varchar(200)
);

insert into contabancaria(titular, saldo) values ('Felipe Santos', 2000);

select * from transferenciaBancaria;

create trigger triggervendas
on vendas
after insert
as
begin
	declare @idProduto integer
	select @idProduto = (select inserted.idProduto from inserted);

	update produtos set estoque -= (select inserted.valorVenda from inserted)
	where  produtos.id = @idProduto;

end

create trigger produtopreco
on produtos
after update
as
begin
	declare @value float
	select @value = (select inserted.preco from inserted)

	if @value <= 0
		begin
			raiserror('Valores devem ser acima de 0', 14, 1);
			rollback transaction
		end
	else
		begin
			update produtos set preco = @value where produtos.id = (select inserted.id from inserted)
		end
	
end

drop trigger triggertransferencia;

create trigger triggertransferencia
on transferenciaBancaria
after insert
as
begin
	declare @precoCompra float
	select @precoCompra = (select inserted.valorCompra from inserted);

	declare @saldo float
	select @saldo = (select saldo from contabancaria where id = (select inserted.idConta from inserted))

	if @precoCompra > @saldo
		begin
			raiserror('O saldo é insuficiente para concluir a transição!', 14,1);
			rollback transaction
		end
	else
		begin
			insert into transferenciaBancaria(idConta, valorCompra, tipoTransferencia)
			values ((select inserted.idConta from inserted),
					(select inserted.valorCompra from inserted),
					(select inserted.tipoTransferencia from inserted));

			update contabancaria set saldo -= @precoCompra 
			where contabancaria.id = (select inserted.idConta from inserted); 

			print('Transferencia concluida com sucesso!');
		end
end

insert into transferenciaBancaria(idConta, valorCompra, tipoTransferencia) 
values (1, 50, 'PIX');

insert into produtos(nomeProduto, estoque) values ('Caneta', 200);

insert into vendas(valorVenda, idProduto) values (10, 1);

select * from produtos;

update produtos
set preco = 15
where produtos.id = 1;

create table requisicoes(
	id integer primary key identity,
	entrada integer,
	saida integer,
	movimentacao varchar(60) not null,
	idProduto integer foreign key references produtos(id)
);

insert into produtos(nomeProduto, estoque) values ('Caderno', 10);

select * from produtos;

select * from requisicoes;

insert into requisicoes(entrada, saida, movimentacao, idProduto) values (0, 6, 'Saida', 5);

create trigger triggerrequisicoes
on requisicoes
after insert
as
begin
	declare @valorEntrada integer
	declare @valorSaida integer
	declare @movimentacao varchar(60)
	declare @entradaCount integer
	declare @saidaCount integer
	declare @nomeProduto varchar(200);

	select @entradaCount = (select count(*) from requisicoes where movimentacao = 'Entrada')
	select @saidaCount = (select count(*) from requisicoes where movimentacao = 'Saida')

	select @valorEntrada = (select inserted.entrada from inserted);
	select @valorSaida = (select inserted.saida from inserted);
	select @movimentacao = (select inserted.movimentacao from inserted);

	if @movimentacao = 'Entrada'
		begin
			update produtos set estoque += @valorEntrada where produtos.id = (select inserted.idProduto from inserted);

			select @nomeProduto = p.nomeProduto
			from inserted i
			join produtos p on p.id = i.idProduto;

			print('Entrada do produto ' + @nomeProduto);
		end
	else if @movimentacao = 'Saida'
		begin
			update produtos set estoque -= @valorSaida where produtos.id = (select inserted.idProduto from inserted);

			select @nomeProduto = p.nomeProduto
			from inserted i
			join produtos p on p.id = i.idProduto;

			print('Saida do produto ' + @nomeProduto);

			if @saidaCount > (select produtos.estoque * 0.7 from produtos where produtos.id = (select inserted.idProduto from inserted))
				begin
					update produtos set estoque += 1 where produtos.id = (select inserted.idProduto from inserted);

					select @nomeProduto = p.nomeProduto
					from inserted i
					join produtos p on p.id = i.idProduto;

					print('Entrada do produto ' + @nomeProduto);
				end
		end
end 