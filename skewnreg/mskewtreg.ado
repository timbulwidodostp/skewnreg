*! version 1.0.0  31oct2010
program mskewtreg, eclass
	version 11.1

	if replay() {
		if "`e(cmd)'" != "mskewtreg" {
			error 301
		}
		Display `0'
		exit
	}
	tempname esthold
	qui _estimates hold `esthold', nullok
	cap noi Estimate `0'
	local rc = _rc
	eret local cmdline `"mskewtreg `0'"'
	cap mata: mata drop $SKEW_userinfo
	global SKEW_userinfo
	if (`rc') {
		qui _estimates unhold `esthold'
	}
	exit `rc'
end

program Estimate, eclass

	_parse comma 0 rhs : 0
	syntax [anything(equalok)] [if] [in] [fw]
	if "`weight'" != "" {
		local wgt "[`weight'`exp']"
	}

	gettoken depvars xvars : anything, parse("=")
	unab depvars : `depvars'
	cap confirm numeric variable `depvars'
	if (_rc) {
		di as err "dependent variables must be numeric"
		exit 198
	}
	gettoken eq xvars : xvars, parse("=")

	local 0 `xvars' `if' `in' `wgt' `rhs'
	syntax [varlist(default=none numeric fv)] [if] [in] [fw] ///
			[, 					///
					df(string)		///
					initdf(real 8)		///
					init(passthru) 		///
					Level(passthru)		///
					ESTMetric		///
					noSHOWOMega		///
					POSTDP			///
					initdp(string)		/// //undoc.
					MLMETHOD(string)	///
					NOCONStant		///
					* 			///
			]
	opts_exclusive "`showomega' `estmetric'"
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
	}
	if (`initdf'<1e-3) {
		di as err "{bf:initdf()} must be positive number"
		exit 198
	}	
	if (!inlist("`mlmethod'","","lf0","lf1","d0","d1",	///
			"lf1debug","d1debug")) {
		di as err "{bf:mlmethod(`mlmethod')} not allowed"
		exit 198
	}

	_get_diopts diopts mlopts, `options'
	local diopts `level' `estmetric' `showomega' `diopts'

	marksample touse
	markout `touse' `depvars'
	local xvars `varlist'

	if "`weight'" != "" {
		local wgt "[`weight'`exp']"
	}
	else if (substr("`mlmethod'",1,1)=="d") {
		local wgt [fw=1]
	}

	// MVN regression
	local d : word count `depvars'
	qui reg3 (`depvars' = `xvars', `noconstant') if `touse' `wgt'
	mata: st_local("k", strofreal(cols(st_matrix("e(b)"))))
	local k = `k'/`d'
	tempname ll_c
	scalar `ll_c' = e(ll)

	if `"`init'`initdp'"' == "" { // default initial values
		tempname initmat v
		mata: st_matrix("`v'",vech(st_matrix("e(Sigma)"))')
		mat `initmat' = (e(b), J(1,`d',0), `v', `initdf')
		mata: 	///
		  _mskewt_dp2est_b("`initmat'",`d',`k',("`df'"!=""),"`initmat'")
		local init init(`initmat', copy)
	}
	else if ("`initdp'"!="") {
		if ("`init'"!="") {
			di as err "only one of {bf:init()} or {bf:initdp()} is allowed"
			exit 198
		}
		cap confirm matrix `initdp'
		if (_rc) {
			tempname dp0
			mat `dp0' = `initdp'
			local np = colsof(`dp0')
			local nparms = `d'*`k'+`d'+`d'*(`d'+1)/2+("`df'"=="")
			if (`np'!=`nparms') {
				di as err "{bf:initdp()}: matrix must be dimension `nparms'"
				exit 198
			}
		}
		tempname initmat
		mata: _mskewt_dp2est_b("`dp0'",`d',`k',("`df'"!=""),"`initmat'")
		local init init(`initmat', copy)
	}

	// build ml equations
	tokenize `depvars'
	forvalues i=1/`d' {
		local ml_eq `ml_eq' (`"``i''"': ``i'' = `xvars', `noconstant')
		local eta_eq `eta_eq' /eta`i'
		local rho_eq `rho_eq' /rho`i'
		forvalues j=`=`i'+1'/`d' {
			local A_eq `A_eq' /a`i'`j'
		}
	}
	local ml_eq `ml_eq' `eta_eq' `rho_eq' `A_eq'
	if ("`df'"=="") {
		local ml_eq `ml_eq' /lndf
	}
	if ("`mlmethod'"=="") {
		local mlmethod lf1
		local ml_prog _mskewt_lf1_dp()
	}
	else if (substr("`mlmethod'",1,1)=="l") {
		local ml_prog _mskewt_lf1_dp()
	}
	else if (substr("`mlmethod'",1,1)=="d") {
		local ml_prog _mskewt_d1_dp()
	}
	tempname uinfo
	global SKEW_userinfo `uinfo'
	mata: `uinfo' = `d'
	if ("`df'"!="") {
		mata: `uinfo' = (`uinfo', 1, `df')
	}
	else {
		mata: `uinfo' = (`uinfo', 0)
	}
	ml model `mlmethod' `ml_prog' `ml_eq' `wgt' if `touse', 	///
			maximize 					///
			`init' 						///
			waldtest(`d')					///
			 title("Multivariate skew-t regression")	///
			userinfo($SKEW_userinfo)			///
			`options'
	// ereturn results
	if ("`df'"=="") {
		eret scalar fixed_df = 0
		eret scalar df = exp(_b[lndf:_cons])
	}
	else {
		eret scalar fixed_df = 1
		eret scalar df = `df'
	}
	eret scalar skew_dp = ("`postdp'"!="")
	eret local noconstant "`noconstant'"
	eret local cmd "mskewtreg"
	eret local predict "mskewt_p"
	eret local xvars "`xvars'"
	if ("`weight'"=="") {
		eret local wtype ""
		eret local wexp ""
	}
	eret scalar k_aux = `d'+`d'*(`d'+1)/2+("`df'"=="")
	/* matrices */
	local coleq : coleq e(b)
	local colname : colname e(b)
	if ("`initmat'"!="") {
		mat coleq `initmat' = `coleq'
		mat colname `initmat' = `colname'
		eret mat b0 = `initmat'
	}
	tempname b
	if ("`postdp'"=="") {
		mata: _mskewt_est2dp_b("`b'")
	}
	else {
		tempname V
		mata: _mskewt_est2dp_bV("`b'","`V'")
	}
	// store Omega, alpha
	tempname Omega alpha
	mat `Omega' = `b'[1,"Omega11:".."Omega`d'`d':"]
	mata: st_matrix("`Omega'", invvech(st_matrix("`Omega'")'))
	mat colname `Omega' = `depvars'
	mat rowname `Omega' = `depvars'
	mat `alpha' = `b'[1,"alpha1:".."alpha`d':"]
	mat coleq `alpha' = ""
	mat colname `alpha' = `depvars'
	ereturn matrix Omega = `Omega'
	ereturn matrix alpha = `alpha'

	if ("`postdp'"!="") { //post DP
		RepostE `b' `V'
	}
	//LR test
	if ("`e(vcetype)'"!="Robust") {
		eret scalar ll_c = `ll_c'
		eret scalar chi2_c = 2*(e(ll)-e(ll_c))
		eret scalar df_c = `d'+("`df'"=="")
		if ("`df'"=="") {
			ereturn scalar p_c = 0.5*chi2tail(`d',e(chi2_c))+ ///
					     0.5*chi2tail(`d'+1,e(chi2_c))
		}
		else {
			ereturn scalar p_c = chi2tail(e(df_c),e(chi2_c))
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

	syntax [, ESTMetric POSTDP Level(passthru) noSHOWOMega COEFLegend * ]

	opts_exclusive "`showomega' `estmetric'"
	_get_diopts tabopts eform, `options'
	if ("`eform'"!="") {
		di as err `"`eform' not allowed"'
		exit 198
	}
	if ("`coeflegend'"!="") {
		local estmetric estmetric
		di as txt "note: {bf:coeflegend} implies {bf:estmetric}"
	}
	if (`e(skew_dp)' & `"`estmetric'"'!="") {
		mata: _skew_post_err("mskewtreg", "postdp")
	}
	if (`e(skew_dp)' & "`postdp'"!="") {
		exit
	}
	if ("`estmetric'"!="") {
		ml display, `tabopts' `level' `coeflegend'
		DiLRT
		exit
	}
	if (!`e(skew_dp)') {
		tempname ehold
		_estimates hold `ehold', copy restore
		tempname b V
		mata: _mskewt_est2dp_bV("`b'","`V'")
		RepostE `b' `V'
		if ("`postdp'"!="") { //post DP
			_estimates unhold `ehold', not
			mata: st_numscalar("e(skew_dp)", 1)
			exit
		}
	}
	local d = e(k_dv)
	ml display, neq(`d') plus `tabopts' `level' `coeflegend'
	_diparm __lab__, label(alpha) eqlabel
	forvalues i=1/`d' {
		_diparm alpha`i', label(`i') `level' `coeflegend'
	}
	if ("`showomega'"=="") {
		_diparm __sep__
		_diparm __lab__, label(Omega) eqlabel
		forvalues i=1/`d' {
			_diparm Omega`i'`i' Omega`i'`i', label(`i' `i') ///
				     f(@1) d(1 0) ci(log) `level' `coeflegend'
			forvalues j=`=`i'+1'/`d' {
				_diparm Omega`i'`j', label(`i' `j') ///
					f(@) d(1) `level' `coeflegend'
			}
		}
		_diparm __sep__
	}
	if (!`e(fixed_df)') {
		_diparm df df, label(df) `level' f(@1) d(1 0) ci(log)
	}
	else {
		_diparm __lab__, label(df) value(`e(df)')
	}
	_diparm __bot__
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
		di as txt "LR test vs MVN regression:" 		///
       	   	   as txt _col(`=39-`k'') "chi2(" as res e(df_c) 	///
	   	   as txt ") =" _col(48) as res `fmt' e(chi2_c) 	///
		   _col(59) as txt "Prob > chi2 =" 		///
		   _col(73) as res %6.4f e(p_c)
	}
	else {
		local d = e(k_dv)
		di as txt "LR test vs MVN regression:" 		///
		   _col(32) "{help j_chibar##|_new:chibar2(`d'_`=`d'+1') =}" ///
		   _col(46) as res `fmt' e(chi2_c) ///
		   _col(55) as txt "Prob >= chibar2 = " ///
		   _col(73) as res %6.4f e(p_c)
	}
end
