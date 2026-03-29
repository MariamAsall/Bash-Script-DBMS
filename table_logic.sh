:'
This script contains the logic for creating a new table,
including input validation and metadata management. 
It is sourced by the main menu script when the user chooses to create a new table. 
1- Create Table
2- List Tables
3- Drop Table
4- Update Table
'

# 1- CREATING A NEW TABLE
#!/bin/bash
shopt -s extglob

create_table() {
echo " CREATE NEW TABLE"

    # first we need table name
    read -p "Enter Table Name: " table_name

    if [[ "$table_name" == "" ]]; then
        echo "Please enter a name!"
        return
    fi

    # validation if the table already exists
    if [[ -f "$table_name" || -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' already exists!"
        return
    fi

    # number of columns
    read -p "Enter number of columns: " num_cols

    if [[ "$num_cols" == "" ]]; then
        echo "Please enter a number of columns!"
        return
    fi

    case $num_cols in
        +([0-9]))
            ;;  
        *)
            echo "Please enter a number of columns"
            return
            ;;
    esac

    if [[ "$num_cols" -le 0 ]]; then
        echo "please dont enter a negative number!"
        return
    fi

    echo "Now enter details for each column:"

    metadata=""

    for ((i=1; i<=num_cols; i++)); do
        echo "Column $i:"

        read -p "   Column name: " col_name
        if [[ "$col_name" == "" ]]; then
            echo "Error: Column name cannot be empty!"
            return
        fi

        # now data type
        read -p "   Data type (int or string): " col_type

        case $col_type in
            int|Int|INT|string|String|STRING)
                ;;  
            *)
                echo "Error: Data type must be 'int' or 'string' only!"
                return
                ;;
        esac

        # see primary key
        is_pk="no"
        read -p "   Is this the Primary Key? (y/n): " pk_choice

        case $pk_choice in
            y|Y|yes|Yes|YES)
                is_pk="yes"
                ;;
            n|N|no|No|NO)
                is_pk="no"
                ;;
            *)
                echo "Error: Please answer y or n only!"
                return
                ;;
        esac

        # Add this column info to metadata
        metadata+="$col_name:$col_type:$is_pk"$'\n'
    done

    # Save metadata to file
    echo -n"$metadata" > "$table_name.metadata"
    # Create empty data file
    touch "$table_name"

    echo "✅ Table '$table_name' created successfully!"
    echo "   Files created: $table_name   and   $table_name.metadata"
}

table_menu


# 2- LIST TABLES
list_tables() {
    echo "Available tables:"