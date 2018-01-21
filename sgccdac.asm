*******************************************************************************
* FILE:		sgccdac.asm
* DESCRIPTION:	Driver DAC SOZOBON by Paul Lee
*******************************************************************************

*******************************************************************************
* MACRO:	PlaySound
* DESCRIPTION:	play a sample throught DAC
* PARAMETERS:	\1 name of the symbol of the sound
*******************************************************************************
PlaySound	macro
	move.l	#\1,d0
	move.l	#(\1_End-\1),d1
	bsr	SGCCDAC_Play
	nop
	endm

*******************************************************************************
* MACRO:	StopSound
* DESCRIPTION:	Stop the DAC
* PARAMETERS:	
*******************************************************************************
StopSound	macro
	bsr	SGCCDAC_Stop
	nop
	endm

*******************************************************************************
* FUNCTION:	SGCCDAC_Init
* DESCRIPTION:	
* PARAMETERS:	/
*******************************************************************************
SGCCDAC_Init:
	movem.l	d0-d1/a0,-(sp)
	lea	SGCCDAC_Driver,a0
	move.l	#(SGCCDAC_Driver_End-SGCCDAC_Driver),d0
	bsr	Z80_Load
	movem.l	(sp)+,d0-d1/a0
	rts

*******************************************************************************
* FUNCTION:	SGCCDAC_Play
* DESCRIPTION:	Play a sample using the DAC
* PARAMETERS:	d0 address of sample
*		d1 length of sample
* TRASHED:	a0
*******************************************************************************
SGCCDAC_Play
	movem.l	d0-d2/a0,-(sp)
	Z80_GetBus
	move.l	#$a00036,a0

* nb 64ko banks
	move.l	d1,d2
	lsr.l	#8,d2
	lsr.l	#8,d2
	move.b	d2,(a0)+
* Set remain
	move.l	d1,d2
	and.l	#$FFFF,d2
	move.b	d2,(a0)+
	lsr.l	#8,d2
	move.b	d2,(a0)+

* Set Enable Flag
	move.b	#1,(a0)+
	
* Store address of sample
	move.b	d0,(a0)+
	lsr.l	#8,d0
	move.b	d0,(a0)+
	lsr.l	#8,d0
	move.b	d0,(a0)+

* Store length of sample
	move.b	d1,(a0)+
	lsr.l	#8,d1
	move.b	d1,(a0)+
	lsr.l	#8,d1
	move.b	d1,(a0)+

	Z80_ReleaseBus
	movem.l	(sp)+,d0-d2/a0
	rts

*******************************************************************************
* FUNCTION:	SGCCDAC_Stop
* DESCRIPTION:	stop the sound playing
* PARAMETERS:	/
* TRASHED:	a5
*******************************************************************************
SGCCDAC_Stop
	Z80_GetBus
	move.l	#$a00036,a5
	move.b	#0,(a5)
	Z80_ReleaseBus
	rts
	
*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
SGCCDAC_Reset:
	Z80_BUSREQ_ON
	Z80_RESET_OFF
	Z80_RESET_ON
	Z80_BUSREQ_OFF
	Z80_RESET_OFF
	rts

*******************************************************************************
* Z80 Driver
*******************************************************************************
	cnop	0,2
SGCCDAC_Driver:
	incbin sgccdac.bin
SGCCDAC_Driver_End:
	


