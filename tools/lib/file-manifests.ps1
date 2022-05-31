<#
    file-manifests.ps1
        Defines hashtables mapping friendly names to files needed by the data generation scripts.
        This prevents the need to update multiple files when a file is renamed.
#>

using namespace System.Diagnostics.CodeAnalysis

. (Join-Path $PSScriptRoot 'paths.ps1')


# Map friendly name to built SQLite database populated using the finished CSV data files.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$SQLiteDataFiles = @{
    'SQLiteDatabase' = @{ Path = 'mr2dx-data.db'; FileType = 'Binary' }
}

# Map friendly names to finished CSV data file paths. These files can be used on their own as a data set,
# but are also used to generate/populate other database formats (such as an SQLite database.)
# NOTE: The order here matters. When generating databases, foreign key constraints can be violated
# if a referenced row hasn't been created in the referenced table yet.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$FinishedDataFiles = [ordered]@{
    # Defines the available monster breeds.
    'Breeds' = @{ Path = 'Breeds.csv'; FileType = 'CSV' }

    # Defines the types of forces that techniques can draw their power from. (Power, Intelligence)
    'ForceTypes' = @{ Path = 'ForceTypes.csv'; FileType = 'CSV' }

    # Defines the ranges that a technique can be executed in. (Near, Middle, Far, Very Far)
    'TechniqueRanges' = @{ Path = 'TechniqueRanges.csv'; FileType = 'CSV' }

    # Defines the types of technique natures. (Normal, Good, Bad)
    'TechniqueNatures' = @{ Path = 'TechniqueNatures.csv'; FileType = 'CSV' }

    # Defines the types of techniques. (Basic, Hit, Heavy, Withering, Sharp, Special)
    'TechniqueTypes' = @{ Path = 'TechniqueTypes.csv'; FileType = 'CSV' }

    # Defines the techniques available to each monster breed.
    'Techniques' = @{ Path = 'Techniques.csv'; FileType = 'CSV' }
}

# Map friendly names to manually compiled intermediate data file paths. These files contain additional
# data points not needed in the finished data, including implementation-detail data points (such as flag
# names used throughout the game data files) and IDs used to associate data with data obtained
# from another source (such data scraped from LegendCup.)
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$IntermediateDataFiles = @{
    # Defines the available monster breeds.
    'Breeds' = @{ Path = 'Breeds.csv'; FileType = 'CSV' }

    # Defines the types of forces that techniques can draw their power from. (Power, Intelligence)
    'ForceTypes' = @{ Path = 'ForceTypes.csv'; FileType = 'CSV' }

    # Defines the ranges that a technique can be executed in. (Near, Middle, Far, Very Far)
    'TechniqueRanges' = @{ Path = 'TechniqueRanges.csv'; FileType = 'CSV' }

    # Defines the types of technique natures. (Normal, Good, Bad)
    'TechniqueNatures' = @{ Path = 'TechniqueNatures.csv'; FileType = 'CSV' }

    # Defines the types of techniques. (Basic, Hit, Heavy, Withering, Sharp, Special)
    'TechniqueTypes' = @{ Path = 'TechniqueTypes.csv'; FileType = 'CSV' }
}

# Map friendly names to intermediate data files containing data extracted from the MR2DX game files.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ExtractedIntermediateDataFiles = @{
    # Defines the techniques available to each monster breed.
    'Techniques' = @{ Path = 'TechniquesExtracted.csv'; FileType = 'CSV' }
}

# Map friendly names to intermediate data files containing data scraped from the web.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ScrapedIntermediateDataFiles = @{
    # Defines the techniques available to each monster breed. Used to obtain additional data points
    # on techniques not extracted from the game files such as English names and hit/miss durations.
    'TechniquesLegendCup' = @{ Path = 'TechniquesLegendCup.csv'; FileType = 'CSV' }
}

# Map friendly names to game file paths.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$GameFiles = @{
    # CSV table defining the monster variations that can be obtained at the shrine.
    'ShrineMonsters' = @{ Path = 'SDATA_MONSTER.csv'; FileType = 'CSV' }

    # TSV table mapping song IDs in the English music database to a corresponding shrine monster ID
    # as well as an offset that may be applied to the monster after shrining.
    'ShrineMonster_Songs' = @{ Path = 'en_sqlout_b.txt'; FileType = 'TSV' }

    # TSV table mapping song IDs in the English music database
    # to the corresponding artist name and title.
    'Songs' = @{ Path = 'en_sqlout_name.txt'; FileType = 'TSV' }

    # Data files defining the techniques available to each monster breed.
    # Files are encoded using Shift-JIS.
    'TechniquesKA' = @{ # Pixie
        Path = 'mf2/data/mon/kapi/ka_ka_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKB' = @{ # Dragon
        Path = 'mf2/data/mon/kbdr/kb_kb_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKC' = @{ # Centaur
        Path = 'mf2/data/mon/kckn/kc_kc_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKD' = @{ # ColorPandora
        Path = 'mf2/data/mon/kdro/kd_kd_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKE' = @{ # Beaclon
        Path = 'mf2/data/mon/kebe/ke_ke_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKF' = @{ # Henger
        Path = 'mf2/data/mon/kfhe/kf_kf_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKH' = @{ # Wracky
        Path = 'mf2/data/mon/khcy/kh_kh_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKI' = @{ # Golem
        Path = 'mf2/data/mon/kigo/ki_ki_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKK' = @{ # Zuum
        Path = 'mf2/data/mon/kkro/kk_kk_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKL' = @{ # Durahan
        Path = 'mf2/data/mon/klyo/kl_kl_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesKM' = @{ # Arrow Head
        Path = 'mf2/data/mon/kmto/km_km_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMA' = @{ # Tiger
        Path = 'mf2/data/mon/marig/ma_ma_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMB' = @{ # Hopper
        Path = 'mf2/data/mon/mbhop/mb_mb_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMC' = @{ # Hare
        Path = 'mf2/data/mon/mcham/mc_mc_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMD' = @{ # Baku
        Path = 'mf2/data/mon/mdbak/md_md_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesME' = @{ # Gali
        Path = 'mf2/data/mon/megar/me_me_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMF' = @{ # Kato
        Path = 'mf2/data/mon/mfakr/mf_mf_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMG' = @{ # Zilla
        Path = 'mf2/data/mon/mggjr/mg_mg_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMH' = @{ # Bajarl
        Path = 'mf2/data/mon/mhlam/mh_mh_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMI' = @{ # Mew
        Path = 'mf2/data/mon/minya/mi_mi_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMJ' = @{ # Phoenix
        Path = 'mf2/data/mon/mjfbd/mj_mj_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMK' = @{ # Ghost
        Path = 'mf2/data/mon/mkgho/mk_mk_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesML' = @{ # Metalner
        Path = 'mf2/data/mon/mlspm/ml_ml_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMM' = @{ # Suezo
        Path = 'mf2/data/mon/mmxsu/mm_mm_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMN' = @{ # Jill
        Path = 'mf2/data/mon/mnsnm/mn_mn_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMO' = @{ # Mochi
        Path = 'mf2/data/mon/mochy/mo_mo_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMP' = @{ # Joker
        Path = 'mf2/data/mon/mpjok/mp_mp_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMQ' = @{ # Gaboo
        Path = 'mf2/data/mon/mqnen/mq_mq_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMR' = @{ # Jell
        Path = 'mf2/data/mon/mrpru/mr_mr_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMS' = @{ # Undine
        Path = 'mf2/data/mon/msund/ms_ms_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMT' = @{ # Niton
        Path = 'mf2/data/mon/mtgai/mt_mt_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMU' = @{ # Mock
        Path = 'mf2/data/mon/muoku/mu_mu_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMV' = @{ # Ducken
        Path = 'mf2/data/mon/mvdak/mv_mv_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMW' = @{ # Plant
        Path = 'mf2/data/mon/mwpla/mw_mw_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMX' = @{ # Monol
        Path = 'mf2/data/mon/mxris/mx_mx_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMY' = @{ # Ape
        Path = 'mf2/data/mon/mylau/my_my_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesMZ' = @{ # Worm
        Path = 'mf2/data/mon/mzmus/mz_mz_wz.dat'; FileType = 'Text'; CodePage = 932
    }
    'TechniquesNA' = @{ # Naga
        Path = 'mf2/data/mon/naaga/na_na_wz.dat'; FileType = 'Text'; CodePage = 932
    }

    # Data file defining baseline stats and parameters for all non-special monster types.
    # Encoded using Shift-JIS.
    'MonsterTypeBaselines' = @{
        Path = 'mf2/data/monbase/mon_base.dat'; FileType = 'Text'; CodePage = 932
    }
}

# Map file manifest names to their directory and file table.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$FileManifests = @{
    'SQLiteData' = [PSCustomObject]@{
        Directory = $SQLiteDataPath
        Files     = $SQLiteDataFiles
    }

    'FinishedData' = [PSCustomObject]@{
        Directory = $FinishedDataPath
        Files     = $FinishedDataFiles
    }

    'IntermediateData' = [PSCustomObject]@{
        Directory = $IntermediateDataPath
        Files     = $IntermediateDataFiles
    }

    'ExtractedData' = [PSCustomObject]@{
        Directory = $ExtractedIntermediateDataPath
        Files     = $ExtractedIntermediateDataFiles
    }

    'ScrapedData' = [PSCustomObject]@{
        Directory = $ScrapedIntermediateDataPath
        Files     = $ScrapedIntermediateDataFiles
    }

    'GameFiles' = [PSCustomObject]@{
        Directory = $GameFilesPath
        Files     = $GameFiles
    }
}
