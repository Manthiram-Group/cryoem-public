#!/bin/bash

# Running this script will use the functions in "cryosparc_notifications_library.sh" to enable notifications for the specified job or workspace in CryoSPARC.

# Ensure that this file and "cryosparc_notifications_library.sh" are in the same directory 
source "$PWD/cryosparc_notifications_library.sh"

### USER INPUTS ###
project_uid="" # Necessary
workspace_uid="" # If this is not specified, a job_uid must be specified. If workspace_uid and job_uid are specified, this script will default to enabling notifications for the workspace, rather than the job.
job_uid="" # If this is not specified, a workspace_uid must be specified.
uid="" # Necessary. Your user ID that can be found in the CryoSPARC web interface by clicking the three dots in the left toolbar then clicking your name at the bottom of the list. Example: 6603e22f4943a7fdd263e2f6
username="" # Necessary. Your first name all lowercase. This will tell the functions which person to send the Slack notifications to.
time_between_loops_mag="" # Optional. The magnitude of time between each loop of the while loop that checks whether a new notification should be sent. Defaults to 5.
time_between_loops_unit="" # Optional. The unit of time between each loop of the while loop that checks whether a new notification should be sent. Can be either 's', 'm', or 'h'. Defaults to 'm'.
create_tag=true # The first time you run this script, leave this value as true to create the 'notif-on' tag in CryoSPARC. Afterwards, you can set this to false.

### ENABLING NOTIFICATIONS: DO NOT EDIT BELOW THIS LINE ###

if $create_tag; then
    create_notification_tag "$uid"
fi

if [ -n "$workspace_uid" ]; then # If workspace_uid has a value, enable notifications for the workspace.
    workspace_notifications "$project_uid" "$workspace_uid" "$uid" "$username" "$time_between_loops_mag" "$time_between_loops_unit"
elif [ -n "$job_uid" ]; then # Else, if job_uid has a value, enable notifications for the job.
    job_notifications "$project_uid" "$job_uid" "$uid" "$username" "$time_between_loops_mag" "$time_between_loops_unit"
else
    echo "You must specify either a workspace UID or a job UID. Notifications could not be enabled."
    exit 1
fi
