********************************************************************************** (0) Globals and Locals*******************************************************************************clear allvers 10.1 cap log closepause onforeach ado in ivreg2 outreg2 estout ranktest mat2txt plausexog {	cap which `ado'	if _rc!=0 ssc install `ado'}* DIRECTORIESglobal Directory /Users/pedm/Documents/jobs/Damian-Clarkeglobal Data          "${Directory}/Data"global Source        "${Directory}/Code"global Log           "${Directory}/Log"global Graphs        "${Directory}/Results/Graphs"global Tables        "${Directory}/Results/Outreg"* SWITCHES (1 if run, else not run)global zscores        0global OLS            0global IV             1global subsamples     0global fullcontrols   1global fixmissing1    1global evalmissing    0global sumstats       0global graphs         0global fastTesting    1* VARIABLES* We cannot obtain a measure of educf - Mother's years of education * Instead we use natural_mother_education_NVQ - mothers edu levelglobal outcomes Q_Verbal_Similarities Q_Number_Skills Q_Word_Reading Q_Pattern_Constructionglobal base malec _country* _yb* _dob*global age motherage motheragesq motheragecub agefirstbirthglobal S _mother_edu*global H heightglobal sumstatsC malec _country* year_birth CM_DOB_Year CM_DOB_Month motherage agefirstbirth natural_mother_education_NVQ heightglobal dataset data-v2* options for dataset is data-v1 or data-v2* ECONOMETRIC SPECIFICATIONS* Only include CM that are available in Wave 5local cond if ALL==1 local se cluster(MCSID)local wt [pw=sweight]* FIGURESlocal famsize   famsizelocal famsize_n famsize_natsibslocal twinbord  twinbybordlocal idealfam  idealfamsize* FILE NAMESlocal fSuffix        ""local Suffix         ""local Prefix         DataV2********************************************************************************** (1) Generate full dataset QQ-Ready-for-Regressions.dta (SLOW)******************************************************************************** Here there are two versions, differentiated based on * Version1 (Aug5): counts siblings using a mix of "natural siblings only" and "natural sibs + half siblings from same mother" * Version2: attempts to count siblings using entirely "natural sibs + half siblings from same mother"/** Both versions use:do "${Directory}/Code/Fertility-Count-Using-Half-Siblings.do"do "${Directory}/Code/Mother-Health-Education.do"do "${Directory}/Code/Quality-Outcomes.do"* v2: Aug 25* Order of these files mattersdo "${Directory}/Code/Nat-Mom-Age-At-First-Birth.do"* Dependent upon natural_children_of_CM_mom_wave5.dtado "${Directory}/Code/testing.do"* Must run last, because dependent upon natural_children_of_natural_mother.dtado "${Directory}/Code/HH-Grid-Birth-Order-Using-Natural-Children.do"*//*v1 : Aug 5do "${Directory}/CodeAug5/Nat-Mom-Age-At-First-Birth.do"do "${Directory}/CodeAug5/HH-Grid-Birth-Order.do"*/* Both versions use the same file to merge Intermediate dta files* For version 1, should always use agefirstbirth.dta. Not meant to be used with agefirstbirth_composite* For version 2, should I use agefirstbirth_composite.dta or agefirstbirth.dta? Doesn't seem to matter. Results robust to both measures/*do "${Directory}/Code/Merge-Intermediate-Data.do"*/********************************************************************************** (2) Discretionary choices*******************************************************************************if $fullcontrols==1{	global base $base _eth*	global S $S _inc*	global H $H daily_cig_before_preg weekly_alcohol_b_preg complications_during_preg	global sumstatsC $sumstatsC _eth1-_eth4 _inc* daily_cig_before_preg weekly_alcohol_b_preg complications_during_preg}if $fullcontrols==0{	*Modify directories	local fSuffix "`fSuffix'-DHSControlsOnly"}if $fixmissing1==1{	*Modify directories	local Suffix "`Suffix'IncludeMissing"}if $fixmissing1==0{	*Modify directories	local Suffix "`Suffix'OmitMissing"}* Note: If fullcontrols==0, we produce estimates using the same controls available in DHS* These estimates are stored in the folder Outreg-DHScontrolsif $subsamples==1{	local conditions ALL==1 income_quint==1 income_quint>1&income_quint<5 malec==0 malec==1	local fnames All LowIncome MidIncome Girls Boys}else{	local conditions ALL==1 malec==0 	local fnames All Girls}* Never used in production runs, as it overrides other switchesif $fastTesting==1{	global outcomes Q_Verbal_Similarities	local conditions ALL==1	local fnames All	}* PRODUCE DIRECTORIEScap mkdir "$Tables"cap mkdir "$Graphs"foreach dirname in Summary OLS OLS-DHSControlsOnly OLS-EffectSizes IV IV-DHSControlsOnly IV-EffectSizes {	cap mkdir "$Tables/`dirname'"}********************************************************************************** (3) Data Setup*******************************************************************************/* * Use "legacy" data to compare two different measures of birth order* if using Aug7 dta, rename outcome varsuse "${Data}/Final/QQ-Ready-for-Regressions-Aug7.dta"rename Quality_EVSTSCO Q_Verbal_Similaritiesrename Quality_Number_Skills Q_Number_Skillsrename Quality_Word_Reading Q_Word_Reading rename Quality_Pattern_Construction Q_Pattern_Construction*/use "${Data}/Final/QQ-Ready-for-Regressions.dta"gen ALL = 1replace bmi=. if bmi>50replace height=. if height>2.4replace height=. if height<0.8replace motherage=. if motherage<=0* Incorporate into the regression all observations with missing controlsif $fixmissing1==1{	* We need only add a zero, as these variables are categorical	foreach var of varlist country year_birth ethnic_group income_quint natural_mother_education_NVQ{		replace `var' = 0 if `var'==.	}		* Continuous variables: replace with zero and add a dummy to the regression	gen miss_motherage= motherage==.	replace motheragecub=0 if motherage==.	replace motheragesq=0 if motherage==.	replace motherage=0 if motherage==.	gen miss_agefirstbirth= agefirstbirth==.	replace agefirstbirth=0 if agefirstbirth==.	global age $age miss_motherage miss_agefirstbirth		foreach var of varlist $H{		gen miss_`var'= `var'==.		replace `var'=0 if `var'==.		global H $H miss_`var'	}}* Generate dummy varsqui tab country, gen(_country)qui tab year_birth, gen(_yb)qui tab ethnic_group, gen(_eth)qui tab income_quint, gen(_inc)qui tab natural_mother_education_NVQ, gen(_mother_edu)drop _mother_edu6 _inc5qui tab bord, gen(_bord)qui tab CM_DOB_Month, gen(_dob_m)qui tab CM_DOB_Year, gen(_dob_y)if $zscores==1{	* Generate Z scores of outcome variables	foreach var of varlist $outcomes {		egen `var'_sd=sd(`var')		egen `var'_mean=mean(`var')			gen Z`var'=(`var'-`var'_mean)/`var'_sd		drop `var'_sd `var'_mean		global outcomes $outcomes Z`var'	}}************************************************************************************ (4) Estimation samples for IV regression********************************************************************************local max 1local fert 2foreach num in two three four {	* two_plus = 1 for the family that had 2+ births    gen `num'_plus=bord<=`max'&fert>=`fert'	replace `num'_plus=0 if NOCMHH != 1		* twin_two_fam = 1 if a family has a twin at the second birth and 0 otherwise	* TODO: this does not account for families that have multiple twin births  	gen twin_`num'_fam = (LaterTwin_birth_order == `fert')    local ++max    local ++fert}************************************************************************************ (5a) Investigate missing values - how can I increase sample size?********************************************************************************	if $evalmissing==1{	keep `cond'	qui reg Q_Verbal_Similarities fert $base $age $S $H, `se'	generate sample = e(sample)	tab sample	egen base_miss = rowmiss($base)	egen age_miss = rowmiss($age)	egen S_miss = rowmiss($S)	egen H_miss = rowmiss($H)	egen Q_miss = rowmiss($outcomes)	egen miss = rowmiss($base $age $S $H $outcomes)	* edit Qual fert $base $age $S $H if sample == 0}* Fixed: Sample size has increased by 50% after adding bmi and height from wave1************************************************************************************ (5b) Sum Stats********************************************************************************* twinfamily = At least one twin in family* CM_has_twin_siblings - if at least one twin birth counted in siblings	* NOCMHH - number of CMgen twinfamily = (NOCMHH>1)|(CM_has_twin_siblings==1)if c(os)=="Unix" local format epselse if c(os)!="Unix" local format png* SUM STATS - Generate samplesgen All=1qui reg `y' fert $base $age $S $H, `se'gen OLSsample=e(sample)qui ivregress 2sls `y' $base $age $S $H (fert=twin_two_fam) `wt' if two_plus==1gen IVTwoPlus = e(sample)qui ivregress 2sls `y' $base $age $S $H (fert=twin_three_fam) `wt' if three_plus==1gen IVThreePlus = e(sample)qui ivregress 2sls `y' $base $age $S $H (fert=twin_three_fam) `wt' if four_plus==1gen IVFourPlus = e(sample)if $sumstats==1 {	* Produce sum stats output	local cells "count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))"	local sumstatsSamples All OLSsample IVTwoPlus IVThreePlus IVFourPlus	foreach subSample of local sumstatsSamples {			*Compute five types of sum stats:		* 1. all observations		* 2. observations with no twins in family		* 3. obs with at least one twin in family		* 4. obs with no later twins (the IV)		* 5. obs with at least one later twin			eststo clear		qui eststo: qui estpost sum $sumstatsC if `subSample'		sort twinfamily		qui by twinfamily: eststo: qui estpost sum $sumstatsC if `subSample'		sort CM_has_later_twin_siblings		qui by CM_has_later_twin_siblings: eststo: qui estpost sum $sumstatsC if `subSample'		esttab using "${Tables}/Summary/`Prefix'-`subSample'-`Suffix'.rtf", cells("`cells'") mtitle("All" "No twins fam" "Twin in fam" "No later twins" "Later Twins") nonumber replace		local cells "mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))"	}}****************************************************************************** (5c) Graphical*** graph 1: total births by family type (twins vs non-twins)*** graph 2: total births by family type - fertility excluding half siblings*** graph 3: Proportion of twins by birth order (line)*** graph 4: Proportion of twins by birth order (histogram)*** graph 5: Proportion of twins by mothers age***************************************************************************if $graphs==1 {		twoway kdensity fert if twinfamily>0&twinfamily!=., lpattern(dash) bw(2) `wt' || ///	  kdensity fert if twinfamily==0, bw(2) scheme(s1color) ytitle("Density") `wt' ///	  legend(label(1 "Twin Family") label(2 "Singleton Family")) ///	  title("Total births by Family Type") xtitle("total children ever born (includes half sibs)") 	graph save "$Graphs/`famsize'", replace	graph export "$Graphs/`famsize'.`format'", as(`format') replace		twoway kdensity fertility_count_by_nat_siblings if twinfamily>0&twinfamily!=., lpattern(dash) bw(2) `wt' || ///	  kdensity fertility_count_by_nat_siblings if twinfamily==0, bw(2) scheme(s1color) ytitle("Density") `wt' ///	  legend(label(1 "Twin Family") label(2 "Singleton Family")) ///	  title("Total births by Family Type") xtitle("total children ever born (natural siblings only)") 	graph save "$Graphs/`famsize_n'", replace	*graph export "$Graphs/`famsize_natsibs'.`format'", as(`format') replace						* TODO: repeat this using different sample sizes (as in, the one with all, then the one just with those with no missings, etc etc)						* twind  Child is a twin (binary)	* Am I defining this right? I ask because this is about CM twins, not later born twins	* TODO: make graphs for "later born twins" ie the IV	gen twind = NOCMHH>1		local note1 "Single births are 1-frac(twins). "	local note2 "Total fraction of twins is represented by the solid line."	local gnote "`note1' `note2'"	sum twind	local twinave=r(mean)		preserve	* Compute mean by birth order	collapse twind `wt', by(bord)		* collapse (count) twind `wt', by(bord)	* collapse (sum) twind `wt', by(bord)		gen twinave=`twinave'		line twind bord if bord<11, lpattern(dash) title("Twinning by birth order") ///	  ytitle("Fraction twins") xtitle("Birth Order") yline(0.0189) ///	  note(`gnote') scheme(s1color)	graph save "$Graphs/`twinbord'", replace	graph export "$Graphs/`twinbord'.`format'", as(`format') replace	twoway bar twind bord if bord<11 || ///	line twinave bord if bord<11, title("Twinning by birth order") ///	  ytitle("Fraction twins") xtitle("Birth Order")  ///	  note(`gnote') scheme(s1color)	graph save "$Graphs/`twinbord'_hist", replace	graph export "$Graphs/`twinbord'_hist.`format'", as(`format') replace	restore	preserve	collapse twind `wt', by( motherage )	edit	twoway connected twind motherage if motherage<=45, lpattern(dash) title("Twinning by mother's age") ///	  ytitle("Fraction twins (CM)") xtitle("Mother's Age at birth of CM") yline(0.0189) ///	  note(`gnote') scheme(s1color)	* save	restore		}************************************************************************************ (6) Simple OLS of Q-Q (can then apply Altonji)********************************************************************************if $OLS==1{	tokenize `fnames'	local i 1	foreach condition of local conditions {		local condition_name = "``i''"			local out "${Tables}/OLS`fSuffix'/`Prefix'-`condition_name'-`Suffix'.xls"		cap rm "`out'"		cap rm "${Tables}/OLS`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"		foreach n in two three {			preserve			keep `cond'&`condition'&`n'_plus==1			foreach y of varlist $outcomes {									qui reg `y' fert $base $age $S $H, `se'						qui reg `y' fert $base $age `wt' if e(sample), `se'				qui outreg2 fert $age using "`out'", excel append						qui reg `y' fert $base $age $H `wt' if e(sample), `se'				qui outreg2 fert $age $H using "`out'", excel append						qui reg `y' fert $base $age $S $H `wt', `se'				qui outreg2 fert $age $S $H using "`out'", excel append				qui reg `y' fert $base $age $S $H _bord* `wt', `se'				outreg2 fert $age $S $H using "`out'", excel append				}			restore		}		local ++i	}}************************************************************************************ (7) IV (using twin at order n), subsequent inclusion of twin predictors********************************************************************************* There are two measures of fertility: * fert = natural + half siblings from mothers side* fertility_count_by_nat_siblings = fertility count excluding half siblings/*drop fertrename fertility_count_by_nat_siblings fert*/* I do not include cluster(MCSID) because our sample does not include non-singleton CMsif $IV==1{	tokenize `fnames'	local i 1	foreach condition of local conditions {		local condition_name = "``i''"			local out "${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.xls"		cap rm "`out'"		cap rm "${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"		foreach n in two three four {			*foreach n in three {			preserve			keep `cond'&`condition'&`n'_plus==1									foreach y of varlist $outcomes {				* use ivreg2				* export				qui ivregress 2sls `y' $base $age $S $H (fert=twin_`n'_fam) `wt'				qui ivregress 2sls `y' $base (fert=twin_`n'_fam) `wt' if e(sample)						qui outreg2 fert $age using "`out'", excel append							qui ivregress 2sls `y' $base $age $S (fert=twin_`n'_fam) `wt' if e(sample)				qui outreg2 fert $age $S using "`out'", excel append							qui ivregress 2sls `y' $base $age $S $H (fert=twin_`n'_fam) `wt'				* make qui if I don't want seeout command				qui outreg2 fert $age $S $H using "`out'", excel append			}			restore		}		local ++i	}	di "seeout using ${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"	seeout using "${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"}********************************************************************************** (8) Miscellaneous Commands*******************************************************************************/** Not a problem! We should only see twins-pre-index-child when we're in the IVFourPlus sample* This is because of how we select our sample: based on number of children* We see twins-pre-index-child when using the IVFourPlus sample, because then family size is large enoughtab CM_has_twin_siblings CM_has_later_twin_siblings if IVThreePlustab CM_has_twin_siblings CM_has_later_twin_siblings if IVFourPlus*/* Things to try:* 1) interaction effects between missing dummies* xi: ivregress 2sls Q_E i.malec i.country i.CM_dob i.year_birth $age $S $H (fert=twin_three_fam) i.miss_height*height i.miss_mothe~e*motherage i.miss_mothe~e*motheragesq i.miss_mothe~e*motheragecub i.miss_agefirstbi~h*agefirstbi~h `wt' if three_plus* DONE* 2) reduce the number of _yb* and _dob* dummies -> make yb categories* =====> month of birth and year of birth only dummies* 3) outliers causing the issue? try local linear regression, ridge regression, or lasso regression* 4) Noise in the Independent Variables - ie measurement error in fertility		* idea: flag all families with half siblings, as this is what might create error. Perhaps use eivreg