# rk-mssql 
### Integracja api.razemkupujemy.pl za pomocą SqlSerwer 2019

#### Dokumentacja api: [Postamn](https://www.postman.com/razemkupujemy-partners/workspace/razemkupujemy-pl-api/overview)
### Założenia
W poniższym przykładzie zakładam, że:
1. pobierasz dane do lokalnej bazy danych razemkupujemy 
2. aktualizujesz tabele produktów we własnym zakresie, ze swoją bazą produktów.
3. wysyłasz zaktualizowane produkty do api rk 

Całość można zamknąć w cyklicznym wywołaniu procedur na twoim sqlSerwerze.<br>
Dla przykładu w tym repozytorium masz przygotowane nieależne zapytania jak i gotowe procedury.<br>
Oczywiście Twoja implementacja nie musi wyglądać dokładnie tak jak zostało to opracowane w tym repozytorium, ale zawsze lepiej jest od czegoś zacząć z realnymi przykładami kodu niż wróżyć z fusów jak to mogło by działać.<br>
Te przykłady zostały przetestowane na Windows 10, z podstawową instalacją "SqlSerwer2019" w stylu next, next, next... <br>

>Zakładam że baza **"razemkupujemy"** na twoim sql serwerze, będzie dla Ciebie tylko takim **pojemnikiem tymczasowym** na potrzeby synchronizacji, 
>aby nie tworzyć jakichś wymyślnych tabel tymczasowych czy obiektów, gdyż same operacje z API poprzez baze danych nie należą do super zrozumiałych przez developerów.
>Tabele słownikowe w tym podejściu, są za każdym wywołaniem czyszczone i pobierane dą do nich nowe "świeże" dane z serwera RK.
>Możesz oczywiście to zmienić według uznania ale pamiętaj że każdy DELETE -> INSERT jest o wiele szybszy niż kombinacje z UPSERTAMI. 
>Dlatego też tabele nie mają ani indeksów ani kluczy obccyh, bo w tym podejściu nie jest to po prostu potrzebne.<br>
> 
> Nam również zależy, aby nie trzeba angażować niepotrzebnej pracy ludzi, a produkty, ceny, czy stany magazynowe
synchronizowały się automatycznie. Więc w razie trudności dzwoń lub pisz.<br>
> Co dnie głowy to nie jedna, a sugestie również mile widziane!


### Kontakt / wsparcie 
W razie jakichkolwiek problemów zachęcam do kontaktu przez telefon lub mail.<br>
**Marcin Dąbrowski**<br>
mail: it@razemkupujemy.pl<br>
tel: +48 786 835 621<br>



## Kroki instalacji 
### 1. Zakładamy bazę razemkupujemy 
```sql
CREATE DATABASE razemkupujemy;
```

### 2. Konfigurujemy dodatki sql serwera 
Potrzebne by sqlSerwer potrafił wysyłać requesty do api 
```sql
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO

EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO
```

### 3. Tworzymy table słownikowe na potrzeby synchronizacji

#### Tabela Użytkownicy 
W tej tabeli mamy dwóch użytkowników (demo,prod) 

Docelowo należy dodać api_token realnego użytkownika oraz ustawić flagę (is_active) 
dla tego który jest aktywny
```sql
CREATE TABLE users (
  id INT NOT NULL IDENTITY PRIMARY KEY,
  is_active BIT NOT NULL,
  username VARCHAR(100)  NOT NULL,
  api_token  NVARCHAR(MAX),
  api_url NVARCHAR(MAX),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
);
GO
INSERT INTO [dbo].[users] ([username],[is_active],[api_token],[api_url])
VALUES
('demo',1,'798|GyIoYnHantvMjuK5BZaaL18DAwpdRuslJMKvs89g','https://api.razemkupujemy.pl'),
('prod',0,'<your_api_token>','https://api.razemkupujemy.pl')


```

#### Tabela Kategorie
```sql
CREATE TABLE categories (
  id BIGINT NOT NULL,
  is_active BIT NOT NULL,
  name VARCHAR(MAX),
  category_id BIGINT NULL, 
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY(id)
);
```

#### Tabela Producenci
```sql
CREATE TABLE producers (
  id BIGINT NOT NULL,
  is_active BIT NOT NULL,
  name VARCHAR(MAX), 
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY(id)
);
```

#### Tabela Produkty
```sql
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
    capacity DECIMAL(8,3) NOT NULL DEFAULT 1.0,
    quantity DECIMAL(8,3) NOT NULL DEFAULT 1.0,
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
```

#### Tabela ProduktyKategorie - relacja wiele do wielu 
```sql
CREATE TABLE category_product (
    id          BIGINT NULL,
    category_id BIGINT NULL,
    product_id  BIGINT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY(id)
);
```

exec GetCategories;

exec GetProducts;
