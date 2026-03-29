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
    read -p "Enter Table Name: " table_name
    if [[ "$table_name" == "" ]]; then
       echo "Please enter a name!"
       return
    fi 

    if [[ -f "$table_name" || -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' already exists!"
        return
    fi

    read -p "Enter number of columns: " num_cols
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
 

    echo "Now enter details for each column:"
    metadata=""
    pk_column=""         
    pk_found=false

    for ((i=1; i<=num_cols; i++)); do
        echo "Column $i:"
        read -p "   Column name: " col_name
         if [[ "$col_name" == "" ]]; then
            echo "Error: Column name cannot be empty!"
            return
        fi


        read -p "   Data type (int or string): " col_type
        col_type=$(echo "$col_type" | tr '[:upper:]' '[:lower:]')
        case $col_type in
            int|Int|INT|string|String|STRING)
                ;;  
            *)
                echo "Error: Data type must be 'int' or 'string' only!"
                return
                ;;
        esac

        # Primary Key
        is_pk="no"
        read -p "   Is this the Primary Key? (y/n): " pk_choice
        pk_choice=$(echo "$pk_choice" | tr '[:upper:]' '[:lower:]')

        if [[ "$pk_choice" == "y" || "$pk_choice" == "yes" ]]; then
            if [[ "$pk_found" == true ]]; then
                echo "Error: Only one Primary Key is allowed!"
                return
            fi
            is_pk="yes"
            pk_column="$col_name"
            pk_found=true
        fi

        metadata+="$col_name:$col_type:$is_pk"$'\n'
    done

    # Enforce that at least one PK was chosen
    if [[ "$pk_found" == false ]]; then
        echo "Error: You must choose one Primary Key column!"
        return
    fi

    # Save metadata
    echo -n "$metadata" > "$table_name.metadata"
    touch "$table_name"


    echo "✅ Table '$table_name' created successfully!"
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


update_table() {
    echo " UPDATE TABLE"
    read -p "Enter Table Name: " table_name

    if [[ "$table_name" == "" ]]; then
        echo "Error: Table name cannot be empty!"
        return
    fi
  

    if [[ ! -f "$table_name" || ! -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' or its metadata does not exist!"
        return
    fi


    # 1. Find the PK column number and name
    pk_col_num=$(awk -F: '$3=="yes" {print NR}' "$table_name.metadata")
    pk_col_name=$(awk -F: '$3=="yes" {print $1}' "$table_name.metadata")

    read -p "Enter $pk_col_name (PK) value to identify record: " pk_value
    read -p "Enter column name to update: " update_col

    if [[ "$pk_col_name" == "" ]]; then
        echo "Error: No Primary Key defined for this table!"
        return
    fi

    echo "Available Columns:"
    awk -F: '{ print NR ". " $1 " (" $2 ")" }' "$table_name.metadata"

   

  
    col_info=$(awk -F: -v col="$update_col" '$1==col {print NR ":" $2}' "$table_name.metadata")

    if [[ "$col_info" == "" ]]; then
        echo "Error: Column '$update_col' not found in metadata!"
        return
    fi

 
    update_idx=$(echo $col_info | cut -d: -f1)
    update_type=$(echo $col_info | cut -d: -f2)
    read -p "Enter new value for $update_col: " new_value

    # Data Type Validation
    if [[ "$update_type" == "int" ]]; then
        if ! [[ "$new_value" =~ ^-?[0-9]+$ ]]; then
            echo "Error: Column '$update_col' is int type. Please enter a valid integer!"
            return
        fi
    fi


    awk -F: -v pk_val="$pk_value" -v pk_idx="$pk_col_num" -v upd_idx="$update_idx" -v new_val="$new_value" '
        BEGIN { OFS=":" }
        {
            # Only change the column if the Primary Key matches in the correct PK column
            if ($pk_idx == pk_val) {
                $upd_idx = new_val
            }
            print $0
        }
    ' "$table_name" > temp_file && mv temp_file "$table_name"

    echo "✅ Update completed successfully!"
    echo "Updated table content:"
    cat "$table_name"
}


# SELECT record

select_record() {
    echo " SELECT RECORD"
    read -p "Enter Table Name: " table_name
    if [[ -z "$table_name" ]]; then
        echo "Error: Table name cannot be empty!"
        return
    fi
    if [[ ! -f "$table_name" ]] || [[ ! -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' or its metadata does not exist!"
        return
    fi

  
    echo "Available Columns:"
    awk -F: '{ print NR ". " $1 " (" $2 ")" }' "$table_name.metadata"

    # Ask user if they want to filter by any column
    read -p "Do you want to filter by a specific column? (y/n): " filter_choice
    filter_choice=$(echo "$filter_choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$filter_choice" == "y" || "$filter_choice" == "yes" ]]; then
        read -p "Enter column name to filter by: " filter_col
        read -p "Enter value to search for: " filter_val

        # Validate column exists
        col_exists=$(awk -F: -v col="$filter_col" '$1 == col {print "yes"}' "$table_name.metadata")
        if [[ "$col_exists" != "yes" ]]; then
            echo "Error: Column '$filter_col' not found!"
            return
        fi

        # Get column number for filtering
        col_num=$(awk -F: -v col="$filter_col" '$1 == col {print NR}' "$table_name.metadata")

        echo "Records where $filter_col = $filter_val :"
        awk -F: -v col_idx="$col_num" -v val="$filter_val" '
            BEGIN { OFS=":"; found=0 }
            {
                if ($col_idx == val) {
                    print "Record " NR ":"
                    for(i=1; i<=NF; i++) {
                        print "  Field " i ": " $i
                    }
                    found=1
                }
            }
            END {
                if (found == 0) print "No matching records found."
            }
        ' "$table_name"

    else
        # Show all records 
        echo "All Records:"
        awk -F: '
            {
                print "Record " NR ":"
                for(i=1; i<=NF; i++) {
                    print "  Field " i ": " $i
                }
            }
        ' "$table_name"
    fi

    echo "✅ Select completed successfully!"
    echo "Total records: $(wc -l < "$table_name")"
}
# DELETE RECORD 

delete_record() {
    echo " DELETE RECORD"
    read -p "Enter Table Name: " table_name

    if [[ "$table_name" == "" ]]; then
        echo "Error: Table name cannot be empty!"
        return
    fi
    if [[ ! -f "$table_name" ]] || [[ ! -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' or its metadata does not exist!"
        return
    fi

    # Read metadata to find the Primary Key column and its position
    pk_col_name=""
    pk_col_num=0
    col_num=0

      pk_col_num=$(awk -F: '$3=="yes" {print NR}' "$table_name.metadata")
      pk_col_name=$(awk -F: '$3=="yes" {print $1}' "$table_name.metadata")

    if [[ "$pk_col_name" ==  "" ]]; then
        echo "Error: No Primary Key defined for this table!"
        return
    fi
  
    echo "Current Records in '$table_name':"
    if [[ ! -s "$table_name" ]]; then
        echo "Table is empty. Nothing to delete."
        return
    fi

    # Show records with column names 
  echo "Records (PK column: $pk_col_name):"
awk -F: '{ print NR ". " $0 }' "$table_name"

    echo "----------------------------------------"
    read -p "Enter $pk_col_name value to delete: " pk_value

    if [[ "$pk_value" == "" ]]; then
        echo "Error: Value cannot be empty!"
        return
    fi

    # Check if record exists
    if ! awk -F: -v pkidx="$pk_col_num" -v val="$pk_value" '$pkidx == val' "$table_name" | grep -q .; then
        echo "Error: Record with $pk_col_name = '$pk_value' not found!"
        return
    fi


    read -p "Are you sure you want to delete this record? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Delete cancelled."
        return
    fi


    # Delete the record using the correct PK column position
    awk -F: -v pkidx="$pk_col_num" -v val="$pk_value" '
        {
            if ($pkidx != val) {
                print $0
            }
        }
    ' "$table_name" > temp_file && mv temp_file "$table_name"

    

    echo "✅ Record with $pk_col_name = '$pk_value' has been deleted successfully."

    echo "----------------------------------------"
    echo "Remaining Records:"
    if [[ -s "$table_name" ]]; then
        awk -F: '{ print NR ". " $0 }' "$table_name"
    else
        echo "Table is now empty."
=======
    echo " Table '$table_name' created successfully!"
    echo "   Files created: $table_name   and   $table_name.metadata"
}

table_menu


# 2- LIST TABLES
list_tables() {
    if [[ -z "$current_db" ]]; then
        echo "No database selected. Please connect to a database first."
        return
    fi

    # Check if there are any .metadata files in the current folder
    if [[ -z "$(ls *.metadata 2>/dev/null)" ]]; then
        echo "Empty database, No tables found. Please create a table first."
    else
        echo "Available tables in database '$current_db':"
        ls | grep "\.metadata$" | sed 's/\.metadata//' | sed 's/^/ - /'
    fi
}

#3- DROP TABLE
drop_table() {
    read -p "Enter the name of the table to drop: " table_name
    
    if [[ -z "$table_name" ]]; then 
        echo "Table name cannot be empty. Please enter a valid name."
    elif [[ ! -f "$table_name" ]]; then
        echo "Table '$table_name' doesn't exist!"
    else
        read -p "Are you sure you want to drop table '$table_name'? (y/n): " confirm
        if [[ $confirm == [yY] ]]; then
            rm -f "$table_name" "$table_name.metadata"
            echo "Table '$table_name' dropped successfully."
        else
            echo "Operation cancelled."
        fi

    fi
}