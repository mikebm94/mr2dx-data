
PWSH ?= pwsh -NoProfile

data_dir = data
sqlite_dir = $(data_dir)/sqlite
finished_dir = $(data_dir)/csv
intermediate_dir = $(data_dir)/intermediate
downloaded_dir = $(intermediate_dir)/downloaded
extracted_dir = $(intermediate_dir)/extracted
scraped_dir = $(intermediate_dir)/scraped
gamefiles_dir = game-files
tools_dir = tools
lib_dir = $(tools_dir)/lib
entities_dir = $(lib_dir)/entities

game_technique_files = \
	$(gamefiles_dir)/mf2/data/mon/kapi/ka_ka_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kbdr/kb_kb_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kckn/kc_kc_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kdro/kd_kd_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kebe/ke_ke_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kfhe/kf_kf_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/khcy/kh_kh_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kigo/ki_ki_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kkro/kk_kk_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/klyo/kl_kl_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/kmto/km_km_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/marig/ma_ma_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mbhop/mb_mb_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mcham/mc_mc_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mdbak/md_md_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/megar/me_me_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mfakr/mf_mf_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mggjr/mg_mg_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mhlam/mh_mh_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/minya/mi_mi_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mjfbd/mj_mj_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mkgho/mk_mk_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mlspm/ml_ml_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mmxsu/mm_mm_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mnsnm/mn_mn_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mochy/mo_mo_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mpjok/mp_mp_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mqnen/mq_mq_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mrpru/mr_mr_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/msund/ms_ms_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mtgai/mt_mt_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/muoku/mu_mu_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mvdak/mv_mv_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mwpla/mw_mw_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mxris/mx_mx_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mylau/my_my_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/mzmus/mz_mz_wz.dat \
	$(gamefiles_dir)/mf2/data/mon/naaga/na_na_wz.dat

game_files = \
	$(game_technique_files) \
	$(gamefiles_dir)/SDATA_MONSTER.csv

finished_data_files = \
	$(finished_dir)/Breeds.csv \
	$(finished_dir)/MonsterTypes.csv \
	$(finished_dir)/BattleSpecials.csv \
	$(finished_dir)/Fortes.csv \
	$(finished_dir)/GrowthTypes.csv \
	$(finished_dir)/ForceTypes.csv \
	$(finished_dir)/TechniqueNatures.csv \
	$(finished_dir)/TechniqueRanges.csv \
	$(finished_dir)/TechniqueTypes.csv \
	$(finished_dir)/Techniques.csv \
	$(finished_dir)/Errantries.csv


.PHONY: all
all: $(finished_data_files)

.PHONY: sqlite-db
sqlite-db: $(sqlite_dir)/mr2dx-data.db

$(game_files) &: $(tools_dir)/extract-game-files.ps1
	$(PWSH) $(tools_dir)/extract-game-files.ps1

$(finished_dir)/Breeds.csv: \
		$(intermediate_dir)/Breeds.csv $(entities_dir)/Breed.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-Breeds.ps1
	$(PWSH) $(tools_dir)/make-Breeds.ps1

$(finished_dir)/MonsterTypes.csv: \
		$(intermediate_dir)/MonsterTypes.csv $(entities_dir)/MonsterType.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-MonsterTypes.ps1
	$(PWSH) $(tools_dir)/make-MonsterTypes.ps1

$(finished_dir)/BattleSpecials.csv: \
		$(intermediate_dir)/BattleSpecials.csv $(entities_dir)/BattleSpecial.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-BattleSpecials.ps1
	$(PWSH) $(tools_dir)/make-BattleSpecials.ps1

$(finished_dir)/Fortes.csv: \
		$(intermediate_dir)/Fortes.csv $(entities_dir)/Forte.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-Fortes.ps1
	$(PWSH) $(tools_dir)/make-Fortes.ps1

$(finished_dir)/ForceTypes.csv: \
		$(intermediate_dir)/ForceTypes.csv $(entities_dir)/ForceType.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-ForceTypes.ps1
	$(PWSH) $(tools_dir)/make-ForceTypes.ps1

$(finished_dir)/TechniqueNatures.csv: \
		$(intermediate_dir)/TechniqueNatures.csv $(entities_dir)/TechniqueNature.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-TechniqueNatures.ps1
	$(PWSH) $(tools_dir)/make-TechniqueNatures.ps1

$(finished_dir)/TechniqueRanges.csv: \
		$(intermediate_dir)/TechniqueRanges.csv $(entities_dir)/TechniqueRange.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-TechniqueRanges.ps1
	$(PWSH) $(tools_dir)/make-TechniqueRanges.ps1

$(finished_dir)/TechniqueTypes.csv: \
		$(intermediate_dir)/TechniqueTypes.csv $(entities_dir)/TechniqueType.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/make-TechniqueTypes.ps1
	$(PWSH) $(tools_dir)/make-TechniqueTypes.ps1

$(extracted_dir)/TechniquesExtracted.csv: \
		$(intermediate_dir)/Breeds.csv $(entities_dir)/Breed.ps1 \
		$(intermediate_dir)/TechniqueRanges.csv $(entities_dir)/TechniqueRange.ps1 \
		$(game_technique_files) \
		$(lib_dir)/file-utils.ps1 \
		$(entities_dir)/Technique.ps1 \
		$(tools_dir)/extract-Techniques.ps1
	$(PWSH) $(tools_dir)/extract-Techniques.ps1

$(downloaded_dir)/LegendCupTechsSrc.js: \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/download-LegendCupTechsSrc.ps1
	$(PWSH) $(tools_dir)/download-LegendCupTechsSrc.ps1

$(scraped_dir)/TechniquesLegendCup.csv: \
		$(finished_dir)/Breeds.csv $(entities_dir)/Breed.ps1 \
		$(downloaded_dir)/LegendCupTechsSrc.js \
		$(lib_dir)/file-utils.ps1 \
		$(entities_dir)/Technique.ps1 \
		$(tools_dir)/scrape-Techniques.ps1
	$(PWSH) $(tools_dir)/scrape-Techniques.ps1

$(finished_dir)/Techniques.csv: \
		$(intermediate_dir)/ForceTypes.csv $(entities_dir)/ForceType.ps1 \
		$(intermediate_dir)/TechniqueNatures.csv $(entities_dir)/TechniqueNature.ps1 \
		$(intermediate_dir)/TechniqueTypes.csv $(entities_dir)/TechniqueType.ps1 \
		$(extracted_dir)/TechniquesExtracted.csv \
		$(scraped_dir)/TechniquesLegendCup.csv \
		$(lib_dir)/file-utils.ps1 \
		$(entities_dir)/Technique.ps1 \
		$(tools_dir)/make-Techniques.ps1
	$(PWSH) $(tools_dir)/make-Techniques.ps1

$(extracted_dir)/ShrineMonstersExtracted.csv: \
		$(intermediate_dir)/MonsterTypes.csv $(entities_dir)/MonsterType.ps1 \
		$(gamefiles_dir)/SDATA_MONSTER.csv \
		$(lib_dir)/file-utils.ps1 \
		$(entities_dir)/ShrineMonster.ps1 \
		$(tools_dir)/extract-ShrineMonsters.ps1
	$(PWSH) $(tools_dir)/extract-ShrineMonsters.ps1

$(scraped_dir)/ErrantryTechniquesLegendCup.csv: \
		$(finished_dir)/Breeds.csv $(entities_dir)/Breed.ps1 \
		$(finished_dir)/Techniques.csv $(entities_dir)/Technique.ps1 \
		$(downloaded_dir)/LegendCupTechsSrc.js \
		$(entities_dir)/ErrantryTechnique.ps1 \
		$(lib_dir)/file-utils.ps1 \
		$(tools_dir)/scrape-ErrantryTechniques.ps1
	$(PWSH) $(tools_dir)/scrape-ErrantryTechniques.ps1

$(sqlite_dir)/mr2dx-data.db: \
		$(finished_data_files) \
		$(sqlite_dir)/mr2dx-data.sql \
		$(tools_dir)/build-SQLiteDatabase.ps1
	$(PWSH) $(tools_dir)/build-SQLiteDatabase.ps1

# Don't clean downloaded data files by default. No need to connect to the internet
# every time the other directories are cleaned.
.PHONY: clean
clean:
	$(PWSH) $(tools_dir)/clean.ps1 SQLiteData FinishedData ScrapedData ExtractedData GameFiles

.PHONY: clean-all
clean-all:
	$(PWSH) $(tools_dir)/clean.ps1

.PHONY: clean-databases
clean-databases:
	$(PWSH) $(tools_dir)/clean.ps1 SQLiteData

.PHONY: clean-finished
clean-finished:
	$(PWSH) $(tools_dir)/clean.ps1 FinishedData

.PHONY: clean-downloaded
clean-downloaded:
	$(PWSH) $(tools_dir)/clean.ps1 DownloadedData

.PHONY: clean-extracted
clean-extracted:
	$(PWSH) $(tools_dir)/clean.ps1 ExtractedData

.PHONY: clean-scraped
clean-scraped:
	$(PWSH) $(tools_dir)/clean.ps1 ScrapedData

.PHONY: clean-gamefiles
clean-gamefiles:
	$(PWSH) $(tools_dir)/clean.ps1 GameFiles
