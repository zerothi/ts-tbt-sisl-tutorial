

all: talk

TEXINPUTS:=../theme/:$(TEXINPUTS)
export TEXINPUTS

talk: talk.pdf
.PHONY: talk.pdf
talk.pdf:
	pdflatex -shell-escape talk.tex

extra:
	bibtex talk ; \
	makeindex talk ; \
clean:
	-rm -f talk.{aux,out,vrb,bbl,bcf,blg,nav,run.xml,snm,toc}
