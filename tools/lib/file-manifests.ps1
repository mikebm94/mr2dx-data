<#
    file-manifests.ps1
        Defines hashtables mapping friendly names to files needed
        by the data generation scripts. This prevents the need
        to update multiple files when a file is renamed.
#>

using namespace System.Diagnostics.CodeAnalysis

. (Join-Path $PSScriptRoot 'paths.ps1')


# Map friendly names to finished CSV data file paths.
# These files can be used on their own as a data set, but are also used
# to generate/populate other database formats (such as an SQLite database.)
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$FinishedDataFiles = @{
    # Defines the available monster breeds.
    'Breeds' = 'Breeds.csv'

    # Defines the types of forces that techniques can draw their power from.
    # (Power, Intelligence)
    'ForceTypes' = 'ForceTypes.csv'

    # Defines the ranges that a technique can be executed in.
    # (Near, Middle, Far, Very Far)
    'TechniqueRanges' = 'TechniqueRanges.csv'

    # Defines the types of technique natures.
    # (Normal, Good, Bad)
    'TechniqueNatureTypes' = 'TechniqueNatureTypes.csv'

    # Defines the types of techniques.
    # (Basic, Hit, Heavy, Withering, Sharp, Special)
    'TechniqueTypes' = 'TechniqueTypes.csv'
}

# Map friendly names to manually compiled intermediate data file paths.
# These files contain additional data points not needed in the finished data,
# including implementation-detail data points (such as flag names used
# throughout the game data files) and IDs used to associate data
# with data obtained from another source (such data scraped from LegendCup.)
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$IntermediateDataFiles = @{
    # Defines the available monster breeds.
    'Breeds' = 'Breeds.csv'

    # Defines the types of forces that techniques can draw their power from.
    # (Power, Intelligence)
    'ForceTypes' = 'ForceTypes.csv'

    # Defines the ranges that a technique can be executed in.
    # (Near, Middle, Far, Very Far)
    'TechniqueRanges' = 'TechniqueRanges.csv'

    # Defines the types of technique natures.
    # (Normal, Good, Bad)
    'TechniqueNatureTypes' = 'TechniqueNatureTypes.csv'

    # Defines the types of techniques.
    # (Basic, Hit, Heavy, Withering, Sharp, Special)
    'TechniqueTypes' = 'TechniqueTypes.csv'
}

# Map friendly names to intermediate data files
# containing data extracted from the MR2DX game files.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ExtractedIntermediateDataFiles = @{}

# Map friendly names to intermediate data files
# containing data scraped from the web.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$ScrapedIntermediateDataFiles = @{
    # Defines the techniques available to each monster breed.
    # Used to obtain additional data points on techniques not extracted
    # from the game files such as English names and hit/miss durations.
    'TechniquesLegendCup' = 'techniques-legendcup.csv'
}

# Map friendly names to game file paths.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$GameFiles = @{
    # CSV table defining the monster variations
    # that can be obtained at the shrine.
    'ShrineMonsters' = 'SDATA_MONSTER.csv'

    # TSV table mapping song IDs in the English music database
    # to a corresponding shrine monster ID as well as an offset
    # that may be applied to the monster after shrining.
    'ShrineMonster_Songs' = 'en_sqlout_b.txt'

    # TSV table mapping song IDs in the English music database
    # to the corresponding artist name and title.
    'Songs' = 'en_sqlout_name.txt'

    # Data files defining the techniques available to each monster breed.
    # Files are encoded using Shift-JIS.
    'TechniquesKA' = [PSCustomObject]@{ # Pixie
        Path = 'mf2/data/mon/kapi/ka_ka_wz.dat'; Codepage = 932
    }
    'TechniquesKB' = [PSCustomObject]@{ # Dragon
        Path = 'mf2/data/mon/kbdr/kb_kb_wz.dat'; Codepage = 932
    }
    'TechniquesKC' = [PSCustomObject]@{ # Centaur
        Path = 'mf2/data/mon/kckn/kc_kc_wz.dat'; Codepage = 932
    }
    'TechniquesKD' = [PSCustomObject]@{ # ColorPandora
        Path = 'mf2/data/mon/kdro/kd_kd_wz.dat'; Codepage = 932
    }
    'TechniquesKE' = [PSCustomObject]@{ # Beaclon
        Path = 'mf2/data/mon/kebe/ke_ke_wz.dat'; Codepage = 932
    }
    'TechniquesKF' = [PSCustomObject]@{ # Henger
        Path = 'mf2/data/mon/kfhe/kf_kf_wz.dat'; Codepage = 932
    }
    'TechniquesKH' = [PSCustomObject]@{ # Wracky
        Path = 'mf2/data/mon/khcy/kh_kh_wz.dat'; Codepage = 932
    }
    'TechniquesKI' = [PSCustomObject]@{ # Golem
        Path = 'mf2/data/mon/kigo/ki_ki_wz.dat'; Codepage = 932
    }
    'TechniquesKK' = [PSCustomObject]@{ # Zuum
        Path = 'mf2/data/mon/kkro/kk_kk_wz.dat'; Codepage = 932
    }
    'TechniquesKL' = [PSCustomObject]@{ # Durahan
        Path = 'mf2/data/mon/klyo/kl_kl_wz.dat'; Codepage = 932
    }
    'TechniquesKM' = [PSCustomObject]@{ # Arrow Head
        Path = 'mf2/data/mon/kmto/km_km_wz.dat'; Codepage = 932
    }
    'TechniquesMA' = [PSCustomObject]@{ # Tiger
        Path = 'mf2/data/mon/marig/ma_ma_wz.dat'; Codepage = 932
    }
    'TechniquesMB' = [PSCustomObject]@{ # Hopper
        Path = 'mf2/data/mon/mbhop/mb_mb_wz.dat'; Codepage = 932
    }
    'TechniquesMC' = [PSCustomObject]@{ # Hare
        Path = 'mf2/data/mon/mcham/mc_mc_wz.dat'; Codepage = 932
    }
    'TechniquesMD' = [PSCustomObject]@{ # Baku
        Path = 'mf2/data/mon/mdbak/md_md_wz.dat'; Codepage = 932
    }
    'TechniquesME' = [PSCustomObject]@{ # Gali
        Path = 'mf2/data/mon/megar/me_me_wz.dat'; Codepage = 932
    }
    'TechniquesMF' = [PSCustomObject]@{ # Kato
        Path = 'mf2/data/mon/mfakr/mf_mf_wz.dat'; Codepage = 932
    }
    'TechniquesMG' = [PSCustomObject]@{ # Zilla
        Path = 'mf2/data/mon/mggjr/mg_mg_wz.dat'; Codepage = 932
    }
    'TechniquesMH' = [PSCustomObject]@{ # Bajarl
        Path = 'mf2/data/mon/mhlam/mh_mh_wz.dat'; Codepage = 932
    }
    'TechniquesMI' = [PSCustomObject]@{ # Mew
        Path = 'mf2/data/mon/minya/mi_mi_wz.dat'; Codepage = 932
    }
    'TechniquesMJ' = [PSCustomObject]@{ # Phoenix
        Path = 'mf2/data/mon/mjfbd/mj_mj_wz.dat'; Codepage = 932
    }
    'TechniquesMK' = [PSCustomObject]@{ # Ghost
        Path = 'mf2/data/mon/mkgho/mk_mk_wz.dat'; Codepage = 932
    }
    'TechniquesML' = [PSCustomObject]@{ # Metalner
        Path = 'mf2/data/mon/mlspm/ml_ml_wz.dat'; Codepage = 932
    }
    'TechniquesMM' = [PSCustomObject]@{ # Suezo
        Path = 'mf2/data/mon/mmxsu/mm_mm_wz.dat'; Codepage = 932
    }
    'TechniquesMN' = [PSCustomObject]@{ # Jill
        Path = 'mf2/data/mon/mnsnm/mn_mn_wz.dat'; Codepage = 932
    }
    'TechniquesMO' = [PSCustomObject]@{ # Mochi
        Path = 'mf2/data/mon/mochy/mo_mo_wz.dat'; Codepage = 932
    }
    'TechniquesMP' = [PSCustomObject]@{ # Joker
        Path = 'mf2/data/mon/mpjok/mp_mp_wz.dat'; Codepage = 932
    }
    'TechniquesMQ' = [PSCustomObject]@{ # Gaboo
        Path = 'mf2/data/mon/mqnen/mq_mq_wz.dat'; Codepage = 932
    }
    'TechniquesMR' = [PSCustomObject]@{ # Jell
        Path = 'mf2/data/mon/mrpru/mr_mr_wz.dat'; Codepage = 932
    }
    'TechniquesMS' = [PSCustomObject]@{ # Undine
        Path = 'mf2/data/mon/msund/ms_ms_wz.dat'; Codepage = 932
    }
    'TechniquesMT' = [PSCustomObject]@{ # Niton
        Path = 'mf2/data/mon/mtgai/mt_mt_wz.dat'; Codepage = 932
    }
    'TechniquesMU' = [PSCustomObject]@{ # Mock
        Path = 'mf2/data/mon/muoku/mu_mu_wz.dat'; Codepage = 932
    }
    'TechniquesMV' = [PSCustomObject]@{ # Ducken
        Path = 'mf2/data/mon/mvdak/mv_mv_wz.dat'; Codepage = 932
    }
    'TechniquesMW' = [PSCustomObject]@{ # Plant
        Path = 'mf2/data/mon/mwpla/mw_mw_wz.dat'; Codepage = 932
    }
    'TechniquesMX' = [PSCustomObject]@{ # Monol
        Path = 'mf2/data/mon/mxris/mx_mx_wz.dat'; Codepage = 932
    }
    'TechniquesMY' = [PSCustomObject]@{ # Ape
        Path = 'mf2/data/mon/mylau/my_my_wz.dat'; Codepage = 932
    }
    'TechniquesMZ' = [PSCustomObject]@{ # Worm
        Path = 'mf2/data/mon/mzmus/mz_mz_wz.dat'; Codepage = 932
    }
    'TechniquesNA' = [PSCustomObject]@{ # Naga
        Path = 'mf2/data/mon/naaga/na_na_wz.dat'; Codepage = 932
    }

    # Data file defining baseline stats and parameters
    # for all non-special monster types.
    # Encoded using Shift-JIS.
    'MonsterTypeBaselines' = [PSCustomObject]@{
        Path = 'mf2/data/monbase/mon_base.dat'; Codepage = 932
    }
}

# Map file manifest names to their directory and file table.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$FileManifests = @{
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
