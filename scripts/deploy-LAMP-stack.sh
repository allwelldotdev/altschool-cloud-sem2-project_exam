#!/bin/bash

# Exit bash script upon any erors
set -e

# Define a function to run when an error occurs
error_handling() {
    echo "The script failed due to a fault"
    echo "Error on line $1 of bash script"
}

# Trap any ERR signal and call error_handling function with the line number
trap 'error_handling $LINENO' ERR


# -------------------------------------------


# Get user input for variables

# User input for DBNAME - Database Name
read -s -p "Enter the name of the Laravel Database (e.g. lavarel_db) NB. It doesn't have to be the same as the example \"e.g.\" : " DBNAME

# User input for DBNAME - Database Username
echo -e "\n###################################################"
read -s -p "Enter the username of the Laravel Database (e.g. lavarel_user) NB. It doesn't have to be the same as the example \"e.g.\" : " DBUSER

# User input for DBNAME - Database Password
echo -e "\n###################################################"
read -s -p "Enter the password of the Laravel Database (e.g. lavarel_pass) NB. It doesn't have to be the same as the example \"e.g.\" : " DBPASS
echo -e "\n###################################################"



echo $DBNAME
echo $DBUSER
echo $DBPASS


echo "Script executed successfully."
