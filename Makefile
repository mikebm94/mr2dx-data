
PWSH ?= pwsh -NoProfile

data_dir = data
finished_dir = $(data_dir)/csv
intermediate_dir = $(data_dir)/intermediate
extracted_dir = $(intermediate_dir)/extracted
scraped_dir = $(intermediate_dir)/scraped
gamefiles_dir = game-files


.PHONY: all
all: \
		$(finished_dir)/Breeds.csv \
		$(finished_dir)/ForceTypes.csv \
		$(finished_dir)/TechniqueRanges.csv \
		$(finished_dir)/TechniqueNatures.csv \
		$(finished_dir)/TechniqueTypes.csv

$(finished_dir)/%.csv: \
		$(intermediate_dir)/%.csv \
		tools/make-%.ps1 \
		tools/lib/file-utils.ps1
	$(PWSH) tools/make-$*.ps1

$(scraped_dir)/techniques-legendcup.csv: \
		tools/scrape-techniques.ps1 \
		tools/lib/file-utils.ps1
	$(PWSH) tools/scrape-techniques.ps1

# Don't clean scraped data files by default.
# Shouldn't need to connect to the internet every time
# the other directories are cleaned.
.PHONY: clean
clean:
	$(PWSH) tools/clean.ps1 FinishedData ExtractedData GameFiles

.PHONY: clean-all
clean-all:
	$(PWSH) tools/clean.ps1

.PHONY: clean-finished
clean-finished:
	$(PWSH) tools/clean.ps1 FinishedData

.PHONY: clean-extracted
clean-extracted:
	$(PWSH) tools/clean.ps1 ExtractedData

.PHONY: clean-scraped
clean-scraped:
	$(PWSH) tools/clean.ps1 ScrapedData

.PHONY: clean-gamefiles
clean-gamefiles:
	$(PWSH) tools/clean.ps1 GameFiles
