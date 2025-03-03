*! version 1.0.0  31oct2010
program skewtreg, eclass
	version 11.1

	if replay() {
		if "`e(cmd)'" != "skewtreg" {
			error 301
		}
		Display `0'
		exit
	}
	tempname esthold
	qui _estimates hold `esthold', nullok
	cap noi Estimate `0'
	local rc = _rc
	eret local cmdline `"skewtreg `0'"'
	cap mata: mata drop $SKEW_userinfo
	global SKEW_userinfo
	if (`rc') {
		qui _estimates unhold `esthold'
	}
	exit `rc'
end

program Estimate, eclass
	syntax varlist(fv) [if] [in] [fw] [, 			///
					NOCONStant		///
					df(string)		///
					initdf(real 10)		///
					init(passthru) 		///
					Level(passthru)		///
					ESTMetric 		///
					POSTDP			///
					* 			/// //ml_opts
					]
	if ("`df'"!="") {
		cap confirm number `df'
		if _rc {
			di as err "{bf:df()} must be positive number"
			exit 198
		}
		if (`df'<1e-3) {
			di as err "{bf:df()} must be positive number"
			exit 198
		}
		local mlprog _skewt_lf_dp_fixed()
	}
	else {
		local mlprog _skewt_lf_dp()
		local dfeq /lndf
	}
	if (`initdf'<1e-3) {
		di as err "{bf:initdf()} must be positive number"
		exit 198
	}	

	if (`"`weight'"'!="") {
		local wgt [`weight' `exp']
	}
	_get_diopts diopts mlopts, `options'
	local diopts `level' `estmetric' `diopts'

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
		// map gamma to real line
		scalar `gamma' = ln((`gmax'+`gamma')/(`gmax'-`gamma'))
		mat `initmat' = (e(b), `gamma', `lnsigma')
		if ("`df'"=="") {
			mat `initmat' = (`initmat', ln(`initdf'))
		}
		local init init(`initmat', copy)
	}

	if ("`df'"!="") {	
		tempname uinfo
		global SKEW_userinfo `uinfo'
		mata: `uinfo' = `df'
	}
	ml model lf `mlprog' (`depvar':`depvar' = `xvars', `noconstant') ///
			  /alpha /lnomega `dfeq' if `touse' `wgt', 	 ///
			 maximize `init' `mlopts' 			 ///
			 userinfo($SKEW_userinfo)			 ///
			 title("Skew-t regression")
	eret scalar fixed_df = ("`df'"!="")
	tempname b
	if ("`postdp'"=="") {
		mata: _skewt_est2dp_b("`b'")
	}
	else {
		tempname V
		mata: _skewt_est2dp_bV("`b'","`V'")
	}
	local k = colsof(`b')
	if ("`df'"=="") {
		local k = `k'-1
		eret scalar df = exp(_b[lndf:_cons])
	}
	else {
		eret scalar df = `df'
	}
	eret scalar alpha = `b'[1, `k'-1]
	eret scalar omega = `b'[1, `k']
	if ("`postdp'"!="") { //post DP
		RepostE `b' `V'
	}

	eret local predict "skewt_p"
	eret local noconstant "`noconstant'"
	eret local xvars "`xvars'"
	eret local depvar "`depvar'"
	eret local cmdline `"skewtreg `0'"'
	eret local cmd "skewtreg"

	eret scalar k_aux = 3
	eret scalar skew_dp = ("`postdp'"!="")

	// LR test
	if ("`e(vcetype)'"!="Robust") {
		eret scalar ll_c = `ll_c'
		eret scalar chi2_c = 2*(e(ll)-e(ll_c))
		if ("`df'"=="") {
			eret scalar df_c = 2
			ereturn scalar p_c = 0.5*chi2tail(1,e(chi2_c))+ ///
					     0.5*chi2tail(2,e(chi2_c))
		}
		else {
			eret scalar df_c = 1
			ereturn scalar p_c = chi2tail(1,e(chi2_c))
		}
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
	syntax [, ESTMetric POSTDP Level(passthru) COEFLegend * ]
	_get_diopts tabopts eform, `options'
	if ("`eform'"!="") {
		di as err `"`eform' not allowed"'
		exit 198
	}
	if (`e(skew_dp)' & `"`estmetric'"'!="") {
		mata: _skew_post_err("skewtreg", "postdp")
	}
	if ("`coeflegend'"!="") {
		local estmetric estmetric
		di as txt "note: {bf:coeflegend} implies {bf:estmetric}"
	}
	if ("`estmetric'"!="") {
		ml display, `tabopts' `level' `coeflegend'
		DiLRT
		exit
	}
	if ("`postdp'"!="") { //post DP
		tempname b V
		mata: _skewt_est2dp_bV("`b'","`V'")
		RepostE `b' `V'
		mata: st_numscalar("e(skew_dp)", 1)
		exit
	}
	ml display, first plus `tabopts' `level' `coeflegend'
	_diparm alpha, label(alpha) `level' `coeflegend'
	_diparm __sep__
	if (`e(skew_dp)') {
		_diparm omega, label(omega) `level' `coeflegend'
		_diparm __sep__
		if (`e(fixed_df)') {
			_diparm __lab__, label(df) value(`e(df)')
		}
		else { 
			_diparm df df, label(df) f(@1) d(1 0) ci(log) 	///
					`level' `coeflegend'
		}
		_diparm __bot__
	}
	else {
		_diparm lnomega, label(omega) exp `level' `coeflegend'
		_diparm __sep__
		if (`e(fixed_df)') {
			_diparm __lab__, label(df) value(`e(df)')
		}
		else { 
			_diparm lndf, label(df) exp `level' `coeflegend'
		}
		_diparm __bot__
	}
	DiLRT
end

program DiLRT
	if ("`e(chi2_c)'"=="") exit

	if ((e(chi2_c) > 0.005) & (e(chi2_c)<1e5)) | (e(chi2_c)==0) {
		local fmt "%8.2f"
	}
	else    local fmt "%8.2e"
	if (`e(fixed_df)') {
		local k = length("`e(df_c)'")
		di as txt "LR test vs normal regression:" 		///
       	   	   as txt _col(`=39-`k'') "chi2(" as res e(df_c) 	///
	   	   as txt ") =" _col(48) as res `fmt' e(chi2_c) 	///
		   _col(59) as txt "Prob > chi2 =" 		///
		   _col(73) as res %6.4f e(p_c)
	}
	else {
		di as txt "LR test vs normal regression:" 		///
		   _col(32) "{help j_chibar##|_new:chibar2(1_2) =}" ///
		   _col(46) as res `fmt' e(chi2_c) ///
		   _col(55) as txt "Prob >= chibar2 = " ///
		   _col(73) as res %6.4f e(p_c)
	}
end
