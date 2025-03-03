*! version 1.0.0  16nov2010
program skewrplot
	version 11.1
	if !inlist("`e(cmd)'", "skewnreg","skewtreg","mskewnreg","mskewtreg") {
		error 301
	}
	syntax [, pp qq rvf NORMAL * ]
	opts_exclusive "`pp' `qq' `rvf'"
	opts_exclusive "`rvf' `normal'"
	local options `normal' `options'
	local type "`pp'`qq'`rvf'"
	if ("`e(cmd)'"=="skewnreg") {
		if ("`type'"=="") {
			local type fit
		}
		if ("`pp'`qq'"!="") {
			local options `options' `type'
			local plotname _skew_pq_plots sn
		}
		else {
			local plotname _skewn_`type'plot
		}
	}
	else if ("`e(cmd)'"=="skewtreg") {
		if ("`type'"=="") {
			local type fit
		}
		if ("`pp'`qq'"!="") {
			local options `options' `type'
			local plotname _skew_pq_plots st
		}
		else {
			local plotname _skewt_`type'plot
		}
	}
	else if ("`e(cmd)'"=="mskewnreg") {
		if ("`rvf'"!="") {
			di as err "option rvf not allowed"
			exit 198
		}
		if ("`type'"=="") {
			local type qq
		}
		local options `options' `type'
		local plotname _skew_pq_plots msn
	}
	else if ("`e(cmd)'"=="mskewtreg") {
		if ("`rvf'"!="") {
			di as err "option rvf not allowed"
			exit 198
		}
		if ("`type'"=="") {
			local type qq
		}
		local options `options' `type'
		local plotname _skew_pq_plots mst
	}
	`plotname', `options'
end

program _skewn_rvfplot
	syntax [, cp /*undoc.*/ * ]
	tempvar xb r
	qui predict double `xb', xb `cp' nolab
	qui predict double `r', resid `cp' nolab
	if ("`cp'"!="") {
		local lab , CP
	}
	scatter `r' `xb', xti("Fitted values`lab'")	///
			  yti("Residuals`lab'") `options'
end

program _skewt_rvfplot
	syntax [, * ]
	tempvar xb r
	qui predict double `xb', xb nolab
	qui predict double `r', resid nolab
	scatter `r' `xb', xti("Fitted values")	///
			  yti("Residuals") `options'
end

program _skewn_fitplot

	syntax [, fitted KDENsity LEGend(string asis) NORMAL ///
		  cp /*undoc.*/ * ]

	if ("`fitted'"!="") {
		if (`e(df_m)'!=0) {
			di as err "option {bf:fitted} is only allowed " ///
				  "with constant-only models"
			exit 198
		}
		if ("`cp'"!="") {
			di as txt "(option {bf:cp} is irrelevant in combination with option {bf:fitted})"
		}
	}
	if ("`kdensity'"=="") {
		local npopts HISTOPts
	}
	else {
		local npopts KDENOPts
	}
	_get_gropts, graphopts(`options') gettwoway 	///
		     getallowed(LINEOPts `npopts' NORMOPts ADDPLOT)
	local twopts `"`s(twowayopts)'"'
	local histopts `"`s(histopts)'"'
	_chk_histopts, `histopts' 
	local kdenopts `"`s(kdenopts)'"'
	local lineopts `"`s(lineopts)'"'
	local normopts `"`s(normopts)'"'
	local addplot `"`s(addplot)'"'
	if (`"`s(graphopts)'"'!="") {
		di as err `"`s(graphopts)' not allowed"'
		exit 198
	}
	
	marksample touse
	tempvar esamp
	qui gen byte `esamp' = 1 if e(sample)
	markout `touse' `esamp'
	qui drop `esamp'

	tempvar x snfit r
	if ("`fitted'"=="") {
		qui predict double `r' if `touse', resid `cp'
	}
	else {
		qui gen double `r' = `e(depvar)' if `touse'
		local labvar : variable label `e(depvar)'
		if ("`labvar'"=="") {
			local labvar `e(depvar)'
		}
		label variable `r' "`labvar'"
	}
	tempname bdp xi omega alpha
	if (`e(skew_dp)') {
		mat `bdp' = e(b)
	}
	else {
		mata: _skewn_est2dp_b("`bdp'")
	}
	local d = colsof(`bdp')
	scalar `omega' = `bdp'[1,`d']
	scalar `alpha' = `bdp'[1,`d'-1]
	if ("`fitted'"!="") {
		scalar `xi' = `bdp'[1,`d'-2]
	}
	else if ("`cp'"!="") {
		scalar `xi' = -sqrt(2/_pi)*`omega'*`alpha'/sqrt(1+(`alpha')^2)
	}
	else {
		scalar `xi' = 0
	}
	local shape = string(`alpha', "%10.2f")
	qui summ `r' if `touse', meanonly
	local n = min(100, `c(N)')
	qui range `x' `r(min)' `r(max)' `n'
	label variable `x' "`: variable label `r''"
	qui gen double `snfit' = .
	qui _skewn_pdf `snfit' `touse' `x' `xi' `omega' `alpha'
	label variable `snfit' "Skew-normal, alpha = `shape'"
	if (`"`legend'"'=="") {
		local legend label(1 "Nonparametric") 
	}
	if ("`kdensity'"!="") {
		local mainplot kdensity `r'
		local mainopts `kdenopts'
	}
	else {
		local mainplot histogram `r'
		local mainopts `histopts'
	}
	if (`"`addplot'"'=="") {
		if ("`fitted'"=="") {
			local title "Distribution of residuals"
		}
		else {
			local title "Distribution of {bf:`e(depvar)'}"
		}
		local xtitle "`: variable label `r''"
		local ytitle "Density"
	}
	local addplot (line `snfit' `x', sort `lineopts') || (`addplot')
	if ("`normal'"!="") {
		local legend `legend' label(2 "Normal")
		local normalopts `normal' normopts(`normopts')
	}
	`mainplot',	`normalopts'			///
			 addplot(`addplot')		///
			title(`"`title'"') 		///
			xtitle(`"`xtitle'"')		///
			ytitle(`"`ytitle'"')		///
			leg(`legend')			///
			`mainopts'			///
			`twopts'
end

program _skewt_fitplot

	syntax [, fitted KDENsity LEGend(string asis) NORMAL * ]

	if ("`fitted'"!="") {
		if (`e(df_m)'!=0) {
			di as err "option {bf:fitted} is only allowed " ///
				  "with constant-only models"
			exit 198
		}
	}
	if ("`kdensity'"=="") {
		local npopts HISTOPts
	}
	else {
		local npopts KDENOPts
	}
	_get_gropts, graphopts(`options') gettwoway 	///
		     getallowed(LINEOPts `npopts' NORMOPts ADDPLOT)
	local twopts `"`s(twowayopts)'"'
	local histopts `"`s(histopts)'"'
	_chk_histopts, `histopts' 
	local kdenopts `"`s(kdenopts)'"'
	local lineopts `"`s(lineopts)'"'
	local normopts `"`s(normopts)'"'
	local addplot `"`s(addplot)'"'
	if (`"`s(graphopts)'"'!="") {
		di as err `"`s(graphopts)' not allowed"'
		exit 198
	}
	
	marksample touse
	tempvar esamp
	qui gen byte `esamp' = 1 if e(sample)
	markout `touse' `esamp'
	qui drop `esamp'

	tempvar x stfit r
	if ("`fitted'"=="") {
		qui predict double `r' if `touse', resid
	}
	else {
		qui gen double `r' = `e(depvar)' if `touse'
		local labvar : variable label `e(depvar)'
		if ("`labvar'"=="") {
			local labvar `e(depvar)'
		}
		label variable `r' "`labvar'"
	}
	tempname xi omega alpha df
	scalar `df' = e(df)
	scalar `omega' = e(omega)
	scalar `alpha' = e(alpha)
	if ("`fitted'"!="") {
		tempname bdp
		mat `bdp' = e(b)
		scalar `xi' = `bdp'[1,1]
	}
	else {
		scalar `xi' = 0
	}
	local shape = string(`alpha', "%10.2f")
	local tail = string(`df', "%10.2f")
	qui summ `r' if `touse', meanonly
	local n = min(100, `c(N)')
	qui range `x' `r(min)' `r(max)' `n'
	label variable `x' "`: variable label `r''"
	qui gen double `stfit' = .
	qui _skewt_pdf `stfit' `touse' `x' `xi' `omega' `alpha' `df'
	label variable `stfit' "Skew-t, alpha = `shape', df = `tail'"
	if (`"`legend'"'=="") {
		local legend label(1 "Nonparametric")
	}
	if ("`kdensity'"!="") {
		local mainplot kdensity `r'
		local mainopts `kdenopts'
	}
	else {
		local mainplot histogram `r'
		local mainopts `histopts' 
	}
	if (`"`addplot'"'=="") {
		if ("`fitted'"=="") {
			local title "Distribution of residuals"
		}
		else {
			local title "Distribution of {bf:`e(depvar)'}"
		}
		local xtitle "`: variable label `r''"
		local ytitle "Density"
	}
	local addplot (line `stfit' `x', sort `lineopts') || (`addplot')
	if ("`normal'"!="") {
		local legend `legend' label(2 "Normal")
		local normalopts `normal' normopts(`normopts')
	}
	`mainplot',	`normalopts'			///
			 addplot(`addplot')		///
			title(`"`title'"') 		///
			xtitle(`"`xtitle'"')		///
			ytitle(`"`ytitle'"')		///
			leg(`legend')			///
			`mainopts'			///
			`twopts'
end

program _chk_histopts
	syntax [, DISCrete FRACtion FREQuency percent HORizontal 	///
		  NORMal NORMOPts(string asis) KDENsity 		///
		  KDENOPts(string asis) * ]

	local hopts `discrete'`fraction'`frequency'`percent'`normal'`kdensity'
	local hopts `hopts'`normopts'`kdenopts'
	if ("`hopts'"!="") {
		di as err "{p}{bf:skewrplot, histopts()}: options " ///
			  "discrete, fraction, frequency, percent, " ///
			  "horizontal, normal, normopts(), kdensity, " ///
			  "kdenopts() are not allowed{p_end}"
		exit 198
	}
end

program _skew_pq_plots, sortpreserve
	syntax anything(name=model) [,  PP QQ Normal overlay 	///
					LEGend(passthru) 	///
					YCOMmon			///
					ASPECTratio(string) YSIZe(string) * ]
	if ("`overlay'"=="" & "`normal'"!="") {
		local globopts getcombine
		local globname combineopts
	}
	else if "`overlay'"!="" {
		if ("`qq'"!="") {
			di as err "{bf:overlay} is not allowed with {bf:qq}"
			exit 198
		}
		if ("`normal'"=="") {
			di as err 	///
				"{bf:overlay} is allowed only with {bf:normal}"
			exit 198
		}
		if ("`addplot'"!="") {
			di as err "{bf:addplot()} is not allowed with {bf:overlay}"
			exit 198
		}
		local globopts gettwoway
		local globname twowayopts
	}
	if ("`pp'"!="") {
		if (`"`aspectratio'"'=="") {
			local aspectratio 1
		}
		if (`"`ysize'"'=="") {
			local ysize 3
		}
	}
	local plotsize aspectratio(`aspectratio') ysize(`ysize')
	local getallowed RLOPts addplot NORMOPts
	_get_gropts, graphopts(`options') getallowed(`getallowed') `globopts'
	local scatteropts "`s(graphopts)'"
	local rlopts `"`s(rlopts)'"'
	local normopts `"`s(normopts)'"'
	local addplot `"`s(addplot)'"'
	local globopts `"`s(`globname')'"'
	_check4gropts rlopts, opt(`rlopts')

	marksample touse
	qui replace `touse'=0 if !e(sample)
	qui count if `touse'
	local n = r(N)

	if (substr("`model'",1,1)=="m") {
		local d = e(k_dv)
		local resid dmahalanobis
	}
	else {
		local d=1
		local resid rscaled
	}
	if ("`model'"=="sn") {
		local predictdp dp
	}
	tempvar pt r
	qui predict double `r' if `touse', `resid' `predictdp'
	qui replace `r' = (`r')^2 if `touse'
	local fmt : format `r'
	qui sort `r'
	qui gen double `pt' = sum(`touse')/(`n'+1) if `touse'
	if ("`model'"=="sn") {
		label variable `r' "Scaled squared residuals"
		if ("`normal'"=="") {
			if ("`qq'"!="") {
				local yttl "Scaled squared residuals"
				local snplot qchi
			}
			else if ("`pp'"!="") {
				local yttl ///
		"{&chi}{superscript:2}(scaled squared residuals), d.f. = 1"
				local snplot pchi
			}
			`snplot' `r' if `touse', df(1) 		///
				        addplot(`addplot')	///
					ytitle(`"`yttl'"')	///
					rlopts(`rlopts')	///
					`legend' `plotsize'	/// 
					`scatteropts' `globopts'
			exit
		}
		else if ("`qq'"!="") {
			tempvar qt
			qui gen double `qt' = invchi2(1,`pt') if `touse'
			local xttl "Expected {&chi}{superscript:2} d.f. = 1"
			local skewtitle "Skew-normal Q-Q plot"
		}
		else if ("`pp'"!="") {
			tempvar pskew
			qui gen double `pskew' = chi2(1,`r') if `touse'
				local yttl ///
		"{&chi}{superscript:2}(scaled squared residuals), d.f. = 1"
			local skewtitle "Skew-normal P-P plot"
			local normyttl ///
		"{&chi}{superscript:2}(scaled squared residuals), d.f. = 1"
		}
	}
	else if ("`model'"=="st") {
		local df = string(e(df), "%10.2f")
		label variable `r' "Scaled squared residuals"
		if ("`qq'"!="") {
			tempvar qt
			qui gen double `qt' = invF(1,e(df),`pt') if `touse'
			local xttl "Expected F{subscript:1, `df'}"
			local skewtitle "Skew-t Q-Q plot"
		}
		else if ("`pp'"!="") {
			tempvar pskew
			qui gen double `pskew' = F(1,e(df),`r') if `touse'
			if ("`overlay'"=="") {
local yttl "F{subscript:1,`df'}(scaled squared residuals)"
			}
			else {
local yttl "F{subscript:1,df}(scaled squared residuals)"
			}
			local skewtitle "Skew-t P-P plot"
			local normyttl ///
		"{&chi}{superscript:2}(scaled squared residuals), d.f. = `d'"
		}
	}
	else if ("`model'"=="msn") {
		label variable `r' "Squared Mahalanobis distances"
		if ("`normal'"=="") {
			if ("`qq'"!="") {
				local yttl "Squared Mahalanobis distances"
				local snplot qchi
			}
			else if ("`pp'"!="") {
				local yttl ///
		"{&chi}{superscript:2}(Mahalanobis{superscript:2}), d.f. = `d'"
				local snplot pchi
			}
			`snplot' `r' if `touse', df(`d') 	///
				        addplot(`addplot')	///
					ytitle(`"`yttl'"')	///
					rlopts(`rlopts')	///
					`legend' `plotsize'	/// 
					`scatteropts' `globopts'
			exit
		}
		else if ("`qq'"!="") {
			tempvar qt
			qui gen double `qt' = invchi2(`d',`pt') if `touse'
			local xttl "Expected {&chi}{superscript:2} d.f. = `d'"
			local skewtitle "Skew-normal Q-Q plot"
		}
		else if ("`pp'"!="") {
			tempvar pskew
			qui gen double `pskew' = chi2(`d',`r') if `touse'
				local yttl ///
		"{&chi}{superscript:2}(Mahalanobis{superscript:2}), d.f. = `d'"
			local skewtitle "Skew-normal P-P plot"
			local normyttl ///
		"{&chi}{superscript:2}(Mahalanobis{superscript:2}), d.f. = `d'"
		}
	}
	else if ("`model'"=="mst") {
		local df = string(e(df), "%10.2f")
		qui replace `r' = `r'/`d' if `touse'
		label variable `r' "Scaled squared Mahalanobis distances"
		if ("`qq'"!="" & "`normal'"=="") {
			tempvar qt
			qui gen double `qt' = invF(`d',e(df),`pt') if `touse'
			local xttl "Expected F{subscript:`d', `df'}"
		}
		else if ("`qq'"!="" & "`normal'"!="") {
			qui replace `r' = `r'*`d' if `touse'
			label variable `r' "Squared Mahalanobis distances"
			tempvar qt
			qui gen double `qt'=`d'*invF(`d',e(df),`pt') if `touse'
			local xttl "Expected scaled F{subscript:`d', `df'}"
			local skewtitle "Skew-t Q-Q plot"
		}
		else if ("`pp'"!="") {
			tempvar pskew
			qui gen double `pskew' = F(`d',e(df),`r') if `touse'
			if ("`overlay'"=="") {
local yttl "F{subscript:`d',`df'}(Mahalanobis{superscript:2}/`d')"
			}
			else {
local yttl "F{subscript:`d',df}(Mahalanobis{superscript:2}/`d')"
			}
			local skewtitle "Skew-t P-P plot"
			local normyttl ///
		"{&chi}{superscript:2}(Mahalanobis{superscript:2}), d.f. = `d'"
		}
	}
	else {
		di as err `"_skew_pq_plots: unknown model {bf:`model'}"'
	}
	if ("`qq'"!="") {
		local yttl : var label `r'
		local yax `r'
		local xax `qt'
		local ylab , nogrid
		local xlab , nogrid
		local normplot qchi
		local normtitle "Normal Q-Q plot"
	}
	else if ("`pp'"!="") {
		label variable `pskew' `"`yttl'"'
		local xttl "Empirical P[i]=i/(N+1)"
		format `pskew' `pt' %9.2f
		local yax `pskew'
		local xax `pt'
		local ylab 0(0.25)1, nogrid
		local xlab 0(0.25)1, nogrid
		local normplot pchi
		local normtitle "Normal P-P plot"
	}
	local scatter scatter `yax' `xax' if `touse',	///
			sort				/// 
			ytitle(`"`yttl'"')		///
			xtitle(`"`xttl'"')		///
			ylabel(`ylab')	 		///
			xlabel(`xlab')			///
			`scatteropts'
	local function function y=x if `touse',		///
		range(`xax') 				///
		n(2) 					///
		lstyle(refline)				///
		yvarlabel("Reference")			///
		yvarformat(`fmt')			///
		`rlopts'
	if ("`legend'`overlay'`addplot'"=="") {
		local legend legend(nodraw)
	}
	if ("`normal'"=="") {
		tw (`scatter') (`function') (`addplot'), ///
					`twopts' `legend' `plotsize'
		exit
	}
	// added normal plots
	tempvar rnorm
	_normal_mahalanobis `rnorm' `touse'
	label variable `rnorm' "Squared Mahalanobis distances"

	if ("`overlay'"!="") {
		local label3 "Skew t, df = `df'"
		local label1 "Normal, df = {&infinity}"
		local leglab label(1 `"`label1'"') label(3 `"`label3'"')
		if (`"`legend'"'=="") {
			local legend legend(order(3 1) `leglab')
		}
		local normopts msymbol(+) `normopts'
		`normplot' `rnorm' if `touse', df(`d') 			///
				        addplot(`scatter' pstyle(p1))	///
					pstyle(p2) `legend' `plotsize' 	///
					`normopts'
		exit
	}
	// separate graphs
	tempname norm skew
	tw (`scatter') (`function') (`addplot'), 		///
					title(`skewtitle')	///
					nodraw			///
					name(`skew')		///
					`legend' `plotsize'
	`normplot' `rnorm' if `touse',  df(`d')			/// 
					title(`normtitle')	///
					nodraw 			///
					addplot(`addplot')	///
					name(`norm')		///
					ytitle(`"`normyttl'"')	///
					`legend' `plotsize' `normopts'
	graph combine `skew' `norm', ycommon `globopts'
end

program _skewn_pdf
	args varname touse at xi omega alpha
	replace `varname' = 2*normalden(`at',`xi',`omega')* ///
			    normal(`alpha'*(`at'-`xi')/`omega') if `touse'
end

program _skewt_pdf
	args varname touse at xi omega alpha df

	tempvar z tz
	qui gen double `z' = (`at'-`xi')/`omega'
	qui gen double `tz' = `alpha'*`z'*sqrt((`df'+1)/(`df'+(`z')^2))
	replace `varname' = 2*tden(`df',`z')*(1-ttail(`df'+1,`tz'))/`omega' ///
								if `touse'
end

program _normal_mahalanobis
	args rnorm touse

	local d = e(k_dv)
	tempname esthold
	_estimate hold `esthold', restore copy
	if ("`e(wtype)'"!="") {
		local wgt [`e(wtype)' `e(wexp)']
	}
	qui reg3 (`e(depvar)' = `e(xvars)', `e(noconstant)') if e(sample) `wgt'
	tempvar normtouse
	qui gen byte `normtouse' = min(`touse', e(sample))
	qui skew_mahalanobis double `rnorm' if `normtouse', vmatname(e(Sigma))
	qui replace `rnorm' = (`rnorm')^2
end
