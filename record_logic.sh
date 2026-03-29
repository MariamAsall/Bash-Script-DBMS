:'
THIS IS THE LOGIC FOR MANAGING RECORDS IN THE DATABASE
1- Insert into Table
2- Select From Table
3- Delete From Table
'

# 1- Insert into Table
insert_table() {
    echo "INSERT INTO TABLE"
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

    while IFS=':' read -r col_name col_type is_pk; do
        
        while true; do
            read -p "   $col_name ($col_type) [PK: $is_pk]: " value

            if [[ -z "$value" ]]; then
                echo "      Error: Value for column '$col_name' cannot be empty!"
                continue 
            fi

    
            if [[ "$col_type" == "int" ]] && ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                echo "      Error: Value for column '$col_name' must be an integer!"
                continue
            fi
            if [[ "$is_pk" == "yes" ]]; then
                
                if cut -d':' -f"$col_index" "$table_name" | grep -qw "$value"; then
                    echo "      Error: Primary Key '$value' already exists in column '$col_name'!"
                    continue
                fi
            fi

            break 
        done

        record+="$value:"
        ((col_index++))

    done < "$table_name.metadata"

    record="${record%:}"
    
    echo "$record" >> "$table_name"
    echo "Record inserted successfully into table '$table_name'"
}
    
# 2- Select From Table

#3- Delete From Table