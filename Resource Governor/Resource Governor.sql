!!!!!!!!!!!!!!!!!!!!!Важно!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--------------------------------------------------------------------
--DB_NAME() не работатет, используем вместо нее ORIGINAL_DB_NAME()--
--------------------------------------------------------------------
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


--Создание пулов ресурсов с указанием ресурсов которые может использовать данный пул
CREATE RESOURCE POOL [HighPriority] WITH(min_cpu_percent=0, 
		max_cpu_percent=80, 
		min_memory_percent=0, 
		max_memory_percent=80)
GO
CREATE RESOURCE POOL [MediumPriority] WITH(min_cpu_percent=0, 
		max_cpu_percent=40, 
		min_memory_percent=0, 
		max_memory_percent=40)
GO
CREATE RESOURCE POOL [LowPriority] WITH(min_cpu_percent=0, 
		max_cpu_percent=20, 
		min_memory_percent=0, 
		max_memory_percent=20)
GO

--Создание функции для регулятора ресурсов
use master
go
if exists (select 1 from sys.objects where name = 'ResourceGovernorCclassifyFunction' and type = 'FN' and schema_id = schema_id('dbo')) 
begin
 alter resource governor with (classifier_function = null)
 alter resource governor reconfigure
 drop function dbo.ResourceGovernorCclassifyFunction
end
go
create function dbo.ResourceGovernorCclassifyFunction() returns sysname
with schemabinding
as begin
    declare @grp_name as sysname   
     --Как настроить ргулятор читаем тут http://blogs.technet.com/b/isv_team/archive/2011/03/31/3417692.aspx
    if (SUSER_SNAME() = 'LOGIN' or SUSER_SNAME()= 'LOGIN') set @grp_name = 'HighPriority' --пользователь с таким-то логином будет направлен в группу HighPriority
    else if (SUSER_SNAME() = 'LOGIN') set @grp_name = 'MediumPriority' --пользователь с таким-то логином будет направлен в группу MediumPriority
    else if (SUSER_SNAME() = 'LOGIN') set @grp_name = 'LowPriority' --пользователь с таким-то логином будет направлен в группу LowPriority
    -- Остальные сессии будут работать в контексте Default
    return @grp_name
end
go

-- Включаем регулятор и присваеваем ему функцию

alter resource governor with (classifier_function = 'ResourceGovernorCclassifyFunction') -- чтобы отключить присвойте null
alter resource governor reconfigure
alter resource governor enable
alter resource governor reconfigure

 

-- Проверка регулятора ресурсов
select * from sys.resource_governor_resource_pools
select * from sys.resource_governor_workload_groups




--------------------------------Доп. Скрипты-------------------------------

--Вкл.\выкл. ресурс гувернер
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = [dbo].[ResourceGovernorClassifyFunction]);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO


--Убить все сессии в дефолтовой группе
declare @i int, @k int
declare @Command varchar(50);
set @k=100
while @k > 0
begin 
SET @i= (SELECT TOP (1) s.session_id
      --COUNT (g.name)    
      FROM sys.dm_exec_sessions s
     INNER JOIN sys.dm_resource_governor_workload_groups g
          ON g.group_id = s.group_id
          where g.name = 'default')
          
set @Command = 'kill ' + rtrim(@i) + ';';
    print @Command;
    execute(@Command);
    set @k=@k -1
end
select COUNT (g.name)    
      FROM sys.dm_exec_sessions s
     INNER JOIN sys.dm_resource_governor_workload_groups g
     ON g.group_id = s.group_id
          where g.name = 'default'
