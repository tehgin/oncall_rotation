#!/bin/bash
################################################
# On-Call Rotation - tehgin                    #
# March 2017                                   #
#                                              #
# An automated solution for maintaining a list #
# of those eligible for "on-call" duties and   #
# sending event notifications.                 #
################################################

##########################
# ----- Variables  ----- #
##########################

# Mailer "TO" Address
MAIL_ADDRESS=""

# MySQL Database Credentials (id,date,name,swapped_name)
MYSQL_USERNAME=""
MYSQL_PASSWORD=""
MYSQL_DATABASE=""

# ----- EDIT BELOW AT YOUR OWN RISK!! -----

# Gather Data
NEXT_DATE=`date -d "next monday" +"%Y-%m-%d"`
NEXT_NAME=$(mysql $MYSQL_DATABASE -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -se "SELECT name FROM rotation_list WHERE date='${NEXT_DATE}'";)
NEXT_ID=$(mysql $MYSQL_DATABASE -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -se "SELECT id FROM rotation_list WHERE date='${NEXT_DATE}'";)
AFTER_NEXT_ID=$NEXT_ID+1
AFTER_NEXT_DATE=$(mysql $MYSQL_DATABASE -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -se "SELECT date FROM rotation_list WHERE id=${AFTER_NEXT_ID}";)
AFTER_NEXT_NAME=$(mysql $MYSQL_DATABASE -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -se "SELECT name FROM rotation_list WHERE id=${AFTER_NEXT_ID}";)
WEEKEND_ID=$NEXT_ID-1
WEEKEND_NAME=$(mysql $MYSQL_DATABASE -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -se "SELECT name FROM rotation_list WHERE id=${WEEKEND_ID}";)

#########################
# ----- Functions ----- #
#########################

### Function: display_help
# Output script usage information.
function display_help {
                echo "On-Call Rotation Script"
                echo "Usage: $0 [Option]"
                echo ""
                echo "   -d, --dry           Execute dry run to validate mail output."
                echo "   -h, --help          Display this output."
                echo "   -m, --mail          Send mail output to MAIL_ADDRESS."
                echo ""
}


### Function: dry
# Perform a dry run for testing purposes.
function dry {
                echo "Executing dry run..."
                OUTPUT=$(gen_output)
                echo $OUTPUT
}


### Function: mail
# Perform a live run with the intention of sending mail.
function send_mail {
                OUTPUT=$(gen_output)
                echo $OUTPUT | mutt -s "On-Call Rotation" -e 'set content_type="text/html"' $MAIL_ADDRESS
}


### Function: gen_output
# Generate HTML output for notification email.
function gen_output {
                echo '<div style="font-family: Courier New;">Weekend - <i>Current</i><br /><b>'$WEEKEND_NAME'</b><br /><br />Next Monday - <i>'$NEXT_DATE'</i><br /><b>'$NEXT_NAME'</b><br /><br />Monday After Next - <i>'$AFTER_NEXT_DATE'</i><br /><b>'$AFTER_NEXT_NAME'</b>'
}


#########################
# ----- Arguments ----- #
#########################

case $2 in
                "") # Avoid multiple arguments.
                ;;
                *)
                display_help
                exit 1
                ;;
esac

case "$1" in
                "-h" | "--help")
                display_help
                exit 0
                ;;
                "-d" | "--dry")
                dry
                exit 0
                ;;
                "-m" | "--mail")
                send_mail
                exit 0
                ;;
                *)
                display_help
                exit 1
                ;;
esac
