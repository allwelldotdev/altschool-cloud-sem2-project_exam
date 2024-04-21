#!/bin/bash
set -e  # Exit bash script upon error

# Define a function to run when an error occurs
error_handling() {
    echo "The script failed because there was a fault"
    echo "Error on line $1"
}

# Trap any ERR signal and call error_handling function with the line number
trap 'error_handling $LINENO' ERR

# Example commands that might fail
rm mydata.txt       # If the file doesn't exist, it will trigger the error trap
cp mydata.txt backup/  # This will not be executed if any prior command fails

echo "Script executed successfully."

