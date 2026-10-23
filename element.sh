#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

element_data=$(psql --username=freecodecamp --dbname=periodic_table --tuples-only --no-align --field-separator='|' --set=element="$1" <<'SQL'
SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass,
     p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p USING (atomic_number)
JOIN types t USING (type_id)
WHERE e.atomic_number::TEXT = :'element'
  OR lower(e.symbol) = lower(:'element')
  OR lower(e.name) = lower(:'element');
SQL
)

if [[ -z "$element_data" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r atomic_number element_name symbol element_type atomic_mass melting_point boiling_point <<< "$element_data"
printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$atomic_number" "$element_name" "$symbol" "$element_type" "$atomic_mass" \
  "$element_name" "$melting_point" "$boiling_point"
