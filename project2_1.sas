options validvarname=V7;
PROC IMPORT OUT= ptest
     DATAFILE= "/home/chaoshunh0/test.csv" 
     DBMS=CSV REPLACE;
     GETNAMES=YES;
     GUESSINGROWS=MAX;
RUN;

PROC IMPORT OUT= train
     DATAFILE= "/home/chaoshunh0/train.csv" 
     DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS= MAX;
RUN;

data ptest;
	set ptest;
	SalePrice = .;
run;

data ptrain;
    set train(rename=(_1stFlrSF = fstFlrSF _2ndFlrSF = sndFlrSF));
    if  Neighborhood='NAmes' or Neighborhood='Edwards' or Neighborhood='BrkSide';
run;


/*data train2;
	set ptrain ptest;
run;*/

/*proc print data=train2;
run;*/

/* looking for missing data */
proc format;
 value $missfmt 'NA'='NA Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;

 
proc freq data=ptrain; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;


data ptrain;
	set ptrain;
	SalePrice_log=log(SalePrice);
run;

data ptrain;
    set ptrain;
    TotalSF = (TotalBsmtSF+fstFlrSF+sndFlrSF)/100.0;
    TotalSF_log = log(TotalSF);
run;

data ptrain;
	set ptrain;
	GrLivArea = GrLivArea/100.0;
	GrLivArea_log=log(GrLivArea);
run;

proc print data=ptrain;
run;

proc univariate data=ptrain;
var SalePrice_log;
histogram SalePrice_log /normal;
qqplot SalePrice_log /normal (mu=est sigma=est) square;
run;

proc univariate data=ptrain;
var TotalSF_log;
histogram TotalSF_log /normal;
qqplot TotalSF_log  /normal (mu=est sigma=est) square;
run;

proc univariate data=ptrain;
var GrLivArea_log;
histogram GrLivArea_log /normal;
qqplot GrLivArea_log  /normal (mu=est sigma=est) square;
run;

proc univariate data=ptrain;
var OverallQual;
histogram OverallQual /normal;
qqplot OverallQual  /normal (mu=est sigma=est) square;
run;

/*correlation matrix */
proc sgscatter data=ptrain;
matrix SalePrice_log TotalSF_log GrLivArea_log OverallQual;
run;

proc sgplot data = ptrain;
scatter x= GrLivArea_log  y = SalePrice_log;
run;

proc sgplot data = ptrain;
scatter x= GrLivArea  y = SalePrice_log;
run;

data ptrain;
	set ptrain;
	if GrLivArea=3.34 or GrLivArea>40 then delete;
run;

/*proc print data=ptrain;
run;*/

proc sgplot data = ptrain;
scatter x= GrLivArea_log  y = SalePrice_log;
run;

proc reg data=ptrain plots=all;
model SalePrice_log= GrLivArea_log OverallQual TotalSF_log;
run;
