source ./menu.sh

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