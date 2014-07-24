* This file uses HH Grid to measure fertility count and produce siblings_from_natural_mother* We measure siblings from natural mother of the CM* This allows us to include half siblings from the same mother* HHGrid does not specify whether half-siblings are from the mother or father's side* Thus we must indirectly obtain this information by counting natural children of the mother*=================================================================================* Section 0: Directories and Setup*=================================================================================vers 10.1 clear allset more offglobal directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/*=================================================================================* Section 1: Get parent's gender from parent interviews*=================================================================================use "${directory}Raw\MCS-Survey-5\stata11\mcs5_parent_interview.dta", clear* Keep relevant variableskeep MCSID EHPNUM00 eppnum00 EPPSEX00 EPCREL00* Drop if not a natural parentdrop if EPCREL00 != 7* Drop if not a femaledrop if EPPSEX00 != 2duplicates drop MCSID EPPSEX00, forcesort MCSID EHPNUM00save ${directory}Intermediate\parent-gender.dta, replace*=================================================================================* Section 2: Merge parent gender into HH grid*=================================================================================use "${directory}Raw\MCS-Survey-5\stata11\mcs5_hhgrid.dta", clear* Keep relevant variableskeep MCSID EHPNUM00 EHPREL0* EHCREL00* Keep only natural parentskeep if EHCREL00 == 7sort MCSID EHPNUM00merge MCSID EHPNUM00 using "${directory}Intermediate\parent-gender.dta"* 99 natural mothers do not have a match in HH griddrop if _merge == 2 | _merge == 1* We are now left only with natural mothers*=================================================================================* Section 3: Compute siblings for each mother*=================================================================================foreach var of varlist EHPREL0A-EHPREL0X {	replace `var' = 0 if `var' != 7	replace `var' = 1 if `var' == 7	* label define `var' 1 "Natural child", replace}egen siblings_from_natural_mother = rsum(EHPREL0A-EHPREL0X)keep MCSID siblings_from_natural_motherlabel var siblings_from_natural_mother "Natural children for CM's mother. Includes half sibs"sort MCSIDsave ${directory}Intermediate\fertility-by-MCSID.dta, replace