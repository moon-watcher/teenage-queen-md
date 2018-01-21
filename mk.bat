snasm68kdb /l -o v+ -o c+ -o m+ cart.asm,tqueen,tqueen,tqueen
snasm68kdb /p -o v+ -o c+ -o m+ main.lnk,tqueen.bin
@echo off
ucon64 -pad -gen -chk tqueen.bin>ucon.txt
