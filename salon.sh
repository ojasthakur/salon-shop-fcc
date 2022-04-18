#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES_MENU(){
	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi
	
	SERVICES=$($PSQL "SELECT *FROM services")
	echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done

	read SERVICE_ID_SELECTED
	#echo $SERVICES_MENU_SELECTION
	#if input is not a number
	if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
	then
		#send to main menu
		SERVICES_MENU "I could not find that service. What would your like today?"
	else
		#check if services exists
		SERVICE_AVAILABILITY=$($PSQL "SELECT *FROM services where service_id='$SERVICE_ID_SELECTED'")
		if [[ -z $SERVICE_AVAILABILITY ]]
		then
			#send to main menu
			SERVICES_MENU "I could not find that service. What would your like today?"
		else
			#get customer info
			echo -e "\nWhat's your phone number?"
			read CUSTOMER_PHONE
			CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where phone='$CUSTOMER_PHONE'")
			
			#if customer doesn't exist
			if [[ -z $CUSTOMER_NAME ]]
			then
				#get new customer name
				echo -e "\nI don't have a record for that phone number, what's your name?"
				read CUSTOMER_NAME

				#insert new customer
				INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

			fi
			#get customer ID
			CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE'")
			
			#get service name
			SERVICE_NAME=$($PSQL "SELECT name from services where service_id='$SERVICE_ID_SELECTED'")
			
			echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
			read SERVICE_TIME
			CREATE_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
			echo $CREATE_APPOINTMENT_RESULT
			echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
		fi
	fi
}

SERVICES_MENU 
