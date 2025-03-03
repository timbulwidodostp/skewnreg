*! version 1.0.0  31oct2010
program mskewn_p
	version 11.1
	syntax [anything] [if] [in] [,  xb stdp NOLABel SCore Residuals ///
					EQuation(string) 		///
					DMAHalanobis 		/// //undoc.
					cp			///
				    ]
	local popts `xb' `stdp' `nolabel' eq(`equation')
	if ("`e(cmd)'"!="mskewnreg") {
		error 301
	}
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

	opts_exclusive "`xb' `stdp' `residuals' `score' `dmahalanobis'"
	opts_exclusive "`cp' `dmahalanobis'"
	opts_exclusive "`cp' `score'"
	if ("`score'"!="" & `e(skew_dp)') {
		mata: _skew_post_err("predict", "postdp")
	}
	if ("`dmahalanobis'`score'"!="" & `e(skew_cp)') {
		mata: _skew_post_err("predict", "postcp")
	}

	marksample touse
	if (`"`equation'"'=="") {
		local depvar : word 1 of `e(depvar)'
	}
	else {
		if (substr(`"`equation'"',1,1)=="#") {
			local eqnum = substr(`"`equation'"',2,.)
			local depvar : word `eqnum' of `e(depvar)'
		}
		else {
			local depvar `equation'
		}
	}
	if ("`score'"!="") {
		tempname d
		mata: `d' = st_numscalar("e(k_dv)")
		cap noi ml score `vtype' `vname' if `touse', 		///
							eq(`equation') 	///
							userinfo(`d')
		mata: mata drop `d'
		if _rc {
			exit _rc
		}
		if ("`nolabel'"=="") {
			label variable `vname' "equation-level score from mskewnreg: `depvar'"
		}
		exit
	}
	if ("`cp'"=="") {
		if (!`e(skew_dp)' & !`e(skew_cp)') {
			tempname ehold
			_estimates hold `ehold', copy restore
			qui mskewnreg, postdp
		}
	}
	else if (!`e(skew_cp)') {
		tempname ehold
		_estimates hold `ehold', copy restore
		qui mskewnreg, postcp
	}
	if ("`cp'"!="" | `e(skew_cp)') {
		local vlabsuf , CP
		local Vname Sigma
	}
	// -xb- note
	if ("`xb'`residuals'`stdp'`dmahalanobis'"=="") {
		di as txt "(option {bf:xb} assumed; fitted values)"
	}
	if ("`dmahalanobis'"!="") {
		if ("`equation'"!="") {
			   "(option {bf:equation(`equation')} ignored)"
		}
		qui skew_mahalanobis `vtype' `vname', vmatname(e(Omega)) ///
								`nolabel'
		exit
	}
	if ("`residuals'"!="") {
		tempvar xb
		qui _predict double `xb' if `touse', xb eq(`equation')
		gen `vtype' `vname' = `depvar'-`xb' if `touse'
		local vlab "Residuals: `depvar'`vlabsuf'"
	}
	else {
		_predict `vtype' `vname' if `touse', `popts'
		local vlab : variable label `vname'
		local vlab `vlab': `depvar'`vlabsuf'
	}
	if ("`nolabel'"=="") {
		label variable `vname' `"`vlab'"'
	}
end
