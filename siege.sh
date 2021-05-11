#!bin/bash
# Bash script to run Siege for API load testing with a simple UI

# Check whether Siege is installed
if ! [ command -v siege ] &> /dev/null
then 
  echo "You don't have Siege installed or else it isn't in your PATH. Please make sure to fix this before running again."
  exit 1
fi

# TODO - allow multi-URL operation mode
echo -e 'This is a simple bash script for running Siege on API endpoints. 
You will need to supply: \n
 👉 An optional location to save test logs \n
 👉 An endpoint \n
 👉 The verb, or type of request you are making \n
 👉 The body of the request \n
 👉 The concurrent number of requests to make \n
'

# Log location (optional)
echo -n "Please enter the location where you want your test log to be saved or press enter to skip this and use the default location. 
By default it will save to <location>/var where <location> is the directory in which Siege is installed.
It will save it under the filename 'siege_test.log':"
read -r log_location

if [[ $log_location != '' ]] 
then 
  log_location="-l $log_location/siege_test.log"
fi

# API endpoint (to test) 
echo -n 'Please enter your endpoint:'

# # Check for valid URLs using an ultra-sophisticated regex
read -r endpoint 
http_regex='(https|http)?://([^ ]+[.])+'

while ! [[ $endpoint =~ $http_regex ]] ; do
  echo -n "Please enter a valid URL. Make sure to include the protocol prefix: "
  read -r endpoint
done

# Verb (GET, POST etc.)
echo -n 'Please enter the HTTP verb:'

read verb
valid_verbs=(GET PATCH POST PUT DELETE)
uppercase_verb=$(echo "$verb" | tr a-z A-Z)

while ! [[ " ${valid_verbs[@]} " =~ ${uppercase_verb} ]] ; do 
  echo -n 'Please enter a valid HTTP verb:'
  read verb
done

# Body of the request in JSON format, e.g.
# {  
#    "coordinates":["11.180168326504514 43.92433128404457"],
#    "auth_key":"O46KbWesN7FV5uGBVF8x",
#    "auth_token":"o65avfsIU0YhcMGXfuqWk2TVg5ezJw",
#    "type":"POINT",
#    "buffer":"10000"
#  } in oneline format
echo -n 'Please provide the body of the request you wish to pass:' 

read -r body 


# Concurrent number of requests
echo -n 'Please enter the concurrent number of requests you wish to make:'

# Check for concurrency being an integer
read concurrency
number_regex='^[1-9]+$'

while ! [[ $concurrency =~ $number_regex ]] ; do
  echo -n "Please enter an integer value greater than 0:"
  read concurrency
done

# Run the Siege program
echo 'Running tests...'

eval "siege $log_location --concurrent=$concurrency --verbose --content-type='application/json' '$endpoint $verb $body'"

echo 'Test done!'