#!bin/bash
# Bash script to run Siege for API load testing with a simple UI

# Check whether Siege is installed
if ! command -v siege &> /dev/null
then 
  echo "You don't have Siege installed or else it isn't in your PATH. Please make sure to fix this before running again."
  exit 1
fi

echo -e 'This is a simple bash script for running Siege on API endpoints. 
You will need to supply: \n
 👉 An optional location to save test logs \n
 👉 The concurrent number of requests to make \n

After that, you can either choose to run it in single-endpoint mode:
 👉 An endpoint \n
 👉 The verb, or type of request you are making \n
 👉 The body of the request \n

Or you can read in a text file of endpoints and verbs for each request. 
It has to be in this format - and if you need any authentication for those endpoints
in the form of query params, put them in there too: 
# comments behind hashes
http://homer.whoohoo.com/cgi-bin/hello.pl POST name=homer
http://homer.whoohoo.com/haha.jsp POST word=doh!&scope=ALL

# To post the contents of a file, use the redirect character <:
http://www.haha.com/reader.php POST < /path/to/file

# If you need authentication AND post file contents, its best to put the params in 
# URL directly instead of separating them out
'


# Logging enabled (optional)
echo -e "Enable logging? If so, logfile location will be outputted at the end of the test"

select choice in "Y" "N"; do
    case $choice in
        Y ) 
          enable_logging="-l" 
          break;;
        N )
          enable_logging=""
          break;;
        *) 
          echo "Select either 1 or 2 to proceed";;
    esac
done

# Mode functions
single_endpoint_mode() {
  # API endpoint (to test) 
  echo -n 'Please enter your endpoint:'

  # Check for valid URLs using an ultra-sophisticated regex
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

  echo $uppercase_verb
  while  [[ ! " ${valid_verbs[@]} " =~ ${uppercase_verb} ]] ; do 
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
  # TODO - fix
  # number_regex='^[1-9]\d*$'

  # while ! [[ $concurrency =~ $number_regex ]] ; do
  #   echo -n "Please enter an integer value greater than 0:"
  #   read concurrency
  # done

  # Run the Siege program
  echo 'Running tests...'

  eval "siege $enable_logging --concurrent=$concurrency --verbose --content-type='application/json' '$endpoint $uppercase_verb $body'"
}

file_read_mode() {
  # File location 
  echo -n 'Please enter the absolute path to your file:'
  read -r file_location 

  while ! [[ -f "$file_location" ]]; do
    echo "File could not be found - did you provide the correct location?"
    echo "Please try again: "
    read -r file_location 
  done

  # Concurrent number of requests
  echo -n 'Please enter the concurrent number of requests you wish to make:'

  # Check for concurrency being an integer
  read concurrency
  # TODO - fix
  # number_regex='^[1-9]+$'

  # while ! [[ $concurrency =~ $number_regex ]] ; do
  #   echo -n "Please enter an integer value greater than 0:"
  #   read concurrency
  # done

  echo -e 'Set internet mode on? The URLs in your file will be hit randomly instead of sequentially'

  select choice in "Y" "N"; do
    case $choice in
        Y ) 
          internet_mode="-i" 
          break;;
        N )
          internet_mode=""
          break;;
        *) 
          echo "Select either 1 or 2 to proceed";;
    esac
  done

  echo -e 'Set delay?'
  read delay_amount

  if [ $delay_amount == "" ] ;
  then
    delay=""
  else 
    delay="--delay=$delay_amount"
  fi

  echo -e 'Set reps?'
  read reps_amount

  if [ $reps_amount == "" ] ;
  then
    reps=""
  else 
    reps="--reps=$reps_amount"
  fi
  
  # Run the Siege program
  echo 'Running tests...'

  eval "siege -f $file_location $reps $delay $internet_mode $enable_logging --concurrent=$concurrency --verbose --content-type='application/json'"
}

# There's two options to choose from - you can either provide a single endpoint or a file of endpoints to read from:
echo -e 'Please select from the following options:'

select selection in "Single endpoint mode" "File read mode" "Exit"; do
    case $selection in
      'Single endpoint mode' ) 
        single_endpoint_mode
        break;;
      'File read mode' )
        file_read_mode
        break;;
      'Exit' )
        exit 0;;
      *) 
        echo "Select a valid option";;
    esac
done

echo 'Test done!'

exit 0

# TODO - fix so we can run the script again
# echo -e "Do you wish to run another test?"

# select restart in "Y" "N"; do
#     case $restart in
#         Y ) 
#           ./$(basename $0) && exit;;
#         N )
#           exit 0;;
#         *) 
#           echo "Select either 1 or 2 to proceed";;
#     esac
# done

