######################################
# target
######################################
TARGET = ch32v003f4u6


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization for size
OPT = -Os


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

######################################
# source
######################################
# C sources
C_SOURCES = \
CH32V_firmware_library/Debug/debug.c \
CH32V_firmware_library/Core/core_riscv.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_iwdg.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_misc.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_rcc.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_dbgmcu.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_tim.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_dma.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_gpio.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_wwdg.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_usart.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_flash.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_exti.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_pwr.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_opa.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_i2c.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_adc.c \
CH32V_firmware_library/Peripheral/src/ch32v00x_spi.c \
User/system_ch32v00x.c \
User/main.c \
User/ch32v00x_it.c \


# ASM sources
ASM_SOURCES =  \
CH32V_firmware_library/Startup/startup_ch32v00x.S

#######################################
# binaries
#######################################
PREFIX = riscv-none-embed-

CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# cpu
CPU = -march=rv32ec -mabi=ilp32e -msmall-data-limit=8 

# For gcc v12 and above
# CPU = -march=rv32imac_zicsr -mabi=ilp32 -msmall-data-limit=8

# mcu
MCU = $(CPU) $(FPU) $(FLOAT-ABI)

# AS includes
AS_INCLUDES = 

# C includes
C_INCLUDES =  \
-ICH32V_firmware_library/Peripheral/inc \
-ICH32V_firmware_library/Debug \
-ICH32V_firmware_library/Core \
-IUser

# compile gcc flags
ASFLAGS = $(MCU) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = CH32V_firmware_library/Ld/Link.ld 

# libraries
LIBS = -lc -lm -lnosys
LIBDIR = 
LDFLAGS = $(MCU) -mno-save-restore -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wunused -Wuninitialized -T $(LDSCRIPT) -nostartfiles -Xlinker --gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map --specs=nano.specs $(LIBS)

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@
#$(LUAOBJECTS) $(OBJECTS)
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

#######################################
# Program
#######################################
program: $(BUILD_DIR)/$(TARGET).elf 
	sudo wch-openocd -f /usr/share/wch-openocd/openocd/scripts/interface/wch-riscv.cfg -c 'init; halt; program $(BUILD_DIR)/$(TARGET).elf verify; reset; wlink_reset_resume; exit;'

isp: $(BUILD_DIR)/$(TARGET).bin
	wchisp flash $(BUILD_DIR)/$(TARGET).bin

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)
  
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
