# Trusted LaTeX toolchain for the verifier. Built from main on the verify runner
# (network allowed during the build only); papers compile in it with no network.
FROM ubuntu:24.04@sha256:68ee22004a9109b44973313b02ff7b1de250f1de0f5ecb628d73f579aaff33ac
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      texlive-latex-base texlive-latex-recommended texlive-latex-extra \
      texlive-fonts-recommended texlive-science texlive-bibtex-extra \
      latexmk lmodern qpdf poppler-utils \
 && rm -rf /var/lib/apt/lists/*
COPY viridis-lean.sty /usr/local/share/texmf/tex/latex/viridis/viridis-lean.sty
RUN mktexlsr /usr/local/share/texmf \
 && kpsewhich article.cls listings.sty natbib.sty booktabs.sty hyperref.sty xcolor.sty geometry.sty amsthm.sty newunicodechar.sty viridis-lean.sty
