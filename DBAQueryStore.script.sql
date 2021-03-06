USE [DBAQueryStore]
GO
/****** Object:  Table [dbo].[tbl_blocker]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_blocker](
	[date] [datetime] NOT NULL,
	[hostname] [varchar](40) NOT NULL,
	[spid] [smallint] NOT NULL,
	[blocker] [smallint] NOT NULL,
	[seconds] [int] NOT NULL,
	[dbname] [varchar](40) NULL,
	[cmd] [varchar](40) NULL,
	[lastwaittype] [varchar](40) NULL,
	[waitresource] [varchar](50) NULL,
	[physical_io] [int] NULL,
	[logical_reads] [int] NULL,
	[cpu_time] [int] NULL,
	[memory_usage] [int] NULL,
	[status] [varchar](20) NULL,
	[open_tran] [bit] NULL,
	[login_time] [datetime] NOT NULL,
	[blocker_sql] [nvarchar](max) NULL,
	[sqltext] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_buffersize]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_buffersize](
	[date] [datetime] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[VM Reserved_MB] [float] NOT NULL,
	[VM Committed_MB] [int] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_fileaudit]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_fileaudit](
	[date] [datetime] NOT NULL,
	[dbname] [varchar](30) NOT NULL,
	[dbsize_MB] [int] NULL,
	[dbgrowth_MB] [int] NULL,
	[filetype] [varchar](30) NULL,
	[filename] [varchar](50) NULL,
	[location] [varchar](100) NULL,
	[status] [varchar](30) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_instancelog]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_instancelog](
	[Logdate] [datetime] NOT NULL,
	[ProcessInfo] [varchar](20) NULL,
	[Text] [varchar](4000) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_memorystats]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_memorystats](
	[date] [datetime] NOT NULL,
	[session_id] [smallint] NOT NULL,
	[dbname] [varchar](30) NULL,
	[dop] [smallint] NOT NULL,
	[physical_memory_in_use_kb] [int] NULL,
	[available_commit_limit_kb] [int] NULL,
	[process_physical_memory_low] [int] NULL,
	[process_virtual_memory_low] [int] NULL,
	[text] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_sqlall]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_sqlall](
	[date] [datetime] NOT NULL,
	[spid] [int] NOT NULL,
	[seconds] [int] NOT NULL,
	[blocked] [int] NOT NULL,
	[hostname] [varchar](30) NULL,
	[loginame] [varchar](30) NULL,
	[cmd] [varchar](30) NULL,
	[application_name] [varchar](100) NULL,
	[dbname] [varchar](30) NULL,
	[cpu] [int] NOT NULL,
	[physical_io] [int] NULL,
	[requested_memory_kb] [int] NULL,
	[granted_memory_kb] [int] NULL,
	[required_memory_kb] [int] NULL,
	[max_used_memory_kb] [int] NULL,
	[sql_text] [varchar](max) NULL,
	[objectname] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_tempdbaudit]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_tempdbaudit](
	[date] [datetime] NOT NULL,
	[session_id] [smallint] NULL,
	[database_id] [smallint] NULL,
	[sum_objects_alloc] [bigint] NULL,
	[sum_objects_dealloc] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_transactionlog]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_transactionlog](
	[date] [datetime] NOT NULL,
	[session_id] [smallint] NOT NULL,
	[dbname] [varchar](30) NULL,
	[transaction_type] [varchar](20) NULL,
	[database_transaction_state] [varchar](100) NULL,
	[log_record_count] [int] NULL,
	[current_logused_kb] [int] NULL,
	[current_syslogused_kb] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_virtualio]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_virtualio](
	[Date] [datetime] NOT NULL,
	[ReadLatency] [int] NOT NULL,
	[WriteLatency] [int] NOT NULL,
	[Latency] [int] NOT NULL,
	[AvgByte/Read] [int] NOT NULL,
	[AvgByte/Write] [int] NOT NULL,
	[AvgByte/Transfer] [int] NOT NULL,
	[Drive] [varchar](5) NULL,
	[DB] [varchar](30) NULL,
	[physical_name] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Date_dbname_blocker]    Script Date: 2018/2/22 14:44:46 ******/
CREATE NONCLUSTERED INDEX [Date_dbname_blocker] ON [dbo].[tbl_blocker]
(
	[date] ASC,
	[dbname] ASC,
	[blocker] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [date_db]    Script Date: 2018/2/22 14:44:46 ******/
CREATE NONCLUSTERED INDEX [date_db] ON [dbo].[tbl_fileaudit]
(
	[date] ASC,
	[dbname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [cpu_memo]    Script Date: 2018/2/22 14:44:46 ******/
CREATE NONCLUSTERED INDEX [cpu_memo] ON [dbo].[tbl_sqlall]
(
	[dbname] ASC,
	[cpu] ASC,
	[max_used_memory_kb] ASC,
	[physical_io] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[getb]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[getb]

as

SELECT  es.session_id,
        ISNULL(blocking_session_id, 0) AS blocking_session_id,
        es.host_name AS host_name,
        es.original_login_name AS login_name,
        es.program_name,
        last_wait_type,
        es.cpu_time,
        es.logical_reads + es.writes AS physical_io,
        DB_NAME(er.database_id) as database_name,
        CASE    WHEN er.statement_start_offset = 0
                AND er.statement_end_offset = 0
                THEN st.text
                WHEN er.statement_start_offset <> 0
                        AND er.statement_end_offset = -1
                        THEN RIGHT(st.text, LEN(st.text) - (er.statement_start_offset / 2) + 1)
                WHEN er.statement_start_offset <> 0
                        AND er.statement_end_offset <> - 1
                        THEN SUBSTRING(st.text, (er.statement_start_offset / 2) + 1, (er.statement_end_offset / 2) - (er.statement_start_offset / 2))
                ELSE st.text
        END AS sql_text_statement,
        wait_time,
        st.text AS sql_text
       
INTO #tmp
FROM sys.dm_exec_sessions es
    LEFT JOIN sys.dm_exec_requests er
        
        ON er.session_id = es.session_id
    LEFT JOIN (sys.dm_exec_connections ec
        CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) st
        )ON ec.session_id = es.session_id

;WITH CTE
AS
(
SELECT  session_id AS RootBlockingSPID,
        session_id,
        blocking_session_id,
        0 AS nestlevel,
        CAST(session_id AS VARCHAR(MAX)) AS blocking_chain,
        host_name,
        login_name,
        program_name,
        last_wait_type,
        cpu_time,
        physical_io,
        wait_time,
        database_name,
        sql_text_statement,
        sql_text
       
FROM #tmp sp
WHERE blocking_session_id = 0
UNION ALL
SELECT  CTE.RootBlockingSPID,
        sp.session_id,
        sp.blocking_session_id,
        CTE.nestlevel + 1,
        blocking_chain + ' <-- ' + CAST(sp.session_id AS VARCHAR(MAX)),
        sp.host_name,
        sp.login_name,
        sp.program_name,
        sp.last_wait_type,
        sp.cpu_time,
        sp.physical_io,
        sp.wait_time,
        sp.database_name,
        sp.sql_text_statement,
        sp.sql_text
        
FROM #tmp sp
    INNER JOIN CTE
        ON CTE.session_id = sp.blocking_session_id
),
CTE2
AS
(
SELECT  RootBlockingSPID,
        session_id,
        blocking_session_id,
        blocking_chain,
        host_name,
        login_name,
        program_name,
        last_wait_type,
        cpu_time,
        physical_io,
        wait_time,
        database_name,
        sql_text_statement,
        sql_text
        
FROM CTE
WHERE EXISTS (SELECT 1 FROM CTE CTE2 WHERE CTE2.blocking_session_id = CTE.session_id)
        AND blocking_session_id = 0
UNION ALL
SELECT  RootBlockingSPID,
        session_id,
        blocking_session_id,
        blocking_chain,
        host_name,
        login_name,
        program_name,
        last_wait_type,
        cpu_time,
        physical_io,
        wait_time,
        database_name,
        sql_text_statement,
        sql_text
        
FROM CTE
WHERE blocking_session_id <> 0
)
SELECT  session_id,
        blocking_chain,
        host_name,
        login_name,
        program_name,
        database_name,
        wait_time,
        last_wait_type,
        cpu_time,
        physical_io,
        sql_text_statement,
        sql_text
        
FROM CTE2
ORDER BY    RootBlockingSPID,
            blocking_chain
IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
    DROP TABLE #tmp


GO
/****** Object:  StoredProcedure [dbo].[getbh]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[getbh]

as

select top 100 * from 
dbaquerystore.dbo.tbl_blocker
order by date desc

GO
/****** Object:  StoredProcedure [dbo].[getf]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[getf]

as

 select type_desc, name, physical_name, size*8/1024/1024
 from sys.database_files order by 1 desc



 SELECT DATA_TYPE = TYPE_DESC,
[FREESPACE M] = SUM(SIZE - FILEPROPERTY (NAME, 'SPACEUSED') )/128 ,
[FULL SIZE M] = SUM (SIZE /128 ),
[ActualSpaceUsed MB] = SUM(FILEPROPERTY (NAME, 'SPACEUSED') )/128
FROM SYS.DATABASE_FILES
GROUP BY TYPE_DESC
ORDER BY TYPE_DESC

GO
/****** Object:  StoredProcedure [dbo].[getp]    Script Date: 2018/2/22 14:44:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[getp]

as



SELECT 
ObjectName         = CASE 
		WHEN OBJECT_SCHEMA_NAME(b.objectid,b.dbid) + '.' + OBJECT_NAME(b.objectid, b.dbid) IS NULL THEN 'Explicit User Query' 
		ELSE OBJECT_SCHEMA_NAME(b.objectid,b.dbid) + '.' + OBJECT_NAME(b.objectid, b.dbid) 
		END,
 [blk] = a.blocking_session_id,
 [sid] =  a.session_id, 
 a.wait_type,
 datediff(ss, a.Start_Time, getdate()) as Seconds,
 a.logical_reads,
 a.cpu_time,
 s.login_name,
 d.Name AS DBName,
 a.status,
 s.host_name,
 a.total_elapsed_time / 1000.0 as ElapsedTime,
 m.requested_memory_kb,
 m.max_used_memory_kb,
 m.dop,
 a.command,
 b.text,
 substring(b.text, a.statement_start_offset / 2, case when (a.statement_end_offset - a.statement_start_offset) / 2 > 0 THEN (a.statement_end_offset - a.statement_start_offset) / 2 else 1 END ) as stmt,
 a.wait_time,
 a.last_wait_type,
 a.wait_resource,
 a.reads,
 a.writes,
 a.granted_query_memory 
 --,query_plan = convert (XML,c.query_plan)
FROM sys.dm_exec_requests a with (nolock)
OUTER APPLY sys.dm_exec_sql_text(a.sql_handle) b
OUTER APPLY sys.dm_exec_text_query_plan (a.plan_handle, a.statement_start_offset, a.statement_end_offset) c
LEFT JOIN sys.dm_exec_query_memory_grants m (nolock)
ON m.session_id = a.session_id
 AND m.request_id = a.request_id 
JOIN sys.databases d
ON d.database_id = a.database_id
INNER JOIN sys.dm_exec_sessions s
on a.session_id = s.session_id
WHERE  a.session_id > 50
 and a.session_id <> @@spid
 and wait_type != 'SP_SERVER_DIAGNOSTICS_SLEEP'
--and d.name = 'wdxmjjjsxt'
 --and a.status = 'running'
--and login_name = 'wandataskdb_user'
--ORDER BY Seconds desc 
ORDER BY cpu_time desc 


GO
