
PRAGMA foreign_keys = ON;


CREATE TABLE Breeds (
    BreedId  INTEGER PRIMARY KEY  NOT NULL,

    BreedName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE  CHECK ( LENGTH(BreedName) BETWEEN 3 AND 12 ),

    BloodStrength  INT  NOT NULL  CHECK ( BloodStrength BETWEEN 1 AND 10 )
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

    UNIQUE (MainBreedId, SubBreedId),

    UNIQUE (MainBreedId, MonsterTypeId)
);


CREATE TABLE ForceTypes (
    ForceTypeId  INTEGER PRIMARY KEY  NOT NULL,
    
    ForceTypeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(ForceTypeName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueNatures (
    TechniqueNatureId  INTEGER PRIMARY KEY  NOT NULL,
    
    TechniqueNatureName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueNatureName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueRanges (
    TechniqueRangeId  INTEGER PRIMARY KEY  NOT NULL,
    
    TechniqueRangeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(TechniqueRangeName) BETWEEN 3 AND 12 )
);


CREATE TABLE TechniqueTypes (
    TechniqueTypeId  INTEGER PRIMARY KEY  NOT NULL,
    
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
    
    UNIQUE (BreedId, TechniqueRangeId, Slot),
    UNIQUE (BreedId, TechniqueId),
    UNIQUE (BreedId, TechniqueName)
);


CREATE TABLE BattleSpecials (
    BattleSpecialId  INTEGER PRIMARY KEY  NOT NULL,

    BattleSpecialName  TEXT  UNIQUE  COLLATE NOCASE
        CHECK ( LENGTH(BattleSpecialName) BETWEEN 3 AND 12 ),

    TriggerPriority  INT  NOT NULL,

    Analysis  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(Analysis) BETWEEN 12 AND 60 )
);


CREATE TABLE Fortes (
    ForteId  INTEGER PRIMARY KEY  NOT NULL,

    ForteName  TEXT  UNIQUE  COLLATE NOCASE
        CHECK ( LENGTH(ForteName) BETWEEN 3 AND 12 )
);


CREATE TABLE GrowthTypes (
    GrowthTypeId  INTEGER PRIMARY KEY  NOT NULL,

    GrowthTypeName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(GrowthTypeName) BETWEEN 3 AND 12 ),

    Stage1  INT  NOT NULL  CHECK ( Stage1 BETWEEN 0 AND 100 ),

    Stage2  INT  NOT NULL  CHECK ( Stage2 BETWEEN 0 AND 100 ),

    Stage3  INT  NOT NULL  CHECK ( Stage3 BETWEEN 0 AND 100 ),

    Stage4  INT  NOT NULL  CHECK ( Stage4 BETWEEN 0 AND 100 ),

    Stage5  INT  NOT NULL  CHECK ( Stage5 BETWEEN 0 AND 100 ),

    Stage6  INT  NOT NULL  CHECK ( Stage6 BETWEEN 0 AND 100 ),

    Stage7  INT  NOT NULL  CHECK ( Stage7 BETWEEN 0 AND 100 ),

    Stage8  INT  NOT NULL  CHECK ( Stage8 BETWEEN 0 AND 100 ),

    Stage9  INT  NOT NULL  CHECK ( Stage9 BETWEEN 0 AND 100 ),

    Stage10  INT  NOT NULL  CHECK ( Stage10 BETWEEN 0 AND 100 ),

    CHECK (
        (Stage1 + Stage2 + Stage3 + Stage4 + Stage5 + Stage6 + Stage7 + Stage8 + Stage9 + Stage10) = 100
    )
);


CREATE TABLE Baselines (
    MainBreedId  INT  NOT NULL,
    
    SubBreedId  INT  NOT NULL,
    
    Lifespan  INT  NOT NULL  CHECK ( Lifespan BETWEEN 1 AND 600 ),

    Nature  INT  NOT NULL  CHECK ( Nature BETWEEN -100 AND 100 ),

    GrowthTypeId  INT  NOT NULL
        REFERENCES GrowthTypes (GrowthTypeId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    Lif  INT  NOT NULL  CHECK ( Lif BETWEEN 0 AND 999 ),

    Pow  INT  NOT NULL  CHECK ( Pow BETWEEN 0 AND 999 ),

    IQ  INT  NOT NULL  CHECK ( IQ BETWEEN 0 AND 999 ),

    Ski  INT  NOT NULL  CHECK ( Ski BETWEEN 0 AND 999 ),

    Spd  INT  NOT NULL  CHECK ( Spd BETWEEN 0 AND 999 ),

    Def  INT  NOT NULL  CHECK ( Def BETWEEN 0 AND 999 ),

    LifGainLvl  INT  NOT NULL  CHECK ( LifGainLvl BETWEEN 1 AND 5 ),

    PowGainLvl  INT  NOT NULL  CHECK ( PowGainLvl BETWEEN 1 AND 5 ),

    IQGainLvl  INT  NOT NULL  CHECK ( IQGainLvl BETWEEN 1 AND 5 ),

    SkiGainLvl  INT  NOT NULL  CHECK ( SkiGainLvl BETWEEN 1 AND 5 ),

    SpdGainLvl  INT  NOT NULL  CHECK ( SpdGainLvl BETWEEN 1 AND 5 ),

    DefGainLvl  INT  NOT NULL  CHECK ( DefGainLvl BETWEEN 1 AND 5 ),

    ArenaSpeedLvl  INT  NOT NULL  CHECK ( ArenaSpeedLvl BETWEEN 1 AND 5 ),

    FramesPerGut  INT  NOT NULL  CHECK ( FramesPerGut BETWEEN 1 AND 30 ),

    PRIMARY KEY (MainBreedId, SubBreedId),
    
    FOREIGN KEY (MainBreedId, SubBreedId)
        REFERENCES MonsterTypes (MainBreedId, SubBreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT
) WITHOUT ROWID;


CREATE TABLE Baselines_BattleSpecials (
    MainBreedId  INT  NOT NULL,

    SubBreedId  INT  NOT NULL,

    BattleSpecialId  INT  NOT NULL
        REFERENCES BattleSpecials (BattleSpecialId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,

    PRIMARY KEY (MainBreedId, SubBreedId, BattleSpecialId),

    FOREIGN KEY (MainBreedId, SubBreedId)
        REFERENCES Baselines (MainBreedId, SubBreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT
) WITHOUT ROWID;


CREATE TABLE Baselines_Fortes (
    MainBreedId  INT  NOT NULL,

    SubBreedId  INT  NOT NULL,

    ForteId  INT  NOT NULL
        REFERENCES Fortes (ForteId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,

    PRIMARY KEY (MainBreedId, SubBreedId, ForteId),

    FOREIGN KEY (MainBreedId, SubBreedId)
        REFERENCES Baselines (MainBreedId, SubBreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT
) WITHOUT ROWID;


CREATE TABLE Baselines_Techniques (
    MainBreedId  INT  NOT NULL,

    SubBreedId  INT  NOT NULL,

    TechniqueId  INT  NOT NULL,

    PRIMARY KEY (MainBreedId, SubBreedId, TechniqueId),

    FOREIGN KEY (MainBreedId, SubBreedId)
        REFERENCES Baselines (MainBreedId, SubBreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    FOREIGN KEY (MainBreedId, TechniqueId)
        REFERENCES Techniques (BreedId, TechniqueId)  ON UPDATE RESTRICT  ON DELETE RESTRICT
) WITHOUT ROWID;


CREATE TABLE MonsterTypes_Baselines (
    MonsterTypeId  INT  UNIQUE  NOT NULL,
    
    MainBreedId  INT  NOT NULL,
    
    SubBreedId  INT  NOT NULL,

    PRIMARY KEY (MainBreedId, SubBreedId, MonsterTypeId),

    FOREIGN KEY (MainBreedId, MonsterTypeId)
        REFERENCES MonsterTypes (MainBreedId, MonsterTypeId)  ON UPDATE RESTRICT  ON DELETE RESTRICT,
    
    FOREIGN KEY (MainBreedId, SubBreedId)
        REFERENCES Baselines (MainBreedId, SubBreedId)  ON UPDATE RESTRICT  ON DELETE RESTRICT
) WITHOUT ROWID;


CREATE TABLE Errantries (
    ErrantryId  INTEGER PRIMARY KEY  NOT NULL,

    ErrantryName  TEXT  UNIQUE  NOT NULL  COLLATE NOCASE
        CHECK ( LENGTH(ErrantryName) BETWEEN 3 AND 12 ),

    TechniqueTypeId  INT  UNIQUE  NOT NULL
        CHECK ( TechniqueTypeId != 1 )
        REFERENCES TechniqueTypes (TechniqueTypeId)  ON UPDATE RESTRICT  ON DELETE RESTRICT
);
