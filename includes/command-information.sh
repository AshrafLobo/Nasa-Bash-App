#!/bin/bash

# Holds text to be displayed when help option is called

echo -e "
\033[1;34mNAME\033[0m
    \033[1mnasa.sh\033[0m

\033[1;34mUSAGE\033[0m
    \033[1m./nasa.sh\033[0m opstring parameters
    \033[1m./nasa.sh\033[0m --opstring parameters
    \033[1m./nasa.sh\033[0m [Option]... \033[1m[-d] [Date]\033[0m Destination
    \033[1m./nasa.sh\033[0m [Option]... \033[1m[-t] [Information] [-d] [Date]\033[0m Destination
    \033[1m./nasa.sh\033[0m [Option]... \033[1m[--range] [Start_Date] [End_Date]\033[0m Destination

\033[1;34mDESCRIPTION\033[0m
    A program to obtain information from \033[1mhttps://apod.nasa.gov/\033[0m

    \033[1mDestination\033[0m is an \033[2moptional\033[0m argument that represents a folder location \033[2m'/portfolio/week\ 10/'\033[0m
    \033[1m[Date]\033[0m | \033[1m[Start_Date]\033[0m | \033[1m[End_Date]\033[0m is a date in the format \033[2m'YYYY-MM-DD'\033[0m
    \033[1m[Information]\033[0m represents information on a webpage \033[2m[explanation|details]\033[0m

    \033[94m-h | --help \033[0m
        provides information on the command and how to use it

    \033[94m-d | --date \033[0m
        downloads an image from the website

    \033[94m-t | --type \033[0m
        downloads the document information provided from the website

    \033[94m--range \033[0m
        download a set of images between two dates
        [Start_Date] should be ealier than [End_Date]

\033[1;34mEXAMPLES\033[0m
    ./nasa.sh -d 2019-01-01
    ./nasa.sh -d 2019-01-01 images
    ./nasa.sh --type explanation --date 2019-01-01
    ./nasa.sh -t details -d 2019-01-01
    ./nasa.sh --range 2019-01-01 2019-01-04   
    ./nasa.sh --range 2019-01-01 2019-01-04 images
"