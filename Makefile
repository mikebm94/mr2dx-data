
PWSH ?= pwsh -NoProfile

data_dir = data
sqlite_dir = $(data_dir)/sqlite
finished_dir = $(data_dir)/csv
intermediate_dir = $(data_dir)/intermediate
downloaded_dir = $(intermediate_dir)/downloaded
extracted_dir = $(intermediate_dir)/extracted
scraped_dir = $(intermediate_dir)/scraped
gamefiles_dir = game-files

finished_data_files = \
	$(finished_dir)/Breeds.csv \
	$(finished_dir)/MonsterTypes.csv \
	$(finished_dir)/ForceTypes.csv \
	$(finished_dir)/TechniqueRanges.csv \
	$(finished_dir)/TechniqueNatures.csv \
	$(finished_dir)/TechniqueTypes.csv \
	$(finished_dir)/Techniques.csv \
	$(finished_dir)/Errantries.csv

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

game_files = $(game_technique_files)


.PHONY: all
all: $(finished_data_files)

.PHONY: sqlite-db
sqlite-db: $(sqlite_dir)/mr2dx-data.db

$(sqlite_dir)/mr2dx-data.db: \
		$(finished_data_files) \
		$(sqlite_dir)/mr2dx-data.sql \
		tools/build-SQLiteDatabase.ps1
	$(PWSH) tools/build-SQLiteDatabase.ps1

$(game_files) &: tools/extract-game-files.ps1
	$(PWSH) tools/extract-game-files.ps1

$(finished_dir)/%s.csv: \
		$(intermediate_dir)/%s.csv \
		tools/make-%s.ps1 \
		tools/lib/file-utils.ps1 \
		tools/lib/entities/%.ps1
	$(PWSH) tools/make-$*s.ps1

$(scraped_dir)/ErrantryTechniquesLegendCup.csv: \
		$(downloaded_dir)/LegendCupTechsSrc.js \
		$(finished_dir)/Breeds.csv \
		$(finished_dir)/Techniques.csv \
		tools/lib/entities/Breed.ps1 \
		tools/lib/entities/Technique.ps1 \
		tools/lib/entities/ErrantryTechnique.ps1 \
		tools/lib/file-utils.ps1 \
		tools/scrape-ErrantryTechniques.ps1
	$(PWSH) tools/scrape-ErrantryTechniques.ps1

$(finished_dir)/Techniques.csv: \
		$(extracted_dir)/TechniquesExtracted.csv \
		$(scraped_dir)/TechniquesLegendCup.csv \
		$(intermediate_dir)/ForceTypes.csv \
		$(intermediate_dir)/TechniqueNatures.csv \
		$(intermediate_dir)/TechniqueRanges.csv \
		$(intermediate_dir)/TechniqueTypes.csv \
		tools/lib/entities/ForceType.ps1 \
		tools/lib/entities/TechniqueNature.ps1 \
		tools/lib/entities/TechniqueRange.ps1 \
		tools/lib/entities/TechniqueType.ps1 \
		tools/make-Techniques.ps1 \
		tools/lib/file-utils.ps1 \
		tools/lib/entities/Technique.ps1
	$(PWSH) tools/make-Techniques.ps1

$(extracted_dir)/TechniquesExtracted.csv: \
		$(intermediate_dir)/Breeds.csv \
		$(intermediate_dir)/TechniqueRanges.csv \
		$(game_technique_files) \
		tools/extract-techniques.ps1 \
		tools/lib/entities/Breed.ps1 \
		tools/lib/entities/Technique.ps1 \
		tools/lib/entities/TechniqueRange.ps1 \
		tools/lib/file-utils.ps1
	$(PWSH) tools/extract-techniques.ps1

$(scraped_dir)/TechniquesLegendCup.csv: \
		$(downloaded_dir)/LegendCupTechsSrc.js \
		tools/scrape-techniques.ps1 \
		tools/lib/file-utils.ps1 \
		tools/lib/entities/Breed.ps1 \
		tools/lib/entities/Technique.ps1
	$(PWSH) tools/scrape-techniques.ps1

$(downloaded_dir)/LegendCupTechsSrc.js: \
		tools/download-LegendCupTechsSrc.ps1 \
		tools/lib/file-utils.ps1
	$(PWSH) tools/download-LegendCupTechsSrc.ps1

# Don't clean scraped data files by default.
# Shouldn't need to connect to the internet every time
# the other directories are cleaned.
.PHONY: clean
clean:
	$(PWSH) tools/clean.ps1 SQLiteData FinishedData ExtractedData GameFiles

.PHONY: clean-all
clean-all:
	$(PWSH) tools/clean.ps1

.PHONY: clean-databases
clean-databases:
	$(PWSH) tools/clean.ps1 SQLiteData

.PHONY: clean-finished
clean-finished:
	$(PWSH) tools/clean.ps1 FinishedData

.PHONY: clean-downloaded
clean-downloaded:
	$(PWSH) tools/clean.ps1 DownloadedData

.PHONY: clean-extracted
clean-extracted:
	$(PWSH) tools/clean.ps1 ExtractedData

.PHONY: clean-scraped
clean-scraped:
	$(PWSH) tools/clean.ps1 ScrapedData

.PHONY: clean-gamefiles
clean-gamefiles:
	$(PWSH) tools/clean.ps1 GameFiles
