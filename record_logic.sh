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

    if [[ "$table_name" == "" ]]; then
        echo "Please enter a name!"
        return
    fi

    if [[ "$table_name" =~ [^a-zA-Z0-9_] ]]; then
        echo "Table name should only contain letters, numbers, and underscores"
        return
    fi
    if [[ ! -f "$table_name" || ! -f "$table_name.metadata" ]]; then
        echo "Error: Table '$table_name' does not exist!"
        return
    fi

    IFS=':' read -r -a metadata < "$table_name.metadata"
    num_cols=${metadata[0]}
    col_names=("${metadata[@]:1:$num_cols}")
    col_types=("${metadata[@]:1+$num_cols:$num_cols}")

    echo "Now enter values for each column:"

    record=""

    for ((i=0; i<num_cols; i++)); do
        col_name="${col_names[i]}"
        col_type="${col_types[i]}"

        read -p "   $col_name ($col_type): " value

        if [[ "$value" == "" ]]; then
            echo "Error: Value for column '$col_name' cannot be empty!"
            return
        fi

        case $col_type in
            int)
                if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                    echo "Error: Value for column '$col_name' must be an integer!"
                    return
                fi
                ;;
            string)
                ;;
            *)
                echo "Error: Unknown column type '$col_type' for column '$col_name'!"
                return
                ;;
        esac

        record+="$value:"
    done

    record="${record%:}"
    echo "$record" >> "$table_name"
    echo "Record inserted successfully into table '$table_name'"
}

# 2- Select From Table

#3- Delete From Table