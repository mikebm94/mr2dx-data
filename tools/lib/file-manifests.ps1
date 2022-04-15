<#
    file-manifests.ps1
        Defines hashtables mapping friendly names to files needed
        by the data generation scripts. This prevents the need
        to update multiple files when a file is renamed.
#>

using namespace System.Diagnostics.CodeAnalysis

. (Join-Path $PSScriptRoot 'paths.ps1')


# Map friendly names to game file paths.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$GameFiles = @{
    # CSV table defining the monster variations
    # that can be obtained at the shrine.
    'ShrineMonsters'       = 'SDATA_MONSTER.csv'

    # TSV table mapping song IDs in the English music database
    # to a corresponding shrine monster ID as well as an offset
    # that may be applied to the monster after shrining.
    'ShrineMonster_Songs'  = 'en_sqlout_b.txt'

    # TSV table mapping song IDs in the English music database
    # to the corresponding artist name and title.
    'Songs'                = 'en_sqlout_name.txt'

    # Data files defining the techniques available to each monster breed.
    # Files are encoded using Shift-JIS.
    'TechniquesKA'         = @{ # Pixie
        Path = 'mf2/data/mon/kapi/ka_ka_wz.dat'; Codepage = 932
    }
    'TechniquesKB'         = @{ # Dragon
        Path = 'mf2/data/mon/kbdr/kb_kb_wz.dat'; Codepage = 932
    }
    'TechniquesKC'         = @{ # Centaur
        Path = 'mf2/data/mon/kckn/kc_kc_wz.dat'; Codepage = 932
    }
    'TechniquesKD'         = @{ # ColorPandora
        Path = 'mf2/data/mon/kdro/kd_kd_wz.dat'; Codepage = 932
    }
    'TechniquesKE'         = @{ # Beaclon
        Path = 'mf2/data/mon/kebe/ke_ke_wz.dat'; Codepage = 932
    }
    'TechniquesKF'         = @{ # Henger
        Path = 'mf2/data/mon/kfhe/kf_kf_wz.dat'; Codepage = 932
    }
    'TechniquesKH'         = @{ # Wracky
        Path = 'mf2/data/mon/khcy/kh_kh_wz.dat'; Codepage = 932
    }
    'TechniquesKI'         = @{ # Golem
        Path = 'mf2/data/mon/kigo/ki_ki_wz.dat'; Codepage = 932
    }
    'TechniquesKK'         = @{ # Zuum
        Path = 'mf2/data/mon/kkro/kk_kk_wz.dat'; Codepage = 932
    }
    'TechniquesKL'         = @{ # Durahan
        Path = 'mf2/data/mon/klyo/kl_kl_wz.dat'; Codepage = 932
    }
    'TechniquesKM'         = @{ # Arrow Head
        Path = 'mf2/data/mon/kmto/km_km_wz.dat'; Codepage = 932
    }
    'TechniquesMA'         = @{ # Tiger
        Path = 'mf2/data/mon/marig/ma_ma_wz.dat'; Codepage = 932
    }
    'TechniquesMB'         = @{ # Hopper
        Path = 'mf2/data/mon/mbhop/mb_mb_wz.dat'; Codepage = 932
    }
    'TechniquesMC'         = @{ # Hare
        Path = 'mf2/data/mon/mcham/mc_mc_wz.dat'; Codepage = 932
    }
    'TechniquesMD'         = @{ # Baku
        Path = 'mf2/data/mon/mdbak/md_md_wz.dat'; Codepage = 932
    }
    'TechniquesME'         = @{ # Gali
        Path = 'mf2/data/mon/megar/me_me_wz.dat'; Codepage = 932
    }
    'TechniquesMF'         = @{ # Kato
        Path = 'mf2/data/mon/mfakr/mf_mf_wz.dat'; Codepage = 932
    }
    'TechniquesMG'         = @{ # Zilla
        Path = 'mf2/data/mon/mggjr/mg_mg_wz.dat'; Codepage = 932
    }
    'TechniquesMH'         = @{ # Bajarl
        Path = 'mf2/data/mon/mhlam/mh_mh_wz.dat'; Codepage = 932
    }
    'TechniquesMI'         = @{ # Mew
        Path = 'mf2/data/mon/minya/mi_mi_wz.dat'; Codepage = 932
    }
    'TechniquesMJ'         = @{ # Phoenix
        Path = 'mf2/data/mon/mjfbd/mj_mj_wz.dat'; Codepage = 932
    }
    'TechniquesMK'         = @{ # Ghost
        Path = 'mf2/data/mon/mkgho/mk_mk_wz.dat'; Codepage = 932
    }
    'TechniquesML'         = @{ # Metalner
        Path = 'mf2/data/mon/mlspm/ml_ml_wz.dat'; Codepage = 932
    }
    'TechniquesMM'         = @{ # Suezo
        Path = 'mf2/data/mon/mmxsu/mm_mm_wz.dat'; Codepage = 932
    }
    'TechniquesMN'         = @{ # Jill
        Path = 'mf2/data/mon/mnsnm/mn_mn_wz.dat'; Codepage = 932
    }
    'TechniquesMO'         = @{ # Mochi
        Path = 'mf2/data/mon/mochy/mo_mo_wz.dat'; Codepage = 932
    }
    'TechniquesMP'         = @{ # Joker
        Path = 'mf2/data/mon/mpjok/mp_mp_wz.dat'; Codepage = 932
    }
    'TechniquesMQ'         = @{ # Gaboo
        Path = 'mf2/data/mon/mqnen/mq_mq_wz.dat'; Codepage = 932
    }
    'TechniquesMR'         = @{ # Jell
        Path = 'mf2/data/mon/mrpru/mr_mr_wz.dat'; Codepage = 932
    }
    'TechniquesMS'         = @{ # Undine
        Path = 'mf2/data/mon/msund/ms_ms_wz.dat'; Codepage = 932
    }
    'TechniquesMT'         = @{ # Niton
        Path = 'mf2/data/mon/mtgai/mt_mt_wz.dat'; Codepage = 932
    }
    'TechniquesMU'         = @{ # Mock
        Path = 'mf2/data/mon/muoku/mu_mu_wz.dat'; Codepage = 932
    }
    'TechniquesMV'         = @{ # Ducken
        Path = 'mf2/data/mon/mvdak/mv_mv_wz.dat'; Codepage = 932
    }
    'TechniquesMW'         = @{ # Plant
        Path = 'mf2/data/mon/mwpla/mw_mw_wz.dat'; Codepage = 932
    }
    'TechniquesMX'         = @{ # Monol
        Path = 'mf2/data/mon/mxris/mx_mx_wz.dat'; Codepage = 932
    }
    'TechniquesMY'         = @{ # Ape
        Path = 'mf2/data/mon/mylau/my_my_wz.dat'; Codepage = 932
    }
    'TechniquesMZ'         = @{ # Worm
        Path = 'mf2/data/mon/mzmus/mz_mz_wz.dat'; Codepage = 932
    }
    'TechniquesNA'         = @{ # Naga
        Path = 'mf2/data/mon/naaga/na_na_wz.dat'; Codepage = 932
    }

    # Data file defining baseline stats and parameters
    # for all non-special monster types.
    'MonsterTypeBaselines' = 'mf2/data/monbase/mon_base.dat'
}

# Map file manifest names to their directory and file table.
[SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '')]
$FileManifests = @{
    'GameFiles' = [PSCustomObject]@{
        Directory = $GameFilesPath
        Files     = $GameFiles
    }
}
