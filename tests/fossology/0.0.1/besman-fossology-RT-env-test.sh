#!/bin/bash
operations=(install uninstall validate update reset)

function test_install {
   echo "Testing installation for env $1"

   bes install -env $1 -V $2

   if [ xx"$?" == xx"0" ];then
      echo "Env $1 is installed successfully"
   else
      echo "Error in installing env $1"
   fi
}

function test_uninstall {
   echo "Testing uninstallation for env $1"

   bes uninstall -env $1 -V $2

   if [ xx"$?" == xx"0" ];then
      echo "Env $1 is uninstalled successfully"
   else
      echo "Error in uninstalling env $1"
   fi

}

function test_validate {
   echo "Validate installation of env $1"

   bes validate -env $1

   if [ xx"$?" == xx"0" ];then
      echo "Env $1 is validated successfully"
   else
      echo "Error in validating env $1"
   fi

}

function test_update {

   echo "Testing updation for env $1"

   bes update -env $1

   if [ xx"$?" == xx"0" ];then
      echo "Env $1 is updated successfully"
   else
      echo "Error in updating env $1"
   fi

}

function test_reset {
   echo "Testing Reset for env $1"

   bes reset -env $1

   if [ xx"$?" == xx"0" ];then
      echo "Env $1 is reset successfully"
   else
      echo "Error in resetting env $1"
   fi
   
}


#Main Test
if [ $# -lt 2 ];then
   echo "Env name and Version is mandatory parameter"
   exit 1
fi

envName=$1
envVer=$2

for commandName in ${operations[@]};
do
  test_$commandName $envName $envVer
done
