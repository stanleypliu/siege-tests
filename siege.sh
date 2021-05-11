#!bin/bash

siege -l/home/luca/Desktop/IBAT_api_load_test.log --concurrent=3 --verbose --content-type="application/json" 'https://web-staging.ibat-alliance.org/api/v1/wdpa/intersect/areas POST { "coordinates":["11.180168326504514 43.92433128404457"],"auth_key":"O46KbWesN7FV5uGBVF8x","auth_token":"o65avfsIU0YhcMGXfuqWk2TVg5ezJw","type":"POINT","buffer":"10000"}'
