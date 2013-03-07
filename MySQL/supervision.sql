# Count query by db
SELECT db,count(db) FROM information_schema.processlist GROUP BY db;

# % connections
SELECT ( pl.connections / gv.max_connections ) * 100 AS percentage_used_connections
    FROM
        ( SELECT COUNT(*) AS connections FROM information_schema.processlist ) AS pl,
        ( SELECT VARIABLE_VALUE AS max_connections FROM information_schema.global_variables WHERE variable_name = 'MAX_CONNECTIONS' ) AS gv

# Count lock by database
SELECT db,count(*)
    FROM information_schema.processlist
    WHERE state LIKE '%lock%';

# Oldest query
SELECT user,host,command,db,time
    FROM information_schema.processlist
    WHERE NOT (user  = 'system user' OR command = 'Binlog Dump')
    ORDER BY time DESC LIMIT 1;
