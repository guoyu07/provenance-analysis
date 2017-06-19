# Program: PROCERATO - Program Provenance Analysis
# Author: Duy KHUONG <khuong@eurecom.fr>

include setting.mk

.PHONY:clean clean-all

#all: $(FILES_INFO)
all: $(PROGRAMS_INFO) $(INTERNET_INFO)

$(GITHUB_TOKEN):
	@echo "[-] Please enter your GitHub token key:"
	@read token_key; echo $${token_key} > $@

$(APT_PKGNAMES):
	@echo "[-] List up all packages are currently installed and managed by APT"
	@./apt_pkglist.sh > $@ 2>$(ERR_LOG)

$(PIP_PKGNAMES):
	@echo "[-] List up all packages are currently installed and managed by PIP"
	@pip list --format=legacy 2>>/dev/null | awk '{print $$1}' > $@ 2>>$(ERR_LOG)

$(APT_LST): $(APT_PKGNAMES)
	@echo "[-] List up all files that are managed by APT"
	@./apt_files_list.sh $< > $@ 2>>$(ERR_LOG)

$(PIP_LST): $(PIP_PKGNAMES)
	@echo "[-] List up all files that are managed by PIP"
	@./pip_files_list.sh $< > $@ 2>>$(ERR_LOG)

$(ALL_FILES_LST):
	@echo "[-] List up all files inside $(SCAN_DIRS) directories"
	@./all_files_list.sh $(SCAN_DIRS) "$(SCAN_TYPES)" > $@ 2>>$(ERR_LOG)

$(APT_SO_LST): $(APT_LST)
	@echo "[-] Filter only specific file types, $(SCAN_TYPES), which were installed by APT"
	@cat $< | grep -E "\.($(SCAN_TYPES))" > $@ 2>>$(ERR_LOG)

$(PIP_SO_LST): $(PIP_LST)
	@echo "[-] Filter only specific file types, $(SCAN_TYPES), which were installed by PIP"
	@cat $< | grep -E "\.($(SCAN_TYPES))" > $@ 2>>$(ERR_LOG)

$(INTERESTING_LST): $(APT_SO_LST) $(PIP_SO_LST) $(ALL_FILES_LST)
	@echo "[-] List up only files that are not managed by APT or PIP"
	@sort $< $^ $(word 2,$^) | uniq -u > $@ 2>>$(ERR_LOG)

$(INTERESTING_DIRS_LST): $(INTERESTING_LST)
	@echo "[-] Extract programs list that not managed by APT"
	@./extract_package_dirs.sh $< > $@ 2>>$(ERR_LOG)

$(PROGRAMS_INFO): $(INTERESTING_DIRS_LST) $(INTERESTING_LST)
	@echo "[-] Extract information of each program"
	@echo "path,modified_datetime,modified_datetime_human_readable" > $@
	@cat $< | while read line; do ./extract_info2.sh $$line $(INTERESTING_LST); done >> $@ 2>>$(ERR_LOG)

$(INTERNET_INFO): $(INTERESTING_DIRS_LST) $(INTERESTING_LST) $(GITHUB_TOKEN)
	@echo "[-] Get the latest information of each program from Internet"
	@echo "path,github_user,github_repo,latest_release,latest_commit,comitted_date" > $@
	@cat $< | while read line; do ./internet_info.sh $$line $(INTERESTING_LST); done >> $@ 2>>$(ERR_LOG)

$(FILES_INFO): $(INTERESTING_LST)
	@echo "[-] Extract information of each interesting file"
	@echo "file_path,MD5sum,Build-ID,Size(bytes),ModifiedTime,ModifiedTime(HumanReadable)" > $@
	@cat $< | while read line; do ./extract_info.sh $$line; done >> $@ 2>>$(ERR_LOG)

clean:
	rm -f *.dat

clean-all: clean
	rm -f *.list *.log
