# run with 'make -j4'
SHELL:=/bin/bash
PATTERNFILE:=patterns.tsv
DIR:=
FILE:=

none:

check-patterns-file:
	@if [ ! -f "$(PATTERNFILE)" ]; then echo ">>> ERROR: Invalid patterns file: $(PATTERNFILE)"; exit 1; fi
	@if [ "$$(cat "$(PATTERNFILE)" | wc -l)" -lt "1" ]; then echo "ERROR: Not enough lines in patterns file $(PATTERNFILE)";  exit 1; fi

check-file:
	@if [ ! -f "$(FILE)" ]; then echo ">>> ERROR: Invalid file: $(FILE)"; exit 1; fi

# clean a single file's contents
sanitize-content: check-patterns-file check-file
	@patterns="$$(cat "$(PATTERNFILE)" | sed -e '/^$$/d' -e 's|[[:space:]]|/|g' -e 's|^|s/|g' -e 's|$$|/g;|g' | tr '\n' ' ')" ; \
	perl -pi -e "$${patterns}" "$(FILE)"

