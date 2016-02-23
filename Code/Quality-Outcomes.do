*=================================================================================* Section 0: Directories and Setup*=================================================================================vers 10.1 clear allset more offglobal directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/*======================================================================================* Section 1: EVSTSCO Verbal Score (from child survey S5)*=====================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_cm_asssessment.dta", clearkeep MCSID ECCNUM00 EVSTSCO AGErename ECCNUM00 CMNUM* Verbal Similarities - an assessment from the British Ability Scales: Second Edition (BAS 2) which assesses children’s verbal reasoning and verbal knowledge.* Raw score, ability score and T-scores or standardised scores. There are some issues to keep in mind when using ability scores. The first is that it not a truly continuous scale. rename EVSTSCO Q_Verbal_Similaritiesreplace Q_Verbal_Similarities =. if Q_Verbal_Similarities <=0replace AGE = . if AGE < 0gen CM_age_interview5 = AGE*12lab var CM_age_interview5 "S5 Age in months at time of Verbal Sims interview"drop AGEsort MCSID CMNUMsave "${directory}Intermediate/CM_quality_outcomes.dta", replace*======================================================================================* Section 2: NFER Number Skills, BAS Word Reading, BAS Pattern Construction (Survey 4)*=====================================================================================use "${directory}Raw/MCS-Survey-4/stata9_se/mcs4_assessment_final.dta"rename mcsid MCSIDrename dccnum00 CMNUMrename dcagem00 CM_age_interview4rename dcnsco00 Q_Number_Skillsrename dcwrab00 Q_Word_Readingrename dcwrsd00 Q_Word_Reading_Standardrename dcpcab00 Q_Pattern_Constructionrename dcpcts00 Q_Pattern_Constr_Treplace CM_age_interview4 = . if CM_age_interview4 < 0replace Q_Number_Skills = . if Q_Number_Skills < 0replace Q_Word_Reading = . if Q_Word_Reading < 0replace Q_Word_Reading_Standard = . if Q_Word_Reading_Standard < 0replace Q_Pattern_Construction = . if Q_Pattern_Construction < 0replace Q_Pattern_Constr_T = . if Q_Pattern_Constr_T < 0keep MCSID CMNUM CM_age_interview4 Q_Number_Skills Q_Word_Reading Q_Word_Reading_Standard Q_Pattern_Construction Q_Pattern_Constr_Tsort MCSID CMNUMsave "${directory}Intermediate/CM_quality_outcomes4.dta", replace*======================================================================================* Section 3: Quality outcomes (from parent survey)*=====================================================================================* SDQ Behavioural Development - Measure of Total Difficulties for each CM* S4 DV SDQ Total Difficulties	C1,C2,C3* ddebdta0,ddebdtb0, ddebdtc0/*Wave 3:Family activitiesMain and partner respondents were asked how often they engaged in a number of activities with their children. A selection of their responses is shown in Tables 4.3 to 4.10. A full list of the activities that both main and partner respondents were asked about were reading to their child; telling stories not from a book; doing musical activities; drawing, painting, or making things; playing sports or physically active games; playing with toys or games indoors; and going to a park or outdoor playground with their children.The extent to which parents engage in such activities may be influenced by a number of factors including whether or not they work, how much time they have at home to spend with their children, how many other children they have, and what resources are available to them. The list of activities included in questions is not exhaustive and parents may spend time with their children in activities that were not asked about. There may specifically be culture- specific activities that were not included in the questionnaire.Mothers reported engaging in all activities more often than did fathers, with the exception of playing sports or physically active games. Mothers reported reading to their children more frequently than any of the other activities.Similar patterns can be seen across the various activities and for both mothers and fathers. Parents in England tended to engage in the activities less frequently than those in other countries, with parents in Scotland and Northern Ireland engaging in many activities more frequently than did parents in England and Wales. Pakistani and Bangladeshi parents tended to engage in activities less frequently than other parents and black parents also reported slightly lower frequency of involvement.Differences by parental employment status were not consistent. Parents who were not working were more likely to be clustered at each end of the response options; for most activities, a higher percentage of parents who were not working reported engaging in the activity every day and a higher percentage also reported never engaging in the activity. Other than this, there were few consistent differences. Mothers who were employed reported more frequently engaging in sports and physically active games but less frequently reading to their children. Employed fathers read to their children more frequently, but were less often engaged in story-telling and musical activities.*//*MCS4: Child obesity?*/local parentVars dmcmkd00 dmcswhaa dmcswhab dmcswhac dmscfcaa dmrstpaa daoutc00 mcsid dmsctya0 dmrabsa0 dmsabsa0 dmwabsa0 dmasmia0 dmasuna0 dmamtha0 dmareda0 dmineva0 dmhlwxa0 dmalrda0 dmalwha0use `parentVars' using "/Users/pedm/Documents/jobs/Damian-Clarke/Data/Raw/MCS-Survey-4/stata9_se/mcs4_parent_interview.dta"rename mcsid MCSID* Interesting: Variable = dmcmkd00	Variable label = S4 MAIN Whether plan to have more children  * Pos. = 800	Variable = dmcswhaa	Variable label = S4 MAIN Reason for more than one school MC1 C1  * Pos. = 801	Variable = dmcswhab	Variable label = S4 MAIN Reason for more than one school MC2 C1  * Pos. = 802	Variable = dmcswhac	Variable label = S4 MAIN Reason for more than one school MC3 C1  * Value = 3	Label = Excluded from previous school  * Value = 7	Label = Moved in order to go to a better school* Finding: many examples of "Moved in order to go to a better school." Not many of "Excluded from previous school"* Pos. = 810	Variable = dmscfcaa	Variable label = S4 MAIN  Important factors in choosing school MC1 C1    replace dmrstpaa =. if dmrstpaa <= 0replace dmrstpaa =. if dmrstpaa == 96rename dmrstpaa steps_for_schoolgenerate Q_Proactive_School_Selection = 0replace Q_Proactive_School_Selection = 1 if steps_for_school != .lab var Q_Proactive_School_Selection "S4 MAIN Steps taken to get CM into school MC1 C1"* Other* Pos. = 832	Variable = dmsctya0	Variable label = S4 MAIN  School fees applicable C1  * Pos. = 852	Variable = dmrabsa0	Variable label = S4 MAIN What was the main reason why CM has been off school C1  * Pos. = 850	Variable = dmsabsa0	Variable label = S4 MAIN During this school year, has CM ever been off school C1 * Pos. = 851	Variable = dmwabsa0	Variable label = S4 MAIN In total how many complete weeks has CM been off C1 * Pos. = 883	Variable = dmasmia0	Variable label = S4 MAIN Would like CM to stay on at school C1   * Pos. = 884	Variable = dmasuna0	Variable label = S4 MAIN Would you like CM to attend university? C1  * Pos. = 885	Variable = dmamtha0	Variable label = S4 MAIN Does CM have difficulty at school with maths C1 * Pos. = 886	Variable = dmareda0	Variable label = S4 MAIN Does CM have difficulty at school with reading C1   * Pos. = 889	Variable = dmineva0	Variable label = S4 MAIN  Whether anyone has attended parent's evening C1    * Pos. = 912	Variable = dmhlwxa0	Variable label = S4 MAIN How often CM helped with writing C1 * Pos. = 909	Variable = dmalrda0	Variable label = S4 MAIN Help with reading C1    * Pos. = 910	Variable = dmalwha0	Variable label = S4 MAIN How often help with reading C1  * Help with readingreplace dmalwha0 =. if dmalwha0 <= 0gen Q_Help_Reading_Freq = 0replace Q_Help_Reading_Freq = 5 if dmalwha0 == 1replace Q_Help_Reading_Freq = 3.5 if dmalwha0 == 2replace Q_Help_Reading_Freq = 1.5 if dmalwha0 == 3replace Q_Help_Reading_Freq = 0.5 if dmalwha0 == 4lab var Q_Help_Reading_Freq "S4 MAIN How often help C1 with reading per five day week (computed)"replace dmhlwxa0=. if dmhlwxa0 <=0gen Q_Help_Writing_Freq = 0replace Q_Help_Writing_Freq = 5 if dmhlwxa0 == 1replace Q_Help_Writing_Freq = 3.5 if dmhlwxa0 == 2replace Q_Help_Writing_Freq = 1.5 if dmhlwxa0 == 3replace Q_Help_Writing_Freq = 0.5 if dmhlwxa0 == 4lab var Q_Help_Writing_Freq "S4 MAIN How often help C1 with writing per five day week (computed)"keep MCSID Q_Proactive_School_Selection Q_Help_Reading_Freq Q_Help_Writing_Freqsort MCSIDsave "${directory}Intermediate/CM_quality_outcomes4_parent.dta", replace* TODO: slight improvement to be had if I use separate data for C2, C3* TODO: keep looking from 912 on (parent_interview_ukda_data_dictionary.rtf)