# use `make` -j argument to run in parallel for many files; `make sanitize-all-filenames DIR=somedir -j 4`
SHELL:=/bin/bash
PATTERNFILE:=patterns.tsv
DIR:=
FILE:=

none:

# ~~~~~~~ VALIDATIONS ~~~~~~ #
# make sure dir exists
check-dir:
	@if [ ! -d "$(DIR)" ]; then echo ">>> ERROR: Not a directory: $(DIR); was 'DIR' passed correctly?"; exit 1; fi

# make sure 'patterns' file exists
check-file:
	@if [ ! -f "$(FILE)" ]; then echo ">>> ERROR: Not a file: $(FILE); was 'FILE' passed correctly?"; exit 1; fi

# make sure 'patterns' file doesnt have less than 1 line
check-patterns-file:
	@$(MAKE) check-file FILE="$(PATTERNFILE)"
	@if [ "$$(cat "$(PATTERNFILE)" | wc -l)" -lt "1" ]; then echo "ERROR: Not enough lines in patterns file $(PATTERNFILE)";  exit 1; fi

# need to clean the 'patterns' file; remove Windows carriage returns, empty lines
clean-patterns:
	@perl -pi -e 's|\r\n$$|\n|g' "$(PATTERNFILE)"
	@perl -pi -e 's|^[[:space:]]*$$||g' "$(PATTERNFILE)"

# ~~~~~~~ FILE CONTENTS ~~~~~~ #
# clean a single file's contents
sanitize-file-contents: check-patterns-file clean-patterns check-file
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
sanitize-all-file-contents: check-patterns-file clean-patterns check-dir
	@$(MAKE) sanitize-all-file-contents-recurse FINDALLFILES=1

# run sanitizer on all files
sanitize-all-file-contents-recurse: $(ALLFILES)

$(ALLFILES):
	@$(MAKE) sanitize-file-contents FILE="$@"
.PHONY: $(ALLFILES)


# an alternative very slow method... on Mac requires -i '' syntax or something... also watch the sed delimiters..
SED_DELIM:=|
sanitize-file-contents-debug:
	awk 'BEGIN{ FS=IFS="\t" } { print length($$1) " " $$0; }' "$(PATTERNFILE)" | sort -k 1nr | cut -d ' ' -f 2- | while read line; do \
	if [ ! -z "$${line}" ]; then \
	old="$$(echo "$${line}" | cut -f1)" ; \
	new="$$(echo "$${line}" | cut -f2)" ; \
	echo "$${old} -> $${new}" ; \
	sed -i "$(FILE)" -e "s$(SED_DELIM)$${old}$(SED_DELIM)$${new}$(SED_DELIM)g" ; \
	fi ; \
	done

# need to sort old patterns from longest to shortest
PATTERNS_STR:=$(shell awk 'BEGIN{ FS=IFS="\t" } { print length($$1) " " $$0; }' "$(PATTERNFILE)" | sort -k 1nr | cut -d ' ' -f 2- | sed -e '/^$$/d' -e 's|[[:space:]]|/|g' -e 's|^|s/|g' -e 's|$$|/g;|g' | tr '\n' ' ')
patterns:
	@echo s_C_0UWU6R_P001_d | perl -p -e "$(PATTERNS_STR)"
	# @patterns_str="$(awk 'BEGIN{ FS=IFS="\t" } { print length($$1) " " $$0; }' "$(PATTERNFILE)" | sort -k 1nr | cut -d ' ' -f 2- | sed -e '/^$$/d' -e 's|[[:space:]]|/|g' -e 's|^|s/|g' -e 's|$$|/g;|g' | tr '\n' ' ')" ; \
	# echo $$patterns_str

# ~~~~~~~ FILE NAMES ~~~~~~ #
# remove known patterns from file names
sanitize-filename: check-patterns-file clean-patterns check-file
	@oldname="$$(basename "$(FILE)")" ; \
	newname="$$(dirname  "$(FILE)")/$$(echo $$oldname | perl -p -e '$(PATTERNS_STR)' )" ; \
	/bin/mv -v "$(FILE)" "$${newname}"

FINDALLFILENAMES:=
ALLFILENAMES:=
ifneq ($(FINDALLFILENAMES),)
ALLFILENAMES:=$(shell find '$(DIR)' -type f)
endif
sanitize-all-filenames: check-patterns-file clean-patterns check-dir
	@$(MAKE) sanitize-all-filenames-recurse FINDALLFILENAMES=1

sanitize-all-filenames-recurse: $(ALLFILENAMES)

$(ALLFILENAMES):
	@$(MAKE) sanitize-filename FILE="$@"
.PHONY: $(ALLFILENAMES)
