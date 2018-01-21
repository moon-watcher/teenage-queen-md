*******************************************************************************
* FILE:		md.asm	
* DESCRIPTION:	
*******************************************************************************

*******************************************************************************
* Includes
*******************************************************************************
	include lib/startup.asm
	include lib/68k.asm
	include lib/vdp.asm
	include lib/debug.asm
	include lib/lz77.asm
	include lib/nemesis.asm
	include lib/enigma.asm
	include lib/pal.asm
	include lib/input.asm
	include lib/z80.asm
	include lib/fm.asm
	include lib/checksum.asm

*******************************************************************************
	section Vars
*******************************************************************************

MD_Vars_Begin

MD_VBlank_Cnt		ds.l	1		; compteur de vblank
MD_VBlank_Handler	ds.l	1		; *fct a la vblank
MD_HBlank_Handler	ds.l	1		; *fct a la hblank
MD_VRAMIndex		ds.w	1		; index dans la vram

MD_MemPalette		ds.w	64

MD_Input1		ds.b	1
MD_Input1Pressed	ds.b	1		; pressed buffer
MD_Input2		ds.b	1
MD_Input2Pressed	ds.b	1
MD_Input3		ds.b	1
MD_Input3Pressed	ds.b	1
MD_Input4		ds.b	1
MD_Input4Pressed	ds.b	1

MD_OAM			ds.b	8*80
MD_OAMIndex		ds.b	1		; index dans l'oam

LZ77_Buf		ds.b	4096
LZ77_Out		ds.w	1

MD_Vars_End

*******************************************************************************
	section M68Kcode
*******************************************************************************
VDP_DATA	equ	$c00000
VDP_CTRL	equ	$c00004
HV_COUNTER	equ	$c0000e

*******************************************************************************
* INT
*******************************************************************************
Interrupt:
	rte

*******************************************************************************
* Interruption: HBLANK
*******************************************************************************
HBL:
	rte

*******************************************************************************
*  Interruption: Dummy handler
*******************************************************************************
Dummy_HBlank:
	rts

*******************************************************************************
*  Interruption: VBLANK
*******************************************************************************
VBL:
	68K_DisableINT
	movem.l	d0-d7/a0-a6,-(a7)
	PAD3_UpdatedFlags
	addq.l	#1,MD_VBlank_Cnt
	move.l	MD_VBlank_Handler,a0
	jsr	(a0)
	PAD3_Read1
	movem.l	(a7)+,d0-d7/a0-a6
	68K_EnableINT
	rte

*******************************************************************************
*  Interruption: Dummy handler
*******************************************************************************
Dummy_VBlank:
	rts

*******************************************************************************
* MACRO		68K_InstallVBlankHandler	
* DESCRIPTION:	\1: Adresse de la fonction a instalé
* PARAMETERS:	
*******************************************************************************
MD_InstallVBlankHandler macro
	68K_DisableINT
	move.l	\1,MD_VBlank_Handler
	68K_EnableINT
	endm

*******************************************************************************
* MACRO:	MD_IncrementVRAMIndex
* DESCRIPTION:	met a jour une variable qui contient l'index en vram
* PARAMETERS:	\1: longueur en bytes ajoutée
*******************************************************************************
MD_IncrementVRAMIndex	macro
	add.w	\1,MD_VRAMIndex
	and.w	#$3fff,MD_VRAMIndex
	endm

*******************************************************************************
* MACRO:	MD_ResetVRAMIndex
* DESCRIPTION:	initialise l'index en vram
* PARAMETERS:	\
*******************************************************************************
MD_ResetVRAMIndex	macro
	move.w	#32,MD_VRAMIndex		; n'écrit pas sur le tile 0
	clr.b	MD_OAMIndex
	endm

MD_Add2VRAMIndex	macro
	add	\1,MD_VRAMIndex
	endm

*******************************************************************************
* FUNCTION:	MD_ClearOAM
* DESCRIPTION:	efface le buffer OAM
* PARAMETERS:	
*******************************************************************************
MD_ClearOAM
	movem.l	d0/a0,-(sp)
	lea	MD_OAM,a0
	clr.l	d0
	move.b	#79,d0
@clearloop
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d0,@clearloop

	movem.l	(sp)+,d0/a0
	rts

*******************************************************************************
* FUNCTION:	MD_Init
* DESCRIPTION:	Initialisation de toutes les fonctions
* PARAMETERS:	
*******************************************************************************
MD_Init:
	MD_InstallVBlankHandler #Dummy_VBlank
	MD_ResetVRAMIndex
	bsr	PAD3_Init
	rts

*******************************************************************************
* MACRO:	MD_LoadVRAM
* DESCRIPTION:	
* PARAMETERS:	\1 adresse source
*		\2 taille
* TRASHED:	d0
*******************************************************************************
MD_LoadVRAMW	macro
	lea	\1,a6
	clr.l	d0
	clr.l	d1
	move.w	MD_VRAMIndex,d0
	bsr	VDP_SetVRAMWriteAddrFct
	move.l	#((\2)>>1),d0	
@load\@
	move.w	(a6)+,VDP_DATA
	dbf	d0,@load\@
	MD_Add2VRAMIndex #\2
	endm

*******************************************************************************
* MACRO:	MD_LoadVRAMReg
* DESCRIPTION:	
* PARAMETERS:	d0 adresse
*		d1 taille en bytes
*******************************************************************************
MD_LoadVRAMWReg	macro
	movea.l	\1,a6
	clr.l	d2
	move.l	d1,d2
	clr.l	d0
	move.w	MD_VRAMIndex,d0
	bsr	VDP_SetVRAMWriteAddrFct
	lsr.l	#1,\2
@load\@
	move.w	(a6)+,VDP_DATA
	dbf	\2,@load\@

	add.w	MD_VRAMIndex,d2
	move.w	d2,MD_VRAMIndex
	
	endm

