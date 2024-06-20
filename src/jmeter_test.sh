#!/bin/bash

# Default values
baseUrl="blazedemo.com"
protocol="https"
maxRandTimerDelay=1000
minRandTimerDelay=750
treadsCount=5
rampUp=15
testDuration=1
throughputDestination=32
throughputFlights=25
throughputBooking=35
totalThroughputOp2=105
totalThroughputOp3Home=60
totalThroughputOp3Dest=20
totalThroughputOp3Flight=25
distribution=""


# Base help
print_help() {
    echo "Usage: $0 [options]"
    echo
    echo "  -optionToRun:               There is 3 options to run:"
    echo "                               1.Just With Transaction Controller"
    echo "                               2.One tread with Precise Throughput Timer"
    echo "                               3.Three treads with Precise Throughput Timer" 
    echo "  -treadCount                 Number of threads(users) to run (default: 5)"   
    echo "  -baseUrl                    Base URL (default: blazedemo.com)"
    echo "  -protocol                   Base protocol (default: https)"
    echo "  -maxRandTimerDelay          Max random timer delay (default: 1000)"
    echo "  -minRandTimerDelay          Min random timer delay (default: 750)"
    echo "  -rampUp                     Ramp-up time sec (default: 15)"
    echo "  -testDuration               Test duration min (default: 1)"
    echo "  -throughputDestination      Throughput for Destination of the week requests % (default: 32)"
    echo "  -throughputFlights          Throughput for flights reqests % (default: 25)"
    echo "  -throughputBooking          Throughput for booking reqests %(default: 35)"
    echo "  -totalThroughputOp2         Total throughput in the option 2 req/min (default: 105)"
    echo "  -totalThroughputOp3Home     Total throughput in the option 3 for home requests req/min (default: 60)"
    echo "  -totalThroughputOp3Dest     Total throughput in the option 3 for destination requests req/min (default: 20)"
    echo "  -totalThroughputOp3Flight   Total throughput in the option 3 for flight requests req/min (default: 25)"
    echo "  -distribution               Ips for jmeter distribution test (default: "") Format -R ip, exmpl -distribution='-R 10.10.10.10"
    echo "  -h, --help                  Display help message"
}

# Process command line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -optionToRun)
      optionToRun="$2"
      shift 2
      ;;
    -baseUrl)
      baseUrl="$2"
      shift 2
      ;;
    -protocol)
      protocol="$2"
      shift 2
      ;;
    -maxRandTimerDelay)
      maxRandTimerDelay="$2"
      shift 2
      ;;
    -minRandTimerDelay)
      minRandTimerDelay="$2"
      shift 2
      ;;
    -treadsCount)
      treadsCount="$2"
      shift 2
      ;;
    -rampUp)
      rampUp="$2"
      shift 2
      ;;
    -testDuration)
      testDuration="$2"
      shift 2
      ;;
    -throughputDestination)
      throughputDestination="$2"
      shift 2
      ;;
    -throughputFlights)
      throughputFlights="$2"
      shift 2
      ;;
    -throughputBooking)
      throughputBooking="$2"
      shift 2
      ;;
    -totalThroughputOp2)
      totalThroughputOp2="$2"
      shift 2
      ;;
    -totalThroughputOp3Home)
      totalThroughputOp3Home="$2"
      shift 2
      ;;
    -totalThroughputOp3Dest)
      totalThroughputOp3Dest="$2"
      shift 2
      ;;
    -totalThroughputOp3Flight)
      totalThroughputOp3Flight="$2"
      shift 2
      ;;
    -distribution)
      distribution="$2"
      shift 2
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown parameter: $1"
      print_help
      exit 1
  esac
done
# If option not selected exit test
if [ -z "$optionToRun" ]; then
  echo "Error: -optionToRun is a required argument."
  print_help
  exit 1
fi

echo "TEST CONFIGURATIONS"
echo
echo " OPTION TO RUN:        $optionToRun"
echo " BASE URL:             $baseUrl"
echo " BASE PROTOCOL:        $protocol"
echo " TREADS(USERS) TO RUN: $treadsCount" 
echo " TEST DURATION:        $testDuration min" 
echo " Distribution:         $distribution " 
echo 


testDuration=$((testDuration*60))
resultFolderPath="jData$(date '+%m%d_%H%M%S')"

echo $resultFolderPath
# Jmeter execution
jmeter -n -t blazedemo_h60d20f15b5.jmx \
    ${distribution} \
    -JbaseUrl="$baseUrl" \
    -Jprotocol="$protocol" \
    -JmaxRandTimerDelay="$maxRandTimerDelay" \
    -JminRandTimerDelay="$minRandTimerDelay" \
    -Jtreads${optionToRun}Count="$treadsCount" \
    -JrampUp="$rampUp" \
    -JtestDuration="$testDuration" \
    -JthroughputDestination="$throughputDestination" \
    -JthroughputFlights="$throughputFlights" \
    -JthroughputBooking="$throughputBooking" \
    -JtotalThroughputOp2="$totalThroughputOp2" \
    -JtotalThroughputOp3Home="$totalThroughputOp3Home" \
    -JtotalThroughputOp3Dest="$totalThroughputOp3Dest" \
    -JtotalThroughputOp3Flight="$totalThroughputOp3Flight" \
    -l "$resultFolderPath/log.jtl" -j  "$resultFolderPath/test.log" -e -o  "$resultFolderPath/out"



##### DOCKER POWER
defReportPort=8080

while true; do
    if ! lsof -i:$defReportPort >/dev/null; then
        break
    fi
    defReportPort=$((defReportPort + 1))
done


docker build -t jmeter-report --build-arg jmeter_report_path=$resultFolderPath/out .
docker run -d -p $defReportPort:80 jmeter-report

echo "JMeter report link:  http://localhost:$defReportPort/index.html"
