

presentation: talk
handout: handout.pdf

TEXINPUTS:=../theme/:$(TEXINPUTS)
export TEXINPUTS

talk: talk.pdf
.PHONY: talk.pdf
talk.pdf:
	pdflatex -shell-escape talk.tex

extra:
	bibtex talk
	makeindex talk

.PHONY: handout.pdf
handout.pdf:
	pdflatex -shell-escape -jobname handout "\PassOptionsToClass{handout}{beamer}\input{talk}"

clean:
	-rm -f talk.{aux,out,vrb,bbl,bcf,blg,nav,run.xml,snm,toc}

extra-handout:
	bibtex handout
	makeindex handout
