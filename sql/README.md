**Introduction:**\
Tha SAA requires two types of DB tables:
- The static tables where the users dont have the write priviledes,
- The dynamic tables where the users have the write priviledes.

The standard item tables (i.e. material and fastener) are static tables
while the core system (CS) object tables (e.g. Panel) are dynamic.
Hence, I followed different approaches while designing these tables.

**Static Tables:**\
These are simple MySQL tables storing a small amount of data.
Please review the following sql file as an example:
- create_table__mat1.sql

Other sql files would be implemented similarly: create_table__mat8.sql, create_table__fastener.sql, etc.

**Dynamic Tables:**\
The main README of this repository explains the structural components (SCs), failure modes (FMs), reserve factors (RFs) and load cases (LCs) in detail.
The RF related data may reach up to billions of entries for thousands of SCs and thousands of LCs.
Hence, as its explained in the main README, the LC and RF related data will not be copied to the memory for the efficiency.
Instead, these data will remain in the DB and accessed when required.
Lets call these tables as the **RF tables**.
The tables for the other CS objects (e.g. Panel) are called **non-RF tables**.

**The Design of the Non-RF Tables:**\
Each CS object is defined by the CS statically.
Hence, a table for each object can be created within the DB.
Please review the following sql file as an example:
- create_table__nonRF.sql

**The Design of the RF Tables:**\
The RF tables would include some columns listing the RF related data such as:
- the RF,
- the applied loading,
- the allowable loading,
- some coefficients.

The RF data varies for each SC-FM combination.
The RF data for a SC-FM combination is defined statically by the CS.
Hence, the DB may contain a predefined individual table for each SC-FM combination.

The RF tables are subject to frequent reads and writes.
I will examine both the read and write operations.

The write operations are executed when the user requests a structural analysis (SA) on an SC.
The pseudocode of the process is:
- The solver pack (SP) performs the analysis and returns the results to the core system (CS).
- The CS writes the results to the RF DB tables and wakes the UI.
- The UI reads the RF results from the DB and shows in a form.

Hence, the DB table update is executed after the SP runs the related SA.
As mentioned in the main README, the SA routines are very complex which may contain thousands of statements.
Hence, the DB update time is negligable comparing with the SP run.
In other words, the performance of the write operations can be excluded while designing the RF tables.

The read operations are a part of the reporting utilities of the structural analysis application (SAA)
which is independent of the SP.
The reporting faciliities involve two types:
- reporting via the UI forms,
- reporting by creating report files (e.g. excel or word).

While both of them should be considered performance critical in terms of user performance,
the 1st one is way more crucial.
Anyway, the read operations are performance critical.

**As a summary, the RF tables shall be designed considering the performance of the read operations.**

Currently, the RF tables are separated to define a table for each SC-FM couple.
However, each table corresponding to each SC-FM combination may contain a large number of rows (e.g. 10^8)
so that the queries can take a long time.
The RF tables shall be organized to return to the read queries efficiently.
Considering the large amount of data stored by the RF tables
there exist two aproaches to improve the performance of the read queries: indexing and partitioning.

I will introduce two use cases in order to examine the pros and cons of the two:
- Primary key queries: Ex: return all RF data where SC=panel1234 & FM=buckling
- Non-primary key queries: Ex: return all SCs where RF < 1.0

The 1st use case requires to locate the requested SC-FM pair within a large table.
For example, the data may be located at the rows between 1000 and 2000.
The partitioning works great in this case as it involves reading all data from a single table
if the partitions are defined by the SC id.

The 2nd use case requires gathering distributed data.
If the partitioning is applied based on the SC id,
the query must scan all partitions of the SC-FM pair
which kills the efficiency.
Actually, the 2nd use case is a prove of the queries may include non-primary keys
which is the worst scenario for the partitioning.
The problem can be solved easily by the indexing appproach.

In summary, for the best performance, the 1st use case requires partitions while the 2nd one requires indexing.
What about applying the two alternatives at the same time for the best user performance: a dual-table for each SC-FM pair.
Then, the DB would involve the tables such as:
- RF__SC_Panel__Panel_Buckling__partitioned
- RF__SC_Panel__Panel_Buckling__indexed
- RF__SC_Panel__Panel_Pressure__partitioned
- RF__SC_Panel__Panel_Pressure__indexed
- RF__SC_Stiffener__Strength__partitioned
- RF__SC_Stiffener__Strength__indexed

The CS shall route the queries to the right table type:
- Primary key queries -> partitioned table of the SC-FM pair
- Non-primary key queries -> indexed table of the SC-FM pair

Please review the following sql file as an example:
- create_table__RF.sql
