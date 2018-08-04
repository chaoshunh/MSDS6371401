
data _null_;
  command = 'cd D:\My_Docs\univer\Statistics\Project"';
  call system(command);
run;

PROC IMPORT OUT= test 
     DATAFILE= "test.csv" 
     DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= train 
     DATAFILE= "train.csv" 
     DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data test;
	set test;
	SalePrice = .;
run;

data train2;
	set train test;
run;

proc print data=train2;
run;

/* looking for missing data */
proc format;
 value $missfmt 'NA'='NA Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
 
proc freq data=train; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;

/*correlation matrix */
proc sgscatter data=train;
matrix SalePrice TotalBsmtSF _1stFlrSF 
			GrLivArea GarageArea;
run;

data train;
	set train;
	SalePrice_log=log(SalePrice);
run;

data train;
	set train;
	TotalBsmtSF_log=log(TotalBsmtSF);
run;

data train;
	set train;
	_1stFlrSF_log=log(_1stFlrSF);
run;

data train;
	set train;
	GrLivArea_log=log(GrLivArea);
run;

data train;
	set train;
	GarageArea_log=log(GarageArea);
run;

proc sgplot data = train;
scatter x= GrLivArea  y = SalePrice_log;
run;

proc univariate data=train;
var SalePrice_log;
histogram SalePrice_log /normal;
qqplot SalePrice_log /normal (mu=est sigma=est) square;
run;

proc univariate data=train;
var TotalBsmtSF_log;
histogram TotalBsmtSF_log /normal;
qqplot TotalBsmtSF_log  /normal (mu=est sigma=est) square;
run;

proc univariate data=train;
var _1stFlrSF;
histogram _1stFlrSF_log /normal;
qqplot _1stFlrSF_log  /normal (mu=est sigma=est) square;
run;

proc univariate data=train;
var GrLivArea_log;
histogram GrLivAre_loga /normal;
qqplot GrLivArea_log  /normal (mu=est sigma=est) square;
run;

proc univariate data=train;
var GarageArea_log;
histogram GarageArea_log /normal;
qqplot GarageArea_log  /normal (mu=est sigma=est) square;
run;
