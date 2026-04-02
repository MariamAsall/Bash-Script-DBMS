<<<<<<< HEAD
#!/bin/bash

source ./config.sh
source ./db_logic.sh
source ./table_logic.sh
source ./record_logic.sh

=======
source ./config.sh
source ./db_logic.sh
source ./table_logic.sh   
source ./record_logic.sh

#1- MAIN MENU ITEMS
>>>>>>> 1a5efe38cfd3937d0afb550460e1c78264962b87
main_menu(){
    echo "Welcome to the Database Management System"
    PS3="Please choose an option: "
    select option in "Create a new database" "Connect to an existing database" "List available databases" "Drop a database" "Exit"; 
    do
        case $REPLY in
            1) create_db ;;
            2) connect_db ;;
            3) list_databases ;;
            4) drop_db ;;
            5) echo "Exiting the program. Goodbye!"; exit ;;
            *) echo "Invalid option, Please choose a valid option" ;;
        esac
    done
}
<<<<<<< HEAD

table_menu() {
    while true; do

        echo "TABLE OPERATIONS MENU"
        echo "     1) Create Table"
        echo "     2) List Tables"
        echo "     3) Drop Table"
        echo "     4) Insert into Table"
        echo "     5) Select From Table"
        echo "     6) Delete From Table"
        echo "     7) Update Table"
        echo "     8) Back to Main Menu"

        read -p "Please choose only NUMBERS from (1-8): " choice

        case $choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_table ;;
            5) select_record ;;
            6) delete_record ;;
            7) update_table ;;
            8) echo "→ Going back to Main Menu..."; return ;;
            "") echo "EMPTY, Please enter a number between 1 and 8." ;;
            *) echo "Something is wrong! Please enter a number between 1 and 8." ;;
        esac
    done
}

main_menu
=======
main_menu


>>>>>>> 1a5efe38cfd3937d0afb550460e1c78264962b87
