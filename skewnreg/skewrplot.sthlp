{smcl}
{* *! version 1.0.0  31oct2010}{...}
{cmd:help skewrplot}{right: ({browse "http://www.stata-journal.com/article.html?article=st0207":SJ10-4: st0207})}
{right:also see:  {help skew_postestimation:skewed regression postestimation}}
{right:{help skewnreg}{space 24}}
{right:{help skewtreg}{space 24}}
{right:{help mskewnreg}{space 23}}
{right:{help mskewtreg}{space 23}}
{hline}

{title:Title}

{p2colset 5 18 23 2}{...}
{p2col :{hi:skewrplot} {hline 2}}Residual diagnostic plots for skewed regressions{p_end}
{p2colreset}{...}


{title:Description}

{synoptset 22}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt :{helpb skewrplot##hist:skewrplot, histogram}}residual density plot over histogram; the default with {cmd:skewnreg} and {cmd:skewtreg}{p_end}
{synopt :{helpb skewrplot##kden:skewrplot, kdensity}}residual density plot with kernel-density estimate{p_end}
{synopt :{helpb skewrplot##rvf:skewrplot, rvf}}residual-versus-fitted plot{p_end}
{synopt :{helpb skewrplot##pp:skewrplot, pp}}probability-probability (P-P) plot{p_end}
{synopt :{helpb skewrplot##qq:skewrplot, qq}}quantile-quantile (Q-Q)
plot; the default with {cmd:mskewnreg} and {cmd:mskewtreg}{p_end}
{synoptline}
{p2colreset}{...}


{marker hist}{...}
{title:Residual density plot over histogram}


{title:Syntax}

{p 8 16 2}
{opt skewrplot} [{cmd:,} {opt hist:ogram} {it:options}]

{synoptset 28}{...}
{synopthdr}
{synoptline}
{synopt :{opt histogram}}plot histogram of residuals; the default{p_end}
{synopt :{opt fitted}}plot density of fitted values instead of residuals{p_end}
{synopt :{opt normal}}add a normal density to the generated graph{p_end}
{synopt :{opt normop:ts(norm_options)}}affect rendition of the normal curve{p_end}
{synopt :{opth lineop:ts(line_options:line_options)}}affect rendition of the curve from the skew fit{p_end}
{synopt :{opth histop:ts(histogram##continuous_opts:hist_options)}}any options other than {cmd:discrete}, 
{cmd:fraction}, {cmd:frequency}, {cmd:percent}, {cmd:horizontal}, and all 
{it:Density plots} options 
documented in {manhelp histogram R}{p_end}
{synopt :{opth addplot:(addplot_option:plot)}}add other plots to the generated graph{p_end}
{synopt :{it:{help twoway_options}}}any options other than {opt by()}
  documented in {bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:skewrplot, histogram} (or simply {cmd:skewrplot}) produces a residual
density plot where the skew-normal (or skew-t) density estimate of residuals,
evaluated at maximum likelihood estimates from the previously fit model, is
plotted together with a nonparametric residual density estimate, a histogram.
This plot is available after {cmd:skewnreg} or {cmd:skewtreg} only.


{title:Options}

{phang}
{opt histogram}, the default, requests that the histogram of residuals be 
plotted together with a residual density estimate from a {cmd:skewnreg} or 
{cmd:skewtreg} fit.

{phang}
{opt fitted} requests that the density of fitted values be plotted instead 
of the density of residuals from a {cmd:skewnreg} or {cmd:skewtreg} fit.

{phang}
{cmd:normal} specifies that the histogram be overlaid with an appropriately 
scaled normal density. The normal will have the same mean and standard
deviation as the data. 

{phang}
{opt normopts(norm_options)} affect rendition of the normal curve, such as 
the color and style of line used, and can be any of the options documented in 
{manhelp line_options G:{it:line_options}}.

{phang}
{opt lineopts(line_options)} affect rendition of the curve from the skew fit.
Aspects such as the color and style of line used are affected and can be
specified using any of the options documented in {manhelp line_options G:{it:line_options}}.

{phang}
{opt histopts(hist_options)} are any of the options other than {cmd:discrete}, 
{cmd:fraction}, {cmd:frequency}, {cmd:percent}, {cmd:horizontal}, and all 
{it:Density plot} options documented in {manhelp histogram R}.

{phang}
{opt addplot(plot)} allows adding more {helpb graph twoway} plots to the 
graph; see {manhelp addplot_option G:{it:addplot_option}}.

{phang}
{it:twoway_options} are any of the options other than {cmd:by()} documented 
in {manhelp twoway_options G:{it:twoway_options}}.


{marker kden}{...}
{title:Residual density plot with kernel-density estimate}


{title:Syntax}

{p 8 16 2}
{opt skewrplot}{cmd:,} {opt kden:sity} [{it:options}]

{synoptset 28}{...}
{synopthdr}
{synoptline}
{synopt :{opt kdensity}}plot kernel-density estimate of residuals instead 
of the histogram{p_end}
{synopt :{opt fitted}}plot density of fitted values instead of residuals{p_end}
{synopt :{opt normal}}add a normal density to the generated graph{p_end}
{synopt :{opt normop:ts(norm_options)}}affect rendition of the normal curve{p_end}
{synopt :{opth lineop:ts(line_options:line_options)}}affect rendition of the curve from the skew fit{p_end}
{synopt :{opth kdenop:ts(kdensity##options:kden_options)}}any options documented in 
{manhelp kdensity R}{p_end}
{synopt :{opth addplot:(addplot_option:plot)}}add other plots to the generated graph{p_end}
{synopt :{it:{help twoway_options}}}any options other than {opt by()}
  documented in {bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:skewrplot, kdensity} produces a residual density plot where the 
skew-normal (or skew-t) density estimate of residuals, evaluated at 
maximum likelihood estimates from the previously fit model, is plotted 
together with a nonparametric residual kernel-density estimate.  This 
plot is available after {cmd:skewnreg} or {cmd:skewtreg} only.


{title:Options}

{phang}
{opt kdensity} requests that the kernel-density estimate of residuals be 
plotted together with a residual density estimate from a {cmd:skewnreg} or 
{cmd:skewtreg} fit instead of the histogram.

{phang}
{opt fitted} requests that the density of fitted values be plotted instead 
of the density of residuals from a {cmd:skewnreg} or {cmd:skewtreg} fit.

{phang}
{cmd:normal} requests that a normal density be overlaid on the density 
estimate of residuals from a skewed regression fit.  The normal will have 
the same mean and standard deviation as the data. 

{phang}
{opt normopts(norm_options)} affect rendition of the normal curve, such as 
the color and style of line used, and can be any of the options documented in 
{manhelp line_options G:{it:line_options}}.

{phang}
{opt lineopts(line_options)} affect rendition of the curve from the skew fit, 
such as 
the color and style of line used, and can be any of the options documented in 
{manhelp line_options G:{it:line_options}}.

{phang}
{opt kdenopts(kden_options)} are any of the options documented in 
{manhelp kdensity R}.

{phang}
{opt addplot(plot)} allows adding more {helpb graph twoway} plots to the 
graph; see {manhelp addplot_option G:{it:addplot_option}}.

{phang}
{it:twoway_options} are any of the options other than {cmd:by()} documented 
in {manhelp twoway_options G:{it:twoway_options}}.


{marker rvf}{...}
{title:Residual-versus-fitted plot}


{title:Syntax}

{p 8 16 2}
{opt skewrplot}{cmd:,} {opt rvf} [{it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt rvf}}produce residual-versus-fitted plot{p_end}
{synopt :{opth addplot:(addplot_option:plot)}}add other plots to the generated graph{p_end}
{synopt :{it:{help graph_twoway_scatter##options:scatter_options}}}any options documented in {bind:{bf:[G] graph twoway scatter}}{p_end}
{synopt :{it:{help twoway_options}}}any options other than {opt by()}
  documented in {bind:{bf:[G]} {it:twoway_options}}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd} {cmd:skewrplot, rvf} produces a residual-versus-fitted plot.  This plot
is available after {cmd:skewnreg} or {cmd:skewtreg} only.


{title:Options}

{phang} {opt rvf} requests that a residual-versus-fitted plot be produced
after a {cmd:skewnreg} or {cmd:skewtreg} fit.

{phang} {opt addplot(plot)} allows adding more {helpb graph twoway} plots to
the graph; see {manhelp addplot_option G:{it:addplot_option}}.

{phang} {it:scatter_options} are any of the options documented in 
{manhelp graph_twowa_scatter G:graph twoway scatter}.

{phang} {it:twoway_options} are any of the options other than {cmd:by()}
documented in {manhelp twoway_options G:{it:twoway_options}}.


{marker pp}{...}
{title:Probability-probability plot}


{title:Syntax}

{p 8 16 2}
{opt skewrplot}{cmd:,} {opt pp} [{it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt pp}}produce probability-probability plot{p_end}
{synopt :{opt normal}}add a normal probability plot to the generated graph{p_end}
{synopt :{opt normop:ts(norm_options)}}affect the look of the normal probability plot{p_end}
{synopt :{opt overlay}}overlay probability plots in one plot{p_end}
{synopt :{opth addplot:(addplot_option:plot)}}add other plots to the generated graph{p_end}
{synopt :{it:{help diagnostic_plots##options1:pp_options}}}affect the look of the main probability plot{p_end}
{synopt :{it:graph_options}}specify overall look of graph{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:skewrplot, pp} produces a probability-probability plot of the observed
residuals versus the residuals obtained from the previously fit model using
{cmd:skewnreg}, {cmd:skewtreg}, {cmd:mskewnreg}, or {cmd:mskewtreg}.


{title:Options}

{phang}
{opt pp} requests that a probability-probability plot of the observed
residuals versus the residuals obtained from the previously fit skewed
regression be produced.

{phang}
{cmd:normal} requests that in addition a separate chi-squared probability 
plot of squared standardized residuals from a normal regression fit be 
produced.  This option can be used in combination with {cmd:overlay} to
overlay P-P plots on one graph. 

{phang}
{opt normopts(norm_options)} affect the look of the chi-squared probability 
plot and can be any of the options documented in {manhelp quantile R}.

{phang}
{opt overlay} specifies that the normal plot be overlaid with the main plot 
in one graph.  This option requires the specification of {cmd:normal}.

{phang}
{opt addplot(plot)} allows adding more {helpb graph twoway} plots to the 
graph; see {manhelp addplot_option G:{it:addplot_option}}.

{phang}
{it:pp_options} are any of the options documented in {manhelp quantile R}.

{phang}
{it:graph_options} specify the overall look of a graph.  If {cmd:normal} is 
used without {cmd:overlay}, then {it:graph_options} are any of the options 
documented in {manhelp graph_combine G:graph combine}.  Otherwise, these 
are {it:twoway_options}, any of the options other than {cmd:by()} documented 
in {manhelp twoway_options G:{it:twoway_options}}.


{marker qq}{...}
{title:Quantile-quantile plot}

{title:Syntax}

{p 8 16 2}
{opt skewrplot}{cmd:,} {opt qq} [{it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt qq}}produce quantile-quantile plot{p_end}
{synopt :{opt normal}}add a normal quantile plot to the generated graph{p_end}
{synopt :{opt normop:ts(norm_options)}}affect the look of the normal quantile plot{p_end}
{synopt :{opth addplot:(addplot_option:plot)}}add other plots to the generated graph{p_end}
{synopt :{it:{help diagnostic_plots##options1:qq_options}}}affect the look of the main quantile plot{p_end}
{synopt :{it:graph_options}}specify overall look of graph{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:skewrplot, qq} produces a quantile-quantile plot of the observed 
residuals versus the residuals obtained from the previously fit model 
using {cmd:skewnreg}, {cmd:skewtreg}, {cmd:mskewnreg}, or {cmd:mskewtreg}.  
This plot is the default plot after {cmd:mskewnreg} and {cmd:mskewtreg}.


{title:Options}

{phang}
{opt qq} requests that a quantile-quantile plot of the observed 
residuals versus the residuals obtained from the previously fit skewed 
regression be produced.

{phang}
{cmd:normal} requests that in addition a separate chi-squared quantile
plot of squared standardized residuals from a normal regression fit be 
produced.  

{phang}
{opt normopts(norm_options)} affect the look of the chi-squared quantile 
plot and can be any of the options documented in {manhelp quantile R}.

{phang}
{opt addplot(plot)} allows adding more {helpb graph twoway} plots to the 
graph; see {manhelp addplot_option G:{it:addplot_option}}.

{phang}
{it:qq_options} are any of the options documented in {manhelp quantile R}.

{phang}
{it:graph_options} specify the overall look of graph.  If {cmd:normal} is 
used, {it:graph_options} are any of the options 
documented in {manhelp graph_combine G:graph combine}.  Otherwise, these 
are {it:twoway_options}, any of the options other than {cmd:by()} documented 
in {manhelp twoway_options G:{it:twoway_options}}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use ais}{p_end}
{phang2}{cmd:. skewnreg bmi}{p_end}

{pstd}Produce a default residual density plot{p_end}
{phang2}{cmd:. skewrplot}{p_end}

{pstd}Plot densities of fitted values{p_end}
{phang2}{cmd:. skewrplot, fitted}{p_end}

{pstd}Include a normal density for comparison{p_end}
{phang2}{cmd:. skewrplot, fitted normal}{p_end}

{pstd}Plot kernel-density estimate instead of the histogram{p_end}
{phang2}{cmd:. skewrplot, kdensity}{p_end}

{pstd}Fit a skew-normal regression to {cmd:bmi} adjusted for 
{cmd:bfat} and {cmd:ssf} and obtain a residual-versus-fitted plot{p_end}
{phang2}{cmd:. skewnreg bmi bfat ssf}{p_end}
{phang2}{cmd:. skewrplot, rvf}{p_end}

{pstd}Check goodness-of-fit visually using a quantile-quantile plot{p_end}
{phang2}{cmd:. skewrplot, qq}{p_end}

{pstd}Fit a bivariate skew-normal regression to {cmd:lbm} and {cmd:bmi} 
and obtain a P-P plot; compare it to the normal probability plot{p_end}
{phang2}{cmd:. mskewnreg lbm bmi}{p_end}
{phang2}{cmd:. skewrplot, pp normal}{p_end}


{title:Author}

{pstd}Yulia V. Marchenko{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}
{pstd}ymarchenko@stata.com{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 10, number 4: {browse "http://www.stata-journal.com/article.html?article=st0207":st0207}

{p 4 14 2}
{space 3}Help:  {helpb skew_postestimation:skewed regression postestimation},
{helpb skewnreg},
{helpb skewtreg},
{helpb mskewnreg},
{helpb mskewtreg} (if installed)
{p_end}
