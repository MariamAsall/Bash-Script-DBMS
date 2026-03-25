:'
THIS FILE CONTAINS THE LOGIC FOR THE DATABASE CREATION AND SEEDING
1- CREATE THE DATABASE
2- CONNECT TO THE DATABASE
3- LIST Avaliable DATABASES
4- DROP THE TABLES IN THE DATABASE
'
# 1- CREATE THE DATABASE
create_db(){
    read -p "Enter the name of the database to create: " db_name
    if [[ -z $db_name ]]; then
        echo "Database name is empty Please enter a valid name"
    elif [[ -d "./data/$db_name" ]]; then 
        echo "Database already exists Please choose a different name"
    elif [[ $db_name =~ [^a-zA-Z0-9_] ]]; then
        echo "Database name should only contain letters, numbers, and underscores"
    else
        mkdir "./data/$db_name"
        echo "Database '$db_name' created successfully"
    fi
    
}

# 2- CONNECT TO THE DATABASE
connect_db(){
    read -p "Enter the name of the database to connect: " db_name
    if [[ -z $db_name ]]; then 
        echo "Database name is empty Please enter a valid name"
    elif [[ ! -d "./data/$db_name" ]]; then
        echo "Database doesn't exist Please enter a valid name"
    elif [[ $db_name =~ [^a-zA-Z0-9_] ]]; then
        echo "Database name should only contain letters, numbers, and underscores"
    else
        cd "./data/$db_name"
        echo "Connected to database '$db_name' successfully"
    fi
}

# 3- LIST Avaliable DATABASES
list_databases(){
    if [[ ! -d "./data" ]]; then
        echo "No databases folder found, Please create a database first"
    elif [[ -z "$(ls -A ./data)" ]]; then
        echo "Empty folder, No databases found Please create a database first"
    else
        echo "Available databases:"
        ls "./data"
    fi
}