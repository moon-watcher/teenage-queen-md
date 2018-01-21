*******************************************************************************
* FILE		vdp.asm
* DESCRIPTION:	Gestion du VDP
*******************************************************************************

*******************************************************************************
* MACRO         SetVdpRegister REGISTER,VALUE
* DESCRIPTION:  Puts a value into one of the Genesis's VDP registers.
*               Keeps a local copy in the VDP_SHADOW array - This macro
*               only works for CONSTANTS. Use SetVdpRegisterCode for
*               registers or variables.
* PARAMETERS:   VDP Register #,
*               Value to place into the register
*******************************************************************************
VDP_SetRegister	macro
	move.w  #$8000|(\1<<8)|\2,VDP_CTRL	; check out the SEGA manual
	endm

*******************************************************************************
* MACRO         SetVdpRegisterCode  REGISTER,VALUE
* DESCRIPTION:  Same as SetVdpRegister, but works with registers instead
*               of constants for the value. Will generate slightly more code.
* PARAMETERS:   Register #
*               CPU register containing the value to place into the register
*******************************************************************************
VDP_SetRegisterCode	macro
	and.w	#$00ff,\2		; Mask off high part
	or.w	#$8000|(\1<<8),\2
	move.w	\2,VDP_CTRL
	endm

*******************************************************************************
* MACRO:	VDP_SetPlaneA
* DESCRIPTION:	Attribue l'adresse de la table Plane A
* PARAMETERS:	adresse
*******************************************************************************
VDP_SetPlaneA	macro
	VDP_SetRegister 2,((\1>>10)&$38)
	endm

*******************************************************************************
* MACRO:	VDP_SetSprite
* DESCRIPTION:	
* PARAMETERS:	adresse
*******************************************************************************
VDP_SetSprite	macro
	VDP_SetRegister	5,((\1>>9)&$7f)
	endm

*******************************************************************************
* MACRO:	VDP_SetPlaneB
* DESCRIPTION:	Attribue l'adresse de la table Plane B
* PARAMETERS:	adresse
*******************************************************************************
VDP_SetPlaneB	macro
	VDP_SetRegister	4,((\1>>13)&$7)
	endm

*******************************************************************************
* MACRO:	VDP_SetSpriteTable
* DESCRIPTION:	Attribue l'adresse de la table des sprites
* PARAMETERS:	adresse
*******************************************************************************
VDP_SetSpriteTable	macro
	VDP_SetRegister 5,((\1>>9)&$7f)
	endm

*******************************************************************************
* MACRO:	VDP_SetBGColor
* DESCRIPTION:	Défini la couleur de fond de l'overscan
* PARAMETERS:	\1 Numéro de palette
*		\2 Index de la couleur dans la palette
*******************************************************************************
VDP_SetBGColor	macro
	VDP_SetRegister	7,(((\1&$3)<<4)|(\2&$f))
	endm

*******************************************************************************
* MACRO:	VDP_HScrollTable
* DESCRIPTION:	Attribue l'adresse de la table de scroll H
* PARAMETERS:	adresse
*******************************************************************************
VDP_SetHScroll	macro
	VDP_SetRegister 13,((\1>>10)&$3f)
	endm


*******************************************************************************
* MACRO:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
VDP_SetCRAMReadAddr macro
	move.l	#$00000000|((\1&$3fff)<<16)|((\1>>14)&3)|$20,\2
	endm

*******************************************************************************
* MACRO:	VDP_SetVRAMWriteAddr(Adresse,Destination)
* DESCRIPTION:	Sets up the VDP for vram Write, calcs an address for
*		the VRAM write.
* PARAMETERS:	address of VRAM,
*		Where to store the result - long! (will typically be VCTRL)
*******************************************************************************
VDP_SetVRAMWriteAddr	macro
	move.l	#$40000000|((\1&$3fff)<<16)|((\1>>14)&3),\2
	endm

*******************************************************************************
* MACRO:	VDP_SetVRAMWriteAddrMode(Adresse,Destination)
* DESCRIPTION:	Sets up the VDP for vram Write, calcs an address for
*		the VRAM write.
* PARAMETERS:	\1 address of VRAM,
*		\2 Where to store the result - long! (will typically be VCTRL)
*		\3 mode to or
*******************************************************************************
VDP_SetVRAMWriteAddrFlag macro
	move.l	#$40000000|((\1&$3fff)<<16)|((\1>>14)&3)|\3,\2
	endm

*******************************************************************************
* FUNCTION:	VDP_SetVRAMWriteAddrFct	
* DESCRIPTION:	
* PARAMETERS:	d0: Adresse VRAM ou écrire
* TRASHED:	d0,d1
*******************************************************************************
VDP_SetVRAMWriteAddrFct:
	movem.l	d0-d1,-(sp)

	move.l	d0,d1
	andi.w	#$3fff,d1
	bset	#14,d1
	swap	d1
	clr.w	d1
	lsr.l	#8,d0
	lsr.l	#6,d0
	or.b	d0,d1
	move.l	d1,VDP_CTRL

	movem.l	(sp)+,d0-d1
	rts

****************************************************************************
* MACRO:	VDP_SetCRAMWriteAddr
* DESCRIPTION:	Sets up the VDP for CRAM Write, sets address
* PARAMETERS:	address of VRAM
*		Where to store the result - long! (will typically be VCTRL)
****************************************************************************
VDP_SetCRAMWriteAddr macro
	move.l	#$C0000000|((\1&$3fff)<<16)|((\1>>14)&3),\2
	endm

*******************************************************************************
* FUNCTION	VDP_SetCRAMWriteAddr
* DESCRIPTION:	Set a CRAM entry color
* PARAMETERS:	d0: Address in CRAM exprimed in Word ($0,2$,$4)
* TRASHED:	d5,d6
*******************************************************************************
VDP_SetCRAMWriteAddrFct:
	move.l	d0,d6
	andi.w	#$3fff,d6
	or.w	#$c000,d6
	swap	d6
	clr.w	d6
	lsr.l	#$8,d0
	lsr.l	#$6,d0
	or.b	d0,d6
	move.l	d6,VDP_CTRL
	rts

*******************************************************************************
* MACRO:	VDP_DMA_MEM2VRAM
* DESCRIPTION:	Réalise un transfère DMA copy depuis le 68k->VDP
* PARAMETERS:	\1: adresse source
*		\2: adresse de destination
*		\3: longueur en bytes
*******************************************************************************
VDP_DMA_MEM2VRAM macro
	VDP_SetRegister	$13,((\3>>1)&$ff)	; set length
	VDP_SetRegister	$14,((\3>>9)&$ff)

	VDP_SetRegister	$15,((\1>>1)&$ff)	; set source
	VDP_SetRegister	$16,((\1>>9)&$ff)
	VDP_SetRegister	$17,((\1>>17)&$7f)

	VDP_SetVRAMWriteAddrFlag \2,VDP_CTRL,$80
	endm

*******************************************************************************
* FUNCTION	VDP_DMA_MEM2VRAMFct
* DESCRIPTION:	Réalise un transfère DMA Copy depuis le 68k->VDP
* PARAMETERS:	d0: source addresse (en rom habituellement)
*		d1: adresse de destination (en vram)
*		d2: taille en word
* TRASHED:	d3
*******************************************************************************
VDP_DMA_MEM2VRAMFct:
	movem.l	d1-d3/a5,-(sp)

	lea.l	VDP_CTRL,a5		
	move.w	#$9300,d3		; low lenght reg 13 D2 : length
	move.b	d2,d3
	move.w	d3,(a5)

	lsr.w	#8,d2			; high lenght reg 14
	ori.w	#$9400,d2
	move.w	d2,(a5)

	lsr.l	#1,d0			; low source d0 source
	move.w	#$9500,d3
	move.b	d0,d3
	move.w	d3,(a5)
	
	lsr.l	#8,d0			; mid source
	move.w	#$9600,d3
	move.b	d0,d3
	move.w	d3,(a5)

	lsr.l	#8,d0			; high source
	move.w	#$9700,d3
	move.b	d0,d3
	andi.b	#$7f,d3
	move.w	d3,(a5)
	
	move.l	d1,d3			; d1 destination
	andi.w	#$3fff,d3
	bset	#14,d3
	swap.w	d3
	clr.w	d3
	lsr.l	#8,d1
	lsr.l	#6,d1
	or.b	d1,d3
	ori.b	#$80,d3
	move.l	d3,VDP_CTRL

	movem.l	(sp)+,d1-d3/a5

	rts

*******************************************************************************
* MACRO:	VDP_WaitVSync
* DESCRIPTION:	Wait for the VBlank (macro)
* PARAMETERS:	d# register for being use
* TRASHED:	d#
*******************************************************************************
VDP_WaitVSync	macro
	move.l	MD_VBlank_Cnt,\1
@vloop\@
	cmp.l	MD_VBlank_Cnt,\1
	beq	@vloop\@
	endm

*******************************************************************************
* MACRO:	VDP_WaitNVSync
* DESCRIPTION:	Wait for the VBlank (macro)
* PARAMETERS:	Nombre de Vsync a attendre
*		d# register for being use
*******************************************************************************
VDP_WaitNVSync	macro
	move.l	MD_VBlank_Cnt,\2
	addq.l	\1,\2
@vloop\@
	cmp.l	MD_VBlank_Cnt,\2
	ble	@vloop\@
	endm

*******************************************************************************
* FUNCTION:	VDP_WaitVSyncFct
* DESCRIPTION:	Fonction d'attente de VBlank
* PARAMETERS:	\
* TRASHED:	d7
*******************************************************************************
VDP_WaitVSyncFct:
	VDP_WaitVSync d7
	rts

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
VDP_WaitDMA:
	lea	VDP_CTRL,a6
0:	move.b	(a6),d0
	btst	#1,d0
	beq	0
	rts

