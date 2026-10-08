-- get sql_id from sql_text
select sql_id, sql_text
from v$sql
where upper(sql_text) like '% SELECT %';

select sql_id, sql_text
from gv$sql
where upper(sql_text) like '% SELECT %'

-- Execution plan for the sql_id
select * from dbms_xplan.display_cursor('sql_id');

--- Get size of a table
select ds.owner ,
       ds.segment_name as table_name,
       sum(bytes)/1024/1024/1024 as size_gb,
from dba_segments ds
join dba_objects do
on ds.segment_name = do.object_name
where do.object_type = 'TABLE'
and ds.segment_name = '' -- add table name
group by segment_name, ds.segment_name;

-- Get size of partitions of a table
select ds.owner ,
       ds.segment_name as table_name,
       ds.partition_name,
       sum(bytes)/1024/1024/1024 as size_gb,
from dba_segments ds
join dba_objects do
on ds.segment_name = do.object_name
where do.object_type = 'TABLE'
and ds.segment_name = '' -- add table name
group by segment_name, ds.segment_name , ds.partition_name;

-- Get PCT_FREE value for table, index
select dt.pct_free, dt.table_name, dt.owner
from dba_tables dt
where dt.table_name = ''; --add table name

select di.pct_free, di.index_name, di.owner
from dba_indexes di
where di.index_name = ''; --add table name

-- PCT_ FREE from partitioned tables
select dtp.pct_free, dtp.table_name, dtp.owner, dtp.partition_name
from dba_tab_partitions dtp
where dtp.table_name = '';

-- Get table and index statistics details
select last_analyzed, stale_stats, table_name, owner
from dba_tab_statistics
where table_name = '';

select last_analyzed, stale_stats, index_name, owner
from dba_ind_statistics
where table_name = '';

-- DBA Scheduler
select * from dba_scheduler_programs;
select * from dba_scheduler_jobs;
select *
from dba_autotask_task dat
join dba_scheduler_programs dsp
on upper(dat.task_name) = dsp.program_name;

-- Complete database information
select * -- DBID, name, log_mode, protection_mode as data_guard_mode,
from v$database;

-- SGA Information
select * from v$sga;
select * from v$sgastats;

-- role and privilesges
select * from dba_roles;
select * from dba_role_privs;
select * from role_tab_privs;
select * from dba_tab_privs;
