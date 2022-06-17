#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # test for a number
if [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$1
fi
# test for a symbol
if [[ ${#1} -lt 3 &&  ! $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'") 
  SYMBOL=$1
fi
# test for a name
if [[ ${#1} -gt 2 ]] && [[ ! $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  NAME=$1
fi
if [[ -z $ATOMIC_NUMBER ]]
then
  echo "I could not find that element in the database."
else
  if [[ -z $NAME ]]
  then
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  fi
  if [[ -z $SYMBOL ]]
  then
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  fi
  ATOMIC_NUMBER_FORMATTED=$(echo $ATOMIC_NUMBER | sed 's/ |/"/')
  NAME_FORMATTED=$(echo $NAME | sed 's/ |/"/')
  SYMBOL_FORMATTED=$(echo $SYMBOL | sed 's/ |/"/')
  MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  TYPE=$($PSQL "SELECT type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number =$ATOMIC_NUMBER")
  TYPE_FORMATTED=$(echo $TYPE | sed 's/ |/"/')
  MASS_FORMATTED=$(echo $MASS | sed 's/ |/"/')
  MELTING_POINT_FORMATTED=$(echo $MELTING_POINT | sed 's/ |/"/')
  BOILING_POINT_FORMATTED=$(echo $BOILING_POINT | sed 's/ |/"/')
  echo "The element with atomic number $ATOMIC_NUMBER_FORMATTED is $NAME_FORMATTED ($SYMBOL_FORMATTED). It's a $TYPE_FORMATTED, with a mass of $MASS_FORMATTED amu. $NAME_FORMATTED has a melting point of $MELTING_POINT_FORMATTED celsius and a boiling point of $BOILING_POINT_FORMATTED celsius."
fi
fi