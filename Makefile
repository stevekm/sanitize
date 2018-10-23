# run with 'make -j4'
SHELL:=/bin/bash
PATTERNFILE:=patterns.tsv
DIR:=
FILE:=

none:

# 
check-dir:
	@if [ ! -d "$(DIR)" ]; then echo ">>> ERROR: Not a directory: $(DIR); was 'DIR' passed correctly?"; exit 1; fi

# make sure 'patterns' file exists 
check-file:
	@if [ ! -f "$(FILE)" ]; then echo ">>> ERROR: Not a file: $(FILE); was 'FILE' passed correctly?"; exit 1; fi

# make sure 'patterns' file doesnt have less than 1 line
check-patterns-file:
	@$(MAKE) check-file FILE="$(PATTERNFILE)"
	@if [ "$$(cat "$(PATTERNFILE)" | wc -l)" -lt "1" ]; then echo "ERROR: Not enough lines in patterns file $(PATTERNFILE)";  exit 1; fi

# clean a single file's contents
sanitize-file-contents: check-patterns-file check-file
	@echo ">>> Sanitizing contents of file: $(FILE)"
	@patterns_str="$$(cat "$(PATTERNFILE)" | sed -e '/^$$/d' -e 's|[[:space:]]|/|g' -e 's|^|s/|g' -e 's|$$|/g;|g' | tr '\n' ' ')" ; \
	perl -pi -e "$${patterns_str}" "$(FILE)"

# clean the contents of all files in a directory
FINDALLFILES:=
ALLFILES:=
ALLFILENAMES:=
ifneq ($(FINDALLFILES),)
ALLFILES:=$(shell find '$(DIR)' -type f)
ALLFILENAMES:=$(ALLFILES)
endif
# check dir then recurse to run sanitizer
sanitize-all-file-contents: check-patterns-file check-dir
	@$(MAKE) sanitize-all-file-contents-recurse FINDALLFILES=1

# run sanitizer on all files
sanitize-all-file-contents-recurse: $(ALLFILES)

$(ALLFILES):
	@$(MAKE) sanitize-file-contents FILE="$@"
.PHONY: $(ALLFILES)



# remove known patterns from file names
sanitize-filename: check-patterns-file check-file
	@cat $(PATTERNFILE) | while read line; do \
	if [ ! -z "$${line}" ]; then \
	old="$$(echo "$${line}" | cut -f1)" ; \
	new="$$(echo "$${line}" | cut -f2)" ; \
	if grep -q "$${old}" <<<"$(FILE)" ; then \
	oldname="$$(basename "$(FILE)")" ; \
	newname="$$(dirname "$(FILE)")/$${oldname//$${old}/$${new}}" ; \
	/bin/mv -v "$(FILE)" "$${newname}" ; \
	else : ; \
	fi ; \
	fi ; \
	done

FINDALLFILENAMES:=
ALLFILENAMES:=
ifneq ($(FINDALLFILENAMES),)
ALLFILENAMES:=$(shell find '$(DIR)' -type f)
endif
sanitize-all-filenames: check-patterns-file check-dir
	@$(MAKE) sanitize-all-filenames-recurse FINDALLFILENAMES=1

sanitize-all-filenames-recurse: $(ALLFILENAMES)

$(ALLFILENAMES):
	@$(MAKE) sanitize-filename FILE="$@"
.PHONY: $(ALLFILENAMES)