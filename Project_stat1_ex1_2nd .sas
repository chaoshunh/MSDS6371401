
data _null_;
  command = 'cd D:\My_Docs\univer\Statistics\Project"';
  call system(command);
run;

PROC IMPORT OUT= train 
     DATAFILE= "train.csv" 
     DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data train_neigbor;
   set train;
   if  Neighborhood='NAmes' or Neighborhood='Edwards' or Neighborhood='BrkSide';
run;

data train_neigbor1;
	set train_neigbor;
	if _n_=339 or _n_=131 or _n_=190 or _n_=169   then delete;
	run;

proc glm data = train_neigbor plot = all;
class Neighborhood  (REF="NAmes");
model SalePrice = GrLivArea | Neighborhood / solution clparm;
run;

data train_neigbor_train;
	set train_neigbor1;
	where id<1156;
	run;

data train_neigbor_test;
	set train_neigbor1;
	where id>1155;
	run;

proc glmselect data =train_neigbor_train testdata=train_neigbor_test plots(stepaxis=number) = (criterionpanel ASEPlot);
class Neighborhood  (REF="NAmes");
model SalePrice = GrLivArea | Neighborhood / selection =stepwise (select=cv choose =cv stop=cv) CVDETAILS;
run;


