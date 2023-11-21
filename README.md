# vertica-information-schema
Example partial Vertica SQL implementation of INFORMATION_SCHEMA schema, tables, views.  BSD license applies: no warranty, no support, no guarantee it works for any or all applications.

Implementation details were sourced from the specification document found at https://www.contrib.andrew.cmu.edu/~shadow/sql/sql1992.txt

Install: run the DDL SQL as dbadmin with vsql -f (* this may overwrite any existing objects if schema INFORMATION_SCHEMA exists).  Uninstall: DROP SCHEMA INFORMATION_SCHEMA CASCADE; (which will drop all objects including any added outside of the DDL in this repo)

Only objects and fields supported by Vertica are implemented.  Contributions are welcome to improve behavior.

