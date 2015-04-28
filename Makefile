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

# .............................................................................
# The rest below is generic and probably does not need to be changed.

basename = $(basename $(MAIN_FILE))
pdf_file = $(addsuffix .pdf,$(basename))
md5_file = $(addsuffix .md5,$(basename))
log_file = $(addsuffix .md5,$(basename))

update:;
	git checkout gh-pages
	git stash
	git fetch --all
	git reset --hard origin/master
	make $(pdf_file)
	md5sum $(pdf_file) > $(md5_file)
	git add $(pdf_file) $(md5_file)
	-git add -f $(log_file)
	-git add index.html js css
	-git commit -m "Latest build."
	git push origin gh-pages -f

$(pdf_file): $(MAIN_FILE) Makefile $(wildcard *.tex) $(wildcard *.bib)
	-pdflatex $(MAIN_FILE)
	-bibtex $(MAIN_FILE)
	-pdflatex $(MAIN_FILE)
	-pdflatex $(MAIN_FILE)

clean:
	-rm -f *.aux *.bbl *.blg *.log *.out *.loc *.toc *.pdf
