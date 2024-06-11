#!/bin/bash

# Purpose: Enable Slack notifications for a specified job
job_notifications () {
    # User Inputs:
    # 1: Project UID
    # 2: Job UID
    # 3: UID
    # 4: Username for Slack webhook (first name all lowercase)
    # 5: Time magnitude between tries (optional)
    # 6: Time unit between tries (optional; accepts s, m, or h)

    local turn_notifs_on=false; # Flag to tell the script to enable notifications. This will be switched to true if notifications aren't already on.

    # Check if the project UID is valid
    if [ $(cryosparcm cli "check_project_exists('"$1"')") == False ]; then
 	    echo "Error: Project with UID '"$1"' does not exist."
 	    return 1
    fi

    # Get job type
    local job_type=$(cryosparcm cli "get_job('"$1"','"$2"')['type']")

    # Choose Slack Webhook
    local webhook=""
    case "$4" in
        INSERT_USERNAME_HERE )
            webhook=""
            ;;
        * )
            echo "Invalid username. Slack webhook not found. Notifications for job '"$2"' could not be activated."
            return 1
            ;;
    esac

    # Determine 'notif-on' tag UID
    local counter=0
    local t_uid=""
    local tag_exists=false
    while cryosparcm cli "get_user_tags('"$3"')[$counter]" >/dev/null 2>&1; do # While loop will iterate through all tags created by the user and see if one of them is the 'notif-on' tag. It will error out and exit the while loop if the index of the list holding all user tags is out of bounds. 
        if [ $(cryosparcm cli "get_user_tags('"$3"')[$counter]['title']") == notif-on-"$uid" ]; then
            t_uid=$(cryosparcm cli "get_user_tags('"$3"')[$counter]['uid']")
            tag_exists=true
            break
        fi
        let counter++
    done

    # If 'notif-on' tag has been created, continue. Else, exit with error.
    if $tag_exists; then
        :
    else
        echo "Job '"$2"' 'notif-on' tag not found. Notifications could not be activated."
        return 1
    fi

    # If a tag has never been added or if the 'notif-on' tag is not applied, add the notif-on tag
    local current_tags=$(cryosparcm cli "get_job('"$1"','"$2"')['tags']" 2>/dev/null) # If tags have never been applied, this will error out, and the error will be sent to /dev/null. Otherwise, the variable will contain the tag UIDs of the tags applied to the job.
    if [ $? -ne 0 ]; then # If current_tags errored out, then add the 'notif-on' tag and turn notifications on. '$?'' holds the output of the last command.
        cryosparcm cli "add_tag_to_job('"$1"','"$2"','"$t_uid"')" > /dev/null 2>&1
        turn_notifs_on=true
    else # Else, cycle through all tags. If the 'notif-on' tag is not already applied, add the 'notif-on' tag and turn notifications on.
        # String processing to turn string into array of tag UIDs
        local current_tags_string=$(echo "$current_tags" | tr -d "[],'")
        local -a current_tags_array
        IFS=' ' read -r -a current_tags_array <<< "$current_tags_string"

        # Cycling through all tags applied to the current job to determine if the 'notif-on' tag has already been applied.
        local tag_uid_found=false
        local i
        for i in ${current_tags_array[@]}; do
            if [ "$i" == "$t_uid" ]; then
                tag_uid_found=true
            fi
        done

        # If the 'notif-on' tag is already applied, return without error because notifications are already enabled. Else, add the 'notif-on' tag and enable notifications.
        if $tag_uid_found; then
            echo "Job '"$2"' notifications already enabled."
            return 0
        else
            cryosparcm cli "add_tag_to_job('"$1"','"$2"','"$t_uid"')" > /dev/null 2>&1
            echo "Notifications enabled for job '"$2"' '"$job_type"'."
            turn_notifs_on=true
        fi
    fi

    # Set default values for sleep time between while loop iterations
    local sleep_mag="${5:-5}"
    local sleep_unit="${6:-m}"

    # Calculate sleep time between while loop iterations based on user input (or default value)
    case "$sleep_unit" in
        s|S )
            local sleep_duration="$sleep_mag"
            ;;
        m|M )
            local sleep_duration=$(( sleep_mag * 60 ))
            ;;
        h|H )
            local sleep_duration=$(( sleep_mag * 3600 ))
            ;;
        * )
            echo "Invalid sleep time unit '"$6"'. Use 's' for seconds, 'm' for minutes, or 'h' for hours."
            return 1
            ;;
    esac

    # Set running_count variable so that only one notification will be sent when job begins running in CryoSPARC
    local running_count=0

    # Set waiting_count variable so that only one notification will be sent when job begins waiting in CryoSPARC
    local waiting_count=0

    # Check job status and send Slack notification if necessary
    while $turn_notifs_on; do
        local job_status=$(cryosparcm cli "get_job_status('"$1"','"$2"')")

        # Check if job has been deleted
        if [ $(cryosparcm cli "get_job('"$1"','"$2"')['deleted']") == True ]; then
            curl -X POST -H 'Content-type: application/json' --data '{"text":"Job '"$2"' '"$job_type"' has been deleted. Notifications deactivated."}' $webhook > /dev/null 2>&1
            cryosparcm cli "remove_tag_from_job('"$1"','"$2"','"$t_uid"')" > /dev/null 2>&1
            return 0
        fi

        # Check if 'notif-on' tag is still applied
        local notifs_still_on=false
        local k=0
        while cryosparcm cli "get_job('"$1"','"$2"')['tags'][$k]" >/dev/null 2>&1; do
            if [ $(cryosparcm cli "get_job('"$1"','"$2"')['tags'][$k]") == $t_uid ]; then
                notifs_still_on=true
                break
            fi
            let k++
        done

        # If 'notif-on' tag is not applied anymore, turn off notifications
        if [ ! $notifs_still_on ]; then
            curl -X POST -H 'Content-type: application/json' --data '{"text":"Notfications manually disabled for job '"$2"' '"$job_type"'."}' $webhook > /dev/null 2>&1
            return 0
        fi

        case "$job_status" in
            "building" )
                continue
                ;;
            "completed" )
                curl -X POST -H 'Content-type: application/json' --data '{"text":"Job '"$2"' '"$job_type"' completed. Notifications deactivated."}' $webhook > /dev/null 2>&1
                cryosparcm cli "remove_tag_from_job('"$1"','"$2"','"$t_uid"')" > /dev/null 2>&1
                return 0
                ;;
            "failed" )
                curl -X POST -H 'Content-type: application/json' --data '{"text":"Job '"$2"' '"$job_type"' failed. Notifications deactivated."}' $webhook > /dev/null 2>&1
                cryosparcm cli "remove_tag_from_job('"$1"','"$2"','"$t_uid"')" > /dev/null 2>&1
                return 0
                ;;
            "killed" )
                curl -X POST -H 'Content-type: application/json' --data '{"text":"Job '"$2"' '"$job_type"' killed. Notifications deactivated."}' $webhook > /dev/null 2>&1
                cryosparcm cli "remove_tag_from_job('"$1"','"$2"','"$t_uid"')" > /dev/null 2>&1
                return 0
                ;;
            "launched" )
                continue
                ;;
            "queued" )
                continue
                ;;
            "running" )
                let running_count++
                if [ $running_count == 1 ]; then
                    curl -X POST -H 'Content-type: application/json' --data '{"text":"Job '"$2"' '"$job_type"' launched and running."}' $webhook > /dev/null 2>&1
                    local start_time=$(date +%s) # Set a start time so that while loop will timeout if run for too long
                fi
                ;;
            "started" )
                continue
                ;;
            "waiting" )
                let waiting_count++
                if [ $waiting_count == 1 ]; then
                    curl -X POST -H 'Content-type: application/json' --data '{"text":"Job '"$2"' '"$job_type"' waiting."}' $webhook > /dev/null 2>&1
                    local start_time=$(date +%s) # Set a start time so that while loop will timeout if run for too long
                fi
                ;;
            * )
                curl -X POST -H 'Content-type: application/json' --data '{"text":"Job '"$2"' '"$job_type"': Unknown Job Status ['"$job_status"'] Detected. Notifications deactivated."}' $webhook > /dev/null 2>&1
                cryosparcm cli "remove_tag_from_job('"$1"','"$2"','"$t_uid"')" > /dev/null 2>&1
                return 0
                ;;
        esac

        local end_time=$(date +%s)
        local time_elapsed=$(( ($end_time - $start_time) / 3600)) # Amount of time elapsed in hours since the job began running
        if [ $time_elapsed -ge 37 ]; then
            echo "Job '"$2"' notification timeout. Notifications deactivated."
            return 1
        fi
        
        # Sleep the while loop for the indicated amount of time
        sleep "$sleep_duration"

    done & # The ampersand causes the while loop to run in the background

    return 0
}

workspace_notifications () {
    # User Inputs:
    # 1: Project UID
    # 2: Workspace UID
    # 3: UID
    # 4: Username for Slack webhook (first name all lowercase)
    # 5: Time magnitude between tries (optional)
    # 6: Time unit between tries (optional; accepts s, m, or h)

    # Check if the project UID is valid
    if [ $(cryosparcm cli "check_project_exists('"$1"')") == False ]; then
 	    echo "Error: Project with UID '"$1"' does not exist."
 	    return 1
    fi

    # Check if the workspace UID is valid
    if [ $(cryosparcm cli "check_workspace_exists('"$1"','"$2"')") == False ]; then
        echo "Error: Workspace with UID '"$2"' does not exist."
        return 1
    fi

    # Set default values for sleep time between while loop iterations
    local sleep_mag="${5:-5}"
    local sleep_unit="${6:-m}"

    # String processing to get an array containing the names of all jobs in the specified workspace
    local job_names_dict_keys=$(cryosparcm cli "get_workspace('"$1"','"$2"')['workspace_stats']['job_types'].keys()")
    local job_names_string_front_removed="${job_names_dict_keys:10}"
    local job_names_string=$(echo "${job_names_string_front_removed:0:${#job_names_string_front_removed}-1}" | tr -d "[],'")
    local -a job_names_array
    IFS=' ' read -r -a job_names_array <<< "$job_names_string" 

    # Go through all jobs in workspace and turn notifications on if not already on
    local i
    local j
    for i in "${job_names_array[@]}"; do
        local num_jobs=$(cryosparcm cli "get_workspace('"$1"','"$2"')['workspace_stats']['job_types']['"$i"']")
        local num_jobs_final_index=$(( $num_jobs - 1 ))
        for j in $(seq 0 $num_jobs_final_index); do
            local j_uid=$(cryosparcm cli "get_jobs_by_type('"$1"','"$2"',['"$i"'])["$j"]['uid']")
            job_notifications "$1" "$j_uid" "$3" "$4" "$5" "$6"
        done
    done

    return 0
}

create_notification_tag () {
    # User Inputs
    # 1: UID

    # Create the 'notif-on' tag for the specified user if not already created.
    local t_uid=$(cryosparcm cli "create_tag('notif-on-"$uid"','"job"','"$1"')['uid']" 2>/dev/null)
    if [ -z "$t_uid" ]; then
        echo "Tag 'notif-on-"$uid"' already exists."
    else
        echo "Tag 'notif-on-"$uid"' with tag UID "$t_uid" created."
    fi

    return 0
}
