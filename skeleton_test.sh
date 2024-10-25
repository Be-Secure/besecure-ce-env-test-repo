#!/bin/bash

# Function to clone a GitHub repository and initialize test cases
clone_and_initialize() {
  env_repourl="$1"
  # Clone the repository
  [[ -d tmp ]] && rm -rf tmp && mkdir tmp
  git clone "$env_repourl" "tmp"
  # Change to the cloned directory
  cd "tmp"
}

# Function to process files in a directory
create_skeletons () {
  currDir=`pwd`
  testDir=${test_repo_path}

  # Iterate over files in the directory
  for file in $currDir/*; do
    if [[ -d "$file" ]]; then
      # If it's a directory, recursively process it
      cd $file
      create_skeletons "$file"
    else
      fn=$(basename $file)
      if [ "${fn: -3}" == ".sh" ];then
        folder1=`echo $file  | sed -e "s/.*\/\([^/]*\)\/[^/]*/\1/"`
        folder2=`awk -F/ '{print $(NF-2)}' <<< $file`
        #echo "second_folder= $folder1"
        #echo "third_folder= $folder2"
        if [ ! -d $testDir/$folder2/$folder1 ];then
          mkdir -p $testDir/$folder2/$folder1
        fi
        test_file_name="${fn%.sh}-test.sh"  # Remove ".txt" and add "_test.sh"
	if [ ! -f $testDir/$fodler2/$folder1/$test_file_name ];then
           cp $skeleton_filepath $testDir/$folder2/$folder1/$test_file_name
	   chmod +x $testDir/$folder2/$folder1/$test_file_name
	fi
      fi
    fi
  done
}

# updates list of available env testcases
update_env_list (){
  currDir=`pwd`
  testDir=${test_repo_path}
  list_filename="${testDir}/env_list.txt"

  [[ ! -f $list_filename ]] && touch $list_filename

  # Iterate over files in the directory
  for file in $currDir/*; do
    if [[ -d "$file" ]]; then
      # If it's a directory, recursively process it
      cd $file
      update_env_list "$file"
    else
      fn=$(basename $file)
      if [ "${fn: -3}" == ".sh" ];then
         folder1=`echo $file  | sed -e "s/.*\/\([^/]*\)\/[^/]*/\1/"`
         folder2=`awk -F/ '{print $(NF-2)}' <<< $file`

	 cat $list_filename | grep $folder2
         if [ xx"$?" != xx"0" ];then
            echo $folder2 >> $list_filename
	 fi
      fi
    fi
  done
}

cleanup (){
  cd $PWD
  [ -d tmp ] && rm -rf tmp
}

# Get the directory to process and repository URL as arguments
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path_to_test_repo>"
  exit 1
fi

test_repo_path="$1"
#env_repo_url="$2"
env_repo_url="https://github.com/Be-Secure/besecure-ce-env-repo"
PWD=`pwd`
base_dir=$PWD

# Get the skeleton file path as an argument (optional)
skeleton_filename="${2:-skeleton.txt}"
skeleton_filepath=$PWD/$skeleton_filename

# Clone the repository and initialize test cases
clone_and_initialize "$env_repo_url"

# Process the specified directory
create_skeletons

cd $base_dir/tmp
#update lis
update_env_list

cd $base_dir
# Clean
cleanup
