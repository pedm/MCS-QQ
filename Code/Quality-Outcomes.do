*=================================================================================* Section 0: Directories and Setup*=================================================================================vers 10.1 clear allset more offglobal directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/*======================================================================================* Section 1: Quality outcomes (from child survey)*=====================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_cm_asssessment.dta", clearkeep MCSID ECCNUM00 EVSTSCOrename ECCNUM00 CMNUMrename EVSTSCO Quality_EVSTSCOreplace Quality_EVSTSCO =. if Quality_EVSTSCO <=0* EVSTSCO	Variable label = S5 DV Verbal Sims standard scoresort MCSID CMNUMsave "${directory}Intermediate/CM_quality_outcomes.dta", replace*======================================================================================* Section 2: Quality outcomes (from parent survey)*=====================================================================================* SDQ Behavioural Development - Measure of Total Difficulties for each CM* S4 DV SDQ Total Difficulties	C1,C2,C3* ddebdta0,ddebdtb0, ddebdtc0* do more here