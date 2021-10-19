# use `make` -j argument to run in parallel for many files; `make sanitize-all-filenames DIR=somedir -j 4`
SHELL:=/bin/bash
.ONESHELL:
PATTERNFILE:=patterns.tsv

# create a Perl expression to replace old patterns with new ones
# need to sort old patterns from longest to shortest first
# convert the contents of each tab-delimited line into a final output string that looks like:
# s|Foo1|Sample1|g; s|Foo2|Sample2|g;
# NOTE: watch out for the presence of the pattern delimiters for sed/Perl as part of the pattern strings
# NOTE: use pipes in the final Perl pattern so that we can scrub filepaths as well
PATTERNS_STR:=$(shell awk 'BEGIN{ FS=IFS="\t" } { print length($$1) " " $$0; }' "$(PATTERNFILE)" | sort -k 1nr | cut -d ' ' -f 2- | sed -e '/^$$/d' -e 's/[[:space:]]/|/g' -e 's/^/s|/g' -e 's/$$/|g;/g' | tr '\n' ' ')
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

check-pattern-str:
	echo "${PATTERNS_STR}"
# ~~~~~~~ FILE CONTENTS ~~~~~~ #
# clean a single file's contents
sanitize-file-contents: check-patterns-file clean-patterns check-file
	echo ">>> Sanitizing contents of file: $(FILE)"
	perl -pi -e "${PATTERNS_STR}" "$(FILE)"

# TODO: should this use the PATTERNS_STR instead?
# @patterns_str="$$(cat "$(PATTERNFILE)" | sed -e '/^$$/d' -e 's|[[:space:]]|/|g' -e 's|^|s/|g' -e 's|$$|/g;|g' | tr '\n' ' ')" ;


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
# SED_DELIM:=|
# sanitize-file-contents-debug:
# 	awk 'BEGIN{ FS=IFS="\t" } { print length($$1) " " $$0; }' "$(PATTERNFILE)" | sort -k 1nr | cut -d ' ' -f 2- | while read line; do \
# 	if [ ! -z "$${line}" ]; then \
# 	old="$$(echo "$${line}" | cut -f1)" ; \
# 	new="$$(echo "$${line}" | cut -f2)" ; \
# 	echo "$${old} -> $${new}" ; \
# 	sed -i "$(FILE)" -e "s$(SED_DELIM)$${old}$(SED_DELIM)$${new}$(SED_DELIM)g" ; \
# 	fi ; \
# 	done

# ~~~~~~~ FILE NAMES ~~~~~~ #
# remove known patterns from file names
sanitize-filename: check-patterns-file clean-patterns check-file
	@oldname="$$(basename "$(FILE)")" ; \
	newname="$$(dirname  "$(FILE)")/$$(echo $$oldname | perl -p -e '$(PATTERNS_STR)' )" ; \
	/bin/mv -v "$(FILE)" "$${newname}" || echo ">>> could not rename $${oldname} to $${newname}"

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


# ~~~~~ BAM FILE READ GROUPS ~~~~~ #

# https://gatk.broadinstitute.org/hc/en-us/articles/360037226472-AddOrReplaceReadGroups-Picard-
# https://github.com/broadinstitute/picard/releases/tag/2.23.7
# https://github.com/broadinstitute/picard/releases/download/2.23.7/picard.jar

# parallel -k -N0 -n 0 -j 4 "echo your command here ; sleep 2" ::: {1..10}
# find bam/ -type f -name "*.bam" | parallel 'make sanitize-bam INFILE={} OUTFILE=new_bam/$(basename {})'

# samtools/1.9
INFILE:=
OUTFILE:=
sanitize-bam:
	@echo ">>> Sanitizing contents of file: $(INFILE), saving to: $(OUTFILE)"
	samtools view -h "$(INFILE)" | perl -p -e '$(PATTERNS_STR)' | samtools view -S -b - > $(OUTFILE) && samtools index $(OUTFILE)
