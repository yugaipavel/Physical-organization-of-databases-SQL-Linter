drop trigger auto_partition_in_insert;
drop table LogTable_02;
drop table LogTable_01;
drop table LogTable_00;
drop index IDX_LogTable_LogId on LogTable;
drop table LogTable;

create or replace table LogTable(
LogId int,
Timestmp CHAR(20),
SubjectId int,
ObjectName CHAR(32),
Action CHAR(32)
);
create or replace index IDX_LogTable_LogId on LogTable(LogId);

create or replace table LogTable_00 as select * from LogTable where 1=0;
create or replace table LogTable_01 as select * from LogTable where 1=0;
create or replace table LogTable_02 as select * from LogTable where 1=0;

create or replace trigger auto_partition_in_insert
before insert on LogTable for each row execute
declare
code
    if new.LogId <= 0
    then
        execute "insert into LogTable_00 values (?, ?, ?, ?, ?);"
        using new.LogId, new.Timestmp, new.SubjectId, new.ObjectName, new.Action;
    endif;
    
    if new.LogId >= 0 and new.LogId < 1073741823
    then
        execute "insert into LogTable_01 values (?, ?, ?, ?, ?);"
        using new.LogId, new.Timestmp, new.SubjectId, new.ObjectName, new.Action;
    endif;
    
    if new.LogId >= 1073741823 and new.LogId < 2147483648
    then
        execute "insert into LogTable_02 values (?, ?, ?, ?, ?);"
        using new.LogId, new.Timestmp, new.SubjectId, new.ObjectName, new.Action;
    endif;
end;

insert into LogTable values (-13, '22:10 19.11.2019', 13, 'test1', 'do');
insert into LogTable values (1073741822, '22:11 19.11.2019', 13, 'test2', 'write');
insert into LogTable values (2147483647, '22:12 19.11.2019', 13, 'test3', 'read');

select * from LogTable;
select * from LogTable_00;
select * from LogTable_01;
select * from LogTable_02;

// simple query to all system and user tables

select
cast ($$$s34 as char(18)) as "UserName",
cast ($$$s13 as char(18)) as "TableName",
linter_file_info($$$s11,1,1,'size') as "DataFileSize",
linter_file_info($$$s11,0,1,'size') as "IndexFileSize"
from LINTER_SYSTEM_USER.$$$sysrl, LINTER_SYSTEM_USER.$$$usr
where $$$s31 = $$$s12 and $$$s11 > 0 and $$$s32 = 0 and getbyte($$$s14,6) = 0
order by "UserName", "TableName";

// full query to all system and user tables

select
cast ($$$s34 as char(18)) as "UserName",
cast ($$$s13 as char(18)) as "TableName",
linter_file_info($$$s11,0,1,'size') as "IndexFileSize",
linter_file_info($$$s11,0,1,'bitmap_size') as "IndexBitmapSize",
linter_file_info($$$s11,0,1,'conv_size') as "IndexConvSize",
linter_file_info($$$s11,0,1,'full_page_count') as "IndexFullCount",
linter_file_info($$$s11,0,1,'free_page_count') as "IndexFreeCount",
linter_file_info($$$s11,1,1,'size') as "DataFileSize",
linter_file_info($$$s11,1,1,'bitmap_size') as "DataBitmapSize",
linter_file_info($$$s11,1,1,'full_page_count') as "DataFullCount",
linter_file_info($$$s11,1,1,'free_page_count') as "DataFreeCount",
case when getbyte($$$s14,102) > 0
then linter_file_info($$$s11,2,1,'size') 
else NULL end as "BlobFileSize",
case when getbyte($$$s14,102) > 0
then linter_file_info($$$s11,2,1,'bitmap_size')
else NULL end as "BlobBitmapSize",
case when getbyte($$$s14,102) > 0
then linter_file_info($$$s11,2,1,'full_page_count')
else NULL end as "BlobFullCount",
case when getbyte($$$s14,102) > 0
then linter_file_info($$$s11,2,1,'free_page_count')
else NULL end as "BlobFreeCount"
from LINTER_SYSTEM_USER.$$$sysrl, LINTER_SYSTEM_USER.$$$usr
where $$$s31 = $$$s12 and $$$s11 > 0 and $$$s32 = 0 and getbyte($$$s14,6) = 0;

//simple query to LOGTABLE withoutIndexFullCount, IndexFreeCount, BlobFullCount, BlobFreeCount

select
cast ($$$s34 as char(18)) as "UserName",
cast ($$$s13 as char(18)) as "TableName",
linter_file_info($$$s11,1,1,'size') as "DataFileSize",
linter_file_info($$$s11,0,1,'size') as "IndexFileSize"
from LINTER_SYSTEM_USER.$$$sysrl, LINTER_SYSTEM_USER.$$$usr
where $$$s31 = $$$s12 and $$$s11 > 0 and $$$s32 = 0 and getbyte($$$s14,6) = 0 and $$$s13 = 'LOGTABLE';


// full query to LOGTABLE about DataFileSize, IndexFileSize, IndexFullCount, IndexFreeCount, BlobFullCount, BlobFreeCount

select
cast ($$$s34 as char(18)) as "UserName",
cast ($$$s13 as char(18)) as "TableName",
linter_file_info($$$s11,1,1,'size') as "DataFileSize",
linter_file_info($$$s11,0,1,'size') as "IndexFileSize",
linter_file_info($$$s11,0,1,'full_page_count') as "IndexFullCount",
linter_file_info($$$s11,0,1,'free_page_count') as "IndexFreeCount",
case when getbyte($$$s14,102) > 0
then linter_file_info($$$s11,2,1,'full_page_count') 
else NULL end as "BlobFullCount",
case when getbyte($$$s14,102) > 0
then linter_file_info($$$s11,2,1,'free_page_count')
else NULL end as "BlobFreeCount"
from LINTER_SYSTEM_USER.$$$sysrl, LINTER_SYSTEM_USER.$$$usr
where $$$s31 = $$$s12 and $$$s11 > 0 and $$$s32 = 0 and getbyte($$$s14,6) = 0 and $$$s13 = 'LOGTABLE';