*! version 1.0.0  31oct2010
program skewn_p
	version 11.1
	syntax [anything] [if] [in] [,  xb stdp NOLABel SCore Residuals ///
					RSCaled cp dp /* undoc */ ]
	if ("`e(cmd)'"!="skewnreg") {
		error 301
	}
	opts_exclusive "`xb' `stdp' `residuals' `score' `rscaled'"
	opts_exclusive "`cp' `dp'"
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
		if ("`cp'"!="") {
			di as txt "(option {bf:cp} is irrelevant: equation-level scores are the same in the CP and DP metrics)"
		}
		tempname omega alpha
		scalar `omega' = e(omega)
		scalar `alpha' = e(alpha)
		tempvar z mills
		qui predict double `z' if `touse', resid dp nolabel
		qui replace `z' = `z'/`omega' if `touse'
		qui gen double `mills' = normalden(`alpha'*`z')/	///
					 normal(`alpha'*`z') if `touse'
		gen `vtype' `vname' = `z'/`omega'-`alpha'*`mills'/`omega' ///
								if `touse'
		if ("`nolabel'"=="") {
			label variable `vname' "equation-level score from skewnreg"
		}
		exit
	}
	if (`e(skew_dp)' & "`cp'"!="") {
		mata: _skew_post_err("predict", "postdp")
	}
	// -xb- note
	if ("`xb'`residuals'`stdp'`rscaled'"=="") {
		di as txt "(option {bf:xb} assumed; fitted values)"
	}
	if ("`rscaled'"!="") {
		local residuals residuals
	}
	if ("`cp'"=="") { // DP is default
		if (!`e(skew_dp)') {
			tempname ehold
			_estimates hold `ehold', copy restore
			qui skewnreg, postdp
		}
		if "`rscaled'"!="" {
			tempname omega
			scalar `omega' = e(omega)
		}
		local vlabsuffix	
	}
	else {
		if "`rscaled'"!="" {
			tempname omega
			scalar `omega' = e(omega)
		}
		local vlabsuffix , CP
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
		label variable `vname' `"`vlab'`vlabsuffix'"'
	}
end
