#!/bin/bash

# Log file
LOGFILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Ensure log file exists
touch $LOGFILE
chmod 644 $LOGFILE

# Ensure password file exists
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

# Check if the input file is provided
if [ $# -eq 0 ]; then
    log_message "No input file provided."
    echo "Usage: $0 <input-file>"
    exit 1
fi

INPUT_FILE=$1

# Check if the input file exists
if [ ! -f $INPUT_FILE ]; then
    log_message "Input file $INPUT_FILE does not exist."
    echo "Input file does not exist."
    exit 1
fi

# Read the input file
while IFS=';' read -r username groups; do
    username=$(echo $username | xargs) # Remove leading/trailing whitespace
    groups=$(echo $groups | xargs) # Remove leading/trailing whitespace

    if id "$username" &>/dev/null; then
        log_message "User $username already exists."
        echo "User $username already exists."
        continue
    fi

    # Create the user with a home directory
    useradd -m -s /bin/bash $username
    if [ $? -eq 0 ]; then
        log_message "User $username created successfully."
    else
        log_message "Failed to create user $username."
        continue
    fi

    # Create a personal group for the user
    groupadd $username
    usermod -aG $username $username
    log_message "Group $username created and user $username added to it."

    # Add user to specified groups
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo $group | xargs) # Remove leading/trailing whitespace
        if [ $(getent group $group) ]; then
            usermod -aG $group $username
            log_message "User $username added to group $group."
        else
            groupadd $group
            usermod -aG $group $username
            log_message "Group $group created and user $username added to it."
        fi
    done

    # Generate a random password
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    log_message "Password set for user $username."

    # Store the password in the password file
    echo "$username,$password" >> $PASSWORD_FILE
done < $INPUT_FILE

# Ensure only root can read the password file
chmod 600 $PASSWORD_FILE

log_message "User creation process completed."
echo "User creation process completed. Check the log file for details."

