##
## @file    Makefile
## @brief   Simple Makefile for LaTeX projects
## @author  Michael Hucka <mhucka@caltech.edu>
##
## This file is part of Vireo.  Please visit the following page for more
## information and the latest version:  https://github.com/mhucka/vireo
## ----------------------------------------------------------------------------

# Change the following to the file name of the main LaTeX file.

MAIN_FILE = document.tex

# Change the following to the name of the file you want to use to capture the
# output of running "make" on the document.  Note: this is NOT the same as
# LaTeX's own log file, and DO NOT name this the same as $(MAIN_FILE).log.

CONSOLE_LOG = vireo.log

# .............................................................................
# The rest below is generic and probably does not need to be changed.

basename = $(basename $(MAIN_FILE))
pdf_file = $(addsuffix .pdf,$(basename))
md5_file = $(addsuffix .md5,$(basename))

latex_options = -interaction=nonstopmode -file-line-error

$(pdf_file): $(MAIN_FILE) Makefile $(wildcard *.tex) $(wildcard *.bib)
	-pdflatex $(latex_options) -draftmode $(MAIN_FILE)
	-bibtex $(basename)
	-pdflatex $(latex_options) -draftmode $(MAIN_FILE)
	-pdflatex $(latex_options) $(MAIN_FILE)

update:;
	git checkout gh-pages
	git stash
	git fetch --all
	git reset --hard origin/master
	date > $(CONSOLE_LOG)
	make $(pdf_file) >> $(CONSOLE_LOG) 2>&1
	md5sum $(pdf_file) > $(md5_file)
	git add $(pdf_file) $(md5_file)
	-git add -f $(CONSOLE_LOG)
	-git add index.html js css
	-git commit -m "Latest build."
	git push origin gh-pages -f

clean:
	-rm -f *.aux *.bbl *.blg *.log *.out *.loc *.toc *.pdf
