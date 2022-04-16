
PWSH = pwsh -NoProfile

# Common directories.
scraped_data_dir = data/intermediate/scraped


all: $(scraped_data_dir)/techniques-legendcup.csv

$(scraped_data_dir)/techniques-legendcup.csv: \
  tools/scrape-techniques.ps1 \
  tools/lib/file-utils.ps1
	$(PWSH) tools/scrape-techniques.ps1

.PHONY: clean
clean:
	$(PWSH) tools/clean.ps1
