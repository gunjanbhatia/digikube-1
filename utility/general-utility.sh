function download_file {
        
   local dest_file_path="/tmp/"
   local dest_file_name=""

   if [ $# -lt 2 ]; then
      echo "Insufficient parameters provided."
      eval $__resultvar="''"
      exit 1
   else
      local source_url=$1   #should check the format
      echo $source_url
      local dest_file_name="${dest_file_path}digikube-${RANDOM}"
      echo $dest_file_name
      echo "wget -q --no-cache -O $dest_file_name - $source_url"
      wget -q --no-cache -O $dest_file_name - $source_url
      #exit_code1=$?
      exit_code1=0
      if [[ $exit_code1 -eq 0 ]]; then
         if [[ -f $dest_file_name ]]; then
                echo "File downloaded: $dest_file_name"
                local  __resultvar=$2
                eval $__resultvar="'$dest_file_name'"
         else
                echo "Error while downloading file. Do something"
                exit 1
         fi
      else
         echo "Error while downloading file. Do something"
         eval $__resultvar="''"
         exit 1
      fi
   fi

}

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}