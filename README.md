# Setting Up a Slack App to Be Able to Receive CryoSPARC Notifications

1. If you are the first person in your Slack workspace who will be receiving CryoSPARC notifications, you will have to create a Slack app. Visit the following link and click "Create New App": https://api.slack.com/apps.
2. Select "From scratch."
3. Give your app a name (e.g., CryoSPARC Notifications) and pick the workspace you wish to receive notifications in from the dropdown.
4. In the "Add features and functionality" toggle menu, select "Incoming Webhooks."
5. Toggle "Activate Incoming Webhooks" to On.
6. Select "Add New Webhook to Workspace" at the bottom of the page.
7. In the dropdown menu, choose the channel you'd like the CryoSPARC notifications to be sent to and click "Allow." (I would recommend choosing your DMs so as not to spam other users of the Slack workspace). __Note that each user who wishes to receive notifications should be a collaborator on the Slack app and make their own webhook. Otherwise, whoever made the webhook will receive notifications in addition to the target DM channel. Collaborators can be added to the Slack app in the "Collaborators" menu under "Settings" in the left sidebar.__
8. In the left column under "Settings," select "Basic Information" to go back.
9. Expand the "Install your app" toggle heading, and click "Install to Workspace" to finish up the app installation process.

# Creating a New Webhook in an Existing Slack App

1. Visit the following link to view the Slack apps you are a collaborator on: https://api.slack.com/apps. If you have not been added as a collaborator, ask the app creator to add you (reference step 7 in the above section of this README).
2. Select your notifications app under the "App Name" column.
3. Expand the "Add features and functionality" toggle heading, and select the "Incoming Webhooks" button.
4. Select "Add New Webhook to Workspace" at the bottom of the page.
5. In the dropdown menu, choose the channel you'd like the CryoSPARC notifications to be sent to and click "Allow." (I would recommend choosing your DMs so as not to spam other users of the Slack workspace).
6. You can now copy your webhook to your clipboard using the "Copy" button next to your webhook in the "Webhook URL" column.

# Enabling Slack Notifications for CryoSPARC

__If you have not already set up a Slack app and made a webhook, complete the steps in one or both of the above sections before coming here.__

1. Download the "cryoem-public" repository as a zip file by clicking the green box that says "<> Code" and selecting "Download Zip" from the dropdown.
2. Copy the cryoem-public repo into your cemaster directory using secure copy (scp) in your shell as follows:
   
   ```
   scp -r /path/to/cryoem-public/repo username@cemaster:/path/to/destination/on/cemaster
   ```
   
   This command will prompt you for a password, which is your cemaster password you should have previously set with smbldap-passwd (also the same as the password you use to ssh into the cemaster cluster).

   An example of the above command:
   
   ```
   scp -r Desktop/cryoem-public nsnyder@cemaster:cryosparc
   ```
   
   If you are on the Caltech campus wifi and not the VPN, you may need to replace "cemaster" with "cemaster.caltech.edu" in the above commands.
   
3. SSH into the cemaster cluster by executing the following command in your terminal (login with your password when prompted):

   ```
   ssh -Y -l username cemaster # If on Caltech VPN
   ssh -Y -l username cemaster.caltech.edu # If on Caltech campus Wifi
   ```

   Replace "username" with your cemaster username in the above command.

4. Navigate to the directory on the cemaster cluster containing the scripts "cryosparc_enable_notifications.sh" and "cryosparc_notifications_library.sh" (these must be in the same directory) using the command line interface in your terminal. Use cd. For example, if you copied the cryoem-public folder into your cryosparc folder on cemaster, the command will be as follows:

   ```cd cryosparc/cryoem-public```

   You can also use the ```ls``` command to view all files and directories in your working directory. The working directory will be output with the command ```pwd``` (for print working directory).

5. Open the "cryosparc_notifications_library.sh" script in the VIM text editor using the following command in the terminal:

   ```vim cryosparc_notifications_library.sh```

6. 

7. Open the "cryosparc_enable_notifications.sh" script in the VIM text editor using the following command in the terminal:

   ```vim cryosparc_enable_notifications.sh```

8. Edit the "cryosparc_enable_notifications.sh" script under where it says ### USER INPUTS ### to match your needs. To do so, press "i" on your keyboard to enter INSERT mode. Use the arrow keys to navigate around and make changes as necessary. Once you are done editing, press Esc on your keyboard to re-enter COMMAND mode. Type ":wq" and hit return to save your changes (wq stands for "write quit").

9. Run the following command in your terminal:

   ```bash cryosparc_enable_notifications.sh```

# Working Principle of the CryoSPARC Notifications System
