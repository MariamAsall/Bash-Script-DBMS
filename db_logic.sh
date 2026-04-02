
# 1- CREATE THE DATABASE
create_db(){
    read -p "Enter the name of the database to create: " db_name
    if [[ -z $db_name ]]; then
        echo "Database name is empty Please enter a valid name"
    elif [[ -d "$DB_DIR/$db_name" ]]; then 
        echo "Database already exists Please choose a different name"
    elif [[ $db_name =~ [^a-zA-Z0-9_] ]]; then
        echo "Database name should only contain letters, numbers, and underscores"
    else
        mkdir "$DB_DIR/$db_name"
        echo "Database '$db_name' created successfully"
    fi
    
}

# 2- CONNECT TO THE DATABASE
connect_db(){
    read -p "Enter the name of the database to connect: " db_name
    if [[ -z $db_name ]]; then 
        echo "Database name is empty Please enter a valid name"
    elif [[ ! -d "$DB_DIR/$db_name" ]]; then
        echo "Database doesn't exist Please enter a valid name"
    elif [[ $db_name =~ [^a-zA-Z0-9_] ]]; then
        echo "Database name should only contain letters, numbers, and underscores"
    else
        cd "$DB_DIR/$db_name"
        export current_db="$db_name"
        echo "Connected to database '$db_name' successfully"
        table_menu
    fi
}

# 3- LIST AVALIABLE DATABASES
list_databases(){
    if [[ ! -d "$DB_DIR" ]]; then
        echo "No databases folder found, Please create a database first"
    elif [[ -z "$(ls -A $DB_DIR)" ]]; then
        echo "Empty folder, No databases found Please create a database first"
    else
        echo "Available databases:"
        ls "$DB_DIR"
    fi
}

# 4- DROP THE DATABASE
drop_db(){
    read -p "Enter the name of the database to drop: " db_name
    if [[ -z $db_name ]]; then 
        echo "Database name is empty Please enter a valid name"
    elif [[ ! -d "$DB_DIR/$db_name" ]]; then
        echo "Database doesn't exist Please enter a valid name"
    elif [[ $db_name =~ [^a-zA-Z0-9_] ]]; then
        echo "Database name should only contain letters, numbers, and underscores"
    else
        read -p "Are you sure you want to drop '$db_name'? (y/n): " confirm
        if [[ $confirm == [yY] ]]; then
            rm -rf "$DB_DIR/$db_name"
            echo "Database '$db_name' dropped successfully"
        else
            echo "Operation cancelled"
        fi
    fi
}
