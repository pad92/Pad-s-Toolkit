SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema NOT IN ('mysql','performance_schema','information_schema')
    ORDER BY table_schema;
