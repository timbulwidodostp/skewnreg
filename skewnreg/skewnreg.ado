*! version 1.0.0  31oct2010
program skewnreg, eclass
	version 11.1

	if replay() {
		if ("`e(cmd)'"!="skewnreg") {
			error 301
		}
		Display `0'
		exit
	}

	syntax varlist(fv) [if] [in] [fw] [, 			///
					INIT(passthru) 		///
					Level(passthru)		///
					DPMetric 		///
					ESTMetric 		///
					POSTDP			///
					* 			/// //ml_opts
					NOCONStant		/// //undoc.
					]
	if (`"`weight'"'!="") {
		local wgt [`weight' `exp']
	}

	_get_diopts diopts mlopts, `options'
	local diopts `level' `estmetric' `dpmetric' `diopts'

	marksample touse
	gettoken depvar xvars : varlist

	// normal regression
	qui regress `depvar' `xvars' if `touse' `wgt', `noconstant'
	tempname ll_c
	scalar `ll_c' = e(ll)
	if `"`init'"' == "" { // default initial values
		tempvar resid
		tempname initmat gmax gamma lnsigma
		scalar `lnsigma' = ln(e(rmse)*sqrt(e(df_r)/e(N)))
		qui _predict double `resid' if `touse', resid
		qui summ `resid' if `touse' `wgt', detail
		scalar `gamma' = r(skewness)
		// ensures that values of gamma admissible
		scalar `gmax' = 0.5*(4-_pi)*(2/(_pi-2))^1.5 - epsdouble()^(0.5)
		if (abs(`gamma')>`gmax') {
			scalar `gamma' = 0.95*`gmax'*sign(`gamma')
		}
		mat `initmat' = (e(b), `gamma', `lnsigma')
		local init init(`initmat', copy)
	}
	
	ml model lf _skewn_lf_cp() 					///
			(`depvar':`depvar' = `xvars', `noconstant') 	///
			  /gamma /lnsigma if `touse' `wgt', 		///
			 maximize `init' `mlopts' 			///
			 title("Skew-normal regression")
	if ("`postdp'"!="") { //post DP
		tempname b V
		mata: _skewn_est2dp_bV("`b'", "`V'")
	}
	else {
		tempname b
		mata: _skewn_est2dp_b("`b'")
	}
	eret local predict "skewn_p"
	eret local noconstant "`noconstant'"
	eret local xvars "`xvars'"
	eret local depvar "`depvar'"
	eret local cmdline `"skewnreg `0'"'
	eret local cmd "skewnreg"

	eret scalar k_aux = 2
	eret scalar skew_dp = ("`postdp'"!="")
	local k = colsof(`b')
	eret scalar alpha = `b'[1, `k'-1]
	eret scalar omega = `b'[1, `k']
	tempname bcp
	mat `bcp' = e(b)
	eret scalar gamma = `bcp'[1, `k'-1]
	eret scalar sigma = exp(`bcp'[1, `k'])

	if ("`postdp'"!="") { //post DP
		RepostE `b' `V'
	}

	// LR test
	if ("`e(vcetype)'"!="Robust") {
		eret scalar ll_c = `ll_c'
		eret scalar df_c = 1
		eret scalar chi2_c = 2*(e(ll)-e(ll_c))
		ereturn scalar p_c = chi2tail(e(df_c),e(chi2_c))
	}

	if (!`c(noisily)') exit
	Display , `diopts'

end

program RepostE, eclass
	args b V
	eret repost b = `b' V = `V', rename
	_ms_build_info e(b)
end

program Display
	syntax [, ESTMetric DPMetric POSTDP Level(passthru) COEFLegend * ]

	_get_diopts tabopts eform, `options'
	if ("`eform'"!="") {
		di as err `"`eform' not allowed"'
		exit 198
	}
	local tabopts tabopts(`tabopts')
	local diopts `level' `coeflegend'
	if ("`coeflegend'"!="") {
		local estmetric estmetric
		di as txt "note: {bf:coeflegend} implies {bf:estmetric}"
	}
	if (`e(skew_dp)' & `"`estmetric'"'!="") {
		mata: _skew_post_err("skewnreg","postdp")
	}
	if (`e(skew_dp)') {
		DiTable alpha omega, dpopts(f(@) d(1)) `tabopts' `diopts'
		DiLRT
		exit
	}
	if (`"`estmetric'"'!="") {
		DiTable gamma lnsigma, `tabopts' `diopts'
		DiLRT
		exit
	}
	if ("`postdp'`dpmetric'"=="") {
		DiTable gamma lnsigma, labels(gamma sigma) dp2(exp) 	///
				`tabopts' `diopts'
		DiLRT
		DiGammaNote
		exit
	}

	tempname ehold
	_estimates hold `ehold', copy restore
	tempname bdp Vdp bdp_e Vdp_e
	mata: _skewn_est2dp_bV("`bdp'", "`Vdp'")
	RepostE `bdp' `Vdp'
	if ("`postdp'"!="") {
		mata: st_numscalar("e(skew_dp)",1)
		_estimates unhold `ehold', not
		_estimates drop `ehold'
		exit
	}
	/* use f() and d() to suppress sig. tests */
	DiTable alpha omega, labels(alpha omega) dp1(f(@) d(1)) omegacilog ///
				`tabopts' `diopts'
	DiLRT
	//Note: CIs for 'sigma' and 'omega' are based on exponentiating
	//      the end points of normal-based CIs in the log metric
end

program DiTable
	syntax namelist(name=eqnames min=2 max=2), [ labels(string) 	///
						     dpopts(string)	///
						     tabopts(string)	///
						     dp1(string) 	///
						     dp2(string)	///
						     omegacilog		///
							 * 		///
						   ]
	ml display, first plus `tabopts' `options'
	gettoken eq eqnames : eqnames
	gettoken lab labels : labels
	if ("`lab'"=="") {
		local lab `eq'
	}
	_diparm `eq', label(`lab') `dp1' `dpopts' `options'
	if ("`lab'"=="gamma") {
		ChkRanges r(est) r(ub) r(lb)
	}
	_diparm __sep__
	gettoken eq eqnames : eqnames
	gettoken lab labels : labels
	if ("`lab'"=="") {
		local lab `eq'
	}
	if ("`omegacilog'"=="") {
		_diparm `eq', label(`lab') `dp2' `dpopts' `options'
	}
	else {
		_diparm `eq' `eq', label(`lab') f(@1) d(1 0) ci(log) 	///
					`dpopts' `options'
	}
	_diparm __bot__
end

program ChkRanges
	args est lb ub
	
	tempname gmax max
	scalar `gmax' = 0.5*(4-_pi)*(2/(_pi-2))^1.5
	scalar `max' = max(abs(`est'), abs(`lb'),abs(`ub'))
	if (`max'>`gmax') {
		mata: st_numscalar("e(gamma_bnd)", 1)
	}
end

program DiGammaNote
	if ("`e(gamma_bnd)'"!="1") exit

	if ("`e(chi2_c)'"!="") {
		di
	}
	local r = string(0.5*(4-_pi)*(2/(_pi-2))^1.5,"%5.4f")
	di as txt "Note: {bf:gamma} (or its CI) is outside its " ///
		"allowable range (-`r',`r')."
end

program DiLRT
	if ("`e(chi2_c)'"=="") exit

	if ((e(chi2_c) > 0.005) & (e(chi2_c)<1e5)) | (e(chi2_c)==0) {
		local fmt "%8.2f"
	}
	else    local fmt "%8.2e"
	local k = length("`e(df_c)'")
	di as txt "LR test vs normal regression:" 			///
       	   as txt _col(`=39-`k'') "chi2(" as res e(df_c) 		///
	   as txt ") =" _col(48) as res `fmt' e(chi2_c) 		///
		_col(59) as txt "Prob > chi2 =" 			///
		_col(73) as res %6.4f e(p_c)
end
