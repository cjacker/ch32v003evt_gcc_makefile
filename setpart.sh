#!/bin/bash

# if no Makefile
if [ ! -f Makefile ]; then
	echo "Please run './generate_project_from_evt.sh <part>' first."
  exit
fi 

PART_LIST="./ch32v-parts-list.txt"

# if no arg,
if [ $# -ne 1 ]; then
  echo "Usage: ./setpart.sh <part>"
  echo "Please specify a ch32v part:"
  while IFS= read -r line
  do
    part=$(echo "$line"|awk -F ' ' '{print $1}'| tr '[:upper:]' '[:lower:]')
    echo "$part"
  done < "$PART_LIST"
  exit
fi

# iterate the part list to found part info.
PART=$1
FLASHSIZE=
RAMSIZE=
STARTUP_ASM=
ZIPFILE=

FOUND="f"

while IFS= read -r line
do
  cur_part=$(echo "$line"|awk -F ' ' '{print $1}'| tr '[:upper:]' '[:lower:]')
  FLASHSIZE=$(echo "$line"|awk -F ' ' '{print $2}')
  RAMSIZE=$(echo "$line"|awk -F ' ' '{print $3}')
  STARTUP_ASM=$(echo "$line"|awk -F ' ' '{print $4}')
  ZIPFILE=$(echo "$line"|awk -F ' ' '{print $5}')
  if [ "$cur_part""x" == "$PART""x" ]; then
    FOUND="t"
    break;
  fi
done < "$PART_LIST"

#if not found
if [ "$FOUND""x" == "f""x" ];then
  echo "Your part is not supported."
  exit
fi

setpart()
{
	PART_FAMILY=$1
  if [ -f ./CH32V_firmware_library/Peripheral/inc/$PART_FAMILY"0x.h" ]; then
    sed -i "s/^TARGET = .*/TARGET = $PART/g" Makefile
    # generate the Linker script
    sed "s/FLASH_SIZE/$FLASHSIZE/g" Link.ld.template.$PART_FAMILY > CH32V_firmware_library/Ld/Link.ld
    sed -i "s/RAM_SIZE/$RAMSIZE/g" CH32V_firmware_library/Ld/Link.ld
    sed -i "s/^CH32V_firmware_library\/Startup\/startup.*/CH32V_firmware_library\/Startup\/$STARTUP_ASM/g" Makefile
  else
    echo "Not $PART_FAMILY project, can not set part to $PART"
    exit
  fi
}

if [[ $PART = ch32v0* ]]; then
	setpart ch32v0
fi

if [[ $PART = ch32v1* ]]; then
	setpart ch32v1
fi

if [[ $PART = ch32v2* ]]; then
	setpart ch32v2
  if [ $STARTUP_ASM == "startup_ch32v20x_D8.S" ]; then
    sed -i "s/^TARGET_DEFS =.*/TARGET_DEFS = -DCH32V20x_D8/g" Makefile
  elif [ $STARTUP_ASM == "startup_ch32v20x_D8W.S" ]; then
    sed -i "s/^TARGET_DEFS =.*/TARGET_DEFS = -DCH32V20x_D8W/g" Makefile
  else
    sed -i "s/^TARGET_DEFS =.*/TARGET_DEFS = /g" Makefile
  fi
fi

if [[ $PART = ch32v3* ]]; then
	setpart ch32v3
fi


