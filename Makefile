
PWSH = pwsh -NoProfile

# Common directories.
data_dir = data
finished_data_dir = $(data_dir)/csv
intermediate_data_dir = $(data_dir)/intermediate
extracted_data_dir = $(intermediate_data_dir)/extracted
scraped_data_dir = $(intermediate_data_dir)/scraped


all: \
  $(finished_data_dir)/Breeds.csv \
  $(scraped_data_dir)/techniques-legendcup.csv \

$(finished_data_dir)/Breeds.csv: \
  $(intermediate_data_dir)/breeds.csv \
  tools/make-breeds-tbl.ps1 \
  tools/lib/file-utils.ps1
	$(PWSH) tools/make-breeds-tbl.ps1

$(scraped_data_dir)/techniques-legendcup.csv: \
  tools/scrape-techniques.ps1 \
  tools/lib/file-utils.ps1
	$(PWSH) tools/scrape-techniques.ps1

.PHONY: clean
clean:
	$(PWSH) tools/clean.ps1
