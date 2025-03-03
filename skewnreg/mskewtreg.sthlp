{smcl}
{* *! version 1.0.0  31oct2010}{...}
{cmd:help mskewtreg}{right: ({browse "http://www.stata-journal.com/article.html?article=st0207":SJ10-4: st0207})}
{right:also see:  {help mskewtreg postestimation}}
{hline}

{title:Title}

{p2colset 5 18 22 2}{...}
{p2col :{hi:mskewtreg} {hline 2}}Multivariate skew-t regression{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt mskewtreg} {depvars} [{cmd:=} {indepvars}] {ifin} {weight}
   [{cmd:,} {it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt df(#)}}fix degrees-of-freedom parameter at {it:#}{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{opt col:linear}}keep collinear variables{p_end}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or
   {opt jack:knife}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt estm:etric}}display parameters in the estimation metric{p_end}
{synopt :{opt noshowom:ega}}suppress display of the covariance (or scale) 
matrix{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synopt :{opt postdp}}post DP estimates and their VCE to {cmd:e(b)} and {cmd:e(V)}{p_end}
{synopt :{it:{help mskewtreg##display_options:display_options}}}control spacing
           and display of omitted variables and base and empty cells{p_end}
{synopt :{it:{help mskewtreg##maximize_options:maximize_options}}}control the maximization process{p_end}
{synoptline}
{p2colreset}{...}
INCLUDE help fvvarlist
{p 4 6 2}
{cmd:fweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}
See {help mskewtreg postestimation} for features
available after estimation.{p_end}


{title:Description}

{pstd}
{cmd:mskewtreg} fits a model of continuous {it:depvars} on {it:indepvars} 
using multivariate skew-t linear regression.


{title:Options}

{phang}
{opt df(#)} specifies that the degrees-of-freedom parameter be fixed at
{it:#} during estimation.  This is equivalent to the constrained estimation
using the {cmd:constraints()} option when the degrees-of-freedom parameter
is set to {it:#}.

{phang}
{opt constraints(constraints)}, {opt collinear}; see
{helpb estimation options:[R] estimation options}. 

INCLUDE help vce_asymptall

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt estmetric} displays results in the estimation metric instead of the 
default centered parameters metric.  This option may be specified either at estimation or 
upon replay.

{phang}
{opt noshowomega} specifies that the display of the covariance (or scale)
matrix be suppressed.

{phang}
{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.

{phang}
{opt postdp} stores direct parameters (DP) estimates and their
variance-covariance estimator (VCE) in
{cmd:e(b)} and {cmd:e(V)}, respectively.

{phang}
{opt nocnsreport}; see {helpb estimation options##nocnsreport:[R] estimation options}.

{marker display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{marker maximize_options}{...}
{phang}
{it:maximize_options}:
{opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{cmd:{ul:no}}]{opt lo:g}, {opt tr:ace}, 
{opt grad:ient}, {opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance}; 
see {manhelp maximize R}.  Also, {opt init(ml_init_args)} can be specified; see 
{manhelp ml R:ml init}.

{marker remarks}{...}
{title:Remarks}

{pstd}
The {cmd:mskewtreg} command fits a multivariate skew-t linear regression, a
more flexible parametric alternative to the multivariate normal linear
regression accommodating asymmetry and heavy tails in the distribution of
residuals (or, equivalently, in the conditional distribution of {it:depvars}
given {it:indepvars}).  If typed without predictors {it:indepvars},
{cmd:mskewtreg} fits a multivariate skew-t distribution to {it:depvars}.

{pstd}
The multivariate skew-t distribution, ST_d(xi,Omega,alpha,nu), is
introduced by Azzalini and Capitanio (2003).  xi (Real^d) is a
d-dimensional location parameter, Omega is a positive-definite scale matrix,
alpha (Real^d) is a d-dimensional shape parameter, and nu>0 is
a degrees-of-freedom parameter.  When alpha=0, the multivariate
skew-t distribution becomes the multivariate Student's t distribution and
becomes the
multivariate normal distribution when in addition degrees of freedom is
infinite.  When the degrees of freedom tends to infinity, the multivariate
skew-t distribution reduces to the multivariate skew-normal distribution.

{pstd}
The multivariate skew-t regression is defined 
in the usual manner except the distribution of residuals is assumed to be 
ST_d(0,Omega,alpha,nu).

{pstd}
Parameters (xi,Omega,alpha,nu) are referred to as DP and form the so-called DP metric.  As in the 
univariate case, the problem of {help skewnreg##remarks_singular:singular} 
information matrix at alpha=0 seems to vanish for the 
multivariate skew-t models (Azzalini and Capitanio 2003; Azzalini and 
Genton 2008), but the sampling distributions of the maximum 
likelihood estimates can be far from the normal distribution in 
moderate samples.  The alternative centered parameterization for the 
multivariate skew-t model is currently under development in the 
literature.

{pstd}
{cmd:mskewtreg} estimates model parameters in the metric described by 
Azzalini and Capitanio (2003) in section 5.1.  
The estimation metric is (eta,rho,vech[A],ln[nu]), where 
{bind:eta_i=alpha_i/omega_i}, omega_i=sqrt(Omega_ii), 
{bind:i=1,...,d}, and A and rho are such that 
{bind:inv(Omega)=A*diag{exp(-2*rho)}*A'}, where A is a lower 
triangular matrix with diagonal terms equal to one.  The results are 
displayed in the DP metric and, if desired, can be posted to {cmd:e(b)} 
and {cmd:e(V)} by using the {cmd:postdp} option.

{pstd}
For a thorough review of multivariate skew-t and other skewed 
distributions, see the book edited by Genton (2004) and the review by 
Azzalini (2005).  For more detail about the command and examples, see 
Marchenko and Genton (2010a).

{pstd}
For data with positive support, such as income or precipitation data, the 
multivariate log-skew-t distribution (or regression) can be considered.  
Similarly to the multivariate lognormal distribution, the multivariate 
log-skew-t distribution is the distribution of the exponentiated 
(component-wise) skew-t random vector.  Equivalently, 
the component-wise log of a log-skew-t random vector follows a 
multivariate skew-t distribution.  So to fit a multivariate 
log-skew-t model, it is sufficient to fit a multivariate skew-t model 
to the log-transformed dependent variables.  For more 
detail, see Marchenko and Genton (2010b) and the references given therein.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use ais}{p_end}

{pstd}Fit a bivariate skew-t distribution to {cmd:lbm} and 
{cmd:bmi}{p_end}
{phang2}{cmd:. mskewtreg lbm bmi}{p_end}

{pstd}Redisplay results in the DP metric{p_end}
{phang2}{cmd:. mskewtreg, postdp}{p_end}

{pstd}Fit a bivariate skew-t regression to {cmd:lbm} and {cmd:bmi} 
adjusted for gender{p_end}
{phang2}{cmd:. mskewtreg lbm bmi = female}{p_end}

{pstd}Model the distribution of precipitation in June, July, and August 
jointly using a trivariate log-skew-t distribution{p_end}
{phang2}{cmd:. use precip07_national}{p_end}
{phang2}{cmd:. generate lnprecip = ln(precip)}{p_end}
{phang2}{cmd:. reshape wide precip lnprecip, i(year) j(month)}{p_end}
{phang2}{cmd:. mskewtreg lnprecip6 lnprecip7 lnprecip8}{p_end}


{title:Saved results}

{pstd}
{cmd:mskewtreg} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in model Wald test{p_end}
{synopt:{cmd:e(k_aux)}}number of auxiliary parameters{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_autoCns)}}number of base, empty, and omitted constraints{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}significance{p_end}
{synopt:{cmd:e(ll_c)}}log likelihood, comparison model{p_end}
{synopt:{cmd:e(chi2_c)}}chi-squared, comparison model{p_end}
{synopt:{cmd:e(df_c)}}degrees of freedom, comparison model{p_end}
{synopt:{cmd:e(p_c)}}p-value, comparison model{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(skew_dp)}}{cmd:1} if DP estimates and their VCE are posted to {cmd:e(b)} and {cmd:e(V)}, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(fixed_df)}}{cmd:1} if {cmd:df()} specified, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(df)}}degrees of freedom{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mskewtreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(xvars)}}names of independent variables{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald} model chi-squared test{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(singularHmethod)}}{cmd:m-marquardt} or {cmd:hybrid}; method used
                          when Hessian is singular{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(asbalanced)}}factor variables {cmd:fvset} as {cmd:asbalanced}{p_end}
{synopt:{cmd:e(asobserved)}}factor variables {cmd:fvset} as {cmd:asobserved}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(b0)}}initial values of model parameters in the estimation metric{p_end}
{synopt:{cmd:e(Omega)}}scale matrix{p_end}
{synopt:{cmd:e(alpha)}}shape parameters{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
Azzalini, A. 2005.  The skew-normal distribution and related multivariate 
families (with discussion by Marc G. Genton and a rejoinder by the author).  
{it:Scandinavian Journal of Statistics} 32: 159-200.

{phang}
Azzalini, A., and A. Capitanio. 2003.  Distributions generated by perturbation 
of symmetry with emphasis on a multivariate skew-t distribution.  
{it:Journal of the Royal Statistical Society, Series B} 65: 367-389.

{phang}
Azzalini, A., and M. G. Genton. 2008.  Robust likelihood methods based on 
the skew-t and related distributions.  
{it:International Statistical Review} 76: 106-129.

{phang}
Genton, M. G., ed. 2004.  
{it:Skew-Elliptical Distributions and Their Applications: A Journey Beyond Normality}.  Boca Raton, FL: Chapman & Hall/CRC.

{phang}
Marchenko, Y. V., and M. G. Genton. 2010a.  
{browse "http://www.stata-journal.com/article.html?article=st0207":A suite of commands for fitting the skew-normal and skew-t models}.
{it:Stata Journal} 10: 507-539.

{phang}
-----. 2010b.  Multivariate log-skew-elliptical 
distributions with applications to precipitation data.  {it:Environmetrics} 
21: 318-340.


{title:Author}

{pstd}Yulia V. Marchenko{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}
{pstd}ymarchenko@stata.com{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 10, number 4: {browse "http://www.stata-journal.com/article.html?article=st0207":st0207}

{p 4 14 2}
{space 3}Help:  {helpb mskewtreg postestimation},
{helpb skewnreg},
{helpb skewtreg},
{helpb mskewnreg},
{manhelp regress R},
{manhelp rreg R} (if installed)
{p_end}
