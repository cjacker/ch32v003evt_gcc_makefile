# ch32v003evt with gcc and makefile support

This is pre-converted ch32v003 firmware library with gcc and makefile support from WCH official CH32V003EVT.ZIP. 

It is converted by '[ch32v_evt_makefile_gcc_project_template](https://github.com/cjacker/ch32v_evt_makefile_gcc_project_template)'

This firmware library support below parts from WCH:

- ch32v003j4m6
- ch32v003a4m6
- ch32v003f4u6
- ch32v003f4p6

The default part is set to 'ch32v003f4u6', you can change it with `./setpart.sh <part>`. the corresponding settings such flash and ram size will update automatically from the template. Since up to now, all known ch32v003 models had the same resources (16k flash, 2k ram), it only affect target name in Makefile. For new models in future, it can be added to `ch32v-parts-list.txt`.

All examples shipped in original EVT package provided in 'Examples' dir.

The default 'User' codes is 'GPIO_Toggle' example, the default system frequency is set to 'SYSCLK_FREQ_48MHZ_HSI' in 'User/system_ch32v00x.c'. 

To build the project, type `make`.

**NOTE:** ch32v003 is rv32ec, do not use riscv-gcc v12.0 and above now due to the changes of riscv `-march` of gcc.

**NOTE:** the default demo codes will toggle PD6 since [nanoCH32V003](https://github.com/wuxx/nanoCH32V003) board from muselab has the led connect to PD6, if your board is different, you need modify main.c in 'User' dir.
