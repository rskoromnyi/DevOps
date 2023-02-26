#! /usr/bin/bash

## encrypt (default password is set to 1234 for encryption/decryption)
# ./compressor_Skoromnyi.sh dir_name comp_algo out_name 
## gzip example
# ./compressor_Skoromnyi.sh folder_to_compress gzip compressed 
## none example
# ./compressor_Skoromnyi.sh folder_to_compress none compressed 

## decrypt 
## for decryption create folder "decrypted_gzip" and "decrypted_none" and run examples below matching encryption examples above
## gzip example
# openssl enc -aes-256-cbc -d -pass pass:1234 < compressed.tar.gzip.enc | tar --extract --gzip -C decrypted_gzip/
## none example
# openssl enc -aes-256-cbc -d -pass pass:1234 < compressed.tar.none.enc | tar --extract -C decrypted_none/


# list of compression options to check if the option is available
comp_algos_list=(
	"gzip" "bzip2" "xz" "lzip" "lzma" 
	"lzop" "zstd" "compress" "none"
)

# store input arguments
dir_name="$1"
comp_algo="$2"
out_name="$3.tar.${comp_algo}"

# check if directory dir_name exists or is a directory
# if there is no such directory throw error to error.log and exit
if [[ ! (-e $dir_name  ||  -d $dir_name) ]]; then
	echo "$dir_name directory is not available" >> error.log
	exit 1
fi

# check if compression option is available
if [[ ! " ${comp_algos_list[*]} " =~ " ${comp_algo} " ]]; then
	echo "$comp_algo compression option is not available" >> error.log
    exit 1
fi

# if directory exists and chosen compression option is available
# create an encrypted archive
# process "none" compression option seperately
if [[ $comp_algo == "none" ]]; then
	out_name="compressed.tar.none"
	(tar --create $dir_name | openssl enc -aes-256-cbc -e -pass pass:1234 > "${out_name}.enc") 2>> error.log
else
	out_name="compressed.tar.${comp_algo}"
	(tar --create --${comp_algo} $dir_name | openssl enc -aes-256-cbc -e -pass pass:1234 > "${out_name}.enc") 2>> error.log
fi


