<#
    file-manifests.ps1
        Defines hashtables mapping friendly names to files needed
        by the data generation scripts. This prevents the need
        to update multiple files when a file is renamed.
#>


. (Join-Path $PSScriptRoot 'paths.ps1')


# Map friendly names to game file paths.
$GameFiles = @{
    # CSV table defining the monster variations
    # that can be obtained at the shrine.
    'ShrineMonster'  = 'SDATA_MONSTER.csv'

    # TSV table mapping song IDs in the English music database
    # to a corresponding shrine monster ID as well as an offset
    # that may be applied to the monster after shrining.
    'SongShrineInfo' = 'en_sqlout_b.txt'

    # TSV table mapping song IDs in the English music database
    # to the corresponding artist name and title.
    'SongInfo'       = 'en_sqlout_name.txt'

    # Data files defining the techniques available to each monster breed.
    # Files are encoded using Shift-JIS.
    'Technique_ka'   = @{ # Pixie
        Path = 'mf2/data/mon/kapi/ka_ka_wz.dat'; Codepage = 932
    }
    'Technique_kb'   = @{ # Dragon
        Path = 'mf2/data/mon/kbdr/kb_kb_wz.dat'; Codepage = 932
    }
    'Technique_kc'   = @{ # Centaur
        Path = 'mf2/data/mon/kckn/kc_kc_wz.dat'; Codepage = 932
    }
    'Technique_kd'   = @{ # ColorPandora
        Path = 'mf2/data/mon/kdro/kd_kd_wz.dat'; Codepage = 932
    }
    'Technique_ke'   = @{ # Beaclon
        Path = 'mf2/data/mon/kebe/ke_ke_wz.dat'; Codepage = 932
    }
    'Technique_kf'   = @{ # Henger
        Path = 'mf2/data/mon/kfhe/kf_kf_wz.dat'; Codepage = 932
    }
    'Technique_kh'   = @{ # Wracky
        Path = 'mf2/data/mon/khcy/kh_kh_wz.dat'; Codepage = 932
    }
    'Technique_ki'   = @{ # Golem
        Path = 'mf2/data/mon/kigo/ki_ki_wz.dat'; Codepage = 932
    }
    'Technique_kk'   = @{ # Zuum
        Path = 'mf2/data/mon/kkro/kk_kk_wz.dat'; Codepage = 932
    }
    'Technique_kl'   = @{ # Durahan
        Path = 'mf2/data/mon/klyo/kl_kl_wz.dat'; Codepage = 932
    }
    'Technique_km'   = @{ # Arrow Head
        Path = 'mf2/data/mon/kmto/km_km_wz.dat'; Codepage = 932
    }
    'Technique_ma'   = @{ # Tiger
        Path = 'mf2/data/mon/marig/ma_ma_wz.dat'; Codepage = 932
    }
    'Technique_mb'   = @{ # Hopper
        Path = 'mf2/data/mon/mbhop/mb_mb_wz.dat'; Codepage = 932
    }
    'Technique_mc'   = @{ # Hare
        Path = 'mf2/data/mon/mcham/mc_mc_wz.dat'; Codepage = 932
    }
    'Technique_md'   = @{ # Baku
        Path = 'mf2/data/mon/mdbak/md_md_wz.dat'; Codepage = 932
    }
    'Technique_me'   = @{ # Gali
        Path = 'mf2/data/mon/megar/me_me_wz.dat'; Codepage = 932
    }
    'Technique_mf'   = @{ # Kato
        Path = 'mf2/data/mon/mfakr/mf_mf_wz.dat'; Codepage = 932
    }
    'Technique_mg'   = @{ # Zilla
        Path = 'mf2/data/mon/mggjr/mg_mg_wz.dat'; Codepage = 932
    }
    'Technique_mh'   = @{ # Bajarl
        Path = 'mf2/data/mon/mhlam/mh_mh_wz.dat'; Codepage = 932
    }
    'Technique_mi'   = @{ # Mew
        Path = 'mf2/data/mon/minya/mi_mi_wz.dat'; Codepage = 932
    }
    'Technique_mj'   = @{ # Phoenix
        Path = 'mf2/data/mon/mjfbd/mj_mj_wz.dat'; Codepage = 932
    }
    'Technique_mk'   = @{ # Ghost
        Path = 'mf2/data/mon/mkgho/mk_mk_wz.dat'; Codepage = 932
    }
    'Technique_ml'   = @{ # Metalner
        Path = 'mf2/data/mon/mlspm/ml_ml_wz.dat'; Codepage = 932
    }
    'Technique_mm'   = @{ # Suezo
        Path = 'mf2/data/mon/mmxsu/mm_mm_wz.dat'; Codepage = 932
    }
    'Technique_mn'   = @{ # Jill
        Path = 'mf2/data/mon/mnsnm/mn_mn_wz.dat'; Codepage = 932
    }
    'Technique_mo'   = @{ # Mochi
        Path = 'mf2/data/mon/mochy/mo_mo_wz.dat'; Codepage = 932
    }
    'Technique_mp'   = @{ # Joker
        Path = 'mf2/data/mon/mpjok/mp_mp_wz.dat'; Codepage = 932
    }
    'Technique_mq'   = @{ # Gaboo
        Path = 'mf2/data/mon/mqnen/mq_mq_wz.dat'; Codepage = 932
    }
    'Technique_mr'   = @{ # Jell
        Path = 'mf2/data/mon/mrpru/mr_mr_wz.dat'; Codepage = 932
    }
    'Technique_ms'   = @{ # Undine
        Path = 'mf2/data/mon/msund/ms_ms_wz.dat'; Codepage = 932
    }
    'Technique_mt'   = @{ # Niton
        Path = 'mf2/data/mon/mtgai/mt_mt_wz.dat'; Codepage = 932
    }
    'Technique_mu'   = @{ # Mock
        Path = 'mf2/data/mon/muoku/mu_mu_wz.dat'; Codepage = 932
    }
    'Technique_mv'   = @{ # Ducken
        Path = 'mf2/data/mon/mvdak/mv_mv_wz.dat'; Codepage = 932
    }
    'Technique_mw'   = @{ # Plant
        Path = 'mf2/data/mon/mwpla/mw_mw_wz.dat'; Codepage = 932
    }
    'Technique_mx'   = @{ # Monol
        Path = 'mf2/data/mon/mxris/mx_mx_wz.dat'; Codepage = 932
    }
    'Technique_my'   = @{ # Ape
        Path = 'mf2/data/mon/mylau/my_my_wz.dat'; Codepage = 932
    }
    'Technique_mz'   = @{ # Worm
        Path = 'mf2/data/mon/mzmus/mz_mz_wz.dat'; Codepage = 932
    }
    'Technique_na'   = @{ # Naga
        Path = 'mf2/data/mon/naaga/na_na_wz.dat'; Codepage = 932
    }

    # Data file defining baseline stats and parameters
    # for all non-special monster types.
    'Baseline'       = 'mf2/data/monbase/mon_base.dat'
}
