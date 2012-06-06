SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET SESSION tx_isolation='READ-UNCOMMITTED';
SET sql_log_bin = 0;
LOAD DATA INFILE '/tmp/dump.txt' INTO TABLE database.table;
