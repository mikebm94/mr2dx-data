
PWSH ?= pwsh -NoProfile

data_dir = data
finished_dir = $(data_dir)/csv
intermediate_dir = $(data_dir)/intermediate
extracted_dir = $(intermediate_dir)/extracted
scraped_dir = $(intermediate_dir)/scraped
gamefiles_dir = game-files


.PHONY: all
all: \
		$(finished_dir)/Breeds.csv

$(finished_dir)/Breeds.csv: \
		$(intermediate_dir)/breeds.csv \
		tools/make-breeds-tbl.ps1 \
		tools/lib/file-utils.ps1
	$(PWSH) tools/make-breeds-tbl.ps1

$(scraped_dir)/techniques-legendcup.csv: \
		tools/scrape-techniques.ps1 \
		tools/lib/file-utils.ps1
	$(PWSH) tools/scrape-techniques.ps1

.PHONY: clean
clean:
	$(PWSH) tools/clean.ps1
