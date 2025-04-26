/* Forming kids cohort for my capstone project

   BMI - 39156-5
   BMI percentile
   Height - 8302-2
   Weight - 3141-9

    Using: https://www.cdc.gov/nccdphp/dnpa/growthcharts/training/modules/module1/text/module1print.pdf

*/

proc sort data=raw.vitals_signs;
    by patient_id;
run;


data bmi;
    merge scd2.kids19(in=i) raw.vitals_signs scd.patient(keep=patient_id year_of_birth);
    by patient_id;
    
    if i;
    if not missing(value);

    /* these are by far the most common codes by category */
    length desc $8;
    if code='39156-5' then desc='BMI';
    if code='59574-4' then desc='BMI Percentile';
    if code='8302-2' then desc='Height';
    if code='3141-9' then desc='Weight';

    if not missing(desc);
    
    keep patient_id sex race year_of_birth date code desc value units_of_measure;
run;

proc sort data=bmi out=check nodupkey;
    by patient_id;
run;

/* Get Date */
data bmi;
    set bmi;

    code_d = input(date, yymmdd10.);
    format code_d date9.;

    b_day = 1;
    b_mo = 1;
    dob = mdy(b_mo, b_day, year_of_birth);

    format dob date9.;

    drop b_day b_mo;
run;

data bmi;
    set bmi;
    drop date;
    age = intck('year', dob, code_d);
run;
/* --------- */



/* Get Patients with data between 2014-2019 */
proc sort data=bmi nodupkey;
    by patient_id code code_d;
run;

proc sort data=bmi;
    by patient_id code_d;
run;

data bmi;
    set bmi;
    if code_d < '01JAN2020'd;

run;

/* --------------------------------------- */

/* Need to calc BMI for patients with Height + weight on the same date */
/* After calc, set desc = bmi*/

/* No outstanding height / weight
proc freq data=bmi;
    tables desc;
run;

/* -------------- */

/* Look at BMI only - transpose for growth over time */
data bmi;
    set bmi;
    if desc='BMI';
run;

/* make additional predictors. Take log_BMI*/
proc sort data=bmi out=check nodupkey;
    by patient_id;
run;

data bmi;
    set bmi;
    BMI = input(value, 8.);
    code_yr = year(code_d);
    drop desc value;
run;

proc sort data=bmi nodupkey;
    by patient_id code_d;
run;

proc means data=bmi median noprint;
    by patient_id code_yr;
    var BMI;
    output out=results median(BMI)=median_BMI;
run;


proc sort data=bmi out=bmi_s nodupkey;
    by patient_id code_yr;
run;

data results;
    merge results(in=i) bmi_s;
    by patient_id code_yr;

    keep patient_id code_yr median_BMI sex race year_of_birth age;
run;

/* Rid of outliers

There is a sound solution in here somewhere to determining where outliers exist,
    comparing them to the expect value based on previous and next bmi reporting
    where if there isn't a next or previous, we could impute them. But for the sake of time
    I know that a lot of the crazy outliers are in the top 100 BMI, so I'm just going
    to delete them myself by looking through.
*/

proc sort data=results out=results;
    by descending median_BMI;
run;

/* First Pass: Get the previous BMI */
proc sort data=results out=check;
    by patient_ID age;
run;

data with_prev_bmi;
    set check;
    by patient_ID;
    prev_BMI = lag(median_BMI);
    if first.patient_ID then prev_BMI = .;
run;

/* Reverse Sort for Second Pass*/
proc sort data=results out=check2;
    by descending patient_ID descending age;
run;

data with_next_bmi;
    set check2;
    by descending patient_ID descending age;
    next_BMI = lag(median_BMI);
    if first.patient_ID then next_BMI = .;
run;

/* Sort back to original order*/ 
proc sort data=with_next_bmi;
    by patient_ID age;
run;

/* Merge the two datasets */
data combined;
    merge with_prev_bmi (in=a) with_next_bmi (in=b);
    by patient_ID age;
    if a and b;

    prev_change = abs(median_BMI - prev_BMI) / prev_BMI;
    next_change = abs(median_BMI - next_BMI) / next_BMI;

run;

proc sort data=combined;
    by age descending median_BMI;
run;

data combined;
    set combined;
    by age;
    
    if first.age then counter = 0;
    counter + 1;
    if counter <= 10;
run;
    

/* Output the final dataset */
proc print data=combined;
    var patient_ID age prev_BMI median_BMI next_BMI;
    *where patient_id = '7937ec9a0ce3fa3f82af520e0bf54d8e703c9a27';
    where 7 <= age <= 13;
run;


data results;
    set results;
    if age=8 & median_bmi > 40 then delete;
    if age=9 & median_BMI = 32.000 then delete;
    if median_BMI = 0 then delete;
run;


/* MALE CHILDREN */

title 'Male Children';

data bmi_m;
    set results;
    if sex='M';

    sqrtAge = sqrt(age);
    InveAge = 1/age;
    LogBMI = log(median_BMI);

run;

proc freq data=bmi_m;
    tables patient_id / nocum;
run;

proc sort data=bmi_m out=check nodupkey;
    by patient_id age;
run;


proc univariate data=bmi_m;
    var median_bmi;
run;

proc quantreg data=bmi_m algorithm=interior(tolerance=1e-5) ci=sparsity;
    model logbmi = inveage sqrtage age sqrtage*age age*age age*age*age
        / quantile=0.03 0.05 0.1 0.25 0.5 0.75 0.85 0.9 0.95 0.97;
    output out=outp pred=p stdp=std_error/columnwise;
run;

data outbmi_m;
    set outp;
    pbmi=exp(p);
    pbmi_err = exp(std_error);
run;

proc sort data=outbmi_m;
    by age;
run;

data fin.outbmi_m_meeting;
    set outbmi_m;
run;

proc print;



/*
proc sgplot data=outbmi_m;
    title 'BMI Percentiles for Male Children with Sickle Cell Disease: 1-17 Years Old (N=632)';
    yaxis label='BMI (kg/m^2)' min=8 max=50 values=(8 to 50 by 2);
    y2axis label=' ' min=8 max=50 values=(8 to 50 by 2);
    xaxis label='Age (Years)' min=2 max=17 values=(1 to 17 by 1);
    scatter x=age y=median_BMI / markerattrs=(size=2);
    scatter x=age y=median_BMI / markerattrs=(size=0) y2axis;
    series x=age y=pbmi/group=QUANTILE lineattrs=(thickness=2 pattern=solid) smoothconnect;
run;

/* FEMALE CHILDREN */

title 'Female Children';

data bmi_f;
    set results;
    if sex='F';

    sqrtAge = sqrt(age);
    InveAge = 1/age;
    LogBMI = log(median_BMI);
run;

proc freq data=bmi_f order=freq;
    tables patient_id / nocum;
run;

proc sort data=bmi_f out=check nodupkey;
    by patient_id;
run;

proc quantreg data=bmi_f algorithm=interior(tolerance=1e-5) ci=sparsity;
    model logbmi = inveage sqrtage age sqrtage*age age*age age*age*age
        / quantile=0.03 0.05 0.1 0.25 0.5 0.75 0.85 0.9 0.95 0.97;
    output out=outp pred=p stdp=std_error /columnwise;
run;

data outbmi_f;
    set outp;
    pbmi=exp(p);
    pbmi_err = exp(std_error);
run;

proc sort data=outbmi_f;
    by age;
run;


data fin.outbmi_f_tab;
    set outbmi_f;
run;



proc print;
run;


*proc print data=outbmi_f;
/*
proc sgplot data=outbmi_f;
    title 'BMI Percentiles for Female Children with Sickle Cell Disease: 1-17 Years Old (N=588)';
    yaxis label='BMI (kg/m^2)' min=8 max=50 values=(8 to 50 by 2);
    y2axis label=' ' min=8 max=50 values=(8 to 50 by 2);
    xaxis label='Age (Years)' min=2 max=17 values=(1 to 17 by 1);
    scatter x=age y=median_BMI / markerattrs=(size=2);
    scatter x=age y=median_BMI / markerattrs=(size=0) y2axis;
    series x=age y=pbmi/group=QUANTILE lineattrs=(thickness=2 pattern=solid) smoothconnect;
run;

/* ----------------------------- */

/* ----------------------------- */

title 'male bmi table';
data outbmi_m;
    set outbmi_m;
    keep age pbmi quantile lowercl uppercl;

    quantile=quantile*100;
    if age > 1;

    uppercl = pbmi + (1.96 * pbmi_err);
    lowercl = pbmi - (1.96 * pbmi_err);
run;



proc sort data=outbmi_m nodup;
    by age;
run;



proc print;
run;

proc transpose data=outbmi_m out=fin.outbmi_m_error(drop=_NAME_) prefix=P;
    by age;
    id quantile;
    var pbmi lowercl uppercl;
run;

data fin.outbmi_m_error;
    length stat $7;
    set fin.outbmi_m_error;
    by age;

    if first.age then stat='pred';
    if last.age then stat='uppercl';
    else if missing(stat) then stat='lowercl';
run;

proc print;
run;

title 'female bmi table';
data outbmi_f;
    set outbmi_f;
    keep age pbmi quantile lowercl uppercl;

    quantile=quantile*100;
    if age > 1;

    uppercl = pbmi + (1.96 * pbmi_err);
    lowercl = pbmi - (1.96 * pbmi_err);
run;


proc sort data=outbmi_f nodup;
    by age;
run;


proc transpose data=outbmi_f out=fin.outbmi_f_error(drop=_NAME_) prefix=P;
    by age;
    id quantile;
    var pbmi lowercl uppercl;
run;

data fin.outbmi_f_error;
    set fin.outbmi_f_error;
    by age;

    if first.age then stat='pred';
    if last.age then stat='uppercl';
    else if missing(stat) then stat='lowercl';
run;


proc print;
run;

endsas;


/* Workaround for formatted dates
    (might not need)
*

proc export data=bmi
    outfile='cap/format_workaround.csv'
        dbms=csv replace;
run;


proc import datafile='cap/format_workaround.csv'
    out=bmi
    dbms=csv
    replace;
run;
/* ------------------------------ */


proc transpose data=bmi out=bmi_t;
    by patient_id;
    id code_d;
    var value;
run;

data bmi_t;
    retain patient_id DEC2019 NOV2019 OCT2019 SEP2019 AUG2019 JUL2019 JUN2019 MAY2019 APR2019 MAR2019 FEB2019 JAN2019
        DEC2018 NOV2018 OCT2018 SEP2018 AUG2018 JUL2018 JUN2018 MAY2018 APR2018 MAR2018 FEB2018 JAN2018
        DEC2017 NOV2017 OCT2017 SEP2017 AUG2017 JUL2017 JUN2017 MAY2017 APR2017 MAR2017 FEB2017 JAN2017
        DEC2016 NOV2016 OCT2016 SEP2016 AUG2016 JUL2016 JUN2016 MAY2016 APR2016 MAR2016 FEB2016 JAN2016
        DEC2015 NOV2015 OCT2015 SEP2015 AUG2015 JUL2015 JUN2015 MAY2015 APR2015 MAR2015 FEB2015 JAN2015
        DEC2014 NOV2014 OCT2014 SEP2014 AUG2014 JUL2014 JUN2014 MAY2014 APR2014 MAR2014 FEB2014 JAN2014;
    set bmi_t;
run;

proc contents;

/* ordering */
data cap.bmi_k;
    merge scd2.kids19(keep=patient_id sex race age14-age19) bmi_t;
    by patient_id;
    
run;

proc print;

/* --------------------------------------------------- */

/* Could use consec variable here now */
