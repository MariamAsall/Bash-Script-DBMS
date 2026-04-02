#!/bin/bash

# 1- Insert into Table
insert_table() {
    echo "--- INSERT INTO TABLE ---"
    read -p "Enter Table Name: " table_name

    if [[ -z "$table_name" ]]; then
        echo "Please enter a name!"
        return
    fi

    if [[ ! -f "$table_name" || ! -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' does not exist!"
        return
    fi

    echo "Now enter values for each column:"
    
    record=""
    col_index=1 

    # We use '3<' to read the file so it doesn't fight with the keyboard 'read'
    while IFS=':' read -u 3 -r col_name col_type is_pk; do
        
        while true; do
            # This read now correctly waits for YOU to type
            read -p "   $col_name ($col_type) [PK: $is_pk]: " value

            # 1. Check if empty
            if [[ -z "$value" ]]; then
                echo "      Error: Value for column '$col_name' cannot be empty!"
                continue 
            fi

            # 2. Check if integer
            if [[ "$col_type" == "int" ]] && ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                echo "      Error: Value for column '$col_name' must be an integer!"
                continue
            fi

            # 3. Check for Duplicate Primary Key
            if [[ "$is_pk" == "yes" ]]; then
                if [[ -f "$table_name" ]]; then
                    # Check if the value already exists in that specific column
                    if cut -d':' -f"$col_index" "$table_name" | grep -qw "^$value$"; then
                        echo "      Error: Primary Key '$value' already exists!"
                        continue
                    fi
                fi
            fi

            break 
        done

        # Build the record string (e.g., 1:Mawada)
        if [[ -z "$record" ]]; then
            record="$value"
        else
            record="$record:$value"
        fi
        
        ((col_index++))

    done 3< "$table_name.metadata"

    # Save to file
    echo "$record" >> "$table_name"
    echo "✅ Record inserted successfully into table '$table_name'"
}
    
# 2- Select From Table
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

# 3- Delete From Table
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
}