{smcl}
{* *! version 1.0.0  31oct2010}{...}
{cmd:help skewed regression postestimation}{right: ({browse "http://www.stata-journal.com/article.html?article=st0207":SJ10-4: st0207})}
{right:also see:  {help skewnreg}{space 1}}
{right:{help skewtreg}{space 1}}
{right:{help mskewnreg}}
{right:{help mskewtreg}}
{hline}

{title:Title}

{p2colset 5 41 43 2}{...}
{p2col :{bf:skewed regression postestimation} {hline 2}}Postestimation tools 
for skewnreg, mskewnreg, skewtreg, and mskewtreg{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following postestimation command is of special interest after
{cmd:skewnreg}, {cmd:skewtreg}, {cmd:mskewnreg}, and {cmd:mskewtreg}: 

{synoptset 17}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt :{helpb skewrplot}}residual diagnostic plots{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{p_end}

{pstd}
The following standard postestimation commands are also available:

{synoptset 17}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estat
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt :{helpb skew postestimation##predict:predict}}predictions,
residuals, and other diagnostic measures{p_end}
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{title:Special-interest postestimation command}

{pstd}
{cmd:skewrplot} graphs a number of residual diagnostic plots; see 
{helpb skewrplot}.


{marker predict}{...}
{title:Syntax for predict}

{p 8 19 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]

{marker statistic}{...}
{synoptset 19 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{syntab:Main}
{synopt :{opt xb}}linear prediction; the default{p_end}
{synopt :{opt r:esiduals}}residuals{p_end}
{synopt :{opt stdp}}standard error of the linear prediction{p_end}
{synopt :{opt sc:ore}}score; first derivative of the log likelihood with
   respect to xb{p_end}
{synopt :{opt eq:uation}{cmd:(}{it:eqno}{cmd:)}}specify equation after {cmd:mskewnreg} or {cmd:mskewtreg}; default is 
the first equation, {cmd:equation(#1)}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}Statistics are available both in and out of sample; 
{cmd:type predict ... if e(sample) ...} if wanted only for the estimation
sample.{p_end}


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt xb}, the default, calculates the linear prediction.

{phang}
{opt residuals} calculates the residuals.

{phang}
{opt score} calculates the first derivative of the log likelihood with
respect to xb.

{phang}
{opt stdp} calculates the standard error of the linear prediction xb.  The 
standard error of the prediction is also referred to as the standard error 
of the fitted value.

{phang}
{cmd:equation(}{it:eqno}{cmd:)} is allowed only when you have previously 
fit {cmd:mskewnreg} or {cmd:mskewtreg}.  It specifies the equation to which 
you are referring.

{pmore}
{opt equation()} is filled in with one {it:eqno} for the {cmd:xb}, {cmd:stdp},
and {cmd:residuals} options.  {cmd:equation(#1)} means the calculation is to
be made for the first equation; {cmd:equation(#2)} means the second; and so
on.  You could also refer to the equations by their names:
{cmd:equation(lbm)} would refer to the equation named {cmd:lbm}, and
{cmd:equation(bmi)} would refer to the equation named {cmd:bmi}.

{pmore}
If you do not specify {opt equation()}, results are the same as if you
had specified {cmd:equation(#1)}.


{title:Author}

{pstd}Yulia V. Marchenko{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}
{pstd}ymarchenko@stata.com{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 10, number 4: {browse "http://www.stata-journal.com/article.html?article=st0207":st0207}

{p 4 14 2}
{space 3}Help:  {helpb skewrplot},
{helpb skewnreg},
{helpb skewtreg},
{helpb mskewnreg},
{helpb mskewtreg} (if installed)
{p_end}
