# Count query by db
SELECT db,count(db) FROM information_schema.processlist GROUP BY db;

# % connections
SELECT ( pl.connections / gv.max_connections ) * 100 AS percentage_used_connections
    FROM
        ( SELECT COUNT(*) AS connections FROM information_schema.processlist ) AS pl,
        ( SELECT VARIABLE_VALUE AS max_connections FROM information_schema.global_variables WHERE variable_name = 'MAX_CONNECTIONS' ) AS gv
