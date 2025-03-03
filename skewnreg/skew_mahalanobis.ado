*! version 1.0.0  31oct2010
program skew_mahalanobis
	version 11.1
	if ("`e(cmd)'"=="") {
		error 301
	}
	syntax [anything] [if] [in] , VMATNAME(string) [ * NOLABel ]

	local predictopts `options'
	local k : word count `anything'
	if (`k'>3) {
		di as err "varlist not allowed"
		exit 101
	}
	if (`k'==2) {
		tokenize `anything'
		local vtype `1'
		local vname `2'
	}
	else {
		local vtype float
		local vname `anything'
	}
	confirm new variable `vname'
	marksample touse
	local d = colsof(`vmatname')
	forvalues i=1/`d' {
		tempvar r`i'
		qui `e(predict)' double `r`i'' if `touse', eq(#`i') resid ///
								`predictopts'
		local rnames `rnames' `r`i''
	}
	qui gen `vtype' `vname' = .
	mata: _compute("`rnames'","`touse'", "`vname'", "`vmatname'")
	if ("`nolabel'"=="") {
		label var `vname' "Mahalanobis distances"
	}
end

version 11.1
mata:
mata set matastrict on

void _compute(string scalar rnames, string scalar tname, 
	     string scalar vname, string scalar vmatname)
{
	real matrix R

	st_view(R=.,., tokens(rnames), tname)
	st_store(range(1,rows(R),1),vname,_mahalanobis(R,st_matrix(vmatname)))
}

real colvector _mahalanobis(real matrix X, real matrix Sigma)
{
	return( sqrt(rowsum((X*invsym(Sigma)):*X)) )
}
end
