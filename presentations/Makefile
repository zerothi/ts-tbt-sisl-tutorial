

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
	pdflatex -shell-escape "\PassOptionsToClass{handout}{beamer}\input{talk}"
	mv talk.pdf handout.pdf

clean: clean-talk clean-handout
clean-talk:
	-rm -f talk.aux talk.out talk.vrb talk.bbl talk.bcf talk.blg talk.nav talk.run.xml talk.snm talk.toc
clean-handout:
	-rm -f handout.aux handout.out handout.vrb handout.bbl handout.bcf handout.blg handout.nav handout.run.xml handout.snm handout.toc

extra-handout:
	bibtex handout
	makeindex handout

talks:
	make -C 01
	make -C 02
	make -C 03
