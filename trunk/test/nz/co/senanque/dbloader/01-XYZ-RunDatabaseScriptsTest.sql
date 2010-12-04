--  
  CREATE TABLE "SAMPLEDOMAIN" 
   (
   "ID" NUMBER NOT NULL PRIMARY KEY,
   "FIELD1" VARCHAR2(20), 
   "FIELD2" VARCHAR2(20)
   ) ;
;
COMMENT ON COLUMN "SAMPLEDOMAIN"."FIELD1" IS 'A reference into the LOV table for entries marked as PRICE_FACET_TYPE -- Price Facet Name domain is intended to be at least "Transaction", "Region","Market Segment", "Channel","Product Type","Product Offering", "Product Specification", Product Specification Characteristic Value", "BundleId","Promotion","Distance","Contract Term"';

   INSERT into "SAMPLEDOMAIN" values (1,'A','A');
   INSERT into "SAMPLEDOMAIN" values (2,'B','B');
   INSERT into "SAMPLEDOMAIN" values (3,'C','C');
   INSERT into "SAMPLEDOMAIN" values (4,'D','D');
   INSERT into "SAMPLEDOMAIN" values (5,'E','E');
