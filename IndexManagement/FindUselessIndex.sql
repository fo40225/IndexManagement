DECLARE @IndexNoUseDay INT = 1; --1 is today not used yet
SELECT *
  FROM(SELECT DB_NAME(DB_ID()) AS [DatabaseName]
            , OBJECT_SCHEMA_NAME([I].OBJECT_ID) AS [SchemaName]
            , OBJECT_NAME([I].OBJECT_ID) AS [TableName]
            , [i].[name] AS [IndexName]
            , 'DROP INDEX [' + [i].[name] + '] ON [' + DB_NAME(DB_ID()) + '].[' + OBJECT_SCHEMA_NAME([I].OBJECT_ID) + '].[' + OBJECT_NAME([I].OBJECT_ID) + ']' AS [SQL_Statment]
            , [i].[type_desc]
            , [i].[is_unique]
            , [i].[is_primary_key]
            , [i].[is_unique_constraint]
            , [user_seeks]
            , [user_scans]
            , [user_lookups]
            , [user_updates]
            , [last_user_seek]
            , [last_user_scan]
            , [last_user_lookup]
            , [last_user_update]
            , (SELECT MAX([last_user_used])
                 FROM(SELECT [last_user_seek] AS [last_user_used]
                      UNION
                      SELECT [last_user_scan] AS [last_user_used]) AS [t]) AS [LastUsedTime]
         FROM [sys].[indexes] AS [i]
              LEFT JOIN [sys].[dm_db_index_usage_stats] AS [s]
              ON [s].object_id = [i].object_id
                 AND
                 [s].[index_id] = [i].[index_id]
        WHERE [s].[database_id] = DB_ID()
              AND
              OBJECTPROPERTY([I].OBJECT_ID, 'IsUserTable') = 1
              AND
              [i].[type] = 2
              AND
              [i].[is_unique] = 0) AS [a]
 WHERE DATEDIFF(day, ISNULL([a].[LastUsedTime], '1900-01-01'), GETDATE()) > @IndexNoUseDay - 1
 ORDER BY [LastUsedTime]
        , [SchemaName]
        , [TableName]
        , [IndexName];