*! version 1.0.0  31oct2010
program skewt_p
	version 11.1
	syntax [anything] [if] [in] [,  xb stdp NOLABel SCore Residuals ///
					RSCaled ]
	if ("`e(cmd)'"!="skewtreg") {
		error 301
	}
	opts_exclusive "`xb' `stdp' `residuals' `score' `rscaled'"
	local popts `xb' `stdp' `nolabel'

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
	if ("`score'"!="") {
		ml score `vtype' `vname' if `touse'
		if ("`nolabel'"=="") {
			label variable `vname' "equation-level score from skewtreg"
		}
		exit
	}
	// -xb- note
	if ("`xb'`residuals'`stdp'`rscaled'"=="") {
		di as txt "(option {bf:xb} assumed; fitted values)"
	}
	if ("`rscaled'"!="") {
		local residuals residuals
	}
	if (!`e(skew_dp)') {
		tempname ehold
		_estimates hold `ehold', copy restore
		qui skewtreg, postdp
	}
	if "`rscaled'"!="" {
		tempname omega
		scalar `omega' = _b[omega:_cons]
	}
	if ("`residuals'"!="") {
		tempvar xb
		qui _predict double `xb' if `touse', xb
		gen `vtype' `vname' = `e(depvar)'-`xb' if `touse'
		if ("`rscaled'"!="") {
			qui replace `vname' = `vname'/`omega'
			local vlab "Scaled residuals"
		}
		else {
			local vlab "Residuals"
		}
	}
	else {
		_predict `vtype' `vname' if `touse', `popts'
		local vlab : variable label `vname'
	}
	if ("`nolabel'"=="") {
		label variable `vname' `"`vlab'"'
	}
end
