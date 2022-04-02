
# Directory for game files extracted from the MR2DX game data archive.
$GameFilesPath = Resolve-Path (Join-Path $PSScriptRoot '../game-files/')

# Directory for gathered MR2DX data and images.
$DataPath = Resolve-Path (Join-Path $PSScriptRoot '../data/')

# Directory for data that is used to help generate the finished data tables.
$IntermediateDataPath = Resolve-Path (Join-Path $DataPath 'intermediate/')

# Directory for intermediate data scraped from the web.
$ScrapedDataPath = Resolve-Path (Join-Path $IntermediateDataPath 'scraped/')

# Directory for intermediate data extracted from the MR2DX game files.
$ExtractedDataPath = Resolve-Path (Join-Path $IntermediateDataPath 'extracted/')

# Directory for finished CSV data tables that are suitable for use
# in development and to generate the database.
$FinishedDataPath = Resolve-Path (Join-Path $DataPath 'csv/')

# Directory for images and icons such as technique icons.
$ImageDataPath = Resolve-Path (Join-Path $DataPath 'images/')


# Map friendly names to game file paths.
$GameFiles = @{
    # CSV table of all monster variations that can be obtained at the shrine.
    'ShrineMonsters'     = 'SDATA_MONSTER.csv'

    # Maps each song in the English music database to a corresponding
    # shrine monster ID. Also maps to an ID of an offset that is applied
    # to the monster after shrining.
    'ShrineMonsterSongs' = 'en_sqlout_b.txt'

    # Defines all songs in the English music database.
    'ShrineSongs'        = 'en_sqlout_name.txt'

    # Defines techniques available to a breed.
    'Techs_ka'           = 'mf2/data/mon/kapi/ka_ka_wz.dat'  # Pixie
    'Techs_kb'           = 'mf2/data/mon/kbdr/kb_kb_wz.dat'  # Dragon
    'Techs_kc'           = 'mf2/data/mon/kckn/kc_kc_wz.dat'  # Centaur
    'Techs_kd'           = 'mf2/data/mon/kdro/kd_kd_wz.dat'  # ColorPandora
    'Techs_ke'           = 'mf2/data/mon/kebe/ke_ke_wz.dat'  # Beaclon
    'Techs_kf'           = 'mf2/data/mon/kfhe/kf_kf_wz.dat'  # Henger
    'Techs_kh'           = 'mf2/data/mon/khcy/kh_kh_wz.dat'  # Wracky
    'Techs_ki'           = 'mf2/data/mon/kigo/ki_ki_wz.dat'  # Golem
    'Techs_kk'           = 'mf2/data/mon/kkro/kk_kk_wz.dat'  # Zuum
    'Techs_kl'           = 'mf2/data/mon/klyo/kl_kl_wz.dat'  # Durahan
    'Techs_km'           = 'mf2/data/mon/kmto/km_km_wz.dat'  # Arrow Head
    'Techs_ma'           = 'mf2/data/mon/marig/ma_ma_wz.dat' # Tiger
    'Techs_mb'           = 'mf2/data/mon/mbhop/mb_mb_wz.dat' # Hopper
    'Techs_mc'           = 'mf2/data/mon/mcham/mc_mc_wz.dat' # Hare
    'Techs_md'           = 'mf2/data/mon/mdbak/md_md_wz.dat' # Baku
    'Techs_me'           = 'mf2/data/mon/megar/me_me_wz.dat' # Gali
    'Techs_mf'           = 'mf2/data/mon/mfakr/mf_mf_wz.dat' # Kato
    'Techs_mg'           = 'mf2/data/mon/mggjr/mg_mg_wz.dat' # Zilla
    'Techs_mh'           = 'mf2/data/mon/mhlam/mh_mh_wz.dat' # Bajarl
    'Techs_mi'           = 'mf2/data/mon/minya/mi_mi_wz.dat' # Mew
    'Techs_mj'           = 'mf2/data/mon/mjfbd/mj_mj_wz.dat' # Phoenix
    'Techs_mk'           = 'mf2/data/mon/mkgho/mk_mk_wz.dat' # Ghost
    'Techs_ml'           = 'mf2/data/mon/mlspm/ml_ml_wz.dat' # Metalner
    'Techs_mm'           = 'mf2/data/mon/mmxsu/mm_mm_wz.dat' # Suezo
    'Techs_mn'           = 'mf2/data/mon/mnsnm/mn_mn_wz.dat' # Jill
    'Techs_mo'           = 'mf2/data/mon/mochy/mo_mo_wz.dat' # Mochi
    'Techs_mp'           = 'mf2/data/mon/mpjok/mp_mp_wz.dat' # Joker
    'Techs_mq'           = 'mf2/data/mon/mqnen/mq_mq_wz.dat' # Gaboo
    'Techs_mr'           = 'mf2/data/mon/mrpru/mr_mr_wz.dat' # Jell
    'Techs_ms'           = 'mf2/data/mon/msund/ms_ms_wz.dat' # Undine
    'Techs_mt'           = 'mf2/data/mon/mtgai/mt_mt_wz.dat' # Niton
    'Techs_mu'           = 'mf2/data/mon/muoku/mu_mu_wz.dat' # Mock
    'Techs_mv'           = 'mf2/data/mon/mvdak/mv_mv_wz.dat' # Ducken
    'Techs_mw'           = 'mf2/data/mon/mwpla/mw_mw_wz.dat' # Plant
    'Techs_mx'           = 'mf2/data/mon/mxris/mx_mx_wz.dat' # Monol
    'Techs_my'           = 'mf2/data/mon/mylau/my_my_wz.dat' # Ape
    'Techs_mz'           = 'mf2/data/mon/mzmus/mz_mz_wz.dat' # Worm
    'Techs_na'           = 'mf2/data/mon/naaga/na_na_wz.dat' # Naga

    # Defines baseline stats and parameters for all non-special monster types.
    'MonsterBaselines'   = 'mf2/data/monbase/mon_base.dat'
}


<#
.SYNOPSIS
Create a hashtable from a collection of objects
using the specified properties as the keys and values.
#>
function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        # The objects used to create the hashtable.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]
        $InputObject,

        # The property of the input objects to use as keys for the hashtable.
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [object]
        $KeyProperty,

        # The property of the input objects to use as values for the hashtable.
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNull()]
        [object]
        $ValueProperty
    )

    begin {
        $table = @{}
    }

    process {
        $table.Add($InputObject.$KeyProperty, $InputObject.$ValueProperty)
    }

    end {
        return $table
    }
}
