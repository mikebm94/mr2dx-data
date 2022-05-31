
PRAGMA foreign_keys = ON;


CREATE TABLE Breeds (
    Id  INT  PRIMARY KEY  NOT NULL  CHECK ( Id BETWEEN 0 AND 37 ),

    BreedName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE  CHECK ( LENGTH(BreedName) BETWEEN 3 AND 12 )
);


CREATE TABLE ForceTypes (
    Id  INT  PRIMARY KEY  NOT NULL  CHECK ( Id BETWEEN 0 AND 1 ),
    
    ForceTypeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(ForceTypeName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueNatures (
    Id  INT  PRIMARY KEY  NOT NULL  CHECK ( Id BETWEEN 0 AND 2 ),
    
    TechniqueNatureName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueNatureName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueRanges (
    Id  INT  PRIMARY KEY  NOT NULL  CHECK ( Id BETWEEN 0 AND 3 ),
    
    TechniqueRangeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueRangeName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueTypes (
    Id  INT  PRIMARY KEY  NOT NULL  CHECK ( Id BETWEEN 0 AND 5 ),
    
    TechniqueTypeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueTypeName) BETWEEN 3 AND 12 )
);


CREATE TABLE Techniques (
    BreedId  INT  NOT NULL
        REFERENCES Breeds (Id)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    TechniqueNumber  INT  NOT NULL  CHECK ( TechniqueNumber BETWEEN 0 AND 23 ),

    TechniqueRangeId  INT  NOT NULL
        REFERENCES TechniqueRanges (Id)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    Slot  INT  NOT NULL  CHECK ( Slot BETWEEN 1 AND 6 ),

    TechniqueName  TEXT  NOT NULL  COLLATE NOCASE  CHECK ( LENGTH(TechniqueName) BETWEEN 3 AND 12 ),
    
    TechniqueTypeId  INT  NOT NULL
        REFERENCES TechniqueTypes (Id)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    ForceTypeId  INT  NOT NULL
        REFERENCES ForceTypes (Id)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    TechniqueNatureId  INT  NOT NULL
        REFERENCES TechniqueNatures (Id)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    HitPercent  INT  NOT NULL  CHECK ( HitPercent BETWEEN -50 AND 50 ),

    Damage  INT  NOT NULL  CHECK ( Damage BETWEEN 0 AND 100 ),
    
    Withering  INT  NOT NULL  CHECK ( Withering BETWEEN 0 AND 100 ),
    
    Sharpness  INT  NOT NULL  CHECK ( Sharpness BETWEEN 0 AND 100 ),
    
    GutsCost  INT  NOT NULL  CHECK ( GutsCost BETWEEN 10 AND 99 ),
    
    GutsDrain  INT  NOT NULL  CHECK ( GutsDrain BETWEEN 0 AND 255 ),
    
    HpRecovery  INT  NOT NULL  CHECK ( HpRecovery BETWEEN 0 AND 255 ),
    
    HpDrain  INT  NOT NULL  CHECK ( HpDrain BETWEEN 0 AND 255 ),
    
    SelfDamageHit  INT  NOT NULL  CHECK ( SelfDamageHit BETWEEN 0 AND 255 ),
    
    SelfDamageMiss  INT  NOT NULL  CHECK ( SelfDamageMiss BETWEEN 0 AND 255 ),
    
    Effect  TEXT  CHECK ( LENGTH(Effect) <= 48 ),
    
    DurationHit  REAL  NOT NULL  CHECK ( DurationHit BETWEEN 1.0 AND 15.0 ),

    DurationMiss  REAL  NOT NULL  CHECK ( DurationMiss BETWEEN 1.0 AND 15.0 ),
    
    PRIMARY KEY (BreedId, TechniqueNumber),
    UNIQUE (BreedId, TechniqueRangeId, Slot)
    UNIQUE (BreedId, TechniqueName)
);