
PRAGMA foreign_keys = ON;


CREATE TABLE Breeds (
    BreedId  INT  PRIMARY KEY  NOT NULL,

    BreedName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE  CHECK ( LENGTH(BreedName) BETWEEN 3 AND 12 )
);


CREATE TABLE MonsterTypes (
    MonsterTypeId  INTEGER PRIMARY KEY  NOT NULL,

    MainBreedId  INT  NOT NULL
        REFERENCES Breeds (BreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,

    SubBreedId  INT
        REFERENCES Breeds (BreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,

    CardNumber  INT  UNIQUE  NOT NULL  CHECK ( CardNumber > 0 ),

    MonsterTypeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(MonsterTypeName) BETWEEN 3 AND 12 ),

    MonsterTypeDescription  TEXT  COLLATE NOCASE  CHECK ( LENGTH(MonsterTypeDescription) <= 96 ),

    UNIQUE (MainBreedId, SubBreedId)
);


CREATE TABLE ForceTypes (
    ForceTypeId  INT  PRIMARY KEY  NOT NULL,
    
    ForceTypeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(ForceTypeName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueNatures (
    TechniqueNatureId  INT  PRIMARY KEY  NOT NULL,
    
    TechniqueNatureName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueNatureName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueRanges (
    TechniqueRangeId  INT  PRIMARY KEY  NOT NULL,
    
    TechniqueRangeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueRangeName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueTypes (
    TechniqueTypeId  INT  PRIMARY KEY  NOT NULL,
    
    TechniqueTypeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueTypeName) BETWEEN 3 AND 12 )
);


CREATE TABLE Techniques (
    TechniqueId  INTEGER PRIMARY KEY  NOT NULL,

    BreedId  INT  NOT NULL
        REFERENCES Breeds (BreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,

    TechniqueRangeId  INT  NOT NULL
        REFERENCES TechniqueRanges(TechniqueRangeId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    Slot  INT  NOT NULL  CHECK ( Slot BETWEEN 1 AND 6 ),

    TechniqueName  TEXT  NOT NULL  COLLATE NOCASE  CHECK ( LENGTH(TechniqueName) BETWEEN 3 AND 12 ),
    
    TechniqueTypeId  INT  NOT NULL
        REFERENCES TechniqueTypes (TechniqueTypeId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    ForceTypeId  INT  NOT NULL
        REFERENCES ForceTypes (ForceTypeId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    TechniqueNatureId  INT  NOT NULL
        REFERENCES TechniqueNatures (TechniqueNatureId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
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
    
    UNIQUE (BreedId, TechniqueRangeId, Slot)
    UNIQUE (BreedId, TechniqueName)
);


CREATE TABLE Errantries (
    ErrantryId  INTEGER PRIMARY KEY  NOT NULL,

    ErrantryName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(ErrantryName) BETWEEN 3 AND 12 ),

    TechniqueTypeId  INT  UNIQUE  NOT NULL
        CHECK ( TechniqueTypeId != 1 )
        REFERENCES TechniqueTypes (TechniqueTypeId)  ON UPDATE RESTRICT  ON DELETE RESTRICT
);
