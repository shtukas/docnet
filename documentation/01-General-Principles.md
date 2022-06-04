This dcumentation is a work in progress and convensions / definitions can change unexpectedly and in non backward compatible ways.

### DocNet Files

The entirely of the DocNet dataset is a collection of files, with extension `.fx13` (`.fx12` is the extension used for Catalyst / Nyx files)

Each fx13 file is a sqlite3 database with just one table called `_data_`. This simplicity is for both backward and forward compatibility, and all the data and metadata and attributes of those files will be in this one database table. 


### User Data

All user data is located in `~/docnet`
