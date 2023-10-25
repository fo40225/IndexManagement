SELECT DB_NAME([database_id]) AS [database_name]
     , OBJECT_SCHEMA_NAME(object_id, [database_id]) AS [schema_name]
     , OBJECT_NAME(object_id, [database_id]) AS [table_name]
     , [MisDetail].[equality_columns]
     , [MisDetail].[inequality_columns]
     , [MisDetail].[included_columns]
     , ([user_seeks] + [user_scans]) * [avg_total_user_cost] AS [total_cost_reduced]
     , [MisStatus].[user_seeks] AS [user_seeks]
     , [MisStatus].[user_scans] AS [user_scans]
     , [MisStatus].[avg_total_user_cost] AS [avg_per_user_cost_reduced]
     , [MisStatus].[avg_user_impact] AS [cost_reduced_percentage]
     , [MisStatus].[unique_compiles] AS [number_of_compilations]
     , 'CREATE INDEX IX_' + OBJECT_NAME(object_id, [database_id]) + '_' + CAST([MisDetail].index_handle AS [varchar](10)) + ' ON [' + DB_NAME([database_id]) + '].[' + OBJECT_SCHEMA_NAME(object_id, [database_id]) + '].[' + OBJECT_NAME(object_id, [database_id]) + ']' + CHAR(13) + CHAR(10) +
       '(' + CHAR(13) + CHAR(10) + '    ' +
       ISNULL([MisDetail].[equality_columns], '') + CASE
                                                        WHEN [MisDetail].[equality_columns] IS NOT NULL
                                                             AND
                                                             [MisDetail].[inequality_columns] IS NOT NULL
                                                            THEN ','
                                                        ELSE ''
                                                    END + ISNULL([MisDetail].[inequality_columns], '') + CHAR(13) + CHAR(10) +
       ')' + CHAR(13) + CHAR(10) +
       ISNULL('INCLUDE' + CHAR(13) + CHAR(10) +
       '(' + CHAR(13) + CHAR(10) + '    ' +
       included_columns + CHAR(13) + CHAR(10)+
       ')' + CHAR(13) + CHAR(10), '') +
       'WITH ( ONLINE = ON )' AS [SQL_Statment]
  FROM [sys].[dm_db_missing_index_details] AS [MisDetail]
       LEFT JOIN [sys].[dm_db_missing_index_groups]
       ON [sys].[dm_db_missing_index_groups].[index_handle] = [MisDetail].[index_handle]
       LEFT JOIN [sys].[dm_db_missing_index_group_stats] AS [MisStatus]
       ON [MisStatus].[group_handle] = [sys].[dm_db_missing_index_groups].[index_group_handle]
 WHERE [database_id] = DB_ID()
 ORDER BY [total_cost_reduced] DESC;