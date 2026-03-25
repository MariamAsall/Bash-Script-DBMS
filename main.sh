:'
THIS IS THE MAIN SCRIPT FOR THE DATABASE MANAGEMENT SYSTEM
IT CONTAINS THE MAIN MENU ITEMS (THE LOGIC FOR THE USER INTERACTION)
AND CONNECTING USER TO SPECIFIC DATABASE
'

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