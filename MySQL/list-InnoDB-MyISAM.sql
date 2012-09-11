; list
SELECT table_schema, table_name, engine
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','performance_schema','information_schema') AND engine != 'NULL'
ORDER BY table_schema;

; count
SELECT DISTINCT engine AS engine_name, count(engine) AS engine
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','performance_schema','information_schema') AND engine != 'NULL'
GROUP BY engine;
