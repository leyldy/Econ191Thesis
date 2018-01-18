***********************************
***** ECON 191 STATA MIMIC.do *****
***** Author: Jong Ha Lee	  *****
***********************************

drop _all

cd "\\Client\C$\Users\jonghalee\Desktop\School\ECON 191\"
* Importing MIMIC data *
import delimited using "cleandata\MIMICData.csv", varnames(1)

* Summary statistics *
outreg2 using sumMimic.tex, replace sum(log) ///
keep(growth pctcurrcharge pcttotalexp pctinsureexp pctpir pctindtax ///
realgdpcapita elecpergdp)

drop _all
import delimited using "cleandata\MIMICDataScaled.csv", varnames(1)

* Run MIMIC Model *
eststo clear
eststo m1: quietly sem (Shadow -> elecpergdp realgdpcapita growth) ///
 (Shadow <- pctcurrcharge pcttotalexp pctinsureexp pctpir pctindtax), ///
 iterate(300)
 
esttab using mimicReg.tex, se label replace star(* 0.1 ** 0.05 *** 0.01) 

* Generate shadow economy levels based on coefficients *
gen shadow = 0.0890757*pctcurrcharge + 0.1655975*pcttotalexp + ///
0.0406591*pctinsureexp +0.0353081*pctpir + 0.1151366*pctindtax

gen shadow2 = 0.1655975*pcttotalexp + 0.1151366*pctindtax
save "cleandata\MIMIC.dta", replace
