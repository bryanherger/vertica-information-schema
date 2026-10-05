-- INFORMATION_SCHEMA DDL for Vertica implementing tables/views from SQL92 spec at https://www.contrib.andrew.cmu.edu/~shadow/sql/sql1992.txt
-- revised for 24.1 and later with support for namespaces (namespace = catalog) and 26.x or later Postgres compatibility (PGcompat)
DROP SCHEMA IF EXISTS INFORMATION_SCHEMA CASCADE;
DROP SCHEMA IF EXISTS PG_CATALOG CASCADE;
-- 21.2.1 - BryanH edit 05-Oct-2026 some consumers expect this to be lower-case
CREATE SCHEMA information_schema;
-- BryanH edit 05-Oct-2026 some consumers expect this to exist for PGcompat
CREATE SCHEMA pg_catalog;
-- 21.2.2, 21.2.3 - Vertica only supports one catalog per database, which we'll call "DEFAULT" here, but TODO, this will change with namespace support
-- 21.2.4 SCHEMATA
GRANT USAGE ON SCHEMA INFORMATION_SCHEMA TO PUBLIC;
CREATE VIEW INFORMATION_SCHEMA.SCHEMATA
              AS SELECT
                  schema_namespace_name AS CATALOG_NAME, SCHEMA_NAME, SCHEMA_OWNER,
                  '' AS DEFAULT_CHARACTER_SET_CATALOG, 
				  '' AS DEFAULT_CHARACTER_SET_SCHEMA,
                  '' AS DEFAULT_CHARACTER_SET_NAME
                FROM V_CATALOG.SCHEMATA;
-- 21.2.5 DOMAINS - not sure Vertica supports this
-- 21.2.6 DOMAIN_CONSTRAINTS - not sure Vertica supports this
-- 21.2.7 TABLES - BryanH edit 05-Oct-2026 updated with testing feedback
CREATE VIEW information_schema.tables AS
SELECT
    'DEFAULT' AS table_catalog,
    table_schema,
    table_name,
    'BASE TABLE' AS table_type
FROM v_catalog.tables

UNION ALL

SELECT
    'DEFAULT' AS table_catalog,
    table_schema,
    table_name,
    'VIEW' AS table_type
FROM v_catalog.views;

GRANT SELECT ON information_schema.tables TO PUBLIC;
-- 21.2.8 VIEWS
CREATE VIEW INFORMATION_SCHEMA.VIEWS
              AS SELECT
                table_namespace AS TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, VIEW_DEFINITION,
                  '' AS CHECK_OPTION, 'false' AS IS_UPDATABLE
              FROM V_CATALOG.VIEWS;
-- 21.2.9 COLUMNS
CREATE VIEW INFORMATION_SCHEMA.COLUMNS
              AS SELECT DISTINCT
                table_namespace AS TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME,
                COLUMN_NAME, ORDINAL_POSITION,
                COLUMN_DEFAULT,
                IS_NULLABLE,
                DATA_TYPE,
                DATA_TYPE_LENGTH AS CHARACTER_MAXIMUM_LENGTH,
                DATA_TYPE_LENGTH AS CHARACTER_OCTET_LENGTH,
                NUMERIC_PRECISION,
                NULL AS NUMERIC_PRECISION_RADIX,
                NUMERIC_SCALE,
                DATETIME_PRECISION,
                '' AS CHARACTER_SET_CATALOG,
                '' AS CHARACTER_SET_SCHEMA,
                '' AS CHARACTER_SET_NAME,
                '' AS COLLATION_CATALOG,
                '' AS COLLATION_SCHEMA,
                '' AS COLLATION_NAME,
                '' AS DOMAIN_CATALOG, '' AS DOMAIN_SCHEMA, '' AS DOMAIN_NAME
              FROM V_CATALOG.COLUMNS;
-- 21.2.10 TABLE_PRIVILEGES
CREATE VIEW INFORMATION_SCHEMA.TABLE_PRIVILEGES
              AS SELECT
                GRANTOR, GRANTEE, 'DEFAULT' AS TABLE_CATALOG, OBJECT_SCHEMA AS TABLE_SCHEMA, OBJECT_NAME AS TABLE_NAME,
                  PRIVILEGES_DESCRIPTION AS PRIVILEGE_TYPE, 'false' AS IS_GRANTABLE
              FROM V_CATALOG.GRANTS
                  WHERE OBJECT_TYPE = 'TABLE' AND (GRANTEE IN ( 'PUBLIC', CURRENT_USER ) OR GRANTOR = CURRENT_USER);
-- 21.2.11 COLUMN_PRIVILEGES - TODO, factor in access policies
-- 21.2.12 USAGE_PRIVILEGES - TODO, factor in access policies and grants etc.
-- 21.2.13 TABLE_CONSTRAINTS
CREATE VIEW INFORMATION_SCHEMA.TABLE_CONSTRAINTS
              AS SELECT
                  '' AS CONSTRAINT_CATALOG, '' AS CONSTRAINT_SCHEMA, CONSTRAINT_NAME,
                  'DEFAULT' AS TABLE_CATALOG, '' AS TABLE_SCHEMA, TABLE_NAME,
                  CONSTRAINT_TYPE, 'false' AS IS_DEFERRABLE, 'false' AS INITIALLY_DEFERRED
                FROM V_CATALOG.TABLE_CONSTRAINTS;
-- 21.2.14 REFERENTIAL_CONSTRAINTS - not supported
-- 21.2.15 CHECK_CONSTRAINTS - not supported
-- 21.2.16 KEY_COLUMN_USAGE - not directly supported, TODO
-- 21.2.17 ASSERTIONS - not supported
-- 21.2.18 CHARACTER_SETS - not directly supported
-- 21.2.19 COLLATIONS - not supported
-- 21.2.20 TRANSLATIONS - mot supported
-- 21.2.21 VIEW_TABLES
CREATE VIEW INFORMATION_SCHEMA.VIEW_TABLE_USAGE
              AS SELECT
                '' AS VIEW_CATALOG, TABLE_SCHEMA AS VIEW_SCHEMA, TABLE_NAME AS VIEW_NAME,
                '' AS TABLE_CATALOG, REFERENCE_TABLE_SCHEMA AS TABLE_SCHEMA, REFERENCE_TABLE_NAME AS TABLE_NAME
              FROM V_CATALOG.VIEW_TABLES;
-- 21.2.22 VIEW_COLUMN_USAGE (TODO see VER-22441 on column ID defs) TODO: there doesn't seems to be a way to map view columns to reference table columns, figure out how
CREATE VIEW INFORMATION_SCHEMA.VIEW_COLUMN_USAGE AS
              SELECT '' AS VIEW_CATALOG, C.TABLE_SCHEMA AS VIEW_SCHEMA, C.TABLE_NAME AS VIEW_NAME,
                     '' AS TABLE_CATALOG, '' AS TABLE_SCHEMA, '' AS TABLE_NAME, COLUMN_NAME
                FROM V_CATALOG.VIEW_COLUMNS C;
-- 21.2.23 CONSTRAINT_TABLE_USAGE - TODO, but may not apply since Vertica stores constraints directly, not in catalog TABLES
-- 21.2.24 CONSTRAINT_COLUMN_USAGE - may not apply since Vertica stores constraints directly, not in catalog TABLES
-- 21.2.25 COLUMN_DOMAIN_USAGE - domains not supported
-- 21.2.26 SQL_LANGUAGES - TODO, since this will be a table describing Vertica capabilities, which I need to look up. Currently this will return same SQL99 info as Postgres 9, which seems safe since we are derived from that.
-- sql_language_source | sql_language_year | sql_language_conformance | sql_language_integrity | sql_language_implementation | sql_language_binding_style | sql_language_programming_language
-----------------------+-------------------+--------------------------+------------------------+-----------------------------+----------------------------+-----------------------------------
-- ISO 9075            | 1999              | CORE                     |                        |                             | DIRECT                     |
-- ISO 9075            | 1999              | CORE                     |                        |                             | EMBEDDED                   | C
CREATE TABLE INFORMATION_SCHEMA.SQL_LANGUAGES (SQL_LANGUAGE_SOURCE VARCHAR, SQL_LANGUAGE_YEAR VARCHAR, SQL_LANGUAGE_CONFORMANCE VARCHAR,
                  SQL_LANGUAGE_INTEGRITY VARCHAR, SQL_LANGUAGE_IMPLEMENTATION VARCHAR,
                  SQL_LANGUAGE_BINDING_STYLE VARCHAR, SQL_LANGUAGE_PROGRAMMING_LANGUAGE VARCHAR);
INSERT INTO INFORMATION_SCHEMA.SQL_LANGUAGES VALUES ('ISO 9075','1999','CORE','','','DIRECT','');
INSERT INTO INFORMATION_SCHEMA.SQL_LANGUAGES VALUES ('ISO 9075','1999','CORE','','','EMBEDDED','C');
-- 21.2.27 SQL_IDENTIFIER domain - not supported
-- 21.2.28 CHARACTER_DATA domain - not supported
-- 21.2.29 CARDINAL_NUMBER domain - not supported
-- END of 21.2 INFORMATION_SCHEMA
-- 21.3 DEFINITION_SCHEMA Schema: TODO, but most of these exist in some form in V_CATALOG schema
-- 21.x ROUTINES - BryanH add 05-Oct-2026 from testing feedback
CREATE VIEW information_schema.routines AS
SELECT
    'DEFAULT' AS specific_catalog,
    schema_name AS specific_schema,
    function_name AS specific_name,
    'DEFAULT' AS routine_catalog,
    schema_name AS routine_schema,
    function_name AS routine_name,
    'FUNCTION' AS routine_type
FROM v_catalog.user_functions

UNION ALL

SELECT
    'DEFAULT' AS specific_catalog,
    schema_name AS specific_schema,
    procedure_name AS specific_name,
    'DEFAULT' AS routine_catalog,
    schema_name AS routine_schema,
    procedure_name AS routine_name,
    'PROCEDURE' AS routine_type
FROM v_catalog.user_procedures;
-- pg_catalog shim - BryanH add 05-Oct-2026 from testing feedback on PGcompat
GRANT USAGE ON SCHEMA pg_catalog TO PUBLIC;
CREATE VIEW pg_catalog.pg_namespace AS
SELECT
    schema_id AS oid,
    schema_name AS nspname
FROM v_catalog.schemata;
GRANT SELECT ON pg_catalog.pg_namespace TO PUBLIC;
CREATE VIEW pg_catalog.pg_class AS
SELECT
    table_id AS oid,
    table_name AS relname,
    table_schema_id AS relnamespace,
    'r' AS relkind
FROM v_catalog.tables

UNION ALL

SELECT
    table_id AS oid,
    table_name AS relname,
    table_schema_id AS relnamespace,
    'v' AS relkind
FROM v_catalog.views;

GRANT SELECT ON pg_catalog.pg_class TO PUBLIC;
CREATE VIEW pg_catalog.pg_attribute AS
SELECT
    table_id AS attrelid,
    column_name AS attname,
    DENSE_RANK() OVER (
        ORDER BY LOWER(data_type)
    ) AS atttypid,
    ordinal_position AS attnum,
    NOT is_nullable AS attnotnull
FROM v_catalog.columns;

GRANT SELECT ON pg_catalog.pg_attribute TO PUBLIC;

CREATE VIEW pg_catalog.pg_type AS
SELECT
    DENSE_RANK() OVER (
        ORDER BY LOWER(data_type)
    ) AS oid,
    data_type AS typname
FROM (
    SELECT DISTINCT data_type
    FROM v_catalog.columns
) types;

GRANT SELECT ON pg_catalog.pg_type TO PUBLIC;

CREATE VIEW pg_catalog.pg_description AS
SELECT
    CAST(NULL AS INT) AS objoid,
    CAST(NULL AS INT) AS objsubid,
    CAST(NULL AS VARCHAR(65000)) AS description
WHERE 1 = 0;

GRANT SELECT ON pg_catalog.pg_description TO PUBLIC;

CREATE VIEW pg_catalog.pg_constraint AS
SELECT
    tc.constraint_schema_id AS connamespace,
    tc.table_id AS conrelid,
    ARRAY[c.ordinal_position] AS conkey,
    tc.constraint_type AS contype
FROM v_catalog.table_constraints tc
JOIN v_catalog.constraint_columns cc
    ON cc.constraint_id = tc.constraint_id
JOIN v_catalog.columns c
    ON c.table_id = cc.table_id
    AND c.column_name = cc.column_name
WHERE tc.constraint_type = 'p';

GRANT SELECT ON pg_catalog.pg_constraint TO PUBLIC;

CREATE VIEW pg_catalog.pg_matviews AS
SELECT
    CAST(NULL AS VARCHAR(128)) AS schemaname,
    CAST(NULL AS VARCHAR(128)) AS matviewname,
    CAST(NULL AS VARCHAR(128)) AS matviewowner,
    CAST(NULL AS VARCHAR(128)) AS tablespace,
    CAST(NULL AS BOOLEAN) AS hasindexes,
    CAST(NULL AS BOOLEAN) AS ispopulated,
    CAST(NULL AS VARCHAR(65000)) AS definition
WHERE 1 = 0;

GRANT SELECT ON pg_catalog.pg_matviews TO PUBLIC;
-- Permissions
GRANT SELECT ON ALL TABLES IN SCHEMA INFORMATION_SCHEMA TO PUBLIC;
