#!/bin/bash

#FUNCTIONS --------------------------------

# Check if website is reachable
website_status() {
	sleep 1s
	clear

	# Text to show process started
	printf "Connecting to nasa";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";

	#Store the website status in a variable
	status=$(curl -IsS https://apod.nasa.gov/apod/ | head -1)
	
	#Check if status is null
	if [[ -z $status ]]; then
		echo -e "There was a problem connecting to the website \033[34mhttps://apod.nasa.gov/apod/\033[0m\nCheck your \033[34mWiFi connection\033[0m"
		exit 1
	else
		#Handle different status codes
		if [[ $status =~ "200" ]]; then
			echo -e "Connection to \033[34mhttps://apod.nasa.gov/apod/\033[0m \033[92mSuccessful\033[0m"
		elif [[ $status =~ "404" ]]; then
			echo -e "Status 404. \033[1;31mNot Found\033[0m"
			exit 1
		elif [[ $status =~ "502" ]]; then
			echo -e "Status 502. \033[1;31mBad Gateway\033[0m"
			exit 1
		elif [[ $status =~ "504" ]]; then
			echo -e "Status 504. \033[1;31mGateway Timeout\033[0m"
			exit 1
		else
			echo $status
			exit 1
		fi
	fi

	sleep 2s
	clear
}

# Display helpful error mesage
help_text() {
	echo -e "Try using the option \033[1;94m'./nasa.sh -h'\033[0m for \033[1;94mhelp\033[0m with the command"
	sleep 2s
	exit 1
}

# Check the date format
check_date() {
	printf "Checking date \033[94m'${1}'\033[0m validity";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";

	# Regex for date format
	regex="^[12][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$"

	if [[ ! $1 =~ $regex ]]; then
		sleep 1s; clear;
		echo -e "\033[31;1mError:\033[0m Incorrect argument '${1}' provided. A '--date' is needed."
		help_text
	fi

	# Check if date provided is available
	today=$(date "+%s")
	provided_date=$(date --date "${1}" "+%s")
	first_post=$(date --date "June 16 1995" "+%s")

	if [[ $provided_date -gt today ]]; then
		sleep 1s;clear;
		echo -e "\033[31;1mError:\033[0m The date \033[94m'${1}'\033[0m is in the future."
		echo -e "Please enter a date between today and \033[94mJune 16 1995\033[0m"
		sleep 2s
		exit 1
	elif [[ $provided_date -lt $first_post ]]; then
		sleep 1s;clear;
		echo -e "\033[31;1mError:\033[0m A record for the date \033[94m'${1}'\033[0m does not exist."
		echo -e "The first valid record is from \033[94mJune 16 1995\033[0m"
		sleep 2s
		exit 1
	fi
}

# Get page specified
get_page(){
	#Compress the date to 'yymmdd'
	comp_date=$(echo $1 | sed 's|^[0-9]\{2\}\([0-9]\{2\}\).\([0-9]\{2\}\).\([0-9]\{2\}\)$|\1\2\3|')
	
	#Concatenate the url with the compressed date
	page="https://apod.nasa.gov/apod/ap${comp_date}.html"

	echo "$page"
}

# Get the image url
get_image_url() {
	image=$(curl --silent "$1" | awk '
	/.*<a.+href="image.+/ {
		link = gensub(/.+href="(.+)".*$/, "\\1", "g", $0);
		print link;
	}')

	image_url="https://apod.nasa.gov/apod/${image}"

	echo "$image_url"
}

# Get the title 
get_title() {
	# Get title
	title=$(curl --silent $page | awk '
	BEGIN {
		my_arr[0] = "";
	}

	/.*(b|B)>(.+).*(<\/(b|B)>.*)?/ {
		arr_length = length(my_arr);

		if (my_arr[0] == "") {
			next_item = arr_length - 1;
			delete my_arr[0];
		}
		else {
			next_item = arr_length;
		}

		my_arr[next_item] = $0;
	}

	END {
		print my_arr[0];
	}')

	title=$(echo $title | sed 's|<[^>]*>||g')
	title=$(echo $title | sed -e 's|\s\+$||g' -e 's|\s|_|g')

	echo "$title"
}

# Get Explanation
get_explanation() {
	# Get the explanation text
	explanation=$(curl --silent $1 | sed -n "/[bB]>.*Explanation/, /Tomorrow/ p" | sed "/Tomorrow/, $ d" | sed "/Explanation/ d" | sed "/script/ d")

	# Remove newlines, html tags and combine text
	explanation=$(echo "$explanation" | awk 1 ORS=' ' | sed 's|<[^>]*>||g' | sed 's|\s\+| |g' | sed 's|&.*;||g')

	printf "$explanation"
}

# Get Location
get_location() {
	if [[ ! -z $1 ]]; then
		location=$1
		image_title=$2

		if [[ ! -d $location ]]; then
			printf "Creating \033[94m'${location}'\033[0m folder";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
			mkdir $location
		fi

		image_title=$(echo "${location}/${image_title}")
	fi
}

# Download Image
download_image() {

	# Check that date format is correct
	check_date $1

	# Get the page to download
	page=$(get_page $1)

	# Get image url
	image_url=$(get_image_url "$page")	

	#Get image title 
	image_title=$(get_title $page)
	image_title=$(echo "${image_title}.jpg")

	# If a location argument is provided
	if [[ ! -z $2 ]]; then
		printf "Checking if \033[94m'${2}'\033[0m folder exists";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
		get_location $2 $image_title
	fi

	# Download image
	printf "Downloading \033[94m'${image_title}'\033[0m";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
	curl --progress-bar -o "${image_title}" "${image_url}"
	echo -e "\033[92mDownload Complete\033[0m"
	echo "Finished."
	sleep 1s
}

download_multiple_images() {
	# Convert to date
	start_date=$(date --date "${1}" "+%s")
	end_date=$(date --date "${2}" "+%s")

	# Confirm that start date is earlier than end date
	if [[ $start_date -lt $end_date ]]; then
		sleep 1s;clear;
		echo -e "\033[31;1mError:\033[0m Incorrect date placement for '--range'"
		echo -e "The start_date \033[94m'${1}'\033[0m should be the second argument"
		help_text
	fi

	# Check days between dates
	let secs_btwn_dates=start_date-end_date
	let days=$secs_btwn_dates/60/60/24
	let days=$days+1

	# Divide days into groups of 10
	if [[ days -ge 10 ]]; then
		grps=$(echo "scale=1; ${days}/10" | bc)
		let w_grps=$days/10
		dw_grps=$(printf "%.1f" $w_grps)

		if [[ $grps > $dw_grps ]]; then
			let grps=$w_grps+1
		else
			let grps=$w_grps
		fi
	else
		let grps=1
	fi
	
	printf "Fetching images";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
	sleep 0.2s;
	clear
	sleep 1s

	# Store the dates into an array
	days_remaining=$days
	declare -A data_arr
	date_arr=($1)

	for (( i = 1; i < $days; i++ )); do
		last_date=${date_arr[$i-1]}
		date_arr[i]=$(date --date "${last_date} -1 days" "+%Y-%m-%d")
	done

	# Convert each date to url and save in an array
	url_arr=("")
	let i=0	
	
	if [[ ! -z $3 ]]; then
		clear
		printf "Checking if \033[94m'${3}'\033[0m folder exists";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
	fi
	
	for d in ${date_arr[*]}; do
		page=$(get_page $d)
		
		# Get image url
		image_url=$(get_image_url "$page")
		
		# Get image title
		image_title=$(get_title "$page")
		image_title=$(echo "${image_title}.jpg")
		
		# If a location argument is provided
		if [[ ! -z $3 ]]; then
			get_location $3 $image_title
		fi
		url_arr[i]="-o ${image_title} ${image_url}"
		let i=$i+1
	done

	printf "Please wait for download to begin";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
	sleep 1s
	
	# Download dates
	for (( i = 1; i <= $grps; i++ )); do
		clear
		printf "\nDownloading Group \033[94m${i}\033[0m of \033[94m${grps}\033[0m";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n\n";
		
		curl_str=""

		for (( j = 0; j < 10; j++ )); do
			if [[ $days_remaining -eq 0 ]]; then
				break
			fi

			let index=$days-$days_remaining

			curl_str="${curl_str} ${url_arr[$index]}"

			let days_remaining=$days_remaining-1
		done

		curl --progress-bar $curl_str
	done

	echo -e "\n\033[92mDownload Complete\033[0m"
	echo  "Finished."
	sleep 0.2s
}

#CODE-------------------------------------

# Create an options string for the script
options=$(getopt -n "nasa.sh" -o hd:t: --long help,date:,type:,range: -- "$@") 

# Check if the option string is empty or invalid
[ $? -eq 0 ] || {
	help_text
}

# Evaluate the option string
eval set -- "$options"

# Check website status
website_status

# Run the appropriate command
while true; do
    case "$1" in
    -h | --help)
			bash ./includes/command-information.sh
		;;
	-d | --date)
			let arguments=$#-2

			# Check the amount of arguments given
			if [[ $arguments -gt 2 ]]; then
				
				# Error if arguments are more than 2
				echo -e "\033[31;1mError: \033[0m Too many arguments provided for '--date'"
				help_text

			elif [[ $arguments -eq 2 ]]; then
				
				# Handles download when date and location are given
				img_date=$2 
				shift 2
				location=$2

				download_image $img_date $location

			elif [[ $arguments -eq 1 ]]; then
				
				# Download image in current folder
				download_image $2
			fi

			break
		;;
	-t | --type)
			arr=($*);

			page="${page:=""}"

			for item in ${!arr[*]};do

				# Check if date has been given as an argument
				if [[ ${arr[$item]} = "-d" || ${arr[$item]} = "--date" ]]; then
					date=${arr[$item+1]}

					# Check that date format is correct
					check_date $date

					# Get page
					page=$(get_page $date)

					printf "Checking type";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";

					# Download page
					case "$2" in
						explanation)
							printf "Fetching ${2}";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
							echo  -e "\033[92mFetch Complete\033[0m"; sleep 0.2s;
							clear

							# Get Explanation
							explanation=$(get_explanation "$page")

							# Print the explanation
							echo -e "EXPLANATION - ${date}\n"
							echo "$explanation" 
							echo -e "\nFinished."
							;;
						details)
							printf "Fetching ${2}";sleep 0.2s;printf ".";sleep 0.2s;printf ".";sleep 0.2s;printf ".\n";
							echo  -e "\033[92mFetch Complete\033[0m"; sleep 0.2s;
							clear

							title=$(get_title "$page")
							explanation=$(get_explanation "$page")

							image_credit=$(curl --silent "$page" | sed 's/\r//g' | sed -n '/Credit/, /\(center\|CENTER\)/p' | sed -e 's|.*Credit.*[bB]>\(.*\)|\1|')
							image_credit=$(echo "$image_credit" | sed -e 's|<[^>]*>||g' -e 's|.*>||g' -e 's|<.*||g' -e 's|,||g' | awk 1 ORS=" " | sed -e 's|^,\+||g' -e 's|,\+$||g')

							# Print the details
							echo -e "DETAILS - ${date}\n"
							echo -e "TITLE: $title\n"
							echo -e "EXPLANATION:\n"
							echo -e "$explanation\n"
							echo -e "IMAGE CREDIT: ${image_credit}\n" 
							echo "Finished."
							;;
						*)
							# Error if unavailable type is given
							echo -e "\033[31;1mError: \033[0m No '$2' option available"
							help_text
							;;
					esac
				fi
			done
			
			if [[ -z $page ]]; then
				# Error if no date is given
				echo -e "\033[31;1mError: \033[0m No '--date' option provided"
				help_text
			fi
			break
		;;
	--range)
			let arguments=$#-2

			# Check the amount of arguments given
			if [[ $arguments -gt 3 ]]; then
				
				# Error if arguments are more than 3
				echo -e "\033[31;1mError: \033[0m Too many arguments provide for 'range'"
				help_text
			elif [[ $arguments -eq 3 ]]; then
				# Define start date
				check_date $2
				s_date="$2"
				
				shift 2

				# Define end date
				check_date $2
				e_date="$2"

				# Define location
				location="$3"

				# Download multiple dates
				download_multiple_images $s_date $e_date $location
			elif [[ $arguments -eq 2 ]]; then
				# Define start date
				check_date $2
				s_date="$2"
				
				shift 2

				# Define end date
				check_date $2
				e_date="$2"

				# Download multiple dates
				download_multiple_images $s_date $e_date
			elif [[ $arguments -lt 2 ]]; then
				# Error if arguments are less than 2
				echo -e "\033[31;1mError: \033[0m '--range' needs at least two arguments"
				help_text
			fi

			break
		;;
    --)
        shift
        break
        ;;
    esac
    shift
done

sleep 3s
