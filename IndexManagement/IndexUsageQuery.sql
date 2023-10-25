SELECT DB_NAME(DB_ID()) AS [DatabaseName]
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
  FROM [sys].[indexes] AS [i]
       LEFT JOIN [sys].[dm_db_index_usage_stats] AS [s]
       ON [s].object_id = [i].object_id
          AND
          [s].[index_id] = [i].[index_id]
 WHERE [s].[database_id] = DB_ID()
       AND
       [i].[is_hypothetical] = 0
       AND
       OBJECTPROPERTY([I].OBJECT_ID, 'IsUserTable') = 1
 ORDER BY [user_seeks] + [user_scans] + [user_lookups]
        , [SchemaName]
        , [TableName]
        , [IndexName];