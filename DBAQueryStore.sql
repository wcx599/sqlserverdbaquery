USE [msdb]
GO

/****** Object:  Job [DBAQueryStore]    Script Date: 2018/11/2 10:42:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 2018/11/2 10:42:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBAQueryStore', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Capture SQL instance statistics every 20 seconds. Including SQL statements and blockings  Developed by Chenxu Wang.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_SQLAll]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_SQLAll', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
IF NOT EXISTS(  SELECT *
                FROM    sys.databases
                WHERE   name = ''DBAQueryStore'')
BEGIN

CREATE DATABASE DBAQueryStore

ALTER DATABASE DBAQueryStore SET RECOVERY SIMPLE 

ALTER DATABASE DBAQueryStore SET  MULTI_USER 


END

GO

USE DBAQueryStore
GO
IF OBJECT_ID(''dbo.tbl_sqlall'') IS NULL
BEGIN
create table tbl_sqlall
(date datetime not null,
spid int not null,
seconds int not null,
blocked int not null,
hostname varchar(50),
loginame varchar(30),
cmd varchar(30),
application_name varchar(100),
dbname varchar(60),
cpu int not null,
physical_io int,
requested_memory_kb int,
granted_memory_kb int,
required_memory_kb int,
max_used_memory_kb int,
sql_text varchar(max),
objectname varchar(100)

	 constraint  PK_tbl_sqlall primary key clustered  (date desc, spid)
)
end 

begin

	insert into tbl_sqlall

select 
getdate() as date ,
pros.spid,
seconds = datediff(ss, pros.last_batch, getdate()),
pros.blocked,
pros.hostname, 
pros.loginame,
pros.cmd,
pros.program_name,
dbname = db_name(pros.dbid),
pros.cpu,
pros.physical_io,
mmg.requested_memory_kb,
mmg.granted_memory_kb,
mmg.required_memory_kb,
mmg.max_used_memory_kb,
sqlt.text,
ObjectName   = CASE 
WHEN OBJECT_SCHEMA_NAME(sqlt.objectid,sqlt.dbid) + ''.'' + OBJECT_NAME(sqlt.objectid, sqlt.dbid) IS NULL THEN ''Explicit User Query'' 
ELSE OBJECT_SCHEMA_NAME(sqlt.objectid,sqlt.dbid) + ''.'' + OBJECT_NAME(sqlt.objectid, sqlt.dbid) 
END
from sys.sysprocesses pros
inner join sys.dm_exec_query_memory_grants mmg
on pros.spid = mmg.session_id
cross apply sys.dm_exec_sql_text (pros.sql_handle) as sqlt
where spid <> @@spid
and spid > 50

end


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_blocker_sqltext]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_blocker_sqltext', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
USE DBAQueryStore
GO
IF OBJECT_ID(''dbo.tbl_blocker'') IS NULL
BEGIN
create table tbl_blocker
(
date datetime not null,
hostname varchar(40) not null,
spid smallint not null,
blocker smallint not null,
seconds int not null,
dbname varchar(60),
cmd varchar(40),
lastwaittype varchar(40),
waitresource varchar(50),
physical_io int,
logical_reads int,
cpu_time int, 
memory_usage int,
status varchar(20),
open_tran bit,
login_time datetime not null,
blocker_sql nvarchar(max)  null,
sqltext nvarchar(max) null

 
)

end 

begin 

	insert into tbl_blocker

select
getdate() as date,
pros.hostname,
pros.spid,
pros.blocked, 
DATEDIFF(ss, pros.last_batch, GETDATE()) as seconds,
db_name(pros.dbid) as dbname,
pros.cmd,
pros.lastwaittype, 
pros.waitresource,
pros.physical_io,
sess.logical_reads,
sess.cpu_time,
sess.memory_usage,
pros.status,
pros.open_tran,
pros.login_time,
sqltb.text as blocker_sql,
sqlt.text as sqltext
from sys.sysprocesses pros
inner join sys.dm_exec_connections conn
on pros.blocked = conn.session_id
cross apply sys.dm_exec_sql_text(conn.most_recent_sql_handle) sqltb
cross apply sys.dm_exec_sql_text(pros.sql_handle) sqlt
inner join sys.dm_exec_sessions sess
on sess.session_id = pros.spid

union

select
getdate() as date,
pros2.hostname,
pros2.spid,
pros2.blocked, 
DATEDIFF(ss, pros2.last_batch, GETDATE()) as seconds,
db_name(pros2.dbid) as dbname,
pros2.cmd,
pros2.lastwaittype, 
pros2.waitresource,
pros2.physical_io,
sess.logical_reads,
sess.cpu_time,
sess.memory_usage,
pros2.status,
pros2.open_tran,
pros2.login_time,
'''' as blocker_sql,
sqlt.text as sqltext
from sys.sysprocesses pros
inner join sys.sysprocesses pros2
on pros.blocked = pros2.spid
--cross apply sys.dm_exec_sql_text(conn.most_recent_sql_handle) sqltb
cross apply sys.dm_exec_sql_text(pros2.sql_handle) sqlt
inner join sys.dm_exec_sessions sess
on sess.session_id = pros2.spid


end 
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_querystats]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_querystats', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*

DISABLE THIS FEATURE

USE DBAQueryStore
GO
IF OBJECT_ID(''dbo.tbl_querystats'') IS NULL
BEGIN
create table tbl_querystats
(
last_execution_time datetime not null,
query_hash int not null,
query_plan_hash int not null,
dbname varchar(60),
sqltext varchar(max),
stmt varchar(max),
stmt_start_offset int,
stmt_end_offset int,
last_worker_time int,
last_physical_reads int,
last_logical_reads int,
last_logical_writes int,
query_plan xml

)

end 

begin 
	insert into tbl_querystats
select   
last_execution_time,
checksum(query_hash),
checksum(query_plan_hash),
dbname = db_name(cp.dbid),
sqlt.text as sqltext,
substring(sqlt.text, qs.statement_start_offset / 2, case when (qs.statement_end_offset - qs.statement_start_offset) / 2 > 0 THEN (qs.statement_end_offset - qs.statement_start_offset) / 2 else 1 END ) as stmt,
--checksum(sql_handle), checksum(plan_handle) , 
qs.statement_start_offset , qs.statement_end_offset,
last_worker_time,
last_physical_reads,
last_logical_reads,
last_logical_writes,
'''' as query_plan
-- ,convert (xml, cp.query_plan) as query_plan
from sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) cp
cross apply sys.dm_exec_sql_text (sql_handle) sqlt
where 
datediff(ss, last_execution_time, getdate()) <= 10
order by last_execution_time desc

end


*/
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_dbfiles]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_dbfiles', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

USE DBAQueryStore
GO
IF OBJECT_ID(''tbl_fileaudit'') IS NULL
begin
create table tbl_fileaudit
(
date datetime not null,
dbname varchar(60) not null,
dbsize_MB int,
dbgrowth_MB int,
filetype varchar(30),
filename varchar(50),
location varchar (100),
status varchar (30)
)
end 

begin 
	insert into tbl_fileaudit

select 
getdate() as date,
dbname = db_name(database_id),
dbsize_MB = size * 8 / 1024,
dbgrowth_MB = growth *8 / 1024,
filetype = 
case type when 0 then ''Data'' else ''Log'' end,
filename = name,
location = physical_name,
status = state_desc
from sys.master_files
where database_id  = 2 or database_id > 4

end 

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_virtualio]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_virtualio', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

USE DBAQueryStore
GO
IF OBJECT_ID(''dbo.tbl_virtualio'') IS NULL

create table tbl_virtualio
( Date datetime not null,
  ReadLatency int not null,
  WriteLatency int not null,
  Latency int not null,
  [AvgByte/Read] int not null,
  [AvgByte/Write] int not null,
  [AvgByte/Transfer] int not null,
  Drive varchar(5),
  DB varchar(60),
  physical_name varchar(100)
)


INSERT INTO tbl_virtualio

SELECT
Date = getdate(),
[ReadLatency] =
CASE WHEN [num_of_reads] = 0
THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END,
[WriteLatency] =
CASE WHEN [num_of_writes] = 0
THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END,
[Latency] =
CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END,
[AvgBPerRead] =
CASE WHEN [num_of_reads] = 0
THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END,
[AvgBPerWrite] =
CASE WHEN [num_of_writes] = 0
THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END,
[AvgBPerTransfer] =
CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
THEN 0 ELSE
(([num_of_bytes_read] + [num_of_bytes_written]) /
([num_of_reads] + [num_of_writes])) END,
LEFT ([mf].[physical_name], 2) AS [Drive],
DB_NAME ([vfs].[database_id]) AS [DB],
[mf].[physical_name]
FROM
sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
JOIN sys.master_files AS [mf]
ON [vfs].[database_id] = [mf].[database_id]
AND [vfs].[file_id] = [mf].[file_id]

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_tempdbaudit]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_tempdbaudit', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DBAQueryStore
GO

IF OBJECT_ID(''dbo.tbl_tempdbaudit'') IS NULL
BEGIN 

CREATE TABLE [dbo].[tbl_tempdbaudit]  
    ( date datetime not null,
      session_id SMALLINT ,  
      database_id SMALLINT ,  
      sum_objects_alloc BIGINT ,  
      sum_objects_dealloc BIGINT 
    )  

END


BEGIN

	INSERT INTO tbl_tempdbaudit
SELECT  
		date = getdate(),
		session_id ,  
        database_id ,  
        sum_objects_alloc = user_objects_alloc_page_count + internal_objects_alloc_page_count ,  
        sum_objects_dealloc = user_objects_dealloc_page_count + internal_objects_dealloc_page_count 
FROM    sys.dm_db_session_space_usage  
WHERE session_id > 50
AND user_objects_alloc_page_count + internal_objects_alloc_page_count > 0

END


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_instanceLog]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_instanceLog', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
create table #traceflag
( TraceFlag smallint,
  Status bit,
  Global bit,
  Session bit)

insert into #traceflag
exec (''DBCC TRACESTATUS (1222, -1)'')
insert into #traceflag
exec (''DBCC TRACESTATUS (1204, -1)'')
insert into #traceflag
exec (''DBCC TRACESTATUS (1117, -1)'')
insert into #traceflag
exec (''DBCC TRACESTATUS (1118, -1)'')


declare @flag1204 bit 
select @flag1204 = Status from  #traceflag where TraceFlag = 1204

declare @flag1222 bit 
select @flag1222 = Status from  #traceflag where TraceFlag = 1222

declare @flag1117 bit 
select @flag1117 = Status from  #traceflag where TraceFlag = 1117

declare @flag1118 bit 
select @flag1118 = Status from  #traceflag where TraceFlag = 1118



IF @flag1204 = 0
BEGIN
     DBCC TRACEON (1204, -1)
END 

IF @flag1222 = 0
BEGIN
     DBCC TRACEON (1222, -1)
END

IF @flag1117 = 0
BEGIN
	DBCC TRACEON (1117, -1)	
END

IF @flag1118 = 0
BEGIN
	DBCC TRACEON (1118, -1)
END

drop table #traceflag


USE DBAQueryStore
GO
IF OBJECT_ID(''tbl_instancelog'') IS NULL
BEGIN
create table tbl_instancelog
( Logdate datetime not null,
  ProcessInfo varchar(20),
  Text varchar(4000)
)
END



BEGIN

declare @end datetime =  convert(varchar(20), getdate(), 120)
declare @begin   datetime =  convert(varchar(20),dateadd(ss,-10,getdate()),120)

insert into tbl_instancelog
Exec master..xp_readerrorlog 0,1,Null,Null,@begin,@end,''asc''

END

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_tranlog_generate]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_tranlog_generate', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DBAQueryStore
GO
IF OBJECT_ID(''dbo.tbl_transactionlog'') IS NULL
begin
create table tbl_transactionlog
(
date datetime not null,
session_id smallint not null,
dbname varchar(60),
transaction_type varchar(20),
database_transaction_state varchar(100),
log_record_count int,
current_logused_kb int,
current_syslogused_kb int
)
end


begin 
	insert into tbl_transactionlog

select 
date = getdate(),
sstran.session_id,
dbname = db_name(database_id),
transaction_type =
case database_transaction_type
when 1 then ''R/W tran''
when 2 then ''RO tran''
when 3 then ''Sys tran''
end,
database_transaction_state=
case database_transaction_state
when 1 then ''transaction not initialized''
when 3 then  ''transaction initialized log not generated''
when 4 then ''transaction has generated log records''
when 5 then ''transaction prepared''
when 10 then  ''transaction committed''
when 11 then ''transaction rolled back''
when 12 then ''transaction being committed.Log not hardened''
end,
database_transaction_log_record_count,
currentlogused_kb = (database_transaction_log_bytes_used + database_transaction_log_bytes_reserved) / 1024 ,
currentsyslogused_kb = (database_transaction_log_bytes_used_system + database_transaction_log_bytes_reserved_system) / 1024
from sys.dm_tran_database_transactions  dbtran
inner join sys.dm_tran_session_transactions  sstran 
on dbtran.transaction_id = sstran.transaction_id

end




', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_buffersize]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_buffersize', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
USE DBAQueryStore
GO
IF OBJECT_ID(''dbo.tbl_buffersize'') IS NULL
BEGIN
create table tbl_buffersize 
( 
  date datetime not null, 
  type varchar(50) not null,
  [VM Reserved_MB] float not null,
  [VM Committed_MB] int not null)
END

BEGIN

DECLARE @ratio float 
DECLARE @ratiobase float 
SELECT @ratiobase = cntr_value FROM sys.dm_os_performance_counters
WHERE Rtrim(Ltrim (counter_name)) = ''Buffer cache hit ratio base''
SELECT @ratio = cntr_value FROM sys.dm_os_performance_counters
WHERE Rtrim(Ltrim (counter_name)) = ''Buffer cache hit ratio''
DECLARE @connections int
SELECT @connections = COUNT(*) FROM sys.dm_exec_connections


insert into tbl_buffersize

select 
date = getdate(),
type,
sum(virtual_memory_reserved_kb) / 1024 as [VM Reserved],
sum(virtual_memory_committed_kb) / 1024 as [VM Committed]
from 
sys.dm_os_memory_clerks 
group by type

UNION

select 
date = getdate(),
type = ''Buffer cache hit ratio'',
[VM Reserved] = convert (float, @ratio / @ratiobase ),
[VM Committed] = ''''

UNION

select 
date = getdate(),
type = ''user connections'',
[VM Reserved] = @connections,
[VM Committed] = ''''

END

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [capture_memory_stats]    Script Date: 2018/11/2 10:42:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'capture_memory_stats', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

USE DBAQueryStore
GO
begin

IF OBJECT_ID(''dbo.tbl_memorystats'') IS NULL
create table tbl_memorystats
(
date datetime not null,
session_id smallint not null,
dbname varchar(60) null,
dop smallint not null,
physical_memory_in_use_kb int,
available_commit_limit_kb int,
process_physical_memory_low int,
process_virtual_memory_low int,
text varchar(max)

)
end

begin

insert into tbl_memorystats

select 
date = getdate(), 
'''' as session_id,
'''' as dbname, 
'''' as dop,
physical_memory_in_use_kb,
available_commit_limit_kb,
process_physical_memory_low,
process_virtual_memory_low,
'''' as text
from 
sys.dm_os_process_memory

union

select 
request_time,
session_id, 
dbname = db_name(sqlt.dbid),
dop, 
requested_memory_kb, 
granted_memory_kb,
required_memory_kb,
max_used_memory_kb,
sqlt.text
from sys.dm_exec_query_memory_grants mmg
cross apply sys.dm_exec_sql_text (mmg.sql_handle) sqlt 


end
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Forever', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170222, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'7011d808-9027-406e-b97b-52e261629594'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

