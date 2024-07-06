#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if the input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

FILENAME=$1
LOGFILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Create log and password files if they don't exist
touch $LOGFILE
mkdir -p /var/secure
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

#The Function to generate a random password
generate_password() {
  tr -dc A-Za-z0-9 </dev/urandom | head -c 16
}

# Function to log actions
log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

while IFS=';' read -r user groups; do
  user=$(echo $user | xargs)  # Trim whitespace
  groups=$(echo $groups | xargs)  # Trim whitespace
  
  if id "$user" &>/dev/null; then
    log_action "User $user already exists. Skipping creation."
  else
    useradd -m -s /bin/bash $user
    log_action "Created user $user"
    
    password=$(generate_password)
    echo "$user:$password" | chpasswd
    echo "$user,$password" >> $PASSWORD_FILE
    log_action "Set password for $user"

    usermod -aG $user $user
    log_action "Added user $user to personal group $user"
  fi
  
  IFS=',' read -ra group_array <<< "$groups"
  for group in "${group_array[@]}"; do
    group=$(echo $group | xargs)  # Trim whitespace
    if [ ! -z "$group" ]; then
      if getent group $group &>/dev/null; then
        log_action "Group $group already exists."
      else
        groupadd $group
        log_action "Created group $group"
      fi
      usermod -aG $group $user
      log_action "Added user $user to group $group"
    fi
  done
done < $FILENAME

echo "User creation process completed. Check $LOGFILE for details."
