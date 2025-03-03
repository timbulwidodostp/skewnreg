*! version 1.0.0  31oct2010
program mskewt_p
	version 11.1
	syntax [anything] [if] [in] [,  xb stdp NOLABel SCore Residuals ///
					EQuation(string) DMAHalanobis ]

	if ("`e(cmd)'"!="mskewtreg") {
		error 301
	}
	if ("`score'"!="" & `e(skew_dp)') {
		mata: _skew_post_err("predict", "postdp")
	}
	opts_exclusive "`xb' `stdp' `residuals' `score' `dmahalanobis'"
	local popts `xb' `stdp' `nolabel' eq(`equation')

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
		tempname uinfo
		mata: `uinfo' = st_numscalar("e(k_dv)")
		if (`e(fixed_df)') {
			mata: `uinfo' = (`uinfo', 1, st_numscalar("e(df)"))
		}
		else {
			mata: `uinfo' = (`uinfo', 0)
		}
		cap noi ml score `vtype' `vname' if `touse', 		///
							eq(`equation') 	///
							userinfo(`uinfo')
		mata: mata drop `uinfo'
		if _rc {
			exit _rc
		}
		if ("`nolabel'"=="") {
			label variable `vname' "equation-level score from mskewtreg: `depvar'"
		}
		exit
	}
	// -xb- note
	if ("`xb'`residuals'`stdp'`dmahalanobis'"=="") {
		di as txt "(option {bf:xb} assumed; fitted values)"
	}
	if ("`dmahalanobis'"!="") {
		if ("`equation'"!="") {
			di as txt "(option {bf:equation(`equation')} ignored)"
		}
		qui skew_mahalanobis `vtype' `vname', vmatname(e(Omega)) ///
								`nolabel'
		exit
	}
	if ("`residuals'"!="") {
		tempvar xb
		qui _predict double `xb' if `touse', xb eq(`equation')
		gen `vtype' `vname' = `depvar'-`xb' if `touse'
		local vlab "Residuals: `depvar'"
	}
	else {
		_predict `vtype' `vname' if `touse', `popts'
		local vlab : variable label `vname'
		local vlab `vlab': `depvar'
	}
	if ("`nolabel'"=="") {
		label variable `vname' `"`vlab'"'
	}
end
