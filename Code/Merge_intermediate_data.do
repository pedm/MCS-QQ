*=================================================================================* Section 0: Directories and Setup*=================================================================================vers 10.1 clear allset more offglobal directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/*======================================================================================* Section 1: Prep HH Grid*=====================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_hhgrid.dta", clearsort MCSID* Keep CM onlykeep if EHCREL00 == 96rename EHCNUM00 CMNUMkeep MCSID CMNUM EHCSEX00rename EHCSEX00 CM_Sex*======================================================================================* Section 2: CM quality outcomes*=====================================================================================sort MCSID CMNUMmerge MCSID CMNUM using "${directory}Intermediate/CM_quality_outcomes.dta"drop _merge*======================================================================================* Section 3: Birth Order of CM; Mother edu + health stocks; later born twins*=====================================================================================sort MCSIDmerge MCSID using "${directory}Intermediate/CM_birth_order_and_sibling_count.dta" "${directory}Intermediate/mcs1_mother_derived_variables.dta" "${directory}Intermediate/CM_with_later_born_twins.dta"* These extra observations come from MCS1, since not all CMs could be included in later wavesdrop if _merge == 2drop _merge** Note: If CM are twins, they'll have same birth ordertab CM_birth_order CM_has_later_twin_siblings*======================================================================================* Section 6: Mother fertility (looking at natural mother)*=====================================================================================sort MCSIDmerge MCSID using "${directory}Intermediate/fertility-by-MCSID.dta"drop _merge* Computer mother fertility using siblings + CMsgen mother_fertility = Number_CMs_in_HH + siblings_from_natural_motherlabel var mother_fertility "Fertility: CMs + children for CM's mother. Includes half sibs"* tab mother_fertility fertility_count_by_nat_siblings* We expect Fertility(nat children of mom) = Fert(nat sibs) + Fert(half sibs from CMs mom)* This generally holds: we see mother_fertility > fertility_count_by_nat_siblings for almost all observations* A few exceptions: we see Fert(nat children of mom) = 1 sometimes when Fert(nat sibs) = 2.* In conclusion: mother_fertility is a better measure than fertility_count_by_nat_siblings.* Why? Because it includes half siblings from the same mother* TODO: Birth count should be modified to include half-siblings from same mother. Currently birth count only looks at full siblings*======================================================================================* Section 7: Merge in mother age first birth*=====================================================================================*======================================================================================* Section 8: Merge in mother pre birth info (weight/alcohol/smoking/complications)*=====================================================================================sort MCSIDmerge MCSID using "${directory}Intermediate/mcs1_mother_pregnancy"* _merge == 1: CMs first included in wave 2. Unfortunately wave 2 does not obtain the same information on pre pregnancy health* _merge == 2: CMs included in wave 1 but missing in later wavesdrop if _merge == 2drop _merge*======================================================================================* Section 10: Finish it up*=====================================================================================save "${directory}Final/QQ-Ready-for-Regressions.dta", replacedescribe* TODO: i.mother_age, i.child_age