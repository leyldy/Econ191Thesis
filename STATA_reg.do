***********************************
***** ECON 191 STATA Reg.do *******
***** Author: Jong Ha Lee	  *****
***********************************

drop _all
eststo clear
cd "\\Client\C$\Users\jonghalee\Desktop\School\ECON 191\"

* Importing control-related data, saving as .dta format *
import delimited using "cleandata\controlData.csv", varnames(1)
save "cleandata\controlData.dta", replace


drop _all
* Importing MIMIC data *
import delimited using "cleandata\HUDData.csv", varnames(1)
joinby state year using "cleandata\MIMIC.dta"
drop realgdpcapita
joinby state year using "cleandata\controlData.dta"

* Dependent Variable * 
gen depvar = ln(totalhomeless)

* Descriptive Statistics on dependent variable and controls
outreg2 using sumOthers.tex, replace sum(log) ///
keep(depvar totalhomeless totalyearroundbedsrrh totalbeds treatvar ///
 urate perchs2564 hpi2000nsa avgtemp realgdpcapita)


* Regressions: *
***** Setup *****
gen nonstdTreat = treatvar
drop treatvar
egen treatvar = std(nonstdTreat)

egen urateStd = std(urate)
egen realgdpcapitaStd = std(realgdpcapita)
egen perchs2564Std = std(perchs2564)

encode state, gen(stateEncode)
eststo clear

***** Without Controls *****
* 1) No fixed effects
eststo: reg depvar treatvar shadow c.treatvar#c.shadow

* 2) State fixed effects only
eststo: reg depvar treatvar shadow c.treatvar#c.shadow i.stateEncode
/**
* 3) Time fixed effect only
eststo: reg depvar treatvar shadow c.treatvar#c.shadow i.year
**/
* 4) Time and State fixed effects
eststo: reg depvar treatvar shadow c.treatvar#c.shadow i.year i.stateEncode

***** With Controls *****
* 1) No Fixed Effects
eststo: reg depvar treatvar shadow c.treatvar#c.shadow ///
urateStd realgdpcapitaStd perchs2564Std

* 2) State fixed effects only
eststo: reg depvar treatvar shadow c.treatvar#c.shadow ///
urateStd realgdpcapitaStd perchs2564Std i.stateEncode
/**
* 3) Time fixed effect only
eststo: reg depvar treatvar shadow c.treatvar#c.shadow i.year ///
urate realgdpcapita perchs2564
**/
* 4) Time and State Fixed Effects
eststo: reg depvar treatvar shadow c.treatvar#c.shadow ///
i.year i.stateEncode urateStd realgdpcapitaStd perchs2564Std

esttab using reg.tex, se label replace star(* 0.1 ** 0.05 *** 0.01) ///
indicate("With Controls = urateStd realgdpcapitaStd perchs2564Std" ///
 "With time fixed effects = *year" "With state fixed effects = *stateEncode")

 
********** PLACEBO TESTING WITH TEMPERATURE **************
eststo clear
egen avgtempstd = std(avgtemp)
* 4) Time and State Fixed Effects
eststo: reg depvar treatvar shadow c.treatvar#c.avgtempstd ///
i.year i.stateEncode urateStd realgdpcapitaStd perchs2564Std

esttab using regPlacebo.tex, se label replace star(* 0.1 ** 0.05 *** 0.01) ///
indicate("With Controls = urateStd realgdpcapitaStd perchs2564Std" ///
 "With time fixed effects = *year" "With state fixed effects = *stateEncode")
