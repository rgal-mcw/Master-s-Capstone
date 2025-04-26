/* Compare CDC growth charts to ours for SCD kids */


/* ========== */
/*    Male    */
/* ========== */


data bmi_m;
    set fin.outbmi_m_error;
    id = 'scd_male';
    sex='M';
run;


data bmi_cdc_m;
    set cap.cdc_bmi_m;
    id = 'cdc_male';
    *drop L M S;
    stat='cdc';
    sex='M';
run;

data male;
    set bmi_m bmi_cdc_m;
    *drop sex;
run;

proc sort data=male;
    by age;
run;


proc transpose data=male out=male_t;
    by age;
    id id stat;
run;

data male_t;
    set male_t;
    rename _NAME_ = P;
run;
    
proc print data=male_t;
run;

/* Ideas for comparison graph:
    * Turn down the alpha of the CDC data
    * Segment for many different graphs
*/
footnote;
ods graphics on / imagename='Male_BMI_Compare_Fin' width=9in height=11in;
proc sgplot data=male_t noautolegend;
    title 'BMI Percentiles for Male Children with SCD (N=632) with Comparison to Healthy Male Children';
    yaxis label='BMI (kg/m^2)' min=8 max=32 values=(8 to 40 by 2);
    y2axis label=' ' min=8 max=32 values=(8 to 40 by 2);
    xaxis label='Age (Years)' min=8 max=17 values=(8 to 17 by 1);
    scatter x=age y=scd_malepred / markerattrs=(size=0.5) /*yerrorlower=scd_malelowercl yerrorupper=scd_maleuppercl*/;
    scatter x=age y=scd_malepred / markerattrs=(size=0) y2axis;
    series x=age y=scd_malepred /group=P lineattrs=(thickness=2.75 pattern=solid) smoothconnect curvelabel curvelabelpos=min curvelabelloc=inside curvelabelattrs=(Weight=Bold);

    series x=age y=cdc_malecdc /group=P lineattrs=(thickness=2 pattern=dot) transparency=0.45 smoothconnect curvelabel curvelabelpos=max curvelabelloc=inside;
run;


/* Macro to make a ton of plots - going to animate them together */

%macro percentile_bands_plots_m;
    %let P_list = P3 P5 P10 P25 P50 P75 P85 P90 P95 P97;
    %let p_count = %sysfunc(countw(&P_list));

    %do i=1 %to &p_count;
        %let percentile = %scan(&P_list, &i);
        %let p_name = &percentile._male;

        data temp;
            set male_t;
            if P = "&percentile";
        run;

        ods listing gpath="/data/shared/SCD/ryan/essay/final/plots/male";
        ods graphics on / imagename="&p_name" width=9in height=11in;
        proc sgplot data=temp noautolegend;
            title 'BMI Percentiles for Male Children with SCD (N=632) with Comparison to Healthy Male Children';
            yaxis label='BMI (kg/m^2)' min=8 max=32 values=(8 to 40 by 2);
            y2axis label=' ' min=8 max=32 values=(8 to 40 by 2);
            xaxis label='Age (Years)' min=8 max=17 values=(8 to 17 by 1);
            scatter x=age y=scd_malepred / markerattrs=(size=0.5) /*yerrorlower=scd_malelowercl yerrorupper=scd_maleuppercl*/;
            scatter x=age y=scd_malepred / markerattrs=(size=0) y2axis;
            series x=age y=scd_malepred / group=P lineattrs=(thickness=2.75 pattern=solid) smoothconnect curvelabel curvelabelpos=min curvelabelloc=inside curvelabelattrs=(Weight=Bold);
            series x=age y=cdc_malecdc / group=P lineattrs=(thickness=2.75 pattern=dot) transparency=0.15 smoothconnect curvelabel curvelabelpos=max curvelabelloc=inside;
            band x=age lower=scd_malelowercl upper=scd_maleuppercl / group=P fillattrs=(color=lightgray transparency=0.66);
        run;
     %end;
%mend;

%percentile_bands_plots_m;

/* version control - make sdc_bmi_m_err in to scd_bmi_m in first datastep
ods graphics on / imagename='Male_BMI_Compare_CL' width=9in height=11in;
proc sgplot data=male_t noautolegend;
    title 'BMI Percentiles for Male Children with SCD (N=632) with Comparison to Healthy Male Children';
    yaxis label='BMI (kg/m^2)' min=8 max=32 values=(8 to 40 by 2);
    y2axis label=' ' min=8 max=32 values=(8 to 40 by 2);
    xaxis label='Age (Years)' min=8 max=17 values=(8 to 17 by 1);
    scatter x=age y=scd_male / markerattrs=(size=2);
    scatter x=age y=scd_male / markerattrs=(size=0) y2axis;
    series x=age y=scd_male /group=P lineattrs=(thickness=2.75 pattern=solid) smoothconnect curvelabel curvelabelpos=min curvelabelloc=inside curvelabelattrs=(Weight=Bold);
    series x=age y=cdc_male /group=P lineattrs=(thickness=2 pattern=dot) transparency=0.45 smoothconnect curvelabel curvelabelpos=max curvelabelloc=inside;

run;

*/


/* ========== */
/*   Female   */
/* ========== */

data bmi_f;
    set fin.outbmi_f_error;
    id = 'scd_female';
    sex='F';
run;

data bmi_cdc_f;
    set cap.cdc_bmi_f;
    id = 'cdc_female';
    *drop L M S;
    stat='cdc';
    sex='F';
run;

data female;
    set bmi_f bmi_cdc_f;
    *drop sex;
run;


proc sort data=female;
    by age;
run;


proc transpose data=female out=female_t;
    by age;
    id id stat;
run;

data female_t;
    set female_t;
    rename _NAME_ = P;
run;
    

proc print data=female_t;
run;

footnote;
ods listing gpath="/data/shared/SCD/ryan/essay/final";
ods graphics on / imagename='Female_BMI_Fin' width=9in height=11in;
proc sgplot data=female_t noautolegend;
    title 'BMI Percentiles for Female Children with SCD (N=588) with Comparison to Healthy Female Children';
    yaxis label='BMI (kg/m^2)' min=8 max=32 values=(8 to 40 by 2);
    y2axis label=' ' min=8 max=32 values=(8 to 40 by 2);
    xaxis label='Age (Years)' min=8 max=17 values=(8 to 17 by 1);
    scatter x=age y=scd_femalepred / markerattrs=(size=0.5) /*yerrorlower=scd_malelowercl yerrorupper=scd_maleuppercl*/;
    scatter x=age y=scd_femalepred / markerattrs=(size=0) y2axis;
    series x=age y=scd_femalepred /group=P lineattrs=(thickness=2.75 pattern=solid) smoothconnect curvelabel curvelabelpos=min curvelabelloc=inside curvelabelattrs=(Weight=Bold);
    series x=age y=cdc_femalecdc /group=P lineattrs=(thickness=2 pattern=dot) transparency=0.45 smoothconnect curvelabel curvelabelpos=max curvelabelloc=inside;
run;

%macro percentile_bands_plots_f;
    %let P_list = P3 P5 P10 P25 P50 P75 P85 P90 P95 P97;
    %let p_count = %sysfunc(countw(&P_list));

    %do i=1 %to &p_count;
        %let percentile = %scan(&P_list, &i);
        %let p_name = &percentile._female;

        data temp;
            set female_t;
            if P = "&percentile";
        run;

        ods listing gpath="/data/shared/SCD/ryan/essay/final/plots//female";
        ods graphics on / imagename="&p_name" width=9in height=11in;
        proc sgplot data=temp noautolegend;
            title 'BMI Percentiles for Female Children with SCD (N=588) with Comparison to Healthy Female Children';
            yaxis label='BMI (kg/m^2)' min=8 max=40 values=(8 to 40 by 2);
            y2axis label=' ' min=8 max=40 values=(8 to 40 by 2);
            xaxis label='Age (Years)' min=8 max=17 values=(8 to 17 by 1);
            scatter x=age y=scd_femalepred / markerattrs=(size=0.5) /*yerrorlower=scd_malelowercl yerrorupper=scd_maleuppercl*/;
            scatter x=age y=scd_femalepred / markerattrs=(size=0) y2axis;
            series x=age y=scd_femalepred / group=P lineattrs=(thickness=2.75 pattern=solid) smoothconnect curvelabel curvelabelpos=min curvelabelloc=inside curvelabelattrs=(Weight=Bold);
            series x=age y=cdc_femalecdc / group=P lineattrs=(thickness=2.75 pattern=dot) transparency=0.15 smoothconnect curvelabel curvelabelpos=max curvelabelloc=inside;
            band x=age lower=scd_femalelowe upper=scd_femaleuppe / group=P fillattrs=(color=lightgray transparency=0.66);
        run;
     %end;
%mend;

%percentile_bands_plots_f;

endsas;

/*
ods graphics on / imagename='Female_BMI_Compare' width=9in height=11in;
proc sgplot data=female_t noautolegend;
    title 'BMI Percentiles for Female Children with SCD (N=588) with Comparison to Healthy Female Children';
    yaxis label='BMI (kg/m^2)' min=8 max=40 values=(8 to 40 by 2);
    y2axis label=' ' min=8 max=40 values=(8 to 40 by 2);
    xaxis label='Age (Years)' min=7 max=17 values=(8 to 17 by 1);
    scatter x=age y=scd_female / markerattrs=(size=2);
    scatter x=age y=scd_female / markerattrs=(size=0) y2axis;
    series x=age y=scd_female /group=P lineattrs=(thickness=2.75 pattern=solid) smoothconnect curvelabel curvelabelpos=min curvelabelloc=inside curvelabelattrs=(Weight=Bold);
    series x=age y=cdc_female /group=P lineattrs=(thickness=2 pattern=dot) transparency=0.45 smoothconnect curvelabel curvelabelpos=max curvelabelloc=inside;
run;


/* ========
   Both
   ======== */
title 'both';

data both;
    set male female;

    if id = 'cdc_male' then do;
        sex='M';
        grp = 'cdc';
    end;
    if id = 'cdc_fema' then do;
        sex='F';
        grp='cdc';
    end;

    if missing(grp) then grp='scd';

run;

proc means data=both noprint;
    class age grp;
    var P3 P5 P10 P25 P50 P75 P85 P90 P95 P97;
    output out=both_means;
run;

data both_means;
    set both_means;
    if not missing(age);
    if not missing(grp);
    if _STAT_ = 'MEAN';

    drop _TYPE_ _FREQ_ _STAT_;
run;

proc transpose data=both_means out=both_t;
    by age;
run;

data both_t;
    set both_t;

    rename _NAME_ = P;
    rename COL1 = CDC;
    rename COL2 = SCD;
run;

proc print data=both_t;
run;

ods graphics on / imagename='Both_BMI_Compare' width=9in height=11in;
proc sgplot data=both_t noautolegend;
    title 'BMI Percentiles for Combined Male & Female Children with SCD (N=1220) with Comparison to Healthy, Combined Male & Female Children';
    yaxis label='BMI (kg/m^2)' min=8 max=40 values=(8 to 48 by 2);
    y2axis label=' ' min=8 max=40 values=(8 to 48 by 2);
    xaxis label='Age (Years)' min=2 max=17 values=(2 to 17 by 1);
    scatter x=age y=SCD / markerattrs=(size=2);
    scatter x=age y=SCD / markerattrs=(size=0) y2axis;
    series x=age y=SCD /group=P lineattrs=(thickness=2.75 pattern=solid) smoothconnect curvelabel curvelabelpos=min curvelabelloc=inside curvelabelattrs=(Weight=Bold);
    series x=age y=CDC /group=P lineattrs=(thickness=2 pattern=dot) transparency=0.45 smoothconnect curvelabel curvelabelpos=max curvelabelloc=inside;
run;



/* ===========
  Output Tables
   =========== */

/* proc report */
