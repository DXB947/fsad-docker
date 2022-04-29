/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.
\cd 'YOUR WORKING DIRECTORY HERE'
  -- In PostgreSQL, folders are identified with '/'

-- 1) Create a database called SmokedTrout.

CREATE DATABASE "SmokedTrout"
WITH OWNER = fsad
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;

-- 2) Connect to the database

\c "SmokedTrout" fsad;

/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state

CREATE TYPE "MaterialState" AS ENUM ('Solid', 'Liquid', 'Gas', 'Plasma');

-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.

CREATE TYPE "MaterialComposition" AS ENUM ('Yes', 'No');

-- 3) Create the table TradingRoute with the corresponding attributes.

CREATE TABLE "TradingRoute" (
"MonitoringKey" integer ,
"ShippingCompany" varchar(30) ,
"FleetSize" integer ,
"LastYearRevenue" DECIMAL (7,2),
PRIMARY KEY ("MonitoringKey")
); 

-- 4) Create the table Planet with the corresponding attributes.

CREATE TABLE "Planet" (
"PlanetID" integer ,
"StarSystem" varchar (20) ,
"Name" varchar (20) ,
"PopulationInMillions" integer ,
PRIMARY KEY ("PlanetID")
) ;

-- 5) Create the table SpaceStation with the corresponding attributes.

CREATE TABLE "SpaceStation" (
"StationID" integer ,
"PlanetID" integer ,
"Name" varchar (20) ,
"Longitude" varchar (10) ,
"Latitude" varchar (10) ,
PRIMARY KEY ("StationID") ,
FOREIGN KEY ("PlanetID")
REFERENCES "Planet"("PlanetID")
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;

-- 6) Create the parent table Product with the corresponding attributes.

CREATE TABLE "Product" (
"ProductID" integer ,
"Name" varchar (20) ,
"VolumePerTon" real ,
"ValuePerTon" real ,
PRIMARY KEY ("ProductID")
) ;

-- 7) Create the child table RawMaterial with the corresponding attributes.

CREATE TABLE "RawMaterial" (
"ProductID" integer ,
"MaterialState" "MaterialState" ,
"Composite" "MaterialComposition",
FOREIGN KEY ("ProductID")
REFERENCES "Product" ("ProductID") 
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;


-- 8) Create the child table ManufacturedGood. 

CREATE TABLE "ManufacturedGood" (
"ProductID" integer ,
FOREIGN KEY ("ProductID")
REFERENCES "Product" ("ProductID")
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;


-- 9) Create the table MadeOf with the corresponding attributes.

CREATE TABLE "MadeOf" (
"ProductID" integer ,
"MadeFrom" integer
)
INHERITS("ManufacturedGood") ;

-- 10) Create the table Batch with the corresponding attributes.

CREATE TABLE "Batch" (
"BatchID" integer ,
"ProductID" integer ,
"ExtractionOrManufacturingDate" date ,
"Origin" integer ,
PRIMARY KEY ("BatchID") ,
FOREIGN KEY ("ProductID")
REFERENCES "Product"("ProductID")
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;


-- 11) Create the table Sells with the corresponding attributes.

CREATE TABLE "Sells" (
"BatchID" integer ,
"StationID" integer ,
FOREIGN KEY ("BatchID")
REFERENCES "Batch"("BatchID") ,
FOREIGN KEY ("StationID")
REFERENCES "SpaceStation"("StationID")
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;

-- 12)  Create the table Buys with the corresponding attributes.

CREATE TABLE "Buys" (
"BatchID" integer ,
"StationID" integer ,
FOREIGN KEY ("BatchID")
REFERENCES "Batch"("BatchID") ,
FOREIGN KEY ("StationID")
REFERENCES "SpaceStation"("StationID")
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;


-- 13)  Create the table CallsAt with the corresponding attributes.

CREATE TABLE "CallsAt" (
"MonitoringKey" integer ,
"StationID" integer ,
"VisitOrder" integer ,
FOREIGN KEY ("MonitoringKey")
REFERENCES "TradingRoute"("MonitoringKey") ,
FOREIGN KEY ("StationID")
REFERENCES "SpaceStation"("StationID")
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;

-- 14)  Create the table Distance with the corresponding attributes.

CREATE TABLE "Distance" (
"PlanetOrigin" integer ,
"PlanetDestination" integer ,
"AvgDistance" real ,
FOREIGN KEY ("PlanetOrigin")
REFERENCES "Planet"("PlanetID") ,
FOREIGN KEY ("PlanetDestination")
REFERENCES "Planet"("PlanetID")
ON UPDATE CASCADE
ON DELETE CASCADE
NOT VALID
) ;

/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */

-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.

CREATE TABLE "Dummy" (
"MonitoringKey" integer ,
"FleetSize" integer ,
"OperatingCompany" varchar(30) ,
"LastYearRevenue" DECIMAL (7,2)
) ;

\copy "Dummy" FROM 'data/TradeRoutes.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "TradingRoute" (
"MonitoringKey" ,
"FleetSize" , 
"ShippingCompany" ,
"LastYearRevenue")
SELECT "MonitoringKey" ,
"FleetSize" ,
"OperatingCompany" ,

"LastYearRevenue" FROM "Dummy";

DROP TABLE "Dummy";


-- 3) Populate the table Planet with the data in the file Planets.csv.

CREATE TABLE "Dummy" (
"PlanetID" integer ,
"StarSystem" varchar(20) ,
"Planet" varchar(20) ,
"Population_inMillions_" integer 
);

\copy "Dummy" FROM 'data/Planets.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "Planet" (
"PlanetID" ,
"StarSystem" ,
"Name" , 
"PopulationInMillions")
SELECT "PlanetID" ,
"StarSystem" ,
"Planet" ,
"Population_inMillions_" FROM "Dummy";

DROP TABLE "Dummy";

-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.

CREATE TABLE "Dummy" (
"StationID" integer ,
"PlanetID" integer ,
"SpaceStations" varchar (20) ,
"Longitude" varchar (10) ,
"Latitude" varchar (10)
) ;

\copy "Dummy" FROM 'data/SpaceStations.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "SpaceStation" (
"StationID" ,
"PlanetID" ,
"Name" , 
"Longitude" ,
"Latitude")
SELECT "StationID" ,
"PlanetID" ,
"SpaceStations" ,
"Longitude" ,
"Latitude" FROM "Dummy";

DROP TABLE "Dummy";


-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv. 

CREATE TABLE "Dummy" (
"ProductID" integer ,
"Product" varchar(20) ,
"Composite" "MaterialComposition" ,
"VolumePerTon" real ,
"ValuePerTon" real ,
"State" "MaterialState"
) ;

copy "Dummy" FROM 'data/Products_Raw.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "Product" (
"ProductID" ,
"Name" ,
"VolumePerTon" , 
"ValuePerTon" )
SELECT "ProductID" ,
"Product" ,
"VolumePerTon" ,
"ValuePerTon" FROM "Dummy";

INSERT INTO "RawMaterial" (
"ProductID" ,
"Composite" ,
"MaterialState" )
SELECT "ProductID" ,
"Composite" ,
"State" FROM "Dummy" ;

DROP TABLE "Dummy";

-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.

CREATE TABLE "Dummy" (
"ProductID" integer ,
"Product" varchar(20),
"VolumePerTon" real ,
"ValuePerTon" real) ;

copy "Dummy" FROM 'data/Products_Manufactured.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "Product" (
"ProductID" ,
"Name" ,
"VolumePerTon" , 
"ValuePerTon" )
SELECT "ProductID" ,
"Product" ,
"VolumePerTon" ,
"ValuePerTon" FROM "Dummy";

INSERT INTO "ManufacturedGood" (
"ProductID")
SELECT "ProductID" FROM "Dummy" ;

DROP TABLE "Dummy";

-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.

CREATE TABLE "Dummy" (
"ManufacturedGoodID" integer ,
"ProductID" integer);

\copy "Dummy" FROM 'data/MadeOf.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "MadeOf" (
"ProductID" ,
"MadeFrom")
SELECT "ManufacturedGoodID" ,
"ProductID" FROM "Dummy";

DROP TABLE "Dummy";


-- 8) Populate the table Batch with the data in the file Batches.csv.

CREATE TABLE "Dummy" (
"BatchID" integer ,
"ProductID" integer ,
"ExtractionOrManufacturingDate" date ,
"OriginalFrom" integer);

\copy "Dummy" FROM 'data/Batches.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "Batch" (
"BatchID" ,
"ProductID" ,
"ExtractionOrManufacturingDate" ,
"Origin")
SELECT "BatchID" ,
"ProductID" ,
"ExtractionOrManufacturingDate" ,
"OriginalFrom" FROM "Dummy";

DROP TABLE "Dummy";

-- 9) Populate the table Sells with the data in the file Sells.csv.

CREATE TABLE "Dummy" (
"BatchID" integer ,
"StationID" integer);

\copy "Dummy" FROM 'data/Sells.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "Sells" (
"BatchID" ,
"StationID")
SELECT "BatchID" ,
"StationID" FROM "Dummy";

DROP TABLE "Dummy";

-- 10) Populate the table Buys with the data in the file Buys.csv.

CREATE TABLE "Dummy" (
"BatchID" integer ,
"StationID" integer);

\copy "Dummy" FROM 'data/Buys.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "Buys" (
"BatchID" ,
"StationID")
SELECT "BatchID" ,
"StationID" FROM "Dummy";

DROP TABLE "Dummy";

-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.

CREATE TABLE "Dummy" (
"MonitoringKey" integer ,
"StationID" integer ,
"VisitOrder" integer);

\copy "Dummy" FROM 'data/CallsAt.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "CallsAt" (
"MonitoringKey" ,
"StationID" ,
"VisitOrder")
SELECT "MonitoringKey" ,
"StationID" ,
"VisitOrder" FROM "Dummy";

DROP TABLE "Dummy";

-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.

CREATE TABLE "Dummy" (
"PlanetOrigin" integer ,
"PlanetDestination" integer ,
"Distance" real);

\copy "Dummy" FROM 'data/PlanetDistances.csv'
WITH (FORMAT CSV, HEADER );

INSERT INTO "Distance" (
"PlanetOrigin" ,
"PlanetDestination" ,
"AvgDistance")
SELECT "PlanetOrigin" ,
"PlanetDestination" ,
"Distance" FROM "Dummy";

DROP TABLE "Dummy";

/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute

SmokedTrout=> ALTER TABLE IF EXISTS "TradingRoute"
ADD "Taxes" DECIMAL (7,2);

-- 2) Set the derived attribute taxes as 12% of LastYearRevenue

UPDATE "TradingRoute" SET "Taxes" = "LastYearRevenue" *0.12;

-- 3) Report the operating company and the sum of its taxes group by company.

SmokedTrout=> SELECT "ShippingCompany", SUM("Taxes")"SumOfTaxes"
FROM "TradingRoute"
GROUP BY "ShippingCompany";