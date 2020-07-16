# Physical-organization-of-databases-SQL-Linter

In DBMS Linter, file and data sizes are measured in memory pages. One such page is 4 KBytes. To obtain the sizes of system and user database files and their indexes, you need to refer to the $$$ SYSRL and $$$ USR system tables. $$$ SYSLR has information about all DB tables / views. It contains the following columns:

• $$$ S11 (integer) - Object system identifier.

• $$$ S12 (integer) - Owner ID.

• $$$ S13 (char (66)) - Object name.

• $$$ S14 (byte (262)) - System description of the object.

$$$ USR has information about all database users and their privileges, roles, and the assignment of roles to database users. It contains the following columns:

• $$$ S31 integer:

     for user - user ID, positive RowId value of the table record;
     for schema - schema identifier, positive RowId value of the table 
record;
     for a role - negative RowId value of the table record;
     to assign access rights of database users to database objects - the system identifier of the database user, for which the rights are described;
     to assign roles to database users - the system identifier of the database user to whom the role is assigned;
     to assign user access rights and database roles to database procedures - positive RowId value of the table record for the user and negative RowId value of the table record for the role.

• $$$ S32 (integer):

     for the user - always zero;
     for the scheme - always zero;
     for a role - always zero;
     to assign database user access rights to database objects - the system identifier of the table or view (field S11 of the $$$ SYSRL table), for which access rights are assigned;
     to assign roles to database users - the system identifier of the assigned role;
     to assign a PUBLIC role - zero;
     to assign user access rights and database roles to database procedures - negative RowId value of the procedure record in the $$$ PROC table.

• $$$ S33 integer:

     for user - user privilege mask. The first byte of the column contains user access levels (high 4 bits - RAL, low 4 bits - WAL). The second byte contains the user's group.
     for a role - the system identifier of the database user who created the role;
     to assign access rights of database users to database objects - access mask;
     to assign roles to database users - always zero;
     to assign user access rights and database roles to database procedures - access mask.

• $$$ S34 char (66):

     for user - username;
     for a role - the name of the role;
     for a scheme - the name of the scheme;
     to assign database user access rights to database objects - the name of the database user for which the rights are described;
     to assign roles to database users - filled with spaces;
     to assign user access rights and database roles to database procedures - the name of the user or database role for which the rights are described
     $$$ S35 byte (240) - For user - description of user rights; for other types of records - 18 spaces, other bytes - zeros.


DBMS Linter has a built-in function LINTER_FILE_INFO ("table identifier", "file type", "file number", "information type").
1) The "table identifier" parameter specifies the identifier of the table whose file status information is to be obtained. Table IDs are stored in the $$$ SYSRL system table, column $$$ S11.
2) The "file type" parameter sets the table file type: 0 - index file; 1 - data file; 2 - BLOB data file.
3) The "file number" parameter defines the sequence number of the file of the specified type (starting from 1).
4) The "information type" parameter determines the type of file requested information. The parameter data type is CHAR, the parameter values are case-insensitive.

When the Physical-organization-of-databases-SQL-Linter.py script was run for the first time, it was found that with 1000 records, the table file size is 31 pages, and with 2000 records, 47 pages, and also with 3000 records, the index file size table is 18 pages, and for 4000 records - 34 pages. After that, the script was modified to detect the number of records at which the size of the table file and the table index file increases by changing the loop condition to for local_count in range (1000, 2000) and for local_count in range (3000, 4000), respectively. With 1420 records, the table file size increases from 31 to 47, and with 3797 records, the index file size of this table increases from 18 to 34. The sizes of one table record and one index for it are calculated as follows (one page = 4 KB):

Record_size = 31 * 4 * 1024/1419 = 89.48 bytes.

Index_size = 18 * 4 * 1024/3796 = 19.42 bytes.

To make sure that the single record and index sizes are calculated correctly, calculate the table and index file sizes at 1,000,000 records using the calculated sizes.

Table_size_1000000 = (89.48 * 1000000) / (4 * 1024) ≈ 21845 pages.

Index_size_1000000 = (19.42 * 1000000) / (4 * 1024) ≈ 4741 pages.

The values obtained are approximately the same as those obtained using SQL queries. Thus, the calculated values ​​of the sizes of one record and one index are correct.

Partitioning was carried out only manually, since DBMS Linter does not have tools for automatic partitioning of stored database objects. For manual partitioning, three tables (LOGTABLE_0X) were created that have the same attributes as the original LogTable entity. Also, a trigger was added for splitting, which, when a new record is added, automatically adds it to the corresponding table. (see Physical-organization-of-databases-SQL-Linter.sql)
