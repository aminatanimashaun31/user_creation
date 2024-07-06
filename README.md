# DevOps Task: User Creation Bash Script

## Introduction
This repository contains a bash script (`create_users.sh`) designed to automate the creation of user accounts and group management on a Linux system. This script is particularly useful for SysOps engineers tasked with onboarding multiple new users efficiently and securely.

## Features
- Reads a text file containing usernames and associated groups.
- Creates user accounts and their personal groups.
- Assigns users to additional specified groups.
- Sets appropriate home directory permissions.
- Generates random passwords for users.
- Logs all actions to `/var/log/user_management.log`.
- Stores generated passwords securely in `/var/secure/user_passwords.csv`.

## Prerequisites
- The script must be run with root privileges.
- Ensure `openssl` is installed for password generation.

## Usage
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>

    Prepare the input file containing usernames and groups. Each line should be formatted as user;groups:

light;sudo,dev,www-data
idimma;sudo
mayowa;dev,www-data

Run the script with the input file as an argument:

bash

    sudo bash create_users.sh <name-of-text-file>

Script Breakdown

    Initialization and Checks:
        Ensures the script is run as root.
        Verifies the input file is provided.

    Setting Up Log and Password Files:
        Creates the log file /var/log/user_management.log to record actions.
        Creates the password file /var/secure/user_passwords.csv with restricted permissions for secure storage.

    Generating Random Passwords:
        Uses openssl to generate secure random passwords.

    Processing the Input File:
        Reads the input file line by line, splitting each line into a username and a list of groups.
        For each user:
            Checks if the user already exists.
            Creates the user and personal group if they do not exist.
            Adds the user to any additional groups.
            Sets home directory permissions.
            Generates and sets a random password for the user.
            Logs all actions and stores passwords securely.

Example Input File

light;sudo,dev,www-data
idimma;sudo
mayowa;dev,www-data

Logging and Security

    All actions are logged to /var/log/user_management.log.
    Generated passwords are stored in /var/secure/user_passwords.csv, readable only by the root user.

Technical Article

For a detailed explanation of the script and its implementation, read the accompanying technical article here.
https://medium.com/@aminatanimashaun31/automating-user-creation-and-management-with-bash-eeca89183b2c

    Learn more about the HNG Internship program: HNG Internship
    Opportunities with HNG: HNG Hire

Conclusion

This script automates the process of user and group management, ensuring efficiency, security, and consistency. It is an essential tool for SysOps engineers managing large numbers of user accounts.




