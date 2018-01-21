*******************************************************************************
* FILE:		Gestion du chip FM
* DESCRIPTION:	
*******************************************************************************

*******************************************************************************
* Memory Map
*******************************************************************************
FM_ADDRESS1	equ	$A04000
FM_DATA1	equ	$A04001
FM_ADDRESS2	equ	$A04002
FM_DATA2	equ	$A04003

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
DAC_Init:
	Z80_GetBus

	move.b	#$b4,FM_ADDRESS2		; Stereo ON
	bsr	FM_WaitBusy
	move.b	#$C0,FM_DATA2

	move.b	#$2B,FM_ADDRESS1
	bsr	FM_WaitBusy
	move.b	#$80,FM_DATA1			; init du DAC

	bsr	DAC_InitWrite

	Z80_ReleaseBus

	rts

*******************************************************************************
* FUNCTION:	DAC_Disable
* DESCRIPTION:	Désactive le DAC
* PARAMETERS:	
*******************************************************************************
DAC_Disable
	Z80_GetBus

	move.b	#$2B,FM_ADDRESS1
	bsr	FM_WaitBusy
	move.b	#$80,FM_DATA1			; init du DAC

	Z80_ReleaseBus

	rts

*******************************************************************************
* FUNCTION:	DAC_InitWrite
* DESCRIPTION:	Initialise le write dans le DAC
* PARAMETERS:	
*******************************************************************************
DAC_InitWrite:
	move.b	#$2A,FM_ADDRESS1	
	bsr	FM_WaitBusy
	rts

*******************************************************************************
* MACRO:	DAC_Write
* DESCRIPTION:	Ecrit un byte dans le DAC
* PARAMETERS:	\1 valeur ou registre
*******************************************************************************
DAC_Write	macro

	Z80_GetBus

	move.b	\1,FM_DATA1
	bsr	FM_WaitBusy

	Z80_ReleaseBus

	endm
	
*******************************************************************************
* FUNCTION:	FM_WaitBusy
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
FM_WaitBusy:
	movem.l	d0,-(sp)
	move.b	FM_ADDRESS1,d0
	btst	#7,d0
	bne	FM_WaitBusy	
	movem.l	(sp)+,d0
	rts

