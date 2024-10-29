#!/bin/bash

testfunctions (){
   envN=${1}
   envV=${2}
   envT=$3
   logfileN=$envN-$envV-test-$(date +"%d-%m-%Y").log

   [[ ! -d $baseDir/data ]] && mkdir -p $baseDir/data
   [[ ! -f $baseDir/data/$logfileN ]] && touch $baseDir/data/$logfileN

   logfile=$baseDir/data/$logfileN

   #call install function.
   #source $testSource $envN-$envT-env $envV >> $logfile
   source $testSource $envN-$envT-env $envV

   if [ xx"$?" == xx"0" ];then
      echo "Environment $envN-$envT version $envV is passed." >> $logfile
   else
      echo "$envN-$envT version $envV is failed" >> $logfile
   fi

   #source $testSource validate $envN-$envT-env $envV >> $logfile
   #if [ xx"$?" == xx"0" ];then
   #   echo "Environment $envN-$envT version $envV is validated successfully." >> $logfile
   #else
   #   echo "Error in validating $envN-$envT version $envV" >> $logfile
   #fi

   #source $testSource uninstall $envN-$envT-env $envV >> $logfile
   #if [ xx"$?" == xx"0" ];then
   #   echo "Environment $envN-$envT version $envV is uninstalled successfully." >> $logfile
   #else
   #   echo "Error in uninstalling $envN-$envT version $envV" >> $logfile
   #fi

}
testEnv1 () {
  eN=$1
  # Iterate over files in the directory
  for name in $baseDir/tests/$eN/*; do
       testSource=""
       if [ -d "$name" ]; then
         ver=$(basename $name)
         envType=""
         for envfile in $baseDir/tests/$eN/$ver/besman-*-test.sh
         do
           echo "environment file = $envfile"
           if [ "$envfile" == "$baseDir/tests/$eN/$ver/besman-$eN-RT-env-test.sh" ];then
             testSource="$baseDir/tests/$eN/$ver/besman-$eN-RT-env-test.sh"
             envType="RT"
             testfunctions $eN $ver $envType
           elif [ "$envfile" == "$baseDir/tests/$eN/$ver/besman-$eN-BT-env-test.sh" ];then
             testSource="$baseDir/tests/$eN/$ver/besman-$eN-BT-env-test.sh"
             envType="BT"
             testfunctions $eN $ver $envType
           else
             echo "$ver not found"
           fi
        done
     fi
   done
}

testEnv () {
  envName=$1
  verList=()
  index=0
  # Iterate over files in the directory
  for name in $baseDir/tests/$envName/*; do
    index=0
    verList=()
    while IFS= read -r line
    do
       if [ -d "$line" ]; then
	       echo "$index"
         fn=$(basename $line)
	 echo "version directory path = $fn"
         #vernumber=`echo $fn  | sed -e "s/.*\/\([^/]*\)\/[^/]*/\1/"`
         verList[$index]="$fn"
         let index+=1
       else
         echo "$line not a directory"
       fi
    done <<< $name
    testSource=""
    echo "Number of version in env $envName are ${#verList}"
    for ver in $verList
    do
       envType=""
       #ver=$vernumber
       for envfile in $baseDir/tests/$envName/$ver/besman-*-test.sh
       do
	 echo "environment file = $envfile"
	 if [ "$envfile" == "$baseDir/tests/$envName/$ver/besman-$envName-RT-env-test.sh" ];then
           testSource="$baseDir/tests/$envName/$ver/besman-$envName-RT-env-test.sh"
	   envType="RT"
	   testfunctions $envName $ver $envType
         elif [ "$envfile" == "$baseDir/tests/$envName/$ver/besman-$envName-BT-env-test.sh" ];then
           testSource="$baseDir/tests/$envName/$ver/besman-$envName-BT-env-test.sh"
	   envType="BT"
	   testfunctions $envName $ver $envType
	 else
	   echo "$ver not found"
	 fi
      done
    done
  done
 
}

getTests () {
   fp="$1"
   [[ ! -f "$fp" ]] && echo "File $fp not found." && exit 1
   readarray -t tests < $fp
   for test in "${tests[@]}"
   do
     testEnv1 $test
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
getTests $filepath
