:'
this file contains global variables setup 
'

export root="$(pwd)"  # this variable will hold the root directory of the project, it will be used in all file operations to know where we are working on
export current_db="" # this variable will hold the name of the currently connected database, it will be used in all table operations to know which database we are working on
export DB_DIR="$root/data" # this variable will hold the path to the databases directory, it will be used in all database operations to know where to create, delete, list databases

