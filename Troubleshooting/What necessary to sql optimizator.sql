SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @StringToSearchFor Varchar(255)

Set @StringToSearchFor = '%<MissingIndexes>%'

SELECT  st.text

      ,cp.cacheobjtype

      ,cp.objtype

      ,DB_NAME(st.dbid) AS [DatabaseName]

      ,cp.usecounts

      ,qp.query_plan

FROM sys.dm_exec_cached_plans cp

      CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st

      CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp

WHERE CAST(qp.query_plan AS NVARCHAR(MAX))LIKE @StringToSearchFor

ORDER BY cp.usecounts DESC

Примечание: можно изменить значение @Stringtosearchfor на :

    '%<ColumnsWithNoStatistics>%' чтобы узнать информацию о колонках без статистки;
    '%<MissingIndexes>%' чтобы узнать информацию о недостающих индексах;
    '%<TableScan>%' чтобы узнать какие таблицы были сканированные. 
