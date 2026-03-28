#!/bin/bash
shopt -s extglob

# ==============================================================================
# This script contains the logic for creating a new table,
# including input validation and metadata management. 
# It is sourced by the main menu script when the user chooses to create a new table. 
# 1- Create Table
# 2- List Tables
# 3- Drop Table
# 4- Update Table
# ==============================================================================

# 1- Create Table
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

    if [[ "$num_cols" == "" ]]; thengit pu
        echo "Please enter a number of columns!"
        return
    fi

    case $num_cols in
    *[!0-9]*) 
        echo "Error: Please enter a positive number only!"
        return 
        ;;
    "") 
        echo "Error: Number of columns cannot be empty!"
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
    echo -n "$metadata" > "$table_name.metadata"
    touch "$table_name"

    echo "✅ Table '$table_name' created successfully!"
    echo "   Files created: $table_name   and   $table_name.metadata"
}
##################

update_table() {

    echo "           Update Table"

    read -p "Enter Table Name: " table_name

    if [[ "$table_name" == "" ]]; then
        echo "Error: Table name cannot be empty!"
        return
    fi

    if [[ ! -f "$table_name" || ! -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' or its metadata does not exist!"
        return
    fi

    echo "Current content of table '$table_name':"
    cat "$table_name"
    echo "----------------------------------------"

    echo "Available columns:"
    cat "$table_name.metadata"
    echo "----------------------------------------"

    read -p "Enter column name to update: " update_col
    read -p "Enter Primary Key value: " pk_value
    read -p "Enter new value: " new_value

    if [[ "$update_col" == "" || "$pk_value" == "" || "$new_value" == "" ]]; then
        echo "Error: Column name, PK value or new value cannot be empty!"
        return
    fi

    # Find column number using awk
    col_num=$(awk -F: -v col="$update_col" '{ if($1 == col) print NR }' "$table_name.metadata" | head -1)

    if [[ "$col_num" == "" ]]; then
        echo "Error: Column '$update_col' not found in metadata!"
        return
    fi

    # Update using awk
    awk -F: -v pk="$pk_value" -v col_idx="$col_num" -v val="$new_value" '
    BEGIN {
        OFS=":"
    }
    {
        if ($1 == pk) {
            $col_idx = val
        }
        print $0
    }' "$table_name" > temp_file && mv temp_file "$table_name"

    echo "✅ Update completed successfully!"
    echo "Updated table content:"
    cat "$table_name"
}



