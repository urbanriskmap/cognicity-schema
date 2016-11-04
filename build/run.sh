#!/usr/bin/env bash
# Config
HOST='localhost'
USERNAME='postgres'
DATABASE='cognicity' # Note:- If you use createdb you'll need to adjust the name

# Create db (optional)
## psql -h $HOST -U $USERNAME -f ./cognicity.createdb.sql

# Load schema
psql -h $HOST -U $USERNAME -d $DATABASE -f ../schema/cognicity/cognicity.schema.sql

# Load functions
psql -h $HOST -U $USERNAME -d $DATABASE -f ../schema/cognicity/cognicity.functions.sql

#
