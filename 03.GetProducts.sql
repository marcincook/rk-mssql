USE [razemkupujemy]
GO

-- Variable declaration related to the Object.
 
DECLARE @apiUrl NVARCHAR(MAX); 
DECLARE @apiToken NVARCHAR(64);
DECLARE @contentType NVARCHAR(64);  
DECLARE @requestObj INT;
DECLARE @responseObj INT; 
DECLARE @jsonResponse AS TABLE(Json_Table NVARCHAR(MAX)) 

-- Set Authentications
SET @apiToken = 'Bearer '+(SELECT api_token FROM users WHERE id = 1); 
SET @contentType = 'application/json'; 
SET @apiUrl = (SELECT api_url FROM users WHERE id = 1) +'/api/partner/products' ;
 
    
---- This creates the new object.S
EXEC @responseObj = sp_OACreate 'MSXML2.XMLHTTP', @requestObj OUT;
IF @responseObj <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

-- This calls the necessary methods.
EXEC @responseObj = sp_OAMethod @requestObj, 'open', NULL, 'GET', @apiUrl, 'false';
EXEC @responseObj = sp_OAMethod @requestObj, 'setRequestHeader', NULL, 'Authorization', @apiToken;
EXEC @responseObj = sp_OAMethod @requestObj, 'setRequestHeader', NULL, 'Content-type', @contentType;
EXEC @responseObj = sp_OAMethod @requestObj, 'send'

INSERT into @jsonResponse (Json_Table) EXEC sp_OAGetProperty @requestObj, 'responseText'
-- DEBUG --------------------------------- 
-- SELECT * FROM @jsonResponse
-- SELECT * FROM OPENJSON((SELECT * FROM @jsonResponse)) WITH ( id BIGINT, name VARCHAR(MAX)) 
 
 -- W³aœciwa czêœæ procedury
 -- W tym przyk³adzie za³o¿enie jest takie ¿e lokalna tabla produkty zostaje wyczyszczona a zawartoœæ pobrana z serwera rk wpisuje œwiezy stan produktów 

 -- Kasowanie produktów
 DELETE FROM products
 
 -- wpisanie aktualnych produktów z serwera rk 
 INSERT INTO products 
 (
	id,
	is_active,
	position,
	name_base,
	name,
	description,
	content,
	unit,
	unit_base,
	capacity,
	quantity,
	barcodes,
	sku,
	price,
	price_old,
	vat,
	stock_control,
	stock,
	is_promoted,
	is_sale, 
	partner_id,
	producer_id
 )
 (
 SELECT  
		id,
		is_active,
		position,
		name_base,
		name,
		description,
		content,
		unit,
		unit_base,
		capacity,
		quantity,
		barcodes,
		sku,
		price,
		price_old,
		vat,
		stock_control,
		stock ,
		is_promoted,
		is_sale, 
		partner_id,
		producer_id
	FROM OPENJSON((SELECT * FROM @jsonResponse))
	WITH (   
		id BIGINT,
		is_active BIT,
		position BIGINT,
		name_base VARCHAR(MAX),
		name VARCHAR(MAX),
		description VARCHAR(MAX),
		content VARCHAR(MAX),
		unit VARCHAR(MAX),
		unit_base VARCHAR(MAX),
		capacity DECIMAL(8,2),
		quantity DECIMAL(8,2),
		barcodes VARCHAR(MAX),
		sku VARCHAR(MAX),
		price DECIMAL(8,2),
		price_old VARCHAR(MAX),
		vat INT,
		stock_control BIT,
		stock DECIMAL(8,2),
		is_promoted BIT,
		is_sale BIT, 
		partner_id BIGINT,
		producer_id BIGINT
		) 
)

-- DEBUG --------------------------------
SELECT * FROM products
   
    