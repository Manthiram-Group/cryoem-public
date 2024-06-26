# Working Principle of the CryoSPARC Notifications System

This CryoSPARC notifications script uses the tag system in CryoSPARC to identify which jobs have notifications enabled. By running the cryosparc_enable_notifications.sh script, all specified jobs will be tagged with a user-specific "notifs-on" tag created by the script. The script will then periodically check the job status and send a Slack notification if the job status has changed. Notifications will be sent:

- When a job begins running (not when it is "launched" or "queued").
- When a job is waiting for your input
- When a job is completed (which deactivates notifications).
- When a job fails (which deactivates notifications).
- When a job is killed (which deactivates notifications).
- When a job is deleted (which deactivates notifications).
- When the "notifs-on" tag is manually removed in the CryoSPARC web interface (which deactivates notifications).

The script defaults to check every five minutes whether a job's status has changed, but this time interval can be adjusted. Notifications can be enabled for single CryoSPARC jobs or entire CryoSPARC workspaces with one run of the "cryosparc_enable_notifications.sh" script. Note that you cannot enable notifications by manually tagging a job in the CryoSPARC web interface.

If you run into errors or have questions, please email me at nsnyder@caltech.edu or snydern2000@gmail.com.
  
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

6. Press "i" on your keyboard to enter INSERT mode. Use the arrow keys to navigate to line 27 where it says INSERT_USERNAME_HERE.
7. Replace the "INSERT_USERNAME_HERE" text with a username of your choice. I recommend using either your cemaster username or your first name. Just make sure it is unique for each person using CryoSPARC notifications in your Slack workspace.
8. In line 28 where the script says

   ```webhook=""```

   paste your webhook from your Slack app between the quotations using Ctrl+Shift+V. (Note: __do not__ paste your webhook where the script says ```local webhook=""``` in line 25).

9. Every subsequent user that wishes to add their username and Slack webhook can do so by following the syntax in lines 27-29 to add to the "case" statement.
10. Exit INSERT mode and re-enter COMMAND mode by pressing "Esc" on your keyboard. Type ":wq" and hit return to save your changes (wq stands for "write quit").

11. Open the "cryosparc_enable_notifications.sh" script in the VIM text editor using the following command in the terminal:

    ```vim cryosparc_enable_notifications.sh```

11. Edit the "cryosparc_enable_notifications.sh" script under where it says ### USER INPUTS ### to match your needs. Once again, press "i" on your keyboard to enter INSERT mode. Use the arrow keys to navigate around and make changes as necessary. Once you are done editing, press Esc on your keyboard to re-enter COMMAND mode. Type ":wq" and hit return to save your changes.

12. Run the following command in your terminal to enable notifications for your chosen workspace or job:

    ```bash cryosparc_enable_notifications.sh```

# Turning Off Notifications

In most cases, notifications will be turned off through natural usage of the script. However, if you want to force quit all notification processes you have running, ssh into the cemaster cluster and run the following command:

```pgrep -f cryosparc_enable_notifications.sh -u username```

where "username" is replaced with your cemaster username. This command will output a list of process IDs corresponding to the notification scripts you have running. Run the command 

```kill PID```

where "PID" is replaced with any of the process IDs output by the previous command. You can kill multiple processes like so:

```kill PID1 PID2 PID3```
