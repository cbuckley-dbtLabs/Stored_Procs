/* ============================================================
   load_seed.sql
   Loads the CSV seed files in seed/ (and seed/feeds/) into RetailDW.

   Pattern per file: BULK INSERT into an all-NVARCHAR #staging table,
   then INSERT ... SELECT into the real table with TRY_CONVERT +
   NULLIF(x,'') so empty fields become proper NULLs and typed
   columns convert cleanly. Identity PKs are loaded verbatim under
   SET IDENTITY_INSERT so the FK relationships in the CSVs line up.

   PREREQS:
     - schema/00..06 already deployed (tables exist)
     - the util procs deployed (we call util.usp_BuildCalendar at end)
     - tables are EMPTY. This is a first-load script, not a merge.
       It is an ALTERNATIVE to the inline schema/07_seed_reference.sql
       -- run ONE or the OTHER, not both (they'd collide on PKs).

   PATH / PERMISSIONS GOTCHA:
     BULK INSERT reads the file from the *SQL Server* machine's file
     system using the service account, NOT your client. Set :seeddir
     to a path the server can see (UNC share or local server path).
     For a client-side load use `bcp` or OPENROWSET instead.

   Usage (SQLCMD mode, from repo root):
     :setvar seeddir "C:\deploy\RetailDW\seed"
     sqlcmd -S <server> -d RetailDW -i seed\load_seed.sql -v seeddir="..."
   ============================================================ */
:setvar seeddir "."

USE RetailDW;
GO
SET NOCOUNT ON;
PRINT 'Loading seed data from $(seeddir)';
GO

/* ---------- ref.Currency ---------- */
IF OBJECT_ID('tempdb..#cur') IS NOT NULL DROP TABLE #cur;
CREATE TABLE #cur (CurrencyCode NVARCHAR(50), CurrencyName NVARCHAR(200), MinorUnits NVARCHAR(50));
BULK INSERT #cur FROM '$(seeddir)\ref_currency.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO ref.Currency (CurrencyCode, CurrencyName, MinorUnits)
SELECT CurrencyCode, CurrencyName, TRY_CONVERT(TINYINT, MinorUnits) FROM #cur;
PRINT CONCAT('  ref.Currency: ', @@ROWCOUNT);
GO

/* ---------- ref.Country ---------- */
IF OBJECT_ID('tempdb..#cty') IS NOT NULL DROP TABLE #cty;
CREATE TABLE #cty (CountryCode NVARCHAR(50), CountryName NVARCHAR(200), Region NVARCHAR(100), DefaultCurrency NVARCHAR(50));
BULK INSERT #cty FROM '$(seeddir)\ref_country.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO ref.Country (CountryCode, CountryName, Region, DefaultCurrency)
SELECT CountryCode, CountryName, NULLIF(Region,''), NULLIF(DefaultCurrency,'') FROM #cty;
PRINT CONCAT('  ref.Country: ', @@ROWCOUNT);
GO

/* ---------- ref.FxRate ---------- */
IF OBJECT_ID('tempdb..#fx') IS NOT NULL DROP TABLE #fx;
CREATE TABLE #fx (FromCurrency NVARCHAR(50), ToCurrency NVARCHAR(50), RateDate NVARCHAR(50), Rate NVARCHAR(50));
BULK INSERT #fx FROM '$(seeddir)\ref_fxrate.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO ref.FxRate (FromCurrency, ToCurrency, RateDate, Rate)
SELECT FromCurrency, ToCurrency, TRY_CONVERT(DATE, RateDate), TRY_CONVERT(DECIMAL(18,8), Rate) FROM #fx;
PRINT CONCAT('  ref.FxRate: ', @@ROWCOUNT);
GO

/* ---------- fin.GLAccount ---------- */
IF OBJECT_ID('tempdb..#gl') IS NOT NULL DROP TABLE #gl;
CREATE TABLE #gl (GLAccountId NVARCHAR(50), AccountCode NVARCHAR(50), AccountName NVARCHAR(200), AccountType NVARCHAR(50), IsActive NVARCHAR(10));
BULK INSERT #gl FROM '$(seeddir)\gl_account.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT fin.GLAccount ON;
INSERT INTO fin.GLAccount (GLAccountId, AccountCode, AccountName, AccountType, IsActive)
SELECT TRY_CONVERT(INT,GLAccountId), AccountCode, AccountName, AccountType, TRY_CONVERT(BIT,IsActive) FROM #gl;
SET IDENTITY_INSERT fin.GLAccount OFF;
PRINT CONCAT('  fin.GLAccount: ', @@ROWCOUNT);
GO

/* ---------- util.ConfigParam ---------- */
IF OBJECT_ID('tempdb..#cfg') IS NOT NULL DROP TABLE #cfg;
CREATE TABLE #cfg (ParamKey NVARCHAR(100), ParamValue NVARCHAR(400), ParamType NVARCHAR(20), Description NVARCHAR(400));
BULK INSERT #cfg FROM '$(seeddir)\config_param.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO util.ConfigParam (ParamKey, ParamValue, ParamType, Description)
SELECT ParamKey, ParamValue, ParamType, NULLIF(Description,'') FROM #cfg;
PRINT CONCAT('  util.ConfigParam: ', @@ROWCOUNT);
GO

/* ---------- inv.Warehouse ---------- */
IF OBJECT_ID('tempdb..#wh') IS NOT NULL DROP TABLE #wh;
CREATE TABLE #wh (WarehouseId NVARCHAR(50), WarehouseCode NVARCHAR(50), WarehouseName NVARCHAR(200), CountryCode NVARCHAR(50), IsActive NVARCHAR(10));
BULK INSERT #wh FROM '$(seeddir)\warehouse.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT inv.Warehouse ON;
INSERT INTO inv.Warehouse (WarehouseId, WarehouseCode, WarehouseName, CountryCode, IsActive)
SELECT TRY_CONVERT(INT,WarehouseId), WarehouseCode, WarehouseName, NULLIF(CountryCode,''), TRY_CONVERT(BIT,IsActive) FROM #wh;
SET IDENTITY_INSERT inv.Warehouse OFF;
PRINT CONCAT('  inv.Warehouse: ', @@ROWCOUNT);
GO

/* ---------- dbo.ProductCategory ---------- */
IF OBJECT_ID('tempdb..#pc') IS NOT NULL DROP TABLE #pc;
CREATE TABLE #pc (CategoryId NVARCHAR(50), CategoryName NVARCHAR(200), ParentCategoryId NVARCHAR(50), DefaultMarginPct NVARCHAR(50));
BULK INSERT #pc FROM '$(seeddir)\product_category.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.ProductCategory ON;
INSERT INTO dbo.ProductCategory (CategoryId, CategoryName, ParentCategoryId, DefaultMarginPct)
SELECT TRY_CONVERT(INT,CategoryId), CategoryName, TRY_CONVERT(INT,NULLIF(ParentCategoryId,'')), TRY_CONVERT(DECIMAL(6,3),NULLIF(DefaultMarginPct,'')) FROM #pc;
SET IDENTITY_INSERT dbo.ProductCategory OFF;
PRINT CONCAT('  dbo.ProductCategory: ', @@ROWCOUNT);
GO

/* ---------- dbo.Supplier ---------- */
IF OBJECT_ID('tempdb..#sup') IS NOT NULL DROP TABLE #sup;
CREATE TABLE #sup (SupplierId NVARCHAR(50), SupplierName NVARCHAR(200), CountryCode NVARCHAR(50), LeadTimeDays NVARCHAR(50), IsActive NVARCHAR(10));
BULK INSERT #sup FROM '$(seeddir)\supplier.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.Supplier ON;
INSERT INTO dbo.Supplier (SupplierId, SupplierName, CountryCode, LeadTimeDays, IsActive)
SELECT TRY_CONVERT(INT,SupplierId), SupplierName, NULLIF(CountryCode,''), TRY_CONVERT(INT,LeadTimeDays), TRY_CONVERT(BIT,IsActive) FROM #sup;
SET IDENTITY_INSERT dbo.Supplier OFF;
PRINT CONCAT('  dbo.Supplier: ', @@ROWCOUNT);
GO

/* ---------- dbo.Product ---------- */
IF OBJECT_ID('tempdb..#prod') IS NOT NULL DROP TABLE #prod;
CREATE TABLE #prod (ProductId NVARCHAR(50), Sku NVARCHAR(50), ProductName NVARCHAR(300), CategoryId NVARCHAR(50),
                    SupplierId NVARCHAR(50), UnitCost NVARCHAR(50), ListPrice NVARCHAR(50), Weight_g NVARCHAR(50), Status NVARCHAR(50));
BULK INSERT #prod FROM '$(seeddir)\product.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.Product ON;
INSERT INTO dbo.Product (ProductId, Sku, ProductName, CategoryId, SupplierId, UnitCost, ListPrice, Weight_g, Status)
SELECT TRY_CONVERT(INT,ProductId), Sku, ProductName, TRY_CONVERT(INT,NULLIF(CategoryId,'')),
       TRY_CONVERT(INT,NULLIF(SupplierId,'')), TRY_CONVERT(DECIMAL(18,4),NULLIF(UnitCost,'')),
       TRY_CONVERT(DECIMAL(18,4),NULLIF(ListPrice,'')), TRY_CONVERT(INT,NULLIF(Weight_g,'')), Status
FROM #prod;
SET IDENTITY_INSERT dbo.Product OFF;
PRINT CONCAT('  dbo.Product: ', @@ROWCOUNT);
GO

/* ---------- dbo.PriceList ---------- */
IF OBJECT_ID('tempdb..#pl') IS NOT NULL DROP TABLE #pl;
CREATE TABLE #pl (PriceListId NVARCHAR(50), PriceListName NVARCHAR(200), CurrencyCode NVARCHAR(50),
                  EffectiveFrom NVARCHAR(50), EffectiveTo NVARCHAR(50), IsActive NVARCHAR(10));
BULK INSERT #pl FROM '$(seeddir)\price_list.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.PriceList ON;
INSERT INTO dbo.PriceList (PriceListId, PriceListName, CurrencyCode, EffectiveFrom, EffectiveTo, IsActive)
SELECT TRY_CONVERT(INT,PriceListId), PriceListName, CurrencyCode, TRY_CONVERT(DATE,EffectiveFrom),
       TRY_CONVERT(DATE,NULLIF(EffectiveTo,'')), TRY_CONVERT(BIT,IsActive) FROM #pl;
SET IDENTITY_INSERT dbo.PriceList OFF;
PRINT CONCAT('  dbo.PriceList: ', @@ROWCOUNT);
GO

/* ---------- dbo.PriceListItem ---------- */
IF OBJECT_ID('tempdb..#pli') IS NOT NULL DROP TABLE #pli;
CREATE TABLE #pli (PriceListItemId NVARCHAR(50), PriceListId NVARCHAR(50), ProductId NVARCHAR(50), UnitPrice NVARCHAR(50));
BULK INSERT #pli FROM '$(seeddir)\price_list_item.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.PriceListItem ON;
INSERT INTO dbo.PriceListItem (PriceListItemId, PriceListId, ProductId, UnitPrice)
SELECT TRY_CONVERT(INT,PriceListItemId), TRY_CONVERT(INT,PriceListId), TRY_CONVERT(INT,ProductId), TRY_CONVERT(DECIMAL(18,4),UnitPrice) FROM #pli;
SET IDENTITY_INSERT dbo.PriceListItem OFF;
PRINT CONCAT('  dbo.PriceListItem: ', @@ROWCOUNT);
GO

/* ---------- dbo.Customer ---------- */
IF OBJECT_ID('tempdb..#cust') IS NOT NULL DROP TABLE #cust;
CREATE TABLE #cust (CustomerId NVARCHAR(50), CustomerNo NVARCHAR(50), FirstName NVARCHAR(80), LastName NVARCHAR(80),
                    Email NVARCHAR(200), Phone NVARCHAR(40), CountryCode NVARCHAR(50), Status NVARCHAR(50));
BULK INSERT #cust FROM '$(seeddir)\customer.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.Customer ON;
INSERT INTO dbo.Customer (CustomerId, CustomerNo, FirstName, LastName, Email, Phone, CountryCode, Status)
SELECT TRY_CONVERT(INT,CustomerId), CustomerNo, NULLIF(FirstName,''), NULLIF(LastName,''),
       NULLIF(Email,''), NULLIF(Phone,''), NULLIF(CountryCode,''), Status FROM #cust;
SET IDENTITY_INSERT dbo.Customer OFF;
PRINT CONCAT('  dbo.Customer: ', @@ROWCOUNT);
GO

/* ---------- dbo.CustomerAddress ---------- */
IF OBJECT_ID('tempdb..#addr') IS NOT NULL DROP TABLE #addr;
CREATE TABLE #addr (AddressId NVARCHAR(50), CustomerId NVARCHAR(50), AddressType NVARCHAR(10), Line1 NVARCHAR(200),
                    Line2 NVARCHAR(200), City NVARCHAR(100), PostCode NVARCHAR(20), CountryCode NVARCHAR(50), IsDefault NVARCHAR(10));
BULK INSERT #addr FROM '$(seeddir)\customer_address.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.CustomerAddress ON;
INSERT INTO dbo.CustomerAddress (AddressId, CustomerId, AddressType, Line1, Line2, City, PostCode, CountryCode, IsDefault)
SELECT TRY_CONVERT(INT,AddressId), TRY_CONVERT(INT,CustomerId), AddressType, NULLIF(Line1,''), NULLIF(Line2,''),
       NULLIF(City,''), NULLIF(PostCode,''), NULLIF(CountryCode,''), TRY_CONVERT(BIT,IsDefault) FROM #addr;
SET IDENTITY_INSERT dbo.CustomerAddress OFF;
PRINT CONCAT('  dbo.CustomerAddress: ', @@ROWCOUNT);
GO

/* ---------- dbo.LoyaltyAccount ---------- */
IF OBJECT_ID('tempdb..#loy') IS NOT NULL DROP TABLE #loy;
CREATE TABLE #loy (LoyaltyAccountId NVARCHAR(50), CustomerId NVARCHAR(50), Tier NVARCHAR(20), PointsBalance NVARCHAR(50), LifetimePoints NVARCHAR(50));
BULK INSERT #loy FROM '$(seeddir)\loyalty_account.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT dbo.LoyaltyAccount ON;
INSERT INTO dbo.LoyaltyAccount (LoyaltyAccountId, CustomerId, Tier, PointsBalance, LifetimePoints)
SELECT TRY_CONVERT(INT,LoyaltyAccountId), TRY_CONVERT(INT,CustomerId), Tier, TRY_CONVERT(INT,PointsBalance), TRY_CONVERT(INT,LifetimePoints) FROM #loy;
SET IDENTITY_INSERT dbo.LoyaltyAccount OFF;
PRINT CONCAT('  dbo.LoyaltyAccount: ', @@ROWCOUNT);
GO

/* ---------- inv.StockLevel ---------- */
IF OBJECT_ID('tempdb..#stk') IS NOT NULL DROP TABLE #stk;
CREATE TABLE #stk (WarehouseId NVARCHAR(50), ProductId NVARCHAR(50), QtyOnHand NVARCHAR(50), QtyAllocated NVARCHAR(50),
                   QtyOnOrder NVARCHAR(50), ReorderPoint NVARCHAR(50), ReorderQty NVARCHAR(50));
BULK INSERT #stk FROM '$(seeddir)\stock_level.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO inv.StockLevel (WarehouseId, ProductId, QtyOnHand, QtyAllocated, QtyOnOrder, ReorderPoint, ReorderQty)
SELECT TRY_CONVERT(INT,WarehouseId), TRY_CONVERT(INT,ProductId), TRY_CONVERT(INT,QtyOnHand), TRY_CONVERT(INT,QtyAllocated),
       TRY_CONVERT(INT,QtyOnOrder), TRY_CONVERT(INT,NULLIF(ReorderPoint,'')), TRY_CONVERT(INT,NULLIF(ReorderQty,'')) FROM #stk;
PRINT CONCAT('  inv.StockLevel: ', @@ROWCOUNT);
GO

/* ---------- sales.Promotion ---------- */
IF OBJECT_ID('tempdb..#promo') IS NOT NULL DROP TABLE #promo;
CREATE TABLE #promo (PromotionId NVARCHAR(50), PromoCode NVARCHAR(30), Description NVARCHAR(200), PromoType NVARCHAR(20),
                     DiscountPct NVARCHAR(50), DiscountAmt NVARCHAR(50), MinSpend NVARCHAR(50), CategoryId NVARCHAR(50),
                     EffectiveFrom NVARCHAR(50), EffectiveTo NVARCHAR(50), MaxRedemptions NVARCHAR(50), IsActive NVARCHAR(10));
BULK INSERT #promo FROM '$(seeddir)\promotion.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
SET IDENTITY_INSERT sales.Promotion ON;
INSERT INTO sales.Promotion (PromotionId, PromoCode, Description, PromoType, DiscountPct, DiscountAmt, MinSpend,
                             CategoryId, EffectiveFrom, EffectiveTo, MaxRedemptions, TimesRedeemed, IsActive)
SELECT TRY_CONVERT(INT,PromotionId), PromoCode, NULLIF(Description,''), PromoType,
       TRY_CONVERT(DECIMAL(6,3),NULLIF(DiscountPct,'')), TRY_CONVERT(DECIMAL(18,4),NULLIF(DiscountAmt,'')),
       TRY_CONVERT(DECIMAL(18,4),NULLIF(MinSpend,'')), TRY_CONVERT(INT,NULLIF(CategoryId,'')),
       TRY_CONVERT(DATE,EffectiveFrom), TRY_CONVERT(DATE,NULLIF(EffectiveTo,'')),
       TRY_CONVERT(INT,NULLIF(MaxRedemptions,'')), 0, TRY_CONVERT(BIT,IsActive) FROM #promo;
SET IDENTITY_INSERT sales.Promotion OFF;
PRINT CONCAT('  sales.Promotion: ', @@ROWCOUNT);
GO

/* ============================================================
   FEEDS -> staging tables (input for the ETL / nightly batch).
   These are intentionally raw + a bit dirty (bad qty, unknown
   sku/customer, non-numeric cost) so the ETL reject paths fire.
   ============================================================ */

/* ---------- stg.RawCustomer ---------- */
IF OBJECT_ID('tempdb..#rcust') IS NOT NULL DROP TABLE #rcust;
CREATE TABLE #rcust (CustomerNo NVARCHAR(50), FirstName NVARCHAR(100), LastName NVARCHAR(100), Email NVARCHAR(200), Phone NVARCHAR(60), Country NVARCHAR(60));
BULK INSERT #rcust FROM '$(seeddir)\feeds\raw_customer.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO stg.RawCustomer (CustomerNo, FirstName, LastName, Email, Phone, Country, SourceFile)
SELECT NULLIF(CustomerNo,''), NULLIF(FirstName,''), NULLIF(LastName,''), NULLIF(Email,''), NULLIF(Phone,''), NULLIF(Country,''), 'raw_customer.csv' FROM #rcust;
PRINT CONCAT('  stg.RawCustomer: ', @@ROWCOUNT);
GO

/* ---------- stg.RawProduct ---------- */
IF OBJECT_ID('tempdb..#rprod') IS NOT NULL DROP TABLE #rprod;
CREATE TABLE #rprod (Sku NVARCHAR(60), ProductName NVARCHAR(300), CategoryName NVARCHAR(120), SupplierName NVARCHAR(200), UnitCost NVARCHAR(40), ListPrice NVARCHAR(40));
BULK INSERT #rprod FROM '$(seeddir)\feeds\raw_product.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO stg.RawProduct (Sku, ProductName, CategoryName, SupplierName, UnitCost, ListPrice)
SELECT NULLIF(Sku,''), NULLIF(ProductName,''), NULLIF(CategoryName,''), NULLIF(SupplierName,''), NULLIF(UnitCost,''), NULLIF(ListPrice,'') FROM #rprod;
PRINT CONCAT('  stg.RawProduct: ', @@ROWCOUNT);
GO

/* ---------- stg.RawFxRate ---------- */
IF OBJECT_ID('tempdb..#rfx') IS NOT NULL DROP TABLE #rfx;
CREATE TABLE #rfx (FromCurrency NVARCHAR(50), ToCurrency NVARCHAR(50), RateDateText NVARCHAR(40), RateText NVARCHAR(40));
BULK INSERT #rfx FROM '$(seeddir)\feeds\raw_fxrate.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO stg.RawFxRate (FromCurrency, ToCurrency, RateDateText, RateText)
SELECT NULLIF(FromCurrency,''), NULLIF(ToCurrency,''), NULLIF(RateDateText,''), NULLIF(RateText,'') FROM #rfx;
PRINT CONCAT('  stg.RawFxRate: ', @@ROWCOUNT);
GO

/* ---------- stg.RawOrder ---------- */
IF OBJECT_ID('tempdb..#rord') IS NOT NULL DROP TABLE #rord;
CREATE TABLE #rord (ExternalOrderRef NVARCHAR(60), CustomerNo NVARCHAR(50), OrderDateText NVARCHAR(40), Sku NVARCHAR(60),
                    Qty NVARCHAR(20), UnitPriceText NVARCHAR(40), PromoCode NVARCHAR(40), CurrencyCode NVARCHAR(10), SourceSystem NVARCHAR(40));
BULK INSERT #rord FROM '$(seeddir)\feeds\raw_order.csv'
  WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', FIRSTROW=2, TABLOCK);
INSERT INTO stg.RawOrder (ExternalOrderRef, CustomerNo, OrderDateText, Sku, Qty, UnitPriceText, PromoCode, CurrencyCode, SourceSystem)
SELECT NULLIF(ExternalOrderRef,''), NULLIF(CustomerNo,''), NULLIF(OrderDateText,''), NULLIF(Sku,''),
       NULLIF(Qty,''), NULLIF(UnitPriceText,''), NULLIF(PromoCode,''), NULLIF(CurrencyCode,''), NULLIF(SourceSystem,'') FROM #rord;
PRINT CONCAT('  stg.RawOrder: ', @@ROWCOUNT);
GO

/* ---------- date dimension ---------- */
EXEC util.usp_BuildCalendar;
PRINT '  ref.Calendar built';
GO

PRINT 'Seed load complete.';
GO
