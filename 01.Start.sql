-- Utwórz baze danych 'razemkupujemy'

CREATE DATABASE razemkupujemy;
GO
-- Ustaw opcje sql serwer 2019

USE [razemkupujemy]
GO

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO

EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO


CREATE TABLE users (
  id INT NOT NULL IDENTITY PRIMARY KEY,
  username VARCHAR(100)  NOT NULL,
  api_token  NVARCHAR(MAX),
  api_url NVARCHAR(MAX),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
 
GO

INSERT INTO [dbo].[users] ([username],[api_token],[api_url])
     VALUES('demouser','798|GyIoYnHantvMjuK5BZaaL18DAwpdRuslJMKvs89g','https://api.razemkupujemy.pl')
GO

CREATE TABLE categories (
  id BIGINT NOT NULL,
  is_active BIT NOT NULL,
  name VARCHAR(MAX),
  category_id BIGINT NULL, 
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY(id)
);

GO

CREATE TABLE products (

    id BIGINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 0,
    position BIGINT NOT NULL DEFAULT 0,
    name_base VARCHAR(MAX) NOT NULL,
    name VARCHAR(MAX) NOT NULL,
    description VARCHAR(MAX) NULL,
    content VARCHAR(MAX) NULL,
    unit VARCHAR(MAX) NOT NULL,
    unit_base VARCHAR(MAX) NOT NULL,
    capacity DECIMAL(8,2) NOT NULL DEFAULT 1.0,
    quantity DECIMAL(8,2) NOT NULL DEFAULT 1.0,
    barcodes VARCHAR(MAX) NULL,
    sku VARCHAR(MAX) NOT NULL,
    price DECIMAL(8,2) NOT NULL DEFAULT 1.0,
    price_old VARCHAR(MAX) NULL,
    vat INT NOT NULL DEFAULT 23,
    stock_control BIT NOT NULL DEFAULT 0,
    stock INT NULL,
    is_promoted BIT NOT NULL DEFAULT 0,
    is_sale BIT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    partner_id BIGINT NOT NULL DEFAULT 250,
    producer_id BIGINT NOT NULL,
 
  PRIMARY KEY(id)
);

