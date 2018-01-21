*******************************************************************************
* FILE:		input.asm
* DESCRIPTION:	Gère les inputs de la md
*******************************************************************************

*******************************************************************************
* Defines
*******************************************************************************
PORT_PAD1	equ	$A10003
PORT_PAD2	equ	$A10005
PORT_PAD3	equ	$A10007

* xxSAxxxxxxCBRLDU
PAD_UP		equ	$1
PAD_DOWN	equ	$2
PAD_LEFT	equ	$4
PAD_RIGHT	equ	$8

PAD_B		equ	$10
PAD_C		equ	$20
PAD_A		equ	$40
PAD_START	equ	$80

* for bit testing
PAD_BIT_UP	equ	$0
PAD_BIT_DOWN	equ	$1
PAD_BIT_LEFT	equ	$2
PAD_BIT_RIGHT	equ	$3
PAD_BIT_B	equ	$4
PAD_BIT_C	equ	$5
PAD_BIT_A	equ	$6
PAD_BIT_START	equ	$7

*******************************************************************************
* FUNCTION:	Initialise la lecture du pad
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
PAD3_Init:
	moveq	#$40,d0
	move.b	d0,$a10009
	move.b	d0,$a1000b
	move.b	d0,$a1000d

	clr.w	MD_Input1
	clr.w	MD_Input2
	clr.w	MD_Input3
	clr.w	MD_Input4

	rts

*******************************************************************************
* MACRO:	PAD3_Read1
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
PAD3_Read1 macro
	move.l	#PORT_PAD1,a0
	bsr	PAD3_Read
	move.b	d0,MD_Input1
	endm

*******************************************************************************
* FUNCTION:	read_pad3
* DESCRIPTION:	Lit le pad de la md
* PARAMETERS:	a0 adresse du pad
* Output:	d0 renvoit le pad lus
*******************************************************************************
PAD3_Read:
	move.b	#$40,(a0)		; Set TH 1
	nop
	nop
	move.b	(a0),d1		
	andi.b	#$3f,d1			; ?1CBRLDU
	move.b	#0,(a0)			; Set TH 0
	nop
	nop
	move.b	(a0),d0			; ?0SA00DU
	andi.b	#$30,d0
	lsl.b	#2,d0
	or.b	d1,d0
	not.b	d0			; xxSAxxxxxxCBRLDU
	rts

*******************************************************************************
* FUNCTION:	PAD3_KeyPressed
* DESCRIPTION:	
* PARAMETERS:	a0 adresse de la variable contenant l'input a testé
*		d0 keymask
* TRASHED:	d1,d2
*******************************************************************************
PAD3_KeyPressed:
	move.b	(a0)+,d1	; input
	move.b	(a0),d2		; input_pressed
	eor.b	d2,d1
	beq	@end		; si a 0 alors pas d'event

	and.b	d0,d1		; test si <>
	beq	@end

	and.b	d0,d2
	bne	@end

	moveq	#1,d0

	rts	
@end
	moveq	#0,d0
	rts

*******************************************************************************
* MACRO:	PAD3_CheckStart
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckStart macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_START,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	PAD3_CheckUp
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckUp macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_UP,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	PAD3_CheckDown
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckDown macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_DOWN,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	PAD3_CheckLeft
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckLeft macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_LEFT,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	PAD3_CheckDown
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckRight macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_RIGHT,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	PAD3_CheckButtonA
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckA macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_A,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	PAD3_CheckButtonB
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckB macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_B,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	PAD3_CheckButtonC
* DESCRIPTION:	check if a start key was asserted
* PARAMETERS:	/
* RETURN:	d0 =1 si Start asserted sinon 0
* TRASHED:	d0
*******************************************************************************
PAD3_CheckC macro
	movem.l	d1-d2/a0,-(sp)

	move.b	#PAD_C,d0
	lea	MD_Input1,a0
	bsr	PAD3_KeyPressed

	movem.l	(sp)+,d1-d2/a0
	tst.b	d0

	endm

*******************************************************************************
* MACRO:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
PAD3_UpdatedFlags macro
	move.b	MD_Input1,MD_Input1Pressed
	move.b	MD_Input2,MD_Input2Pressed
	endm



