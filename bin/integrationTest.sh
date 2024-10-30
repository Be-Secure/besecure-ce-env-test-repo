#!/bin/bash

executeTests () {
   envN=${1}
   envV=${2}
   envT=$3
   logfileN=$envN-$envV-test-$(date +"%d-%m-%Y").log

   # Check if the log file already exists, create if not
   [[ ! -d $baseDir/data ]] && mkdir -p $baseDir/data
   [[ ! -f $baseDir/data/$logfileN ]] && touch $baseDir/data/$logfileN
   logfile=$baseDir/data/$logfileN
   
   # Execute env test functions
   source $testSource $envN-$envT-env $envV >> $logfile

   # Log the results of execution
   if [ xx"$?" == xx"0" ];then
      echo "Environment $envN-$envT version $envV is passed." >> $logfile
   else
      echo "$envN-$envT version $envV is failed" >> $logfile
   fi
}

testEnvironment () {
  envName=$1

  # Iterate over version directories in the environment
  for verDirPath in $baseDir/tests/$envName/*; do
       testSource=""

       if [ -d "$verDirPath" ]; then
         envVersion=$(basename $verDirPath)
         envType=""

	 # Get the test file names in version directories of environment under test
         for envfile in $baseDir/tests/$envName/$envVersion/besman-*-test.sh
         do
           # Check for RT or BT tests to call accordingly
           if [ "$envfile" == "$baseDir/tests/$envName/$envVersion/besman-$envName-RT-env-test.sh" ];then
             testSource="$baseDir/tests/$envName/$envVersion/besman-$envName-RT-env-test.sh"
             envType="RT"
             executeTests $envName $envVersion $envType
           elif [ "$envfile" == "$baseDir/tests/$envName/$envVersion/besman-$envName-BT-env-test.sh" ];then
             testSource="$baseDir/tests/$envName/$envVersion/besman-$envName-BT-env-test.sh"
             envType="BT"
             executeTests $envName $envVersion $envType
           else
             echo "$envVersion not found"
           fi
        done
     fi
   done
}

testEnvs () {
   envReadyFile="$1"
   [[ ! -f "$envReadyFile" ]] && echo "File $envReadyFile not found." && exit 1

   # Read the environment ready file to get the list of environments to run test on.
   readarray -t envs < $envReadyFile
   for env in "${envs[@]}"
   do
     testEnvironment $env
   done
}

[[ ! -z $1 ]] && option="$1"
[[ ! -z $2 ]] && filepath="$2"

[[ ! -z $option ]] && [[ "$option" != "--file" ]] &&  echo "Not a valid option" && exit 1
[[ ! -z $filepath ]] && [[ -z $filepath ]] && echo "filepath not given" && exit 1

PWD=`pwd`
baseDir="$PWD"

testSource=""

if [ -z $filepath ];then
  filepath=$baseDir/conf/envReady.txt
fi
testEnvs $filepath
