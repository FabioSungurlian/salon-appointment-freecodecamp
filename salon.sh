#! /bin/bash
PSQL="psql --tuples-only --username=freecodecamp --dbname=salon -c "
SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")"
IFS=" | "
MAIN_MENU(){
  echo -e "\nPlease select a service\n"
  while [[ -z $SERVICE_NAME ]]
  do
    echo "$SERVICES" | sed -E "s/ *([0-9]+) \| (.*) */\1) \2/m"
    read SERVICE_ID_SELECTED
    

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      echo -e "\nError: Service must be a number, please select a service:\n"
      continue
    fi

    SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"

    if [[ -z $SERVICE_NAME ]] 
    then
      echo -e "\nError: Service does not exist, please select a service from the list:\n"
    fi
  done
  echo -e "\nPlease enter your phone number"
  read CUSTOMER_PHONE
  CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_INFO ]]
  then
    echo -e "\nPlease enter your name to register as a new user"
    read CUSTOMER_NAME
    INSERT_COSTUMER_RESULT="$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")"
    CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
  else
    read CUSTOMER_ID CUSTOMER_NAME <<< $CUSTOMER_INFO
  fi
  echo -e "\nPlease select a time for the service:"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"

  if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  
}
MAIN_MENU
