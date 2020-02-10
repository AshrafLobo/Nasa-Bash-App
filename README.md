NAME
    nasa.sh

USAGE
    ./nasa.sh opstring parameters
    ./nasa.sh --opstring parameters
    ./nasa.sh [Option]... [-d] [Date] Destination
    ./nasa.sh [Option]... [-t] [Information] [-d] [Date] Destination
    ./nasa.sh [Option]... [--range] [Start_Date] [End_Date] Destination

DESCRIPTION
    A program to obtain information from https://apod.nasa.gov/

    Destination is an optional argument that represents a folder location '/portfolio/week\ 10/'
    [Date] | [Start_Date] | [End_Date] is a date in the format 'YYYY-MM-DD'
    [Information] represents information on a webpage [explanation|details]

    -h | --help
        provides information on the command and how to use it

    -d | --date
        downloads an image from the website

    -t | --type
        downloads the document information provided from the website

    --range
        download a set of images between two dates
        [Start_Date] should be ealier than [End_Date]

EXAMPLES
    ./nasa.sh -d 2019-01-01
    ./nasa.sh -d 2019-01-01 images
    ./nasa.sh --type explanation --date 2019-01-01
    ./nasa.sh -t details -d 2019-01-01
    ./nasa.sh --range 2019-01-01 2019-01-04
    ./nasa.sh --range 2019-01-01 2019-01-04 images
