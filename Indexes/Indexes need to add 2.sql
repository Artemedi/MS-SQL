-- Не забудьте поправить сценарий создания индексов, 
-- убрав лишние запятые или пустую инструкцию INCLUDE
SELECT 	[Рекомендуемый индекс]= 
		 '-- CREATE INDEX [IX_' + OBJECT_NAME(mid.object_id) + '_' +
		CAST(mid.index_handle AS nvarchar) + '] ON ' + 
		mid.statement + ' (' + ISNULL(mid.equality_columns,'') + 
		', ' + ISNULL(mid.inequality_columns,'') + 
		') INCLUDE (' + ISNULL(mid.included_columns,'') + ');', 
	[Число компиляций] = migs.unique_compiles,
	[Количество операций поиска] = migs.user_seeks,
	[Количество операций просмотра] = migs.user_scans,
	[Средняя стоимость ] = CAST(migs.avg_total_user_cost AS int),
	[Средний процент выигрыша] = CAST(migs.avg_user_impact AS int)
FROM	sys.dm_db_missing_index_groups mig
JOIN	sys.dm_db_missing_index_group_stats migs 
ON	migs.group_handle = mig.index_group_handle
JOIN	sys.dm_db_missing_index_details mid 
ON	mig.index_handle = mid.index_handle
AND	mid.database_id = DB_ID()
