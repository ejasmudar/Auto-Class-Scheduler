/*********************************************
 * OPL 12.5.1.0 Model
 * Author: Ejas M
 * Creation Date: 05-Nov-2013 at 9:22:29 PM
 *********************************************/
using CP;

int k=1;

int SubjectNo=...; //subject nos
int DayNo=...; // day nos
int TimeNo=...; // time slot nos
int RoomNo=...; //classroom nos
int ProfNo=...; //No of Profs

{string} temp;

int profvar;
//int w1=10; //weightage for lamda1 


//// Initialising Ranges /////

range subID1 = 1..SubjectNo;
range subID2 = 1..SubjectNo;
range dayID = 1..DayNo;
range timeID = 1..TimeNo;
range roomID = 1..RoomNo;
range profID = 1..ProfNo;





///Initialising Information Arrays/////
int SubjectCap[subID1] =...; //SubjectCap Array
int RoomCap[roomID] =...; //Room Size Array
int ProfSub[subID1][profID]; //Professor-Subject nD Array
int ProfSub1D[subID1]=...; //Professor-Subject 1D Array from Source
int Th[subID1][subID2]=...; //Subject-Subject Overlap Array
int Th3[subID1][subID1][subID1]; //Subject-Subject Overlap Array
int OP0[1..100*2][1..4]; //Array to Output to Excel
int OP[1..SubjectNo*2][1..4]; //Array to Output to Excel
string TT[timeID][dayID]; //Timetable  Array
string TT0[1..7][1..7]; //Timetable init Array
int P__[profID][dayID]; //Prof/day




////Decision Variables/////

dvar boolean C[subID1][roomID]; //Room/Subj combo
dvar boolean S[subID1][dayID][timeID];  //Main decision variable that becomes 0/1

//Overlap expr
dexpr float Zfloat[i in subID1][j in subID1]=0.5*sum(d in dayID, t in timeID)S[i][d][t]*S[j][d][t];
dexpr int Z[i in subID1][j in subID1]=ftoi(Zfloat[i][j]);

//No of subjects a prof has in a day
dexpr int ProfSubNo[n in profID]=sum (i in subID1) ProfSub[i][n];
//dexpr float P_[n in profID][d in dayID]=sum (i in subID1, t in timeID) ProfSub[i][n]*S[i][d][t];//ProfSubNo[n]+0.1;
//dexpr int P2_[n in profID][d in dayID]=ftoi(P_[n][d]);

///////////////////////////////////////////////
//////////// PreProcessing Block///////////////
//////////////////////////////////////////////

execute ProfSubPreinitialisation
{
  ///Initialising Array to 0////
  for(var i=1; i<=SubjectNo;i++)
  {
    for(var j=1;j<=ProfNo;j++)
    {
      ProfSub[i][j]=0;
    }
  }
  
  ///Converting Array from 2D to nD////
for(var i=1; i<=SubjectNo;i++)
{
  var j=ProfSub1D[i];
  ProfSub[i][j]=1;
}  


for(var i=1; i<=SubjectNo; i++)
{
  for(var j=1; j<=SubjectNo;j++)
  {
    for(var k=1;k<=SubjectNo;k++)
    {
      if(j==k)
      {Th3[i][j][k]=Th[i][j];}
      else if(i==k)
      {Th3[i][j][k]=Th[i][j];}
      else
      {Th3[i][j][k]=Th[i][j]+Th[i][k]+100000;}
    }
  }
}  
}

            
    	





///////////////////////////////////////////////////
/////objective function to minimize overlap//////
////////////////////////////////////////////////

/*
minimize
sum(i in subID1, j in subID2, k in subID2,  d1 in dayID, t1 in timeID, d2 in dayID, t2 in timeID : i!=j) 
Th3[i][j][k]*S[i][d1][t1]*S[j][d1][t1]*S[i][d2][t2]*S[k][d2][t2];
*/
minimize
sum(i in subID1, j in i..SubjectNo, k in j..SubjectNo: i!=j) 
Th3[i][j][k]*Z[i][j]*Z[i][k];



////////////////////////////////////
////Constraint Block//////
////////////////////////////////////
subject  to 
{



//Hard Contraint 1: Only two class per week (day*time combo)
forall (i in subID1)
	Hrd1:
	sum (d in dayID, t in timeID) S[i][d][t] == 2; 


//A room must have greater capacity than subject 
forall (i in subID1, m in roomID)
  roomconstr1:
  if (RoomCap[m]<=SubjectCap[i]-1) 
  {
    C[i][m]==0 ;
    }


//A room must have max of 1 subject per time/day    
forall (m in roomID, d in dayID, t in timeID)
    roomconstr2:
      sum (i in subID1) C[i][m]*S[i][d][t] <=1;  



//Each subject must be taken in 1 room
forall(i in subID1)
  roomconstr3:
    sum (m in roomID) C[i][m]==1;

    
//Each prof takes max one class per day/time
forall (n in profID, d in dayID, t in timeID)
  profconstr1:
    sum (i in subID1)  ProfSub[i][n]*S[i][d][t] <= 1;


/////////SOFT CONSTRAINT BLOCK////////////////

//No multiple classes of same subject in same day

forall (i in subID1, d in dayID)
  soft1:
  sum (t in timeID) S[i][d][t]<=1; //-lamda1[i][d]<=1;


//Cant figure out errors below :(

//Profs prefer multiple subjects/sections per day
/*
forall (n in profID, d in 1..DayNo-1)
{	soft4:
  P_[n][d]+P_[n][d+1]<=1;  //This is working for 1 sub per prof only :/
}
*/


//Profs prefer atleast 1 break between classes

forall (n in profID, d in dayID, t in 1..TimeNo-1)
  soft5:
    sum(i in subID1) ProfSub[i][n]*S[i][d][t] + sum(i in subID1) ProfSub[i][n]*S[i][d][t+1] <=1;

} 


   
////////////////////////////////////
///////POST PROCESSING BLOCK////////
////////////////////////////////////
execute outputblock
{ 
//writeln(P2_[1][1]);
//var f=ftoi(0.25);
//writeln(f);

//Creating Output Array
for(var d=1;d<=DayNo;d++)
{
  for(var t=1;t<=TimeNo;t++)
  {
    for(var i=1;i<=SubjectNo;i++)
    {
        if (S[i][d][t]==1)
    	{
    	for(var m=1;m<=RoomNo;m++)
    		if (C[i][m]==1)
    		{
    	    	OP[k][1]=i;
    	    	OP[k][2]=d;
      			OP[k][3]=t;
      			OP[k][4]=m;
      			k=k+1;
       		}      			
    	}
   }
 }


}



///////////////Creating TimeTable//////////////////

for(var i=1 ; i<=SubjectNo;i++)
{
  for(var d=1;d<=DayNo;d++)
  {
    for(var t=1;t<=TimeNo;t++)
    {
      if(S[i][d][t]==1)
      {
        var temp=i;

          TT[t][d]=TT[t][d]+" "+temp;

                
      }
    }
  }
}                    
}















