USE [razemkupujemy]

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
SET @apiUrl = (SELECT api_url FROM users WHERE id = 1) +'/api/partner/category-product' ;


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
-- SELECT * FROM OPENJSON((SELECT * FROM @jsonResponse)) WITH ( id BIGINT, name VARCHAR(MAX), category_id BIGINT  )

 DELETE FROM category_product WHERE 1=1;


 INSERT INTO category_product (id,category_id,product_id)
 (SELECT
      id,category_id,product_id
	FROM OPENJSON((SELECT * FROM @jsonResponse))
	WITH (
		id BIGINT ,
		category_id BIGINT,
		product_id BIGINT
		)
	)

-- DEBUG --------------------------------
SELECT * FROM category_product

