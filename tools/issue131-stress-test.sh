#!/bin/bash

# Usage: ./test-launch.sh 500

# When launching this test script more than once in current
# Linux session then the CEF initialization issue is hard
# to reproduce. The best results are when launching tests
# in a clean Ubuntu session, just log out and log in again,
# and run the test immediately. You could also run a few
# terminal sessions with several test scripts running
# simultaneously to simulate heavy overload.

for ((i = 1; i <= $1; i++)); do
    output=$(python ./../cef3/wx-subpackage/examples/sample2.py test-launch)
    code=$?
    if [[ $code != 0 || $output != *b8ba7d9945c22425328df2e21fbb64cd* ]]; then
        echo "EXIT CODE: $code"
        echo "OUTPUT: $output"
        echo "ERROR!"
        read -p "Press ENTER to exit"
        exit $code
    fi
    echo RUN $i OK
done

echo TEST SUCCEEDED
read -p "Press ENTER to exit"
