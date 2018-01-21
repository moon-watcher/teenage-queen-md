*******************************************************************************
* FILE:		Z80
* DESCRIPTION:	utilisation du Z80
* PARAMETERS:	
*******************************************************************************

*******************************************************************************
* Memory MAP
*******************************************************************************
Z80_BUSREQ	equ	$a11100
Z80_RESET	equ	$a11200

*******************************************************************************
* 
*******************************************************************************
Z80_GetBus	macro
	Z80_BUSREQ_ON
	Z80_RESET_OFF
	endm

Z80_ReleaseBus	macro
	Z80_BUSREQ_OFF
	endm

*******************************************************************************
* Macro utiles
*******************************************************************************
Z80_BUSREQ_ON	macro
	move.w	#$100,Z80_BUSREQ
	endm

Z80_BUSREQ_OFF	macro
	move.w	#$0,Z80_BUSREQ
	endm

Z80_RESET_ON	macro
	move.w	#$0,Z80_RESET
	endm

Z80_RESET_OFF	macro
	move.w	#$100,Z80_RESET
	endm

*******************************************************************************
* FUNCTION:	Z80_WaitBus
* DESCRIPTION:	Vérifie que le 68k a accès a la mémoire audio ???????????
* PARAMETERS:	
*******************************************************************************
Z80_WaitBus:
	movem.l	d0,-(sp)
@wait
	move.w	Z80_BUSREQ,d0
	btst	#8,d0
	bne.s	@wait	
	rts

	movem.l	(sp)+,d0


*******************************************************************************
* FUNCTION:	Load Program
* DESCRIPTION:	
* PARAMETERS:	d0 taille du driver
*		a0 addresse du driver
* TRASHED:	a1
*******************************************************************************
Z80_Load:
	Z80_BUSREQ_ON
	Z80_RESET_OFF
	lea	$a00000,a1
	subq	#1,d0
Z80loop:
	move.b	(a0)+,(a1)+
	dbra	d0,Z80loop
	Z80_RESET_ON
	Z80_BUSREQ_OFF
	Z80_RESET_OFF
		
	rts


