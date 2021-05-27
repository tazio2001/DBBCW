
-- DATA BASE CREATION AND SETUP

create database LSBUAutoShopDB
go

use LSBUAutoShopDB
go

drop table if exists Customer
go
create table Customer(
	customerID			int			NOT NULL identity(1,1),
	fullName			varchar(35) NOT NULL,
	phoneNumber			varchar(12) NOT NULL,
	dateLastPurchase	date		NULL,
	dateLastPayment		date		NULL,
	customerType		varchar(10)	NOT NULL,

	CONSTRAINT CustomerPK PRIMARY KEY(customerID),
	CONSTRAINT CustomerType UNIQUE(customerID, customerType),
	CONSTRAINT ValidTypes CHECK 
		(customerType in ('retail', 'wholesale'))
)
go
drop table if exists Retail
go
create table Retail(
	customerID				int				NOT NULL,
	creditCardNumber		varchar(16)		NULL,
	creditCardType			varchar(20)		NULL,
	creditCardExpiryDate	varchar(7)		NULL,
	emailAddress			varchar	(25)	NOT NULL,

	CONSTRAINT RetailPK PRIMARY KEY(customerID),
	CONSTRAINT CustomerFK FOREIGN KEY(customerID) 
		REFERENCES Customer(customerID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE,
)
go
drop table if exists Wholesale
go
create table Wholesale(
	customerID				int				NOT NULL,
	contactName				varchar(35)		NOT NULL,
	contactPhoneNumber		varchar(12)		NULL,
	contactEmailAddress		varchar(25)		NOT NULL,
	billingAddress			varchar(50)		NOT NULL,
	shippingAddress			varchar(50)		NOT NULL,
	PurchaseOrderNumber		varchar(20)		NULL,
	discountPercentage		numeric(4,2)	NOT NULL default 0.00,
	taxExempt				varchar(10)		NOT NULL,
	VATRegistrationNumber	varchar(30)		NOT NULL,

	CONSTRAINT WholesalePK PRIMARY KEY(customerID),
	CONSTRAINT WCustomerFK FOREIGN KEY(customerID) 
		REFERENCES Customer(customerID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE,
	CONSTRAINT	TaxStatus CHECK
		(taxExempt in ('yes', 'no'))
)
go
drop table if exists Employee
go
create table Employee(
	employeeID				int			NOT NULL identity(1,1),
	department				varchar(20)	NOT NULL,
	firstName				varchar(15) NOT NULL,
	lastName				varchar(15) NOT NULL,
	homeAddress				varchar(50) NOT NULL,
	monthlySalary			money		NOT NULL,
	nationalInsuranceNumber char(9)		NOT NULL,

	CONSTRAINT EmployeePK PRIMARY KEY(employeeID),
	CONSTRAINT DeparmentValues CHECK
		(department IN ('administration', 'marketing',
		'sales', 'shipping', 'purchasing', 'technology'))
)
go
drop table if exists Administrator
go
create table Administrator(
	employeeID	int			NOT NULL,
	title		varchar(20) NOT NULL,
	bonus		money		NOT NULL default 0.00,

	CONSTRAINT AdminPK PRIMARY KEY(employeeID),
	CONSTRAINT employeeFK FOREIGN KEY(employeeID) 
		REFERENCES Employee(employeeID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE
)
go
drop table if exists SalesRepresentative
go
create table SalesRepresentative(
	employeeID			int		NOT NULL,
	salesRepID			int		NOT NULL identity(1,1),
	currentCommission	money	NOT NULL default 0.00,

	CONSTRAINT SalesRepPK PRIMARY KEY(employeeID),
	CONSTRAINT SalesRepAK UNIQUE(salesRepID),
	CONSTRAINT SREmployeeFK FOREIGN KEY(employeeID) 
		REFERENCES Employee(employeeID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE
)
go
drop table if exists Specialist
go
create table Specialist(
	employeeID		int			NOT NULL,
	specialty		varchar(35) NOT NULL,
	certification	varchar(35) NOT NULL,

	CONSTRAINT SpecialistPK PRIMARY KEY(employeeID),
	CONSTRAINT SEmployeeFK FOREIGN KEY(employeeID) 
		REFERENCES Employee(employeeID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE
)
go
drop table if exists Supplier
go
create table Supplier(
	supplierID		int			NOT NULL identity(1,1),
	supplierName	varchar(25)	NOT NULL,
	phoneNumber		varchar(12)	NULL,
	emailAddress	varchar(25)	NOT NULL,
	--
	restocksOrdered	int			NOT NULL default 0,

	CONSTRAINT SupplierPK PRIMARY KEY(supplierID),
)
go
drop table if exists Part
go
create table Part(
	partID					int			NOT NULL identity(1,1),
	partDescription			text		NOT NULL,
	partPrice				money		NOT NULL,
	supplierID				int			NOT NULL,
	currentStock			int			NOT NULL default 0,
	minimumStock			int			NOT NULL default 0,
	--
	restockOrdered			int			NOT NULL default 0,
	availabilityStatus		varchar(15)	NOT NULL,
	RestockNumOfDays		int			NOT NULL,

	CONSTRAINT PartPK PRIMARY KEY(partID),
	CONSTRAINT SupplierFK FOREIGN KEY(supplierID)
		REFERENCES Supplier(supplierID),
	CONSTRAINT StatusValues CHECK
		(availabilityStatus IN ('In Stock', 'Restocking')),
)
go
drop table if exists CarModel
go
create table CarModel(
	carModelID		int				NOT NULL identity(1,1),
	manufacturer	varchar(25)		NOT NULL,
	model			varchar(15)		NOT NULL,
	productionYear	numeric(4,0)	NOT NULL,

	CONSTRAINT CarModelPK PRIMARY KEY(carModelID),
	CONSTRAINT ValidProductionYear CHECK 
		(productionYear LIKE '[1-2][0-9][0-9][0-9]')
)
go
drop table if exists PartCompatibility
go
create table PartCompatibility(
	partID		int NOT NULL,
	carModelID	int NOT NULL,

	CONSTRAINT CompatibilityPK PRIMARY KEY(partId, carModelID),
	CONSTRAINT PartFK FOREIGN KEY(partID)
		REFERENCES Part(partID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE,
	CONSTRAINT CarModelFK FOREIGN KEY(carModelID)
		REFERENCES CarModel(carModelID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE
)
go
drop table if exists SalesOrder
go
create table SalesOrder(
	salesOrderID	int			NOT NULL identity(1,1),
	orderDate		date		NOT NULL,
	customerID		int			NOT NULL,
	salesRepID		int			NOT NULL,
	billingAddress	varchar(50)	NOT NULL,
	shippingAddress	varchar(50)	NOT NULL,
	VATTotal		money		NOT NULL default 0.00,
	orderTotal		money		NOT NULL default 0.00,
	--
	paymentComplete	varchar(3)	NOT NULL default 'no',
	orderStatus		varchar(20) NOT NULL,

	CONSTRAINT SalesORderPK PRIMARY KEY(salesOrderID),
	CONSTRAINT SOCustomerFK FOREIGN KEY(customerID)
		REFERENCES Customer(customerID),
	CONSTRAINT SalesRepFK FOREIGN KEY(salesRepID)
		REFERENCES SalesRepresentative(salesRepID),
	CONSTRAINT SOStatusValues CHECK
		(orderStatus IN ('complete', 'incomplete', 'cancelled')),
	CONSTRAINT HasPaidValues CHECK
		(paymentComplete IN ('yes', 'no' )),

)
go
drop table if exists OrderItem
go
create table OrderItem(
	salesOrderID	int			NOT NULL,
	partID			int			NOT NULL,
	fufilled		varchar(3)	NOT NULL default 0,
	--
	requested		int			NOT NULL default 1,
	unitPrice		money		NOT NULL,

	CONSTRAINT OrderItemPK PRIMARY KEY(partId, salesOrderID),
	CONSTRAINT OIPartFK FOREIGN KEY(partID)
		REFERENCES Part(partID),
	CONSTRAINT SalesOrderFK FOREIGN KEY(salesOrderID)
		REFERENCES SalesOrder(salesOrderID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE, 
	CONSTRAINT FufilledValues CHECK
		(fufilled IN ('yes', 'no' )),
)
go
drop table if exists RestockAwaited
go
create table RestockAwaited(
	partID				int			NOT NULL,
	restockArrivalTime	datetime	NOT NULL,
	quantity			int			NOT NULL,

	CONSTRAINT RestockPK PRIMARY KEY(partID),
	CONSTRAINT RAPartFK FOREIGN KEY(partID)
		REFERENCES Part(partID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE
)
go


-- ADDING FUNCATIONALITY AND BUISNESS CONSTRAINTS

-- restock procedure
drop procedure if exists restockPartsProcedure
go

create procedure restockPartsProcedure as

	declare @partID int, @date datetime

	begin
		declare cur CURSOR for (select partId, restockArrivalTime from RestockAwaited)
		open cur
			fetch next from cur into @partId, @date
			while (@@FETCH_STATUS = 0) 
			begin
			
				if (datediff(hour, @date, getdate()) < 0)
					delete from RestockAwaited
					where partID = @partID;

				fetch next from cur into @partId, @date
			end
		close cur
		deallocate cur
	end
go
-- on Retail insert
drop trigger if exists RE_onInsert
go

create trigger RE_onInsert on Retail after insert
as
	declare @id int, @type varchar(12)
	begin
		select @id = i.customerID from inserted i
		select @type = customerType from Customer where customerID = @id

		if(@type <> 'retail')
			delete from Retail
			where customerID = @id
	end

-- on wholesale insert
drop trigger if exists WH_onInsert
go

create trigger WH_onInsert on Wholesale after insert
as
	declare @id int, @type varchar(12)
	begin
	select @id = i.customerID from inserted i
	select @type = customerType from Customer where customerID = @id

	if(@type <> 'wholesale')
		delete from Wholesale
		where customerID = @id
	end

--on RestockAwaited delete
drop trigger if exists RA_onDelete
go

create trigger RA_onDelete on RestockAwaited after delete
as
	declare @partID int, @quant int
	begin
		select @partID = d.partID from deleted d
		select @quant = d.quantity from deleted d
		update Part
		set Part.currentStock = currentStock + @quant, Part.availabilityStatus = 'In Stock'
		where Part.partID = @partID;
	end
go

-- on parts update
drop trigger if exists P_onUpdate
go

create trigger P_onUpdate on Part after update
as
	declare @id int, @cs int, @ms int, @sd int, @days int, @d int
	begin 
		select @id = i.partId from inserted i
		select @cs = i.currentStock from inserted i
		select @ms = i.minimumStock from inserted i
		select @sd = i.supplierID from inserted i
		select @days = i.RestockNumOfDays from inserted i
		--23
		select @d = count(*) from RestockAwaited where partID = @id 

		if(@cs < @ms)
		begin
			if(@d = 0)
			begin
				INSERT INTO RestockAwaited Values (@id, DATEADD(DAY, @days, GETDATE()), 50)

				update Supplier
				set restocksOrdered = restocksOrdered + 1
				where supplierID = @sd
				update Part
				set restockOrdered = restockOrdered + 1, availabilityStatus = 'Restocking'
				where partID = @id
			end
		end
	end
go

-- On salesOrder insert
drop trigger if exists SO_onInsert
go

create trigger SO_onInsert  on SalesOrder after insert
as
	declare @id int
	begin
		--updating customers last purchase date
		select @id = i.customerID from inserted i

		update Customer
		set Customer.dateLastPurchase = GETDATE()
		where Customer.customerID = @id
	end
go

drop function if exists checkOrderItems
go 

create function checkOrderItems(@id int)
	returns varchar(3)
	begin
		declare curr CURSOR for (select fufilled from OrderItem where salesOrderID = @id)
		declare @fuf varchar(3), @res varchar(3)
		open curr
			fetch next from curr into @fuf
			set @res = 'yes'
			while (@@FETCH_STATUS = 0)
			begin
				if(@fuf = 'no')
					set @res = 'no'
				fetch next from curr into @fuf
			end
		
		close curr
		deallocate curr
		return @res
	end

go

--On SalesOrder update
drop trigger if exists SO_onUpdate
go

create trigger SO_onUpdate on SalesOrder after update
as
	declare @cid int, @total int, @sid int, @status varchar(20), @price money, @id int

	begin
		select @id = i.salesOrderID from inserted i
		select @status = i.orderStatus from inserted i

		if (@status = 'complete') 
		begin 
			select @status = i.paymentComplete from inserted i
			if(dbo.checkOrderItems(@id) = 'no' or @status = 'no')
				update SalesOrder
				set orderStatus = 'incomplete'
				where salesOrderID = @id
			else
			begin
				select @cid = i.customerID from inserted i
				select @total = i.orderTotal from inserted i
				select @sid = i.salesRepID from inserted i

				--updating customer last payment date
				update Customer
				set Customer.dateLastPayment = getdate()
				where Customer.customerID = @cid
				--adding commision of 5% to sales representative
				update SalesRepresentative
				set SalesRepresentative.currentCommission = SalesRepresentative.currentCommission + (@total * 0.05)
				where SalesRepresentative.salesRepID = @sid
			end
		end

		if (@status = 'cancelled')
		begin
			-- deleting associated orderItems and returning the parts to the stock
			select @sid = i.salesOrderID from inserted i
			declare cur CURSOR for (select partID from OrderItem where salesOrderID = @sid) 
			
			
			fetch next from cur into @cid
			open cur
				while (@@FETCH_STATUS = 0)
				begin 
					delete from OrderItem
					where partID = @cid and salesOrderID = @sid

					fetch next from cur into @cid, @total
				end
			close cur
			deallocate cur

		end

		select @sid = i.salesOrderID from inserted i
		select @price = i.orderTotal from inserted i
		select @cid = i.customerID from inserted i
		--23
		select @status = c.customerType from Customer as c where customerID = @cid
		if(@status = 'wholesale')
		begin
			--23
			select @status = w.taxExempt from Wholesale as w where customerID = @cid 
			--wholesale discount of 5 percent
			set @price = @price * 0.95
			if(@status = 'no')
				update SalesOrder
				set VATTotal = @price / 6, orderTotal = @price
				where salesOrderID = @sid
			else
				update SalesOrder
				set VATTotal = 0, orderTotal = @price
				where salesOrderID = @sid
		end
		else
			update SalesOrder
			set VATTotal = @price / 6, orderTotal = @price
			where salesOrderID = @sid 
	end
go

-- on new orderItmes insert
drop trigger if exists OI_onInsert
go

create trigger OI_onInsert on OrderItem after insert
as
	declare @sid int, @pid int, @req int, @avil int, @price money
	begin
		select @sid = i.salesOrderID from inserted i
		select @pid = i.partID from inserted i
		select @req = i.requested from inserted i

		-- update Part's stock and if parts are available
		--23
		select @avil = p.currentStock from Part as p where partID = @pid
		select @price = p.partPrice from Part as p where partID = @pid

		if(@req > @avil)
		begin
			update OrderItem
			set fufilled = 'no', unitPrice = @price * @req
			where partId = @pid and salesOrderID = @sid 

			update SalesOrder
			set orderStatus = 'incomplete'
			where SalesOrder.salesOrderId = @sid

		end
		if(@req < @avil)
		begin
			update OrderItem
			set fufilled = 'yes', unitPrice = @price * @req
			where partId = @pid and salesOrderID = @sid

			update Part
			set currentStock = currentStock - @req
			where partID =  @pid
		end

		update SalesOrder
		set SalesOrder.orderTotal = SalesOrder.orderTotal + (@price * @req)
		where SalesOrder.salesORderID = @sid
	end
go

--on delete of OrderItem
drop trigger if exists OI_onDelete
go

create trigger OI_onDelete on OrderItem after delete
as
	declare @id int, @req int,  @sid int, @fuf varchar(3), @stat varchar(20), @price money
	begin
		select @id = d.partID from deleted d
		select @fuf = d.fufilled from deleted d
		select @req = d.requested from deleted d
		select @sid = d.salesOrderID from deleted d
		select @price = d.unitPrice from deleted d
		--23
		select @stat = so.orderStatus from SalesOrder as so where salesOrderID = @sid

		if (@fuf = 'yes' and @stat <> 'complete')
			update Part
			set currentStock = currentStock + @req
			where partID = @id

			update SalesOrder
			set SalesOrder.orderTotal = SalesOrder.orderTotal - @price
			where SalesOrder.salesORderID = @sid
	end
go

-- on new orderItmes update
drop trigger if exists OI_onUpdate
go

create trigger OI_onUpdate on OrderItem instead of update
as
	declare @sid int, @pid int, @req int, @avil int, @price money, @fuf varchar(3)
	begin
		select @sid = i.salesOrderID from inserted i
		select @pid = i.partID from inserted i
		select @req = i.requested from inserted i
		--23
		select @fuf = i.fufilled from OrderItem as i where partID = @pid and salesOrderID = @sid 

		-- update Part's stock and if parts are available
		--23
		select @avil = p.currentStock from Part as p where partID = @pid 

		if(@fuf =  'no')
		begin
			if(@req < @avil)
			begin
				update OrderItem
				set fufilled = 'yes'
				where partId = @pid and salesOrderID = @sid

				update Part
				set currentStock = currentStock - @req
				where partID = @pid
			end
		end
	end
go




-- ALL INSERTS / FILLING DATA BASE

-- Customer Inserts 

INSERT INTO Customer VALUES ('Customer0', '0728892673', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer1', '0749443552', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer2', '0770185902', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer3', '0706802051', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer4', '0739327089', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer5', '0786584592', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer6', '0720169582', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer7', '0720832771', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer8', '0740956146', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer9', '0714202113', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer10', '0729500716', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer11', '0772485799', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer12', '0714331177', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer13', '0736248586', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer14', '0779006806', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer15', '0758416519', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer16', '0760741600', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer17', '0742420397', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer18', '0719546084', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer19', '0796603806', NULL, NULL, 'retail')
INSERT INTO Customer VALUES ('Customer20', '0781290993', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer21', '0783647830', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer22', '0775243719', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer23', '0709040499', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer24', '0756486109', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer25', '0720150830', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer26', '0772906846', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer27', '0702210734', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer28', '0756321345', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer29', '0779866339', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer30', '0707237930', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer31', '0785972364', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer32', '0771549898', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer33', '0722650372', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer34', '0791065188', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer35', '0771969355', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer36', '0764629682', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer37', '0758412346', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer38', '0799963192', NULL, NULL, 'wholesale')
INSERT INTO Customer VALUES ('Customer39', '0723913381', NULL, NULL, 'wholesale')
go


-- Retail Inserts

INSERT INTO Retail VALUES (1, '9120686732710132', 'Visa', '02/2025', 'email976@email.com')
INSERT INTO Retail VALUES (2, '6237623927782255', 'Visa', '03/2025', 'email205@email.com')
INSERT INTO Retail VALUES (3, '8366158164204022', 'Visa', '01/2025', 'email953@email.com')
INSERT INTO Retail VALUES (4, '1855201793297563', 'Visa', '02/2025', 'email846@email.com')
INSERT INTO Retail VALUES (5, '7279859414586221', 'Visa', '05/2025', 'email632@email.com')
INSERT INTO Retail VALUES (6, '1252019567421697', 'Visa', '09/2025', 'email687@email.com')
INSERT INTO Retail VALUES (7, '8590120166362766', 'Visa', '01/2025', 'email235@email.com')
INSERT INTO Retail VALUES (8, '1809975608821610', 'Visa', '05/2025', 'email466@email.com')
INSERT INTO Retail VALUES (9, '7513973858082569', 'Visa', '02/2025', 'email50@email.com')
INSERT INTO Retail VALUES (10, '2269554509411434', 'Visa', '11/2025', 'email71@email.com')
INSERT INTO Retail VALUES (11, '0120360659816107', 'Visa', '05/2025', 'email724@email.com')
INSERT INTO Retail VALUES (12, '2487831414644539', 'Visa', '09/2025', 'email805@email.com')
INSERT INTO Retail VALUES (13, '0288073159501227', 'Visa', '08/2025', 'email654@email.com')
INSERT INTO Retail VALUES (14, '0068321623110315', 'Visa', '08/2025', 'email831@email.com')
INSERT INTO Retail VALUES (15, '7456247661324366', 'Visa', '02/2025', 'email586@email.com')
INSERT INTO Retail VALUES (16, '0999572142152010', 'Visa', '08/2025', 'email269@email.com')
INSERT INTO Retail VALUES (17, '0321296255588917', 'Visa', '01/2025', 'email200@email.com')
INSERT INTO Retail VALUES (18, '7100408865412482', 'Visa', '11/2025', 'email0@email.com')
INSERT INTO Retail VALUES (19, '0310152583644560', 'Visa', '02/2025', 'email56@email.com')
INSERT INTO Retail VALUES (20, '5142543571497593', 'Visa', '11/2025', 'email389@email.com')
go


-- Wholesale Inserts

INSERT INTO Wholesale VALUES (21, 'contact0', '0721861076', 'email177@email.com', '898Street, London', '561Street, London', '395942', 0.0, 'yes', '880302')
INSERT INTO Wholesale VALUES (22, 'contact1', '0725898868', 'email222@email.com', '826Street, London', '971Street, London', '845431', 0.0, 'no', '444126')
INSERT INTO Wholesale VALUES (23, 'contact2', '0712232083', 'email588@email.com', '463Street, London', '712Street, London', '241077', 0.0, 'no', '408406')
INSERT INTO Wholesale VALUES (24, 'contact3', '0709148359', 'email88@email.com', '707Street, London', '279Street, London', '570690', 0.0, 'yes', '469802')
INSERT INTO Wholesale VALUES (25, 'contact4', '0799669744', 'email534@email.com', '517Street, London', '735Street, London', '559741', 0.0, 'no', '994191')
INSERT INTO Wholesale VALUES (26, 'contact5', '0769759796', 'email198@email.com', '281Street, London', '960Street, London', '115808', 0.0, 'no', '704644')
INSERT INTO Wholesale VALUES (27, 'contact6', '0708149283', 'email234@email.com', '243Street, London', '768Street, London', '881541', 0.0, 'yes', '262183')
INSERT INTO Wholesale VALUES (28, 'contact7', '0790152638', 'email502@email.com', '591Street, London', '150Street, London', '267803', 0.0, 'no', '331705')
INSERT INTO Wholesale VALUES (29, 'contact8', '0736226875', 'email32@email.com', '969Street, London', '732Street, London', '098102', 0.0, 'no', '719739')
INSERT INTO Wholesale VALUES (30, 'contact9', '0781608283', 'email77@email.com', '346Street, London', '491Street, London', '957719', 0.0, 'yes', '216577')
INSERT INTO Wholesale VALUES (31, 'contact10', '0796078517', 'email835@email.com', '86Street, London', '863Street, London', '461702', 0.0, 'no', '657937')
INSERT INTO Wholesale VALUES (32, 'contact11', '0769854634', 'email656@email.com', '286Street, London', '906Street, London', '239596', 0.0, 'no', '712940')
INSERT INTO Wholesale VALUES (33, 'contact12', '0721059967', 'email701@email.com', '769Street, London', '690Street, London', '808359', 0.0, 'yes', '961619')
INSERT INTO Wholesale VALUES (34, 'contact13', '0783220981', 'email954@email.com', '165Street, London', '275Street, London', '658219', 0.0, 'no', '977664')
INSERT INTO Wholesale VALUES (35, 'contact14', '0768702400', 'email467@email.com', '157Street, London', '789Street, London', '217078', 0.0, 'no', '550872')
INSERT INTO Wholesale VALUES (36, 'contact15', '0733033103', 'email253@email.com', '577Street, London', '502Street, London', '366061', 0.0, 'yes', '971494')
INSERT INTO Wholesale VALUES (37, 'contact16', '0764284745', 'email325@email.com', '30Street, London', '46Street, London', '638257', 0.0, 'no', '385652')
INSERT INTO Wholesale VALUES (38, 'contact17', '0781093568', 'email154@email.com', '854Street, London', '188Street, London', '804079', 0.0, 'no', '072358')
INSERT INTO Wholesale VALUES (39, 'contact18', '0730194753', 'email948@email.com', '633Street, London', '1Street, London', '013315', 0.0, 'yes', '553454')
INSERT INTO Wholesale VALUES (40, 'contact19', '0717586460', 'email193@email.com', '425Street, London', '62Street, London', '888974', 0.0, 'no', '916457')
go


-- Employee Inserts

INSERT INTO Employee VALUES ('administration', 'Empl0', 'Oyee0', '800Street, London', 1109.28, '713849')
INSERT INTO Employee VALUES ('administration', 'Empl1', 'Oyee1', '674Street, London', 1483.56, '020749')
INSERT INTO Employee VALUES ('administration', 'Empl2', 'Oyee2', '435Street, London', 1849.21, '522929')
INSERT INTO Employee VALUES ('administration', 'Empl3', 'Oyee3', '918Street, London', 1945.54, '879359')
INSERT INTO Employee VALUES ('administration', 'Empl4', 'Oyee4', '636Street, London', 1160.94, '621395')
INSERT INTO Employee VALUES ('administration', 'Empl5', 'Oyee5', '363Street, London', 2428.73, '667635')
INSERT INTO Employee VALUES ('administration', 'Empl6', 'Oyee6', '680Street, London', 1571.34, '943733')
INSERT INTO Employee VALUES ('administration', 'Empl7', 'Oyee7', '279Street, London', 2789.6, '558297')
INSERT INTO Employee VALUES ('administration', 'Empl8', 'Oyee8', '640Street, London', 2947.89, '377215')
INSERT INTO Employee VALUES ('administration', 'Empl9', 'Oyee9', '805Street, London', 1442.62, '157919')
INSERT INTO Employee VALUES ('administration', 'Empl10', 'Oyee10', '571Street, London', 1802.58, '029680')
INSERT INTO Employee VALUES ('administration', 'Empl11', 'Oyee11', '481Street, London', 1330.13, '915167')
INSERT INTO Employee VALUES ('administration', 'Empl12', 'Oyee12', '711Street, London', 1930.95, '124492')
INSERT INTO Employee VALUES ('administration', 'Empl13', 'Oyee13', '94Street, London', 2116.02, '805445')
INSERT INTO Employee VALUES ('administration', 'Empl14', 'Oyee14', '483Street, London', 2407.32, '126087')
INSERT INTO Employee VALUES ('administration', 'Empl15', 'Oyee15', '53Street, London', 1620.83, '470726')
INSERT INTO Employee VALUES ('administration', 'Empl16', 'Oyee16', '612Street, London', 2325.53, '869959')
INSERT INTO Employee VALUES ('administration', 'Empl17', 'Oyee17', '223Street, London', 1674.46, '591763')
INSERT INTO Employee VALUES ('administration', 'Empl18', 'Oyee18', '402Street, London', 1219.32, '033278')
INSERT INTO Employee VALUES ('administration', 'Empl19', 'Oyee19', '795Street, London', 1008.1, '654230')
INSERT INTO Employee VALUES ('sales', 'Empl20', 'Oyee20', '957Street, London', 1807.18, '405956')
INSERT INTO Employee VALUES ('sales', 'Empl21', 'Oyee21', '659Street, London', 1026.72, '349690')
INSERT INTO Employee VALUES ('sales', 'Empl22', 'Oyee22', '20Street, London', 2926.48, '932174')
INSERT INTO Employee VALUES ('sales', 'Empl23', 'Oyee23', '598Street, London', 1539.11, '549995')
INSERT INTO Employee VALUES ('sales', 'Empl24', 'Oyee24', '860Street, London', 1074.43, '794709')
INSERT INTO Employee VALUES ('sales', 'Empl25', 'Oyee25', '389Street, London', 1016.53, '597182')
INSERT INTO Employee VALUES ('sales', 'Empl26', 'Oyee26', '406Street, London', 2848.92, '021917')
INSERT INTO Employee VALUES ('sales', 'Empl27', 'Oyee27', '305Street, London', 1428.35, '548867')
INSERT INTO Employee VALUES ('sales', 'Empl28', 'Oyee28', '442Street, London', 2602.03, '422210')
INSERT INTO Employee VALUES ('sales', 'Empl29', 'Oyee29', '501Street, London', 2237.74, '805750')
INSERT INTO Employee VALUES ('sales', 'Empl30', 'Oyee30', '659Street, London', 2427.89, '214825')
INSERT INTO Employee VALUES ('sales', 'Empl31', 'Oyee31', '753Street, London', 2023.29, '802669')
INSERT INTO Employee VALUES ('sales', 'Empl32', 'Oyee32', '500Street, London', 2071.37, '124503')
INSERT INTO Employee VALUES ('sales', 'Empl33', 'Oyee33', '455Street, London', 2200.1, '821383')
INSERT INTO Employee VALUES ('sales', 'Empl34', 'Oyee34', '512Street, London', 2720.33, '658063')
INSERT INTO Employee VALUES ('sales', 'Empl35', 'Oyee35', '9Street, London', 2039.44, '635808')
INSERT INTO Employee VALUES ('sales', 'Empl36', 'Oyee36', '365Street, London', 1021.06, '945715')
INSERT INTO Employee VALUES ('sales', 'Empl37', 'Oyee37', '388Street, London', 2356.02, '897024')
INSERT INTO Employee VALUES ('sales', 'Empl38', 'Oyee38', '962Street, London', 1979.85, '914646')
INSERT INTO Employee VALUES ('sales', 'Empl39', 'Oyee39', '585Street, London', 2054.49, '711026')
INSERT INTO Employee VALUES ('technology', 'Empl40', 'Oyee40', '673Street, London', 2681.41, '836540')
INSERT INTO Employee VALUES ('technology', 'Empl41', 'Oyee41', '830Street, London', 2370.9, '098074')
INSERT INTO Employee VALUES ('technology', 'Empl42', 'Oyee42', '729Street, London', 1628.85, '507073')
INSERT INTO Employee VALUES ('technology', 'Empl43', 'Oyee43', '601Street, London', 1446.91, '779376')
INSERT INTO Employee VALUES ('technology', 'Empl44', 'Oyee44', '851Street, London', 1042.6, '049526')
INSERT INTO Employee VALUES ('technology', 'Empl45', 'Oyee45', '850Street, London', 1563.3, '096913')
INSERT INTO Employee VALUES ('technology', 'Empl46', 'Oyee46', '731Street, London', 1601.21, '498236')
INSERT INTO Employee VALUES ('technology', 'Empl47', 'Oyee47', '82Street, London', 2314.73, '257658')
INSERT INTO Employee VALUES ('technology', 'Empl48', 'Oyee48', '122Street, London', 2672.07, '913680')
INSERT INTO Employee VALUES ('technology', 'Empl49', 'Oyee49', '359Street, London', 2422.64, '211354')
INSERT INTO Employee VALUES ('technology', 'Empl50', 'Oyee50', '224Street, London', 1438.07, '321318')
INSERT INTO Employee VALUES ('technology', 'Empl51', 'Oyee51', '579Street, London', 2866.27, '696587')
INSERT INTO Employee VALUES ('technology', 'Empl52', 'Oyee52', '84Street, London', 2059.52, '283377')
INSERT INTO Employee VALUES ('technology', 'Empl53', 'Oyee53', '121Street, London', 1883.89, '792625')
INSERT INTO Employee VALUES ('technology', 'Empl54', 'Oyee54', '637Street, London', 1132.06, '982069')
INSERT INTO Employee VALUES ('technology', 'Empl55', 'Oyee55', '125Street, London', 2613.73, '895420')
INSERT INTO Employee VALUES ('technology', 'Empl56', 'Oyee56', '665Street, London', 2254.02, '727697')
INSERT INTO Employee VALUES ('technology', 'Empl57', 'Oyee57', '746Street, London', 1541.97, '098435')
INSERT INTO Employee VALUES ('technology', 'Empl58', 'Oyee58', '674Street, London', 2549.7, '918070')
INSERT INTO Employee VALUES ('technology', 'Empl59', 'Oyee59', '64Street, London', 1840.82, '903655')
INSERT INTO Employee VALUES ('marketing', 'Empl60', 'Oyee60', '724Street, London', 1818.02, '931160')
INSERT INTO Employee VALUES ('shipping', 'Empl61', 'Oyee61', '409Street, London', 2852.58, '679242')
INSERT INTO Employee VALUES ('purchasing', 'Empl62', 'Oyee62', '381Street, London', 2122.52, '794503')
INSERT INTO Employee VALUES ('marketing', 'Empl63', 'Oyee63', '215Street, London', 2658.53, '663931')
INSERT INTO Employee VALUES ('shipping', 'Empl64', 'Oyee64', '58Street, London', 2294.41, '406078')
INSERT INTO Employee VALUES ('purchasing', 'Empl65', 'Oyee65', '193Street, London', 2061.6, '077981')
INSERT INTO Employee VALUES ('marketing', 'Empl66', 'Oyee66', '802Street, London', 1239.19, '479776')
INSERT INTO Employee VALUES ('shipping', 'Empl67', 'Oyee67', '879Street, London', 1990.03, '142938')
INSERT INTO Employee VALUES ('purchasing', 'Empl68', 'Oyee68', '245Street, London', 2140.95, '010455')
INSERT INTO Employee VALUES ('marketing', 'Empl69', 'Oyee69', '483Street, London', 2624.48, '426329')
go


-- Administrator Inserts

INSERT INTO Administrator VALUES (1, 'Manager', 102.0)
INSERT INTO Administrator VALUES (2, 'Director', 146.3)
INSERT INTO Administrator VALUES (3, 'leader', 109.17)
INSERT INTO Administrator VALUES (4, 'Manager', 181.64)
INSERT INTO Administrator VALUES (5, 'Director', 167.99)
INSERT INTO Administrator VALUES (6, 'leader', 151.98)
INSERT INTO Administrator VALUES (7, 'Manager', 163.84)
INSERT INTO Administrator VALUES (8, 'Director', 169.22)
INSERT INTO Administrator VALUES (9, 'leader', 105.31)
INSERT INTO Administrator VALUES (10, 'Manager', 118.9)
INSERT INTO Administrator VALUES (11, 'Director', 195.25)
INSERT INTO Administrator VALUES (12, 'leader', 164.5)
INSERT INTO Administrator VALUES (13, 'Manager', 123.81)
INSERT INTO Administrator VALUES (14, 'Director', 101.32)
INSERT INTO Administrator VALUES (15, 'leader', 175.02)
INSERT INTO Administrator VALUES (16, 'Manager', 133.04)
INSERT INTO Administrator VALUES (17, 'Director', 159.93)
INSERT INTO Administrator VALUES (18, 'leader', 199.48)
INSERT INTO Administrator VALUES (19, 'Manager', 170.21)
INSERT INTO Administrator VALUES (20, 'Director', 153.98)
go


-- SalesRepresentative Inserts

INSERT INTO SalesRepresentative VALUES (21, 0.00)
INSERT INTO SalesRepresentative VALUES (22, 0.00)
INSERT INTO SalesRepresentative VALUES (23, 0.00)
INSERT INTO SalesRepresentative VALUES (24, 0.00)
INSERT INTO SalesRepresentative VALUES (25, 0.00)
INSERT INTO SalesRepresentative VALUES (26, 0.00)
INSERT INTO SalesRepresentative VALUES (27, 0.00)
INSERT INTO SalesRepresentative VALUES (28, 0.00)
INSERT INTO SalesRepresentative VALUES (29, 0.00)
INSERT INTO SalesRepresentative VALUES (30, 0.00)
INSERT INTO SalesRepresentative VALUES (31, 0.00)
INSERT INTO SalesRepresentative VALUES (32, 0.00)
INSERT INTO SalesRepresentative VALUES (33, 0.00)
INSERT INTO SalesRepresentative VALUES (34, 0.00)
INSERT INTO SalesRepresentative VALUES (35, 0.00)
INSERT INTO SalesRepresentative VALUES (36, 0.00)
INSERT INTO SalesRepresentative VALUES (37, 0.00)
INSERT INTO SalesRepresentative VALUES (38, 0.00)
INSERT INTO SalesRepresentative VALUES (39, 0.00)
INSERT INTO SalesRepresentative VALUES (40, 0.00)
go


-- Specialist Inserts

INSERT INTO Specialist VALUES (41, 'Breakes Technician', 'Master degree')
INSERT INTO Specialist VALUES (42, 'Engine Technician', '2 month course')
INSERT INTO Specialist VALUES (43, 'Transmission Technician', '6 month course')
INSERT INTO Specialist VALUES (44, 'Body Technician', 'Bachelor Degree')
INSERT INTO Specialist VALUES (45, 'Breakes Technician', 'Apprenticeship Diploma')
INSERT INTO Specialist VALUES (46, 'Engine Technician', 'Master degree')
INSERT INTO Specialist VALUES (47, 'Transmission Technician', '2 month course')
INSERT INTO Specialist VALUES (48, 'Body Technician', '6 month course')
INSERT INTO Specialist VALUES (49, 'Breakes Technician', 'Bachelor Degree')
INSERT INTO Specialist VALUES (50, 'Engine Technician', 'Apprenticeship Diploma')
INSERT INTO Specialist VALUES (51, 'Transmission Technician', 'Master degree')
INSERT INTO Specialist VALUES (52, 'Body Technician', '2 month course')
INSERT INTO Specialist VALUES (53, 'Breakes Technician', '6 month course')
INSERT INTO Specialist VALUES (54, 'Engine Technician', 'Bachelor Degree')
INSERT INTO Specialist VALUES (55, 'Transmission Technician', 'Apprenticeship Diploma')
INSERT INTO Specialist VALUES (56, 'Body Technician', 'Master degree')
INSERT INTO Specialist VALUES (57, 'Breakes Technician', '2 month course')
INSERT INTO Specialist VALUES (58, 'Engine Technician', '6 month course')
INSERT INTO Specialist VALUES (59, 'Transmission Technician', 'Bachelor Degree')
INSERT INTO Specialist VALUES (60, 'Body Technician', 'Apprenticeship Diploma')
go


-- Supplier Inserts 

INSERT INTO Supplier VALUES ('supplier0', '0723637108', 'email255@email.com', 0)
INSERT INTO Supplier VALUES ('supplier1', '0729573989', 'email231@email.com', 0)
INSERT INTO Supplier VALUES ('supplier2', '0778836011', 'email501@email.com', 0)
INSERT INTO Supplier VALUES ('supplier3', '0739943752', 'email395@email.com', 0)
INSERT INTO Supplier VALUES ('supplier4', '0730510166', 'email184@email.com', 0)
INSERT INTO Supplier VALUES ('supplier5', '0756557912', 'email624@email.com', 0)
INSERT INTO Supplier VALUES ('supplier6', '0742924039', 'email513@email.com', 0)
INSERT INTO Supplier VALUES ('supplier7', '0793251144', 'email663@email.com', 0)
INSERT INTO Supplier VALUES ('supplier8', '0720468711', 'email651@email.com', 0)
INSERT INTO Supplier VALUES ('supplier9', '0798647373', 'email396@email.com', 0)
INSERT INTO Supplier VALUES ('supplier10', '0739310475', 'email792@email.com', 0)
INSERT INTO Supplier VALUES ('supplier11', '0758374417', 'email291@email.com', 0)
INSERT INTO Supplier VALUES ('supplier12', '0723691134', 'email445@email.com', 0)
INSERT INTO Supplier VALUES ('supplier13', '0717754317', 'email789@email.com', 0)
INSERT INTO Supplier VALUES ('supplier14', '0713385257', 'email445@email.com', 0)
INSERT INTO Supplier VALUES ('supplier15', '0762250584', 'email50@email.com', 0)
INSERT INTO Supplier VALUES ('supplier16', '0758534357', 'email412@email.com', 0)
INSERT INTO Supplier VALUES ('supplier17', '0779023586', 'email714@email.com', 0)
INSERT INTO Supplier VALUES ('supplier18', '0789688400', 'email691@email.com', 0)
INSERT INTO Supplier VALUES ('supplier19', '0784347080', 'email213@email.com', 0)
go


-- Part Inserts

INSERT INTO Part VALUES ('Description Text', 196.22, 2, 33, 17, 0, 'In Stock', 13)
INSERT INTO Part VALUES ('Description Text', 170.7, 6, 49, 11, 0, 'In Stock', 6)
INSERT INTO Part VALUES ('Description Text', 108.05, 4, 33, 4, 0, 'In Stock', 5)
INSERT INTO Part VALUES ('Description Text', 178.76, 8, 36, 6, 0, 'In Stock', 18)
INSERT INTO Part VALUES ('Description Text', 129.42, 3, 34, 11, 0, 'In Stock', 5)
INSERT INTO Part VALUES ('Description Text', 150.45, 5, 41, 14, 0, 'In Stock', 1)
INSERT INTO Part VALUES ('Description Text', 171.88, 9, 50, 15, 0, 'In Stock', 20)
INSERT INTO Part VALUES ('Description Text', 191.62, 1, 44, 16, 0, 'In Stock', 15)
INSERT INTO Part VALUES ('Description Text', 128.52, 2, 20, 13, 0, 'In Stock', 10)
INSERT INTO Part VALUES ('Description Text', 166.92, 14, 26, 5, 0, 'In Stock', 16)
INSERT INTO Part VALUES ('Description Text', 181.77, 20, 38, 5, 0, 'In Stock', 15)
INSERT INTO Part VALUES ('Description Text', 166.9, 9, 23, 1, 0, 'In Stock', 2)
INSERT INTO Part VALUES ('Description Text', 117.49, 11, 23, 15, 0, 'In Stock', 5)
INSERT INTO Part VALUES ('Description Text', 196.95, 17, 49, 20, 0, 'In Stock', 11)
INSERT INTO Part VALUES ('Description Text', 179.35, 1, 28, 5, 0, 'In Stock', 3)
INSERT INTO Part VALUES ('Description Text', 183.11, 18, 21, 3, 0, 'In Stock', 10)
INSERT INTO Part VALUES ('Description Text', 155.61, 4, 36, 15, 0, 'In Stock', 9)
INSERT INTO Part VALUES ('Description Text', 165.47, 19, 43, 14, 0, 'In Stock', 10)
INSERT INTO Part VALUES ('Description Text', 121.37, 7, 45, 16, 0, 'In Stock', 3)
INSERT INTO Part VALUES ('Description Text', 164.22, 20, 38, 16, 0, 'In Stock', 1)
go


-- CarModel Inserts

INSERT INTO CarModel VALUES ('audi', 'a', 1999)
INSERT INTO CarModel VALUES ('mercedes', 'e', 2000)
INSERT INTO CarModel VALUES ('bwm', 'g', 2000)
INSERT INTO CarModel VALUES ('prosche', 'q', 2020)
INSERT INTO CarModel VALUES ('audi', 't', 2020)
INSERT INTO CarModel VALUES ('mercedes', 's', 2009)
INSERT INTO CarModel VALUES ('bwm', 'j', 1998)
INSERT INTO CarModel VALUES ('prosche', 'se', 1994)
INSERT INTO CarModel VALUES ('audi', 'tv', 2000)
INSERT INTO CarModel VALUES ('mercedes', 'i', 2014)
INSERT INTO CarModel VALUES ('bwm', 'a', 1976)
INSERT INTO CarModel VALUES ('prosche', 'e', 1988)
INSERT INTO CarModel VALUES ('audi', 'g', 1981)
INSERT INTO CarModel VALUES ('mercedes', 'q', 1977)
INSERT INTO CarModel VALUES ('bwm', 't', 1979)
INSERT INTO CarModel VALUES ('prosche', 's', 1972)
INSERT INTO CarModel VALUES ('audi', 'j', 1978)
INSERT INTO CarModel VALUES ('mercedes', 'se', 2014)
INSERT INTO CarModel VALUES ('bwm', 'tv', 2013)
INSERT INTO CarModel VALUES ('prosche', 'i', 2000)
go


-- PartCompatibility Inserts

INSERT INTO PartCompatibility VALUES (16, 7)
INSERT INTO PartCompatibility VALUES (4, 16)
INSERT INTO PartCompatibility VALUES (3, 20)
INSERT INTO PartCompatibility VALUES (12, 14)
INSERT INTO PartCompatibility VALUES (15, 4)
INSERT INTO PartCompatibility VALUES (20, 19)
INSERT INTO PartCompatibility VALUES (10, 4)
INSERT INTO PartCompatibility VALUES (12, 1)
INSERT INTO PartCompatibility VALUES (14, 2)
INSERT INTO PartCompatibility VALUES (9, 11)
INSERT INTO PartCompatibility VALUES (2, 10)
INSERT INTO PartCompatibility VALUES (16, 12)
INSERT INTO PartCompatibility VALUES (6, 11)
INSERT INTO PartCompatibility VALUES (8, 20)
INSERT INTO PartCompatibility VALUES (14, 19)
INSERT INTO PartCompatibility VALUES (10, 7)
INSERT INTO PartCompatibility VALUES (15, 9)
INSERT INTO PartCompatibility VALUES (2, 16)
INSERT INTO PartCompatibility VALUES (5, 15)
INSERT INTO PartCompatibility VALUES (9, 16)
go


-- inserts into SalesOrder and OrderItems
INSERT INTO SalesOrder VALUES (getdate(), 28, 18, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (1, 14, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (1, 6, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (1, 7, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (1, 15, 'yes', 2, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 23, 18, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (2, 4, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (2, 16, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (2, 20, 'yes', 5, 0.0)
INSERT INTO OrderItem VALUES (2, 15, 'yes', 2, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 32, 18, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (3, 14, 'yes', 5, 0.0)
INSERT INTO OrderItem VALUES (3, 5, 'yes', 3, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 36, 9, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (4, 11, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (4, 12, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (4, 8, 'yes', 2, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 37, 9, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (5, 1, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (5, 2, 'yes', 3, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 9, 6, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (6, 2, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (6, 4, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (6, 8, 'yes', 3, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 32, 19, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (7, 8, 'yes', 4, 0.0)
INSERT INTO OrderItem VALUES (7, 10, 'yes', 5, 0.0)
INSERT INTO OrderItem VALUES (7, 5, 'yes', 2, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 9, 18, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (8, 19, 'yes', 5, 0.0)
INSERT INTO OrderItem VALUES (8, 17, 'yes', 4, 0.0)
INSERT INTO OrderItem VALUES (8, 14, 'yes', 4, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 4, 15, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (9, 8, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (9, 13, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (9, 17, 'yes', 3, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 3, 11, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (10, 15, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (10, 6, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (10, 16, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (10, 4, 'yes', 5, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 31, 2, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (11, 8, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (11, 13, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (11, 12, 'yes', 1, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 33, 17, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (12, 11, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (12, 16, 'yes', 1, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 5, 2, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (13, 19, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (13, 7, 'yes', 3, 0.0)
INSERT INTO OrderItem VALUES (13, 5, 'yes', 5, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 38, 19, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (14, 1, 'yes', 4, 0.0)
INSERT INTO OrderItem VALUES (14, 20, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (14, 9, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (14, 14, 'yes', 5, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 28, 11, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (15, 9, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (15, 15, 'yes', 4, 0.0)
INSERT INTO OrderItem VALUES (15, 4, 'yes', 5, 0.0)
INSERT INTO OrderItem VALUES (15, 3, 'yes', 5, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 12, 20, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (16, 11, 'yes', 4, 0.0)
INSERT INTO OrderItem VALUES (16, 4, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (16, 18, 'yes', 5, 0.0)
INSERT INTO OrderItem VALUES (16, 19, 'yes', 2, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 9, 17, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (17, 6, 'yes', 5, 0.0)
INSERT INTO OrderItem VALUES (17, 7, 'yes', 5, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 20, 16, 'random billing address', 'random shipping address', 0.0, 0.0, 'yes', 'incomplete')
INSERT INTO OrderItem VALUES (18, 10, 'yes', 2, 0.0)
INSERT INTO OrderItem VALUES (18, 8, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (18, 7, 'yes', 2, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 15, 2, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (19, 5, 'yes', 1, 0.0)
INSERT INTO OrderItem VALUES (19, 18, 'yes', 1, 0.0)
INSERT INTO SalesOrder VALUES (getdate(), 26, 9, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (20, 2, 'yes', 4, 0.0)
INSERT INTO OrderItem VALUES (20, 16, 'yes', 2, 0.0)
go 


-- SIMULATING DATABASE ACTIVITY

drop procedure if exists completePurchases
go

create procedure completePurchases as
	declare @id int, @stat varchar(3),  @fuf varchar(3), @res varchar(3)

	begin
		declare cur CURSOR for (select salesOrderID, paymentComplete from SalesOrder where orderStatus <> 'complete')
		open cur
			fetch next from cur into @id, @stat
			while (@@FETCH_STATUS = 0) 
			begin
				update SalesOrder
				set orderStatus = 'complete'
				where salesOrderID = @id 
				fetch next from cur into @id, @stat
			end
		close cur
		deallocate cur
	end
go

exec completePurchases
go

-- TASK 4

-- PART A

drop view if exists topAndLeastSales
go

create view topAndLeastSales
	as
	select  e.*, s.sales
	from Employee as e
	inner join SalesRepresentative as sr
		on (sr.employeeID = e.employeeID)
	inner join (
		select top 1 salesRepId, Count(*) as sales
		from SalesOrder
		group by salesRepID
		order by sales desc

		union all

		select top 1 salesRepId, Count(*) as sales
		from SalesOrder
		group by salesRepID
		order by sales) as s
		on (s.salesRepID = sr.salesRepID)
		
go

select * from topAndLeastSales
go

-- PART B

drop procedure if exists SalesStatusTotals
go

create procedure SalesStatusTotals
as
	declare @i int
begin
	select @i = s.c from (select count(*) as c from salesOrder where orderStatus = 'incomplete') s
	print 'Incomplete: ' + cast(@i as varchar(20))
	select @i = s.c from (select count(*) as c from salesOrder where orderStatus = 'cancelled') s
	print 'Cancelled: ' + cast(@i as varchar(20))
	select @i = s.c from (select count(*) as c from salesOrder where orderStatus = 'complete') s
	print 'Complete: ' + cast(@i as varchar(20))
end
go

exec SalesStatusTotals
go

--PART C

	-- the follwing new Sales order will reduce the curret 
	-- stock of Parts with id: bellow the minimum to show that the view functions
	-- as intended

INSERT INTO SalesOrder VALUES (getdate(), 26, 9, 'random billing address', 'random shipping address', 0.0, 0.0, 'no', 'incomplete')
INSERT INTO OrderItem VALUES (21, 1, 'yes', 11, 0.0)
INSERT INTO OrderItem VALUES (21, 8, 'yes', 13, 0.0)

drop view if exists SupplierSForBellowMin
go

create view SupplierSForBellowMin
as
	select s.*
	from Part as p
	inner join Supplier as s  on (p.supplierID = s.supplierID)
	where p.currentStock < p.minimumStock
go

select * from SupplierSForBellowMin


-- PART D
	
	-- I already implmented this task in the triggers RA_onDelete and P_onUpdate
	-- the following select statments display the results and success of the task

SELECT * from RestockAwaited
SELECT * from Part where currentStock < minimumStock
go

--Part E

drop procedure if exists SalesInvoice
go

create procedure SalesInvoice @id int
as
	declare @c int, @str varchar(35), @m1 money, @num int, @m2 money, @da date
	begin
		print 'Invoice For Sale ' + cast(@id as varchar(10))
		select @str = orderStatus from SalesOrder where salesOrderID = @id 
		print 'Current Status: ' + cast(@str as varchar(10))
		select @da = orderDate from SalesOrder where salesOrderID = @id 
		print 'Order Date: ' + cast(@da as varchar(10))
		print '-------------------------------------------------------------------------'

		select @c = customerID from SalesOrder where salesOrderID = @id 
		print 'Customer ' + cast(@c as varchar(10))
		select @str = fullName from Customer where customerID = @c
		print 'Name: ' + cast( @str as varchar(35))
		select @str = phoneNumber from Customer where customerID = @c
		print 'Number: ' + cast( @str as varchar(35))
		select @str = customerType from Customer where customerID = @c
		print 'Type: ' + cast( @str as varchar(35))
		print '-------------------------------------------------------------------------'

		if(@str = 'Retail')
		begin
			print 'Retail Customer info'
			select @str = emailAddress from Retail where customerID = @c
			print 'Email: ' + cast( @str as varchar(35))
			print '-------------------------------------------------------------------------'
		end

		if(@str = 'Wholesale')
		begin
			print 'Wholesale Customer info'
			select @str = contactName from Wholesale where customerID = @c
			print 'Contact Name: ' + cast( @str as varchar(35))
			select @str = contactPhoneNumber from Wholesale where customerID = @c
			print 'Contact Number:' + cast( @str as varchar(35))
			select @str = contactEmailAddress from Wholesale where customerID = @c
			print 'Contact Email:' + cast( @str as varchar(35))
			select @str = taxExempt from Wholesale where customerID = @c
			print 'Is the customer exempt from VAT tax: ' + cast( @str as varchar(35))
			select @str = VATRegistrationNumber from Wholesale where customerID = @c
			print 'VAT Registration Number:' + cast( @str as varchar(35))
			print '-------------------------------------------------------------------------'
		end


		Print 'ITEMS'
		print 'ID	Descrition				PartPrice		Quantity		Unit Price'

		declare cur CURSOR for(select partID, requested, unitPrice from OrderItem where salesOrderID = @id)
		open cur
			fetch next from cur into @c, @num, @m2
			while(@@FETCH_STATUS = 0)
			begin
				select @str = substring(partDescription, 1, 20) from Part where partID = @c
				select @m1 = partPrice from Part where partId = @c

				print cast(@c as varchar(10)) + '	' + cast(@str as varchar(35)) + '...		' + cast(@m1 as varchar(35)) + '				' + cast(@num as varchar(35)) + '				' + cast(@m2 as varchar(35))
				fetch next from cur into @c, @num, @m2
			end
		close cur
		deallocate cur

		print '-------------------------------------------------------------------------'
		
		select @c = customerID from SalesOrder where salesOrderID = @id 
		select @str = customerType from Customer where customerID = @c
		if(@str = 'Wholesale')
			print 'Wholesale Customer Discount: -5%'

		
		select @m1 = VATTotal from SalesOrder where salesOrderID = @id 
		print 'VAT Total: ' + cast(@m1 as varchar(10))
		select @m2 = orderTotal from SalesOrder where salesOrderID = @id
		print 'Items Total: ' + cast((@m2 - @m1) as varchar(10))
		print 'Order Total(VAT Included): ' + cast(@m2 as varchar(10))

	end
	go

	exec SalesInvoice 2
	go


