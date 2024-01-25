************************************************************************
* Project description 
************************************************************************
* Project: U.S. food shopper trends 
* code: Suraj Gurung; ; Suraj Gurung and Angelia Chen; angeliachenlj@gmail.com
* Date Created: November 9, 2021
* Data In: [What data does this do-file draw upon?] "DATA_tracker_202111_ready.dta"
* Data Out: [What data does this do-file produce?]
* Purpose of do-file:
     /*
	Outline
	Part 1: Housekeeping & Introduction
	Part 2: Data preparation； Define useful parameters (macros, scalars, etc), labels, etc
	Part 3: Data work
    */
    
    
************************************************************************
* PART 1: HOUSEKEEPING & INTRODUCTION
************************************************************************
clear
set memory 15000m
set linesize 80 
macro drop _all   
capture log close
log using "2018_consumer_trends.log", replace
set more off
use "/Users/surajgurung/Library/CloudStorage/Dropbox-UFL/Shared with Suraj Gurung/Food shopper trends 2018 data/DATA_food_shopper_trends_2018.dta", clear // 6497 sample

*drop if allgen_new==1

*Install 
/*
net install asdoc, from(http://fintechprofessor.com) replace 
*/

***********************************************************************

************************************************************************
* PART 2: Data preparation
************************************************************************
recode month (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (9=8) (10=9) (11=10) (12=11) (1=12), gen (monthnew)
order monthnew, after (month)

*Define the variable monthnew
la var monthnew "The month that represents consumer perspectives"
note monthnew: Note that the data were collected at the beginning of each month retrospectively. Therefore, the data ///
represent the consumer perspective in the prior month.

   
   *Check if the scale items and the screener have the same value (COMPARED BETWEEEN FOOD ATTITUDE AND ORANGE JUICE PERCEPTION)- same value will be zero and diff value is 1. SO we remove if they all have same value. one right(food attitude) and one left screen (OJ perception).
   
   egen s1_diff=diff (foodattde_1 - foodattde_15 fdatscreen)
   egen s2_diff=diff (ojperception_1 - ojperception_29 ojpscreen)
   tab s1_diff s2_diff
   
   *(Where is diff_fa/oja variable??)
   *order s1_diff, after (diff_fa)
   *order s2_diff, after (diff_ojp)
   
   la var s1_diff "dummy; 0= foodattitude 1-15 and screener have the same value"
   la var s2_diff "dummy; 1= ojpercept 1-195 and screener have the same value"
   
   
   keep if s1_diff ==1 & s2_diff==1
  
*deleted 81 obs. There are "lazy" but "careful" respondents survived the screener but gave identical values in the scale.


**define the region variable***
*********************************************************************************************

gen allgen_new=.
replace allgen_new=1 if gens== 1
replace allgen_new=2 if genb== 1
replace allgen_new=3 if genx== 1
replace allgen_new=4 if genm== 1
replace allgen_new=5 if genz== 1

label de allgen_code_new 1 "Silent Gen" 2 "Baby Boomers" 3 "Generation X" 4 "Millennial" 5 "Gen Z"

label value allgen_new allgen_code_new

label var allgen_new "Allgen_new"

order allgen_new, after (allgen)

drop if allgen_new==. //dropping the greater generation 3 variable

*keeping only region_9

  *9-region solution
gen region_9=3
replace region_9=1 if state == 2 | state ==5 | state ==12 | state ==38 | state ==48
replace region_9=2 if state ==3 | state ==6 |state ==13 | state ==27 | state ==29 | state ==32 | state ==45 | state ==51
 replace region_9=4 if state == 14 | state ==15 | state ==23 | state ==36 | state ==50
replace region_9=5 if state ==31 | state ==33 | state == 39
replace region_9=6 if state ==7 | state ==20 |state ==22 | state ==30 | state ==40 | state ==46
 replace region_9=7 if state == 4 | state ==19 | state ==37 | state ==44
replace region_9=8 if state == 1 | state ==18 | state ==25 | state ==43
replace region_9=9 if state == 8 | state ==9 | state ==10 | state ==11 | state == 21 | state ==34 | state ==41 | state ==47 | state ==49
replace region_9=. if state == 52

label de region_code_9 1 "Pacific" 2 "Mountain" 3 "West North Central" 4 "East North Central" 5 "Middle Atlantic" 6 "New England" 7 "West South Central" 8 "East South Central" 9 "South Atlantic"
label value region_9 region_code_9
label var region_9 "9-region solution"

**Final region 
drop if region_9==. //dropping the one person that live outside the USA


describe, short // Sample data 6412 we have


*save "DataEDIS_2018.dta"

*tab allgen if allgen >1 & allgen !=. //used for figure

** Figure 1

** Create the age group
gen under25 = (age < 25)
gen age_25to35 = (age >= 25 & age <= 35)
gen age_35to45 = (age >= 35 & age <= 45)
gen age_45to55 = (age >= 45 & age <= 55)
gen age_55to65 = (age >= 55 & age <= 65)
gen age_65andabove = (age >65)

gen allage_group = .
replace allage_group=1 if under25== 1
replace allage_group=2 if age_25to35== 1
replace allage_group=3 if age_35to45== 1
replace allage_group=4 if age_45to55== 1
replace allage_group=5 if age_55to65== 1
replace allage_group=6 if age_65andabove== 1

label de allage_code_new 1 "Under 25" 2 "Age 25-35" 3 "Age 35-45" 4 "Age 45-55" 5 "Age 55-65" 6 "Age 65&above"

label value allage_group allage_code_new

label var allage_group "Allage_group"


*Household income
*Goal:Recode household income into three levels 
recode hhinc (1/3=1) (4 5 =2) (6 7 =3), gen(hhinc_3) 
la var hhinc_3 "3-level household income recoded from original var hhinc"
note hhinc_3: This var is recoded from the original var "hhinc"; recode hhinc (1/3=1) (4 5 =2) (6 7 =3), gen(hhinc_3) 
la def income_category_3 1 "<50k" 2 "50-100k" 3 ">100k"
la val hhinc_3 income_category_3

*GLOBAL
global beverage regsoftdrk dsoftdrk dmilk asmilk engdrk sptdrk lfruj allsplwater


************************************************************************
* PART 3: Demographics 
************************************************************************
rename presch kid_6
rename kdgarten kid_9
rename elemen kid_12
rename  teenager kid_18


foreach var of varlist frole gender hhinc_3 edu race ethnic allgen_new hhsize ttlmonth {
	tab `var'    
}

*Composition of the sample graph (NEED SOME EDIT ON THE GRAPH)

sum hhsize age

*Calculated the percentage of pre-school and school age manually from sum data
foreach var of varlist kid_18-kid_6 {
replace `var' =0 if `var'==.  
}

sum kid_6 kid_9 kid_12 kid_18 

gen schoolaged_child = 0
replace schoolaged_child= 1 if kid_9==1
replace schoolaged_child=1 if kid_12==1

sum schoolaged_child //Percentage of school aged children between 6-12. We do not have 6-12 data directly, so I created this one. i.e. 18%

************************************************************************
* PART 3: Food spending
************************************************************************

*What to do with the observation more than 10,000? We removed those. Only see the analysis of people below 1000$.

sum weekly_groexp if  weekly_groexp !=. //we use this result as well.

*For Per Capita
generate percapita_expenditure = (weekly_groexp/hhsize)
order percapita_expenditure, after (weekly_groexp)

sum percapita_expenditure 
sum percapita_expenditure if weekly_groexp <1001 &weekly_groexp !=. //(This is the data we use.)

browse weekly_groexp hhsize hhinc_3 if weekly_groexp >1000 &weekly_groexp !=. //obs=50
sum id weekly_groexp hhsize hhinc_3 if weekly_groexp >2000 &weekly_groexp !=. //obs=18
sum id weekly_groexp hhsize hhinc_3 if weekly_groexp >1000 &weekly_groexp !=. //obs=50

sum id weekly_groexp hhsize hhinc_3 if weekly_groexp <2001 &weekly_groexp !=. //obs=6381

*This is the final food expenditure (THIS IS THE ONE WE USE)
sum id weekly_groexp hhsize hhinc_3 if weekly_groexp <1001 &weekly_groexp !=. //obs=6349
*We usually use $1000 as the weekly expenditure max - Lisa 

tab hhinc_3 if weekly_groexp<2001 & weekly_groexp!=., sum (weekly_groexp)  
tab hhinc_3 if weekly_groexp<1001 & weekly_groexp!=., sum (weekly_groexp)  //we use this DATA on the result section.
tab hhinc_3 if weekly_groexp<501 & weekly_groexp!=., sum (weekly_groexp)  

tab monthnew if weekly_groexp<1001 & weekly_groexp!=., sum (weekly_groexp)
tab monthnew if weekly_groexp<501 & weekly_groexp!=., sum (weekly_groexp)


*Summarize weekly food expenditure based on $500 bar
  sum weekly_groexp if weekly_groexp<501 & weekly_groexp!=.
  tab hhinc_3 if weekly_groexp<501 & weekly_groexp!=., sum (weekly_groexp)  
  tab allgen_new if weekly_groexp<501 & weekly_groexp!=., sum (weekly_groexp) 
 
	 
*Need to account for thr Outliers- Only data less that 1001
graph bar (mean) weekly_groexp if weekly_groexp<1001 & weekly_groexp!=., over (monthnew)

**NEED TO LOOK MORE ON THIS TABLE

asdoc table month if weekly_groexp<1001 & weekly_groexp!=., by(weekly_groexp) save(FST2018_expenditures) title(Descriptive statistics) replace abb(.) label dec(4) ///This data shows the expenses with each weekly_groexp. 

asdoc tabstat weekly_groexp if weekly_groexp<1001 & weekly_groexp!=., stat(mean sd min max) by(monthnew) save(FST2018_expenditures) title(Descriptive statistics) replace abb(.) label dec(4) /// This data shows the expenses with each weekly_groexp by month.

asdoc tabstat weekly_groexp if weekly_groexp<1001 & weekly_groexp!=., stat(mean sd min max) by(ttlmonth) append abb(.) label dec(4)

asdoc tabstat weekly_groexp if weekly_groexp<1001 & weekly_groexp!=., stat(mean sd min max) by(allgen_new) append abb(.) label dec(4)

sum weekly_groexp if  weekly_groexp !=. & weekly_groexp<1001

*The average weekly food expenditure per capita is calculated by dividing the HH expense by the HH size. i.e. (136.18/2.61 = 52.17)

sum hhsize // The average household size is 2.61. The average of our weekly grocery expenses is 136.18 (using data set that weekly grocery is <$1000). = 136.18/2.61= 52.17

tab hhsize //3.28% (210 out of 6412 have 6 more more children)

*Food price sensitivity 
  
  note fp_sens: Recoded from var "fp_sensitivity"; 1= I am still buying my food the same way; 3= I am buying less food; 2= other options under "fp_sensitivity."
  tab fp_sensitivity, generate (fp_sensitivitydum)
  
  *Check for correlation and merge the ones that are highly corrlated.
  pwcorr fp_sensitivity fp_sensitivitydum1- fp_sensitivitydum7 , sig star (0.05)
  pwcorr fp_sensitivitydum1- fp_sensitivitydum7 , sig star (0.05)
  recode fp_sensitivity (7=1) (1/2=2) (5=2) (6=2) (4=3) (3=4), generate(fp_sens4)
  recode fp_sensitivity (7=1) (1=2) (5=2) (2=3) (6=3) (4=4) (3=5), generate(fp_sens5)
  pwcorr fp_sensitivity fp_sens4 fp_sens5, sig star (0.05) //NOT SURE OF fp_sens
  note fp_sensitivity: The name of the label value is "fp_sensitivity."
  la de fp_sens_5levels 1 "I am still buying my food the same way I always have" 2 "I am looking for store deals/promotions and using coupons" ///
              3 "I am buying store brands or larger economy sizes" 4 "I am shopping at super-centers instead of grocery stores" ///
              5 "I am buying less food"			  
  la de fp_sens_4levels 1 "Buying my food the same way I always have" 2 "Looking for in-store deals" ///
              3 "Switching to supercenters for food purchases" 4 "Buying less food"	  
  la val  fp_sens5 fp_sens_5levels
  la val fp_sens4 fp_sens_4levels
  order fp_sensitivitydum1 - fp_sensitivitydum7 fp_sens4 fp_sens5, after (fp_sensitivity)
  
  //final decision is to use fp_sens5 with 5 categories//

 tab fp_sens5 allgen_new 
 
 tab fp_sens5
 
 tab allgen_new
 
 tab fp_sens5 allage_group
 
 //Need to make the table and figure from this.
 
 
*Shopping Outlets

foreach var of varlist supmkt - nonefs{
	replace `var'=0 if `var'==.
}

sort nonefs

sum supmkt - otholt
sum supmkt - otholt if hhinc_3<2 //<50k
sum supmkt - otholt if hhinc_3==2 //50-100k
sum supmkt - otholt if hhinc_3>2 //>100k


asdoc tabstat supmkt - nonefs, stat(mean sd min max) by(hhinc_3) append long format	label


*Store number
generate storenum = ( supmkt+ fresto + consto + spesto + supcnt + wahclb + masmcd + dolsto + drgsto + intgro + milcom + fammkt + otholt + nonefs)
order storenum, after (nonefs)
tab ttlmonth, sum (storenum)
tab monthnew, sum (storenum)

tab hhinc_3, sum (storenum)

sum storenum 

*Conduct the chi-squre test

foreach var of varlist supmkt - nonefs{
	tab `var' hhinc_3, chi2	
}

//Need to make the table and figure from this.
 
************************************************************************
* PART 4: Dietary patterns
************************************************************************

**dietary intake vars**
foreach var of varlist grain-nonefp {
replace `var' =0 if `var'==.
}

egen dietdiv = rowtotal (grain frefru beef pork poultry egg fish candy sltsnk freveg dairy juice othbev)

label var dietdiv "Dietary diversity"

note dietdiv: This variable is the rowtotal of grain frefru beef pork poultry egg fish candy sltsnk freveg dairy juice othbev.

  *balanced diet & food groups*
  gen fru_int =0
  replace fru_int =1 if frefru==1 | juice==1
  label var fru_int "fresh fruits intake -including 100% juices"
  
  gen pro_int =0
  replace pro_int =1 if beef==1 | pork==1 | poultry==1 | egg==1 | fish==1
  
  label var pro_int "Dummy; 1= have protein intake"
  note pro_int: This var includes all kinds of protein, pro_int =1 if beef==1 | pork==1 | poultry==1 | egg==1 | fish==1
  egen pro_div= rowtotal (beef pork poultry egg fish)
  note pro_div: pro_div= rowtotal (beef pork poultry egg fish)
  la var pro_div "Protein intake diversity"
  
  gen sna_int =0
  replace sna_int=1 if candy==1 | sltsnk==1
  label var sna_int "snack intake"
  
  egen foodgroups = rowtotal (grain fru_int pro_int freveg dairy)
  label var foodgroups "Food groups based on GUIDELINES: grain, protein, fruit, vegetable, dairy"
  
  note foodgroups: This var is based on 2015-2020 Dietary Guidelines for Americans, foodgroups = rowtotal (grain fru_int pro_int freveg dairy)
  order dietdiv - foodgroups , after (nonefp)
  
** Calculate the egen with only 10 common food categories
egen dietdiv_common = rowtotal (grain frefru beef pork poultry egg fish freveg dairy juice)  
sum dietdiv_common
 
**************************************************************************
 
tab  race foodgroups
tab  ethnic foodgroups
note foodgroups

foreach var of varlist grain fru_int pro_int freveg dairy foodgroups {
    tab race `var'
    tab ethnic `var'
	tab allgen_new `var'
	tab hhinc_3 `var'
	sum `var'
 }


foreach var of varlist grain fru_int pro_int freveg dairy foodgroups {
    tab hhinc_3 if `var'==1
}

*QSCR6-Which type of food have you personally purchased (store or restaurant) in the past 30 days?
 foreach var of varlist grain - foodgroups {
	replace `var'=0 if `var'==.
}

asdoc sum grain - foodgroups, save(FST2018_food) title (Descriptive statistics) replace abb(.) label dec(4)

**asdoc tabstat grain - foodgroups,  stat(mean sd min max) by(allgen_new) append long format label	

asdoc tabstat grain fru_int pro_int freveg dairy foodgroups,  stat(mean sd min max) by(hhinc_3) append long format label	

asdoc tabstat dietdiv, stat(mean sd min max) by(hhinc_3) append abb(.) label dec(4)

foreach var of varlist grain fru_int pro_int freveg dairy foodgroups {
	tab `var' hhinc_3, chi2	
}

// Significant in grain (0.002), fru_int=0.000, protein= 0.771, veg=0.000, dairy=0.000

************************************************************************
* PART 4: Beverages and water
************************************************************************

*Breakfast
sum bkfstday

*healthy breakfast(NO data)
sum foodattde_3
tab foodattde_3

*Beverage consumption
gen dmilk=0
replace dmilk=1 if whmilk==1 | flmilk==1
la var dmilk "Bought dairy milk incl. flavored"
note dmilk: This var includes both white milk and flavored milk (replace dmilk==1 if whmilk==1 | flmilk==1)
order dmilk, after (othbvg)

gen allsplwater=0
replace allsplwater=1 if splwater==1 | flvsplwater==1
la var allsplwater "Bought sparkling water incl. flavored"
note allsplwater: This var includes both non-flavored and flavored sparkling water (replace dmilk=1 if whmilk==1 | flmilk==1)
order allsplwater, after(othbvg)

*QFJ2-Please indicate if you bought any of the following beverages.

foreach var of varlist regsoftdrk - othbvg {
    replace `var'=0 if `var'==.
 }
 
sum whmilk flmilk asmilk 

asdoc sum  regsoftdrk - othbvg, save(FST2018_beverages) title (Descriptive statistics) replace abb(.) label dec(4)

asdoc tab allgen_new, c(mean whmilk mean flmilk mean asmilk) append abb(.) label dec(4)

  // add "title (Dairy milk and plant-based milk consumption by generation)" wouldn't work but wouldn't produce errors either
  
  
*generate variable for kid under 18
generate kidunder18=.
replace kidunder18=1 if kid_6==1 | kid_9==1 | kid_12==1 | kid_18==1
replace kidunder18=0 if kidunder18==.
  
asdoc tabstat regsoftdrk - othbvg, stat(mean sd min max) by(allgen_new) append long format	label


* Chi-square test

foreach var of varlist regsoftdrk - othbvg {
    tab `var' kidunder18, chi2	
 }

*this is the figure
asdoc tabstat regsoftdrk dsoftdrk dmilk asmilk engdrk sptdrk lfruj allsplwater, stat(mean sd min max) by(kidunder18) append long format	label


asdoc tabstat $beverage, stat(mean sd min max) by(allgen_new) append long format label
   *to check if the numbers are right
    tab allgen_new regsoftdrk, row
	
asdoc bysort allgen_new: sum whmilk flmilk asmilk, append abb(.) dec(4) //option "long" 

**asdoc table allgen_new, c(mean tea mean coffee mean btwater mean flvbtwater ) append abb(.) dec(4)

asdoc table gender hhinc_3, c(mean storenum median weekly_groexp) append abb(.) dec(4)


*QFJ4-How do you or other household members drink water?
foreach var of varlist pln_tap_water - no_water {
	replace `var'=0 if `var'==.	
}

asdoc sum pln_tap_water - no_water, save(FST2018_water) title (How do you or other household members drink water?) ///
      replace abb(.) label dec(4) stat(N mean sd min max)
	  
*asdoc tabstat pln_tap_water - no_water, stat(mean sd min max) by(allgen_new) append long format label	  
	     

*asdoc  tab  edu supmkt, col append abb(.) long


************************************************************************
* PART 5: Social media
************************************************************************
*QMDA1-Which of the following social media sites have you used in the past 30 days?
foreach var of varlist facebook - othsm {
	replace `var'=0 if `var'==.	
}
asdoc sum facebook - othsm, save(FST2018_social_media) title (Which social media sites did you use in the past 30 days?) ///
      replace abb(.) label dec(4) stat(N mean sd min max)
	  
asdoc tabstat facebook - othsm, stat(mean sd min max) by(hhinc_3) append long format label
	  
browse othsm_text if othsm ==1	    


************************************************************************
* PART 5: Best and worst to your health	
************************************************************************

gen edu_new=.

*List for high school, college and graduate level
replace edu_new=1 if edu== 3
replace edu_new=2 if edu== 4
replace edu_new=3 if edu== 5

*QEAT2-Select three charateristics of beverages that you think are the worst for your health
foreach var of varlist ttsugar - iron {
	replace `var'=0 if `var'==.	
}

* Perform a chi-square test by education for Worst Nutrients across educational level
foreach var of varlist ttsugar - iron {
	tab `var' edu_new, chi2
}


*REMOVE the year 

asdoc sum ttsugar - iron, save(Trends_worst_4_health.doc) title (Three factors that are worst for your health) ///
      replace abb(.) label dec(4) stat(N mean sd min max) 
	  
asdoc tabstat ttsugar - iron, stat(mean sd min max) by(allgen_new) append long format label	 

asdoc tabstat ttsugar - iron, stat(mean sd min max) by(edu_new) append long format label
	

*QEAT3-Select three charateristics that you try to include in your diet regularly
foreach var of varlist potassium - flavonoid {
	replace `var'=0 if `var'==.	
}

* Perform a chi-square test by education for Bestt Nutrients across educational level
foreach var of varlist potassium - flavonoid  {
	tab `var' edu_new, chi2
}

asdoc sum potassium - flavonoid, save(Trends_best_4_health.doc) title (Three factors that are best for your health) ///
      replace abb(.) label dec(4) stat(N mean sd min max) 
	  
asdoc tabstat potassium - flavonoid, stat(mean sd min max) by(allgen_new) append long format label	  

asdoc tabstat potassium - flavonoid, stat(mean sd min max) by(edu_new) append long format label	  

************************************************************************
* PART 5: Food-related attitudes
************************************************************************

*Should I add all 14 food attitude? Or we use correlation and remove that are highly correlated?

sum foodattde_1 foodattde_2 foodattde_4 foodattde_5 foodattde_7 foodattde_8 foodattde_9 foodattde_10 foodattde_13

foreach var of varlist foodattde_1 foodattde_2 foodattde_4 foodattde_5 foodattde_7 foodattde_8 foodattde_9 foodattde_10 foodattde_13  {
	tab `var' 
}

cls


foreach var of varlist foodattde_1 foodattde_2 foodattde_4 foodattde_5 foodattde_7 foodattde_8 foodattde_9 foodattde_10 foodattde_13  {
	tab allgen_new `var' if `var' >4
}

asdoc tabstat foodattde_1 foodattde_2 foodattde_4 foodattde_5 foodattde_7 foodattde_8 foodattde_9 foodattde_10 foodattde_13, stat(mean sd min max) by(allgen_new) append long format label	


order allgen_new allage_group

* By the new age group

foreach var of varlist foodattde_1 foodattde_2 foodattde_4 foodattde_5 foodattde_7 foodattde_8 foodattde_9 foodattde_10 foodattde_13  {
	tab allage_group `var' if `var' >4
}

asdoc tabstat foodattde_1 foodattde_2 foodattde_4 foodattde_5 foodattde_7 foodattde_8 foodattde_9 foodattde_10 foodattde_13, stat(mean sd min max) by(allage_group) append long format label	


*Create the (% of consumers who believed organic is more nutritious in all consumers who sought out organic

tab foodattde_8 foodattde_8 /// seek out forganic food = 2397

gen consumer_believe = . 

replace consumer_believe=1 if foodattde_8==5
replace consumer_believe=1 if foodattde_8==6
replace consumer_believe=1 if foodattde_8==7

replace consumer_believe=0 if consumer_believe==.

tab consumer_believe


tab foodattde_13 foodattde_13 ///Believe organic food is more nutritious =  3036

gen consumer_believe1 = . 

replace consumer_believe1=1 if foodattde_13==5
replace consumer_believe1=1 if foodattde_13==6
replace consumer_believe1=1 if foodattde_13==7

replace consumer_believe1=0 if consumer_believe1==.

tab consumer_believe1

*Our desired parameter

generate consumer_believe2=.

replace consumer_believe2 = 1 if consumer_believe == 1 & consumer_believe1 == 1 & consumer_believe2 == .

replace consumer_believe2 = 0 if consumer_believe2==.

tab consumer_believe2 //Here the 2028 repressent the population that believe organic food is more nutritious than conventional food.

** 2028/2397*100 = 85%

log close
exit
