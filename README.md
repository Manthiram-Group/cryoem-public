# Setting Up a Slack App to Be Able to Receive CryoSPARC Notifications

# Enabling Notifications for CryoSPARC

__If you have not already set up a Slack app, made a webhook, and put that webhook in the cryosparc_notifications_library_generic file, complete the steps in the "Setting Up a Slack App to Be Able to Receive CryoSPARC Notifications" section before coming here.__

1. Download the "cryoem" repository as a zip file by clicking the green box that says "<> Code" and selecting "Download Zip" from the dropdown.
2. Copy the cryoem repo into your cemaster directory using secure copy (scp) in your shell as follows:
   
   ```
   scp -r /path/to/cryoem/repo username@cemaster:/path/to/destination/on/cemaster
   ```
   
   This command will prompt you for a password, which is your cemaster password you should have previously set with smbldap-passwd (also the same as the password you use to ssh into the cemaster cluster).

   An example of the above command:
   
   ```
   scp -r Desktop/cryoem nsnyder@cemaster:cryosparc
   ```
   
   If you are on the Caltech campus wifi and not the VPN, you may need to replace "cemaster" with "cemaster.caltech.edu" in the above commands.
   
3. SSH into the cemaster cluster by executing the following command in your terminal (login with your password when prompted):

   ```
   ssh -Y -l username cemaster # If on Caltech VPN
   ssh -Y -l username cemaster.caltech.edu # If on Caltech campus Wifi
   ```

4. Navigate to the directory on the cemaster cluster containing the scripts "cryosparc_enable_notifications.sh" and "cryosparc_notifications_library.sh" (these must be in the same directory) using the command line interface in your terminal. Use cd. For example, if you copied the cryoem folder into your cryosparc folder on cemaster, the command will be as follows:

   ```cd cryosparc/cryoem```

   You can also use the ```ls``` command to view all files and directories in your working directory. The working directory will be output with the command ```pwd``` (for print working directory).

5. Open the "cryosparc_enable_notifications.sh" script in the VIM text editor using the following command in the terminal:

   ```vim cryosparc_enable_notifications.sh```

6. Edit the "cryosparc_enable_notifications.sh" script under where it says ### USER INPUTS ### to match your needs. To do so, press "i" on your keyboard to enter INSERT mode. Use the arrow keys to navigate around and make changes as necessary. Once you are done editing, press Esc on your keyboard to re-enter COMMAND mode. Type ":wq" and hit return to save your changes (wq stands for "write quit").

7. Run the following command in your terminal:

   ```bash cryosparc_enable_notifications.sh```
