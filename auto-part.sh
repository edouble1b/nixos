#!bin/bash
#
# This will partition the 

SWAP="4GiB"
package="auto-part"
while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "$package - build and format partitions for uefi systems"
                        echo " "
                        echo "$package [options] drive [arguments]"
                        echo " "
                        echo "options:"
                        echo "-h, --help                show brief help"
                        echo "-s, --swap=SIZE           specify the size of swap: default is 4GiB"
                        exit 0
                        ;;
                -s)
                        shift
                        if test $# -gt 0; then
                                export SWAP=$1
                        else
                                echo "no swap specified"
                                exit 1
                        fi
                        shift
                        ;;
                --swap*)
                        export SWAP=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

FILE=$1
if [ "$FILE" == "" ]; then
    echo "no drive was given"
    echo "$package [options] drive [arguments]"
    exit 1
fi

if [ ! -f $FILE ]; then
   echo "drive $FILE does not exist"
   exit 1
fi

parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -"$SWAP"
parted /dev/sda -- mkpart primary linux-swap -"$SWAP" 100%
parted /dev/sda -- mkpart ESP fat32 0MiB 512MiB
parted /dev/sda -- set 3 boot on

