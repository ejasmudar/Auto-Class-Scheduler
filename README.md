# Auto-Class-Scheduler
Written as part of a term paper in Uni (2013), this a Proof of Concept for automatically creating class schedules based on student preferences and other constraints. 

There are two components - 
1. Excel file from where the Subject details and student preferences are loaded using a VBA macro.
2. IBM CPLEX ILOG program that runs the linear integer Program and outputs the final call schedules. 



From Abstract:
The objective of this paper is to automate the process of timetabling for 2nd year students (PGP2s) in IIM
Calcutta. Timetabling in this case involves finding subject-timeslot-classroom combinations such that
violation of constraints like professor preference, student preference, class room availability, etc. are
minimized. Currently in IIMC, this process is being done manually by the PGP Office staff. This is a highly
complex and iterative process due to the large number of hard and soft constraints involved. As a result, it is
very time consuming and error-prone when performed manually. Our aim with this term paper is to provide
an algorithm to optimize and automate this process. After from increasing efficiency of the process, the aim
is also to increase effectiveness, which is to say that the timetable developed would be better than the
manual solution being prepared by the PGP Office.


Co-written wwith Debraj Mondal
