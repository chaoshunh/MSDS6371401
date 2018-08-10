
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

/*proc contents data=train order=varnum;*/

data train_neigbor;
   set train;
   if  Neighborhood='NAmes' or Neighborhood='Edwards' or Neighborhood='BrkSide';
run;

data train_neigbor;
	set train_neigbor;
	SalePrice_log=log(SalePrice);
run;

data train_neigbor;
	set train_neigbor;
	TotalSF_log=log(TotalBsmtSF+_1stFlrSF+_2ndFlrSF);
run;

data train_neigbor;
	set train_neigbor;
	GrLivArea_log=log(GrLivArea);
run;

proc print data=train_neigbor;
run;

/*correlation matrix */
proc sgscatter data=train_neigbor;
matrix SalePrice_log GrLivArea_log TotalSF_log OverallQual;
run;

proc sgplot data = train;
scatter x= GrLivArea  y = SalePrice_log;
run;

proc univariate data=train_neigbor;
var SalePrice_log;
histogram SalePrice_log /normal;
qqplot SalePrice_log /normal (mu=est sigma=est) square;
run;

proc univariate data=train_neigbor;
var TotalSF_log;
histogram TotalSF_log /normal;
qqplot TotalSF_log  /normal (mu=est sigma=est) square;
run;

proc univariate data=train_neigbor;
var GrLivArea_log;
histogram GrLivAre_loga /normal;
qqplot GrLivArea_log  /normal (mu=est sigma=est) square;
run;

proc univariate data=train_neigbor;
var OverallQual;
histogram OverallQual /normal;
qqplot OverallQual  /normal (mu=est sigma=est) square;
run; 

data train_neigbor;
	set train_neigbor;
	if _n_=339 or _n_=131 or _n_=136 then delete;
	run;
/* 136 - GrLivArea too small
	131 and 339 GrLivArea too big*/


proc reg data=train_neigbor ;
model SalePrice_log=  KitchenQual | GrLivArea_log OverallQual TotalSF_log Fireplaces  / tol vif collin;
run;

proc glm data=train_neigbor plots=all;
class KitchenQual (REF="Fa");
model SalePrice_log=  KitchenQual | GrLivArea_log OverallQual TotalSF_log Fireplaces  / solution;
run;

/*still need to work on it, */
proc glmselect data=train_neigbor;
class KitchenQual (REF="Fa");
model SalePrice_log=  KitchenQual | GrLivArea_log OverallQual TotalSF_log Fireplaces
	/ selection =forward (stop=CV) cvmethod=random(5) stats=adjrsq;
run;

