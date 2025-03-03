*! version 1.0.0  31oct2010
program mskewnreg, eclass
	version 11.1

	if replay() {
		if ("`e(cmd)'"!="mskewnreg") {
			error 301
		}
		Display `0'
		exit
	}
	tempname esthold
	qui _estimates hold `esthold', nullok
	cap noi Estimate `0'
	local rc = _rc
	eret scalar rc = `rc'
	eret local cmdline `"mskewnreg `0'"'
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

	gettoken depvars xvars : anything, parse("=")
	unab depvars : `depvars'
	cap confirm numeric variable `depvars'
	if (_rc) {
		di as err "dependent variables must be numeric"
		exit 198
	}
	gettoken eq xvars : xvars, parse("=")

	if ("`weight'"!="") {
		local wgt "[`weight'`exp']"
	}
	local 0 `xvars' `if' `in' `wgt' `rhs'
	syntax [varlist(default=none numeric fv)] [if] [in] [fw]	///
			[, 					///
					ESTMetric		/// //replay
					DPMetric		///
					postdp			///
					postcp			///
					noSHOWOMega		///
					INIT(passthru) 		///
					initdp(string)		/// //undoc
					mlmethod(string)	///
					NOCONStant		///
					* 			///
			]
	opts_exclusive "`showomega' `estmetric'"
	opts_exclusive "`postcp' `postdp'"

	_get_diopts diopts mlopts, `options'
	local diopts `level' `dpmetric' `estmetric' `showomega' `diopts'

	if (!inlist("`mlmethod'","","lf0","lf1","d0","d1",	///
			"lf1debug","d1debug")) {
		di as err "{bf:mlmethod(`mlmethod')} not allowed"
		exit 198
	}
	if ("`weight'"!="") {
		local wgt "[`weight'`exp']"
	}
	else if substr("`mlmethod'",1,1)=="d" {
		local wgt [fw=1]
	}
	marksample touse
	markout `touse' `depvars'
	local xvars `varlist'
	local d : word count `depvars'
	// MVN regression
	qui reg3 (`depvars' = `xvars', `noconstant') if `touse' `wgt'
	mata: st_local("k", strofreal(cols(st_matrix("e(b)"))))
	local k = `k'/`d'
	tempname ll_c
	scalar `ll_c' = e(ll)
	if `"`init'`initdp'"' == "" {	
		//default initial values -- method of moments
		tempname initmat
		qui _mskew_moments `depvars' if `touse' `wgt', f(sn) ///
				xvars(`xvars') `noconstant' setbnd dp
		tempname v
		mata: st_matrix("`v'",vech(st_matrix("r(Omega)"))')
		mat `initmat' = (r(xi), r(alpha), `v')
		mata: _mskewn_dp2est_b("`initmat'",`d',`k', "`initmat'")
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
			local nparms = `d'*`k'+`d'+`d'*(`d'+1)/2
			if (`np'!=`nparms') {
				di as err "{bf:initdp()}: matrix must be dimension `nparms'"
				exit 198
			}
		}
		tempname initmat
		mata: _mskewn_dp2est_b("`dp0'",`d',"`initmat'")
		local init init(`initmat', copy)
	}
	//build equations
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
	if ("`mlmethod'"=="") {
		local mlmethod lf1
		local mlprog _mskewn_lf1_fullml_eta()	
	}
	else if (substr("`mlmethod'",1,1)=="l") {
		local mlprog _mskewn_lf1_fullml_eta()	
	}
	else if (substr("`mlmethod'",1,1)=="d") {
		local mlprog _mskewn_d1_fullml_eta()
	}
	local crittype log likelihood
	tempname ndv
	global SKEW_userinfo `ndv'
	mata: `ndv' = `d'
	ml model `mlmethod' `mlprog' `ml_eq' if `touse' `wgt', 		///
			`tech' maximize `init' 				///
			crittype(`crittype') 				///
			`mlopts' 					///
			userinfo($SKEW_userinfo)			///
			title("Multivariate skew-normal regression")
	// ereturn results
	eret scalar skew_dp = ("`postdp'"!="")
	eret scalar skew_cp = ("`postcp'"!="")
	eret local noconstant "`noconstant'"
	eret local cmd "mskewnreg"
	eret local predict "mskewn_p"
	eret local xvars "`xvars'"
	if ("`weight'"=="") {
		eret local wtype ""
		eret local wexp ""
	}
	eret scalar k_aux = `d'+`d'*(`d'+1)/2
	/* matrices */
	local coleq : coleq e(b)
	local colname : colname e(b)
	if ("`initmat'"!="") {
		mat coleq `initmat' = `coleq'
		mat colname `initmat' = `colname'
		eret mat b0 = `initmat'
	}
	// store Sigma, gamma
	tempname bcp Sigma gamma
	if ("`postcp'"=="") {
		mata: _mskewn_est2cp_b("`bcp'")
	}
	else {
		tempname Vcp
		mata: _mskewn_est2cp_bV("`bcp'","`Vcp'")
	}
	mat `Sigma' = `bcp'[1,"Sigma11:".."Sigma`d'`d':"]
	mata: st_matrix("`Sigma'", invvech(st_matrix("`Sigma'")'))
	mat colname `Sigma' = `depvars'
	mat rowname `Sigma' = `depvars'
	mat `gamma' = `bcp'[1,"gamma1:".."gamma`d':"]
	mat coleq `gamma' = ""
	mat colname `gamma' = `depvars'
	ereturn matrix Sigma = `Sigma'
	ereturn matrix gamma = `gamma'
	// store Omega, alpha
	tempname bdp Omega alpha
	if ("`postdp'"=="") {
		mata: _mskewn_est2dp_b("`bdp'")
	}
	else {
		tempname Vdp
		mata: _mskewn_est2dp_bV("`bdp'","`Vdp'")
	}
	mat `Omega' = `bdp'[1,"Omega11:".."Omega`d'`d':"]
	mata: st_matrix("`Omega'", invvech(st_matrix("`Omega'")'))
	mat colname `Omega' = `depvars'
	mat rowname `Omega' = `depvars'
	mat `alpha' = `bdp'[1,"alpha1:".."alpha`d':"]
	mat coleq `alpha' = ""
	mat colname `alpha' = `depvars'
	ereturn matrix Omega = `Omega'
	ereturn matrix alpha = `alpha'
	if ("`postdp'"!="") { //post DP
		RepostE `bdp' `Vdp'
	}
	else if ("`postcp'"!="") { //post CP
		RepostE `bcp' `Vcp'
	}
	//LR test
	if ("`e(vcetype)'"!="Robust") {
		eret scalar ll_c = `ll_c'
		eret scalar df_c = `d'
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
	syntax [, ESTMetric DPMetric POSTDP Level(passthru) noSHOWOMega ///
		  COEFLegend POSTCP * ]

	opts_exclusive "`showomega' `estmetric'"
	opts_exclusive "`postcp' `postdp'"
	_get_diopts tabopts eform, `options'
	if ("`eform'"!="") {
		di as err `"`eform' not allowed"'
		exit 198
	}
	if ("`coeflegend'"!="") {
		local estmetric estmetric
		di as txt "note: {bf:coeflegend} implies {bf:estmetric}"
	}
	if (`e(skew_dp)' & `"`estmetric'`postcp'"'!="") {
		mata: _skew_post_err("mskewnreg", "postdp")
	}
	if (`e(skew_cp)' & `"`estmetric'`postdp'`dpmetric'"'!="") {
		mata: _skew_post_err("mskewnreg", "postcp")
	}
	if (`e(skew_dp)' & "`postdp'"!="") {
		exit
	}
	if (`e(skew_cp)' & "`postcp'"!="") {
		exit
	}
	if ("`estmetric'"!="") {
		ml display, `tabopts' `level' `coeflegend'
		DiLRT
		exit
	}
	if ("`dpmetric'`postdp'"=="" & !`e(skew_dp)' & !`e(skew_cp)') {
		tempname ehold
		_estimates hold `ehold', copy restore
		tempname b V
		mata: _mskewn_est2cp_bV("`b'", "`V'")
		RepostE `b' `V'
		local shname gamma
		local scname Sigma
		if ("`postcp'"!="") { //post CP
			_estimates unhold `ehold', not
			mata: st_numscalar("e(skew_cp)", 1)
			exit
		}
	}
	else if (!`e(skew_dp)' & !`e(skew_cp)') {
		tempname ehold
		_estimates hold `ehold', copy restore
		tempname b V
		mata: _mskewn_est2dp_bV("`b'","`V'")
		RepostE `b' `V'
		local shname alpha
		local scname Omega
		if ("`postdp'"!="") { //post DP
			_estimates unhold `ehold', not
			mata: st_numscalar("e(skew_dp)", 1)
			exit
		}
	}
	if (`e(skew_dp)') {
		local shname alpha
		local scname Omega
	}
	else if (`e(skew_cp)') {
		local shname gamma
		local scname Sigma
	}
	local d = e(k_dv)
	ml display, neq(`d') plus `tabopts' `level' `coeflegend'
	_diparm __lab__, label(`shname') eqlabel
	forvalues i=1/`d' {
		_diparm `shname'`i', label(`i') `level' `coeflegend'
	}
	if ("`showomega'"=="") {
		_diparm __sep__
		_diparm __lab__, label(`scname') eqlabel
		forvalues i=1/`d' {
			// Log-based CIs for variances
			_diparm `scname'`i'`i' `scname'`i'`i', 	///
				     label(`i' `i') 		///
				     f(@1) d(1 0) ci(log) `level' `coeflegend'
			forvalues j=`=`i'+1'/`d' {
				_diparm `scname'`i'`j', label(`i' `j') ///
					f(@) d(1) `level' `coeflegend'
			}
		}
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
	local k = length("`e(df_c)'")
	di as txt "LR test vs MVN regression:" 			///
       	   as txt _col(`=39-`k'') "chi2(" as res e(df_c) 	///
	   as txt ") =" _col(48) as res `fmt' e(chi2_c) 	///
	  	_col(59) as txt "Prob > chi2 =" 		///
	  	_col(73) as res %6.4f e(p_c)
end

program _mskew_moments, rclass
	syntax [varlist(default=none numeric)] [if] [in] [fw],		///
						Family(string)		///
				 	[	xvars(varlist fv) 	///
						NOCONStant		///
						DP			///
						setbnd			///
						bndval(real 0.995)	///
					]
	
	if ("`varlist'"=="") exit
	if ("`weight'"!="") {
		local wgt "[`weight'`exp']"
	}

	local d : word count `varlist'
	marksample touse
	if ("`xvars'"!="") {
		markout `touse' `xvars'
	}
	tempname gamma Sigma mu
	tempname esthold
	qui _estimates hold `esthold', restore nullok
	qui reg3 (`varlist' = `xvars', `noconstant') if `touse' `wgt'
	mat `mu' = e(b)
	local k = colsof(`mu')/`d'
	mat `Sigma' = e(Sigma)
	mat `gamma' = J(1,`d',.)
	forvalues i=1/`d' {
		tempvar r
		qui predict double `r' if `touse', resid eq(#`i')
		qui summ `r' if `touse' `wgt', detail
		mat `gamma'[1,`i'] = r(skewness)
		qui drop `r'
	}
	tempname bnd
	mata: st_rclear()
	mata: __mskewn_chk_boundary("`gamma'", ("`setbnd'"!=""), `bndval')
	ret add

	local colnames : colnames e(Sigma)
	mat colnames `gamma' = `colnames'

	if ("`dp'"=="") {
		ret matrix gamma = `gamma'
		ret matrix Sigma = `Sigma'
		ret matrix mu = `mu'

		if (!`c(noisily)')  exit

		tempname pout tmp
		mat `mu' = return(mu)
		mat `Sigma' = return(Sigma)
		mat `gamma' = return(gamma)
		mat `tmp' = `mu'[1,1..`k']
		local colnames : colnames `tmp'
		mata: st_matrix("`mu'", colshape(st_matrix("`mu'"),`k')')
		mat roweq `mu' = Mean
		mat rownames `mu' = `colnames'
		mat `pout' = `mu'
		local colnames : colnames `Sigma'
		mat roweq `Sigma' = Covariance
		mat rowname `gamma' = "Skewness"
		mat `pout' = `pout' \ `Sigma' \ `gamma'
		mat colnames `pout' = `colnames'

		di 
		di as txt "Method of moments estimates of centered parameters"
		di
		matlist `pout'
		local k_bnd = return(k_bnd)
		if (`k_bnd' & "`setbnd'"!="") {
			di
			di as txt "{p 0 6 2}Note: `k_bnd' marginal "	  ///
				  `"`=plural(`k_bnd',"skewness","+es")'"' ///
				  ", outside admissible range, reset "	  ///
				  "to near boundary value of `bndval'{p_end}"
		}
		else if (`k_bnd') {
			di
			di as txt "{p 0 6 2}Note: `k_bnd' marginal "	  ///
				  `"`=plural(`k_bnd',"skewness","+es")'"' ///
				  " outside admissible range of "	  ///
				  "(-0.99527, 0.99527){p_end}"
		}
		exit
	}
	if (!`c(noisily)') {
		local qui qui
	}
	`qui' _mskewn_cp2dp `mu' `Sigma' `gamma' "`noconstant'" 0
	ret add	
end

program _mskewn_cp2dp, rclass

	args mu Sigma gamma nocons chkbnd alreset
	if ("`chkbnd'"=="") {
		local chkbnd 1
	}
	if ("`alreset'"=="") {
		local alreset 1
	}
	mata: _mskewn_cp2dp(	"`mu'",		///
				"`Sigma'", 	///
				"`gamma'", 	///
				`chkbnd', 	///
				`alreset',	///
				"`nocons'")
	ret add

	if (!`c(noisily)') exit

	if (`chkbnd') {
		_bnd_note `return(k_bnd)'
	}

	tempname pin pout mu Sigma gamma xi Omega alpha
	mat `xi' = return(xi)
	mat `Omega' = return(Omega)
	mat `alpha' = return(alpha)
	local k = colsof(`xi')/colsof(`Omega')
	mat `mu' = return(mu)
	mat `Sigma' = return(Sigma)
	if ("`return(gamma_bnd)'"=="matrix") {
		mat `gamma' = return(gamma_bnd)
	}
	else {
		mat `gamma' = return(gamma)
	}
	tempname tmp
	mat `tmp' = `mu'[1,1..`k']
	local colnames : colnames `tmp'
	mata: st_matrix("`mu'", colshape(st_matrix("`mu'"),`k')')
	mat roweq `mu' = Mean
	mat rownames `mu' = `colnames'
	mata: st_matrix("`xi'", colshape(st_matrix("`xi'"),`k')')
	mat roweq `xi' = Location
	mat rownames `xi' = `colnames'
	local colnames : colnames `Sigma'
	mat roweq `Sigma' = Covariance
	mat rowname `gamma' = "Skewness"
	mat `pin' = `mu' \ `Sigma' \ `gamma'
	mat colnames `pin' = `colnames'

	mat roweq `Omega' = Scale
	mat rownames `alpha' = Shape
	mat `pout' = `xi' \ `Omega' \ `alpha'
	mat colnames `pout' = `colnames'
	di 
	di as txt "Conversion from centered to direct parameters"
	di
	di as txt "{bf:Input CP:}"
	di
	matlist `pin'
	di
	di as txt "{bf:Output DP:}"
	matlist `pout'
	_admissible_note `return(admissible)'
end

program _bnd_note
	args k_bnd

	if (!`k_bnd') exit

	di as txt `"(`k_bnd' marginal `=plural(`k_bnd',"skewness","+es")'"' ///
			  " outside admissible range, resetting "	///
			  "to near boundary value of 0.995)"
end

program _admissible_note
	args isadmis

	if (`isadmis') exit

	di
	di as txt "{p 0 6 2}Note: specified CP parameters not in admissible CP set; DP transfromation is approximate{p_end}"
end
