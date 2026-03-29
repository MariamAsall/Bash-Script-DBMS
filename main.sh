:'
THIS IS THE MAIN SCRIPT FOR THE DATABASE MANAGEMENT SYSTEM
IT CONTAINS THE MAIN MENU ITEMS (THE LOGIC FOR THE USER INTERACTION)
AND CONNECTING USER TO SPECIFIC DATABASE
'

source ./config.sh
source ./db_logic.sh
#1- MAIN MENU ITEMS
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
main_menu

#2- CONNECTING USER TO SPECIFIC DATABASE

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
            1)
               create_table
                ;;
            2)
                echo "→ You chose: List Tables"
                ;;
            3)
                echo "→ You chose: Drop Table"
                ;;
            4)
                echo "→ You chose: Insert into Table"
                ;;
            5)
                echo "→ You chose: Select From Table"
                ;;
            6)
                echo "→ You chose: Delete From Table"
                ;;
            7)
                echo "→ You chose: Update Table"
                ;;
            8)
                echo "→ Going back to Main Menu..."
                return
                ;;
            "")
                echo "EMPTY, Please enter a number between 1 and 8."
                ;;
            *)
                echo "Something is wrong! Please enter a number between 1 and 8."
                ;;
        esac
    done
}