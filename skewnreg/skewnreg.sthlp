{smcl}
{* *! version 1.0.0  31oct2010}{...}
{cmd:help skewnreg}{right: ({browse "http://www.stata-journal.com/article.html?article=st0207":SJ10-4: st0207})}
{right:also see:  {help skewnreg postestimation}}
{hline}

{title:Title}

{p2colset 5 17 22 2}{...}
{p2col :{hi:skewnreg} {hline 2}}Skew-normal regression{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt skewnreg} {depvar} [{indepvars}] {ifin} {weight}
   [{cmd:,} {it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt:{opt col:linear}}keep collinear variables{p_end}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or
   {opt jack:knife}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt dpm:etric}}display parameters in the DP metric{p_end}
{synopt :{opt estm:etric}}display parameters in the estimation metric{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synopt :{opt postdp}}post DP estimates and their VCE to {cmd:e(b)} and {cmd:e(V)}{p_end}
{synopt :{it:{help skewnreg##display_options:display_options}}}control spacing
           and display of omitted variables and base and empty cells{p_end}
{synopt :{it:{help skewnreg##maximize_options:maximize_options}}}control the maximization process{p_end}
{synoptline}
{p2colreset}{...}
INCLUDE help fvvarlist
{p 4 6 2}
{cmd:fweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}
See {help skewnreg postestimation} for features
available after estimation.{p_end}


{title:Description}

{pstd}
{cmd:skewnreg} fits a model of continuous {it:depvar} on {it:indepvars} 
using skew-normal linear regression.


{title:Options}

{phang}
{opt constraints(constraints)}, {opt collinear}; see
{helpb estimation options:[R] estimation options}.

INCLUDE help vce_asymptall

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt dpmetric} displays results in the direct parameters (DP) metric instead
of the default centered parameters (CP) metric.  This option may be specified
either at estimation or upon replay.

{phang}
{opt estmetric} displays results in the estimation metric instead of the 
default CP metric.  This option may be specified either at estimation or 
upon replay.

{phang}
{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.

{phang}
{opt postdp} stores DP estimates and their variance-covariance estimator (VCE) in {cmd:e(b)} and {cmd:e(V)}, respectively.

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
The {cmd:skewnreg} command fits a skew-normal linear regression, a more
flexible parametric alternative to the normal linear regression accommodating
asymmetry in the distribution of residuals (or, equivalently, in the
conditional distribution of {it:depvar} given {it:indepvars}).  If typed
without predictors {it:indepvars}, {cmd:skewnreg} fits a skew-normal
distribution to {it:depvar}.

{pstd}
The skew-normal distribution, SN(xi,omega^2,alpha), is introduced by 
Azzalini (1985) and has the following form:

		f(y) = 2*phi(z)*Phi(alpha*z)/omega,  y is Real

{pstd}
where z = (y-xi)/omega, xi (Real) is a location parameter, omega>0 is a scale
parameter, alpha (Real) is a shape parameter, and phi() and Phi() are the
standard normal probability density function and the cumulative distribution
function, respectively.  When alpha>0, the skew-normal distribution is skewed
to the right; when alpha<0, the distribution is skewed to the left; and when
alpha=0, the distribution is symmetric (and is, in fact, normal).

{pstd}
The skew-normal regression is defined in the usual manner except the 
distribution of residuals is assumed to be SN(0,omega^2,alpha).  It is 
worth noting that the mean of residuals is a function of omega and 
alpha and is zero only when alpha=0.

{marker remarks_singular}{...}
{pstd}
Parameters (xi,omega,alpha) are referred to as DP and form
the so-called DP metric.  As pointed out by Azzalini (1985) and
Azzalini and Capitanio (1999), among others, for skew-normal models the DP
metric has an unfortunate property of having singular information matrix at
alpha=0, making it difficult to use standard likelihood theory to test an
important hypothesis of normality H0: alpha=0.  Also, in moderate samples,
the sampling distributions of the maximum-likelihood estimates of the direct
parameters can be far from normal and can even be bimodal.  To circumvent this
issue, Azzalini (1985) suggested to use an alternative parameterization, the centered
parameterization (mu,sigma,gamma), where mu (Real) is the mean, sigma>0
is the standard deviation, and gamma is the Pearson's index of skewness.  The
singularity issue does not arise at H0: gamma=0, so, for example, the
traditional Wald test can be used to test the hypothesis of normality in the
CP metric.  Also, the sampling distributions of the maximum-likelihood
estimates of the centered parameters are more symmetric and closer to normal
even in moderate samples.  The CP metric is thus recommended for inference.
It is worth noting, however, that although alpha spans the whole real line,
the range of gamma is restricted to approximately (-0.9953, 0.9953).  Provided
that gamma is within its admissible range, there is a one-to-one correspondence
between the CP and DP metrics. So once the CP estimates and their VCE are
obtained, the DP estimates can be obtained via transformation, and vice versa.
See Azzalini (1985), Azzalini and Capitanio (1999), and Arellano-Valle and
Azzalini (2008) for details.

{pstd}
{cmd:skewnreg} implements the skew-normal regression as described by Azzalini
and Capitanio (1999) in section 6.2.  {cmd:skewnreg} estimates all model
parameters other than the standard deviation sigma in the CP metric.  The
standard deviation is estimated in the log metric.  By default, {cmd:skewnreg}
displays results in the CP metric.  The {cmd:dpmetric} option can be used to
redisplay results in the DP metric.  If needed, the {cmd:postdp} option can be
used to post the DP estimates and their VCE to {cmd:e(b)} and {cmd:e(V)},
respectively.

{pstd}
For a thorough review of skew-normal and other skewed distributions, see the 
book edited by Genton (2004) and the review by Azzalini (2005).  For more 
detail about the command and examples, see Marchenko and Genton (2010a).

{pstd}
For data with positive support, such as income or precipitation data, the 
log-skew-normal distribution (or regression) can be considered.  Similar to 
the lognormal distribution, the log-skew-normal distribution is the 
distribution of the exponentiated skew-normal random variate.  Equivalently, 
the log of the log-skew-normal random variate is a skew-normal random 
variate.  So to fit a log-skew-normal model, it is sufficient to fit a 
skew-normal model to the log-transformed variable of interest.  For more 
detail, see Marchenko and Genton (2010b) and the references given therein.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use ais}{p_end}

{pstd}Fit a skew-normal distribution to {cmd:bmi}{p_end}
{phang2}{cmd:. skewnreg bmi}{p_end}

{pstd}Redisplay results in the DP metric{p_end}
{phang2}{cmd:. skewnreg, dpmetric}{p_end}

{pstd}Fit a skew-normal regression to {cmd:bmi} adjusted for 
{cmd:bfat} and {cmd:ssf}{p_end}
{phang2}{cmd:. skewnreg bmi bfat ssf}{p_end}

{pstd}Adjust the regression line for possible difference due to gender{p_end}
{phang2}{cmd:. skewnreg bmi i.female##c.(bfat ssf)}{p_end}

{pstd}Fit a log-skew-normal regression to precipitation adjusting for 
month{p_end}
{phang2}{cmd:. use precip07_national}{p_end}
{phang2}{cmd:. generate lnprecip = ln(precip)}{p_end}
{phang2}{cmd:. skewnreg lnprecip i.month}{p_end}


{title:Saved results}

{pstd}
{cmd:skewnreg} saves the following in {cmd:e()}:

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
{synopt:{cmd:e(alpha)}}shape parameter{p_end}
{synopt:{cmd:e(omega)}}scale parameter{p_end}
{synopt:{cmd:e(gamma)}}skewness index{p_end}
{synopt:{cmd:e(sigma)}}standard deviation{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:skewnreg}{p_end}
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
Arellano-Valle, R. B., and A. Azzalini. 2008.  The centred parametrization 
for the multivariate skew-normal distribution.  
{it:Journal of Multivariate Analysis} 99: 1362-1382.

{phang}
Azzalini, A. 1985.  A class of distributions which includes the normal ones.  
{it:Scandinavian Journal of Statistics} 12: 171-178.

{phang}
-----. 2005.  The skew-normal distribution and related multivariate 
families (with discussion by Marc G. Genton and a rejoinder by the author).  
{it:Scandinavian Journal of Statistics} 32: 159-200.

{phang}
Azzalini, A., and A. Capitanio. 1999.  Statistical applications of the 
multivariate skew-normal distribution.  
{it:Journal of the Royal Statistical Society, Series B} 61: 579-602.

{phang}
Genton, M. G., ed. 2004.  
{it:Skew-Elliptical Distributions and Their Applications: A Journey Beyond Normality}. Boca Raton, FL: Chapman & Hall/CRC.

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

{p 4 14 2}{space 3}Help:  {helpb skewnreg postestimation},
{helpb skewtreg},
{helpb mskewnreg},
{helpb mskewtreg},
{manhelp regress R},
{manhelp rreg R} (if installed)
{p_end}
