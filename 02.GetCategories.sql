USE [razemkupujemy]

-- Variable declaration related to the Object.

DECLARE @apiUrl NVARCHAR(MAX);
DECLARE @apiToken NVARCHAR(64);
DECLARE @contentType NVARCHAR(64);
DECLARE @requestObj INT;
DECLARE @responseObj INT;
DECLARE @jsonResponse AS TABLE(Json_Table NVARCHAR(MAX))

-- Set Authentications
SET @apiToken = 'Bearer '+(SELECT TOP 1 api_token FROM users WHERE is_active = 1);
SET @contentType = 'application/json';
SET @apiUrl = (SELECT TOP 1 api_url FROM users WHERE is_active = 1) +'/api/partner/categories' ;


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

 DELETE FROM categories WHERE 1=1;


 INSERT INTO categories (id,name,category_id,is_active)
 (SELECT
		id,
		name,
		category_id,
		is_active
	FROM OPENJSON((SELECT * FROM @jsonResponse))
	WITH (
		id BIGINT ,
		name VARCHAR(MAX) ,
		category_id BIGINT,
		is_active BIT
		)
	)

-- DEBUG --------------------------------
SELECT * FROM categories

