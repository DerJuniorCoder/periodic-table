#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

PRINT_ELEMENT() {
  COLUMNS=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius
  FROM elements
  INNER JOIN properties ON elements.atomic_number = properties.atomic_number
  INNER JOIN types ON properties.type_id = types.type_id
  WHERE elements.atomic_number=$1")
  echo $COLUMNS | while IFS="|" read TYPE MASS MELT BOIL
    do
      echo "The element with atomic number $1 is $3 ($2). It's a $TYPE, with a mass of $MASS amu. $3 has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done
}

if [[ $1 ]]
  then
    regex="^[0-9]+$"
    regex2="^[A-Z][a-z]*$"
    if [[ $1 =~ $regex ]]
      then
        # Get symbol & name 
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1")
        NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")
        if [[ -z $SYMBOL ]]
          then
            echo "I could not find that element in the database."
          else 
            PRINT_ELEMENT $1 $SYMBOL $NAME
        fi
    elif [[ $1 =~ $regex2 ]]
      then
        # echo "The input is a symbol or a name"
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
        if [[ -z $ATOMIC_NUMBER ]] 
          then
            # Input is a name
            ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
            if [[ -z $ATOMIC_NUMBER ]] 
              then
                echo "I could not find that element in the database."
              else
                SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
                PRINT_ELEMENT $ATOMIC_NUMBER $SYMBOL $1
            fi
          else
            # input is a symbol
            NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
            PRINT_ELEMENT $ATOMIC_NUMBER $1 $NAME
        fi  
      else 
        echo "I could not find that element in the database."
    fi
  else
    echo "Please provide an element as an argument."
fi






