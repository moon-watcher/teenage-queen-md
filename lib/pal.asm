*******************************************************************************
* FILE:		pal.asm
* DESCRIPTION:	Effectue les opérations sur la palette
*******************************************************************************

*******************************************************************************
* MACRO		PAL_ClearAll
* DESCRIPTION:	Efface toutes les palettes
* PARAMETERS:	\1: registre a trashé
*******************************************************************************
PAL_ClearAll macro
	Pal_Clear2Color 0,0,#63,\1
	endm

*******************************************************************************
* MACRO		PAL_Clear
* DESCRIPTION:	Efface toutes les palettes
* PARAMETERS:	\1: numéro de palette
*		\2: d# a trashé
*******************************************************************************
PAL_Clear macro
	PAL_Clear2Color \1,0,#64,\2
	endm

*******************************************************************************
* MACRO		PAL_Clear#
* DESCRIPTION:	Efface la palette indexée
* PARAMETERS:	\1: d# a trashé
*******************************************************************************
PAL_Clear0 macro
	PAL_Clear2Color 0,0,#15,\1
	endm

PAL_Clear1 macro
	PAL_Clear2Color 1,0,#15,\1
	endm

PAL_Clear2 macro
	PAL_Clear2Color 2,0,#15,\1
	endm

PAL_Clear3 macro
	PAL_Clear2Color 3,0,#15,\1
	endm

*******************************************************************************
* MACRO		PAL_Clear
* DESCRIPTION:	Efface une palette
* PARAMETERS:	\1: numéro de la palette
*		\2: couleur
*		\3: Litéral # combien de couleur a effacer
*		\4: d# a trashé
*******************************************************************************
PAL_Clear2Color macro
	VDP_SetCRAMWriteAddr (\1<<4),VDP_CTRL	; Set CRAM ADDRESS
	moveq.l	\3,\4				; set color counter
@clpal1:
	move.w	\2,VDP_DATA			; efface la palette
	dbra	\4,@clpal1
	endm

*******************************************************************************
* MACRO:	PAL_Load
* DESCRIPTION:	
* PARAMETERS:	\1: numéro de la palette
*		\2: Adresse de la palette à charger
*		
*******************************************************************************
PAL_Load macro
*	VDP_SetCRAMWriteAddr (\1<<4),VDP_CTRL	; Set CRAM ADDRESS
*	moveq.l	\3,\4
*@stpal:
*	move.w	\2,VDP_DATA
*	dbra	\4,@stpal
	endm

*******************************************************************************
* MACRO:	PAL_ReadAllToRAM
* DESCRIPTION:	Lits l'ensemble de la palette en mémoire
* PARAMETERS:	\
*******************************************************************************
PAL_ReadAll2RAM macro
	VDP_SetCRAMReadAddr $0,VDP_CTRL
	lea	MD_MemPalette,a0
	moveq.l	#64,d0
@rdpal
	move.w	VDP_DATA,(a0)+
	dbra	d0,@rdpal
	endm

*******************************************************************************
* MACRO:	PAL_FadeOut	
* DESCRIPTION:	
* PARAMETERS:	\1 index de la palett
*		\2 how many color
* TRASHED:	d0,d1,d2,d3,a0
*******************************************************************************
PAL_FadeOut	macro

	PAL_ReadAll2RAM				; lit la palette en ram
	
	moveq	#7,d2				; nb de cycles (3bits)
@t
	moveq	#\2,d0
	bsr	VDP_WaitVSyncFct
	bsr	VDP_WaitVSyncFct
	bsr	VDP_WaitVSyncFct
	bsr	VDP_WaitVSyncFct

	lea	MD_MemPalette,a0
	add	#\1*16*2,a0
@bleu:
	move.w	(a0),d1
	andi.w	#$E00,d1
	beq.s	@vert
	subi.w	#$200,(a0)
@vert:
	move.w	(a0),d1
	andi.w	#$E0,d1
	beq.s	@rouge
	subi.w	#$20,(a0)
@rouge:
	move.w	(a0),d1
	andi.w	#$E,d1
	beq.s	@rien
	subi.w	#$2,(a0)
@rien:
	lea	2(a0),a0
	dbf	d0,@bleu
			
	lea	MD_MemPalette,a0		; a0 = *LogoPallette
	VDP_SetCRAMWriteAddr (\1*16*2),VDP_CTRL	; Set CRAM ADDRESS
	moveq.l	#\2,d3				; set color counter
@ldpal\@:
	move.w	(a0)+,VDP_DATA			; write logo pallette
	dbf	d3,@ldpal\@
	dbf	d2,@t

	endm

*******************************************************************************
* MACRO:	PAL_FadeIn	
* DESCRIPTION:	
* PARAMETERS:	\1 index de la palette
*		\2 how many color
* TRASHED:	d0,d1,d2,d3,a0
*******************************************************************************
PAL_FadeInAll	macro

* <TODO> Clear MD_MemPalette
	move.w	#$E00,d2
	move.w	#$E0,d3
	moveq	#$E,d4
	moveq	#7,d5				; compteur de cycle
@t
	bsr	VDP_WaitVSyncFct
	bsr	VDP_WaitVSyncFct
	bsr	VDP_WaitVSyncFct
	bsr	VDP_WaitVSyncFct
	
	move	#\2,d0				; compteur de couleur
	move.l	a0,a1				; copie a0->a1
	lea	MD_MemPalette,a2		; a2
	add	#\1*16*2,a2
@bleu
	move.w	(a1),d1
	andi.w	#$E00,d1
	cmp.w	d2,d1
	ble.s	@green
	addi.w	#$200,(a2)
@green
	move.w	(a1),d1
	andi.w	#$E0,d1
	cmp.w	d3,d1
	ble.s	@red
	addi.w	#$20,(a2)
@red
	move.w	(a1),d1
	andi.w	#$E,d1
	cmp.w	d4,d1
	ble.s	@rien
	addi.w	#$2,(a2)
@rien
	lea	2(a1),a1
	lea	2(a2),a2
	dbf	d0,@bleu

; retransfère la palette en cram
	68K_DisableINT

	lea	MD_MemPalette,a1		; a0 = *LogoPallette
	VDP_SetCRAMWriteAddr (\1*16*2),VDP_CTRL	; Set CRAM ADDRESS
	moveq.l	#\2,d0				; set color counter
@ldpal\@:
	move.w	(a1)+,VDP_DATA			; write logo pallette
	dbf	d0,@ldpal\@
	68K_EnableINT
	

	subi	#$200,d2
	subi	#$20,d3
	subi	#$2,d4

	dbf	d5,@t				; cycles



	endm
*******************************************************************************
* FUNCTION:	PAL_FadeOut0	
* DESCRIPTION:	Fait un fade out de la palette 0
* PARAMETERS:	/
* TRASHED:	d0,d1,d2,d3,a0
*******************************************************************************
PAL_FadeOut0:
	movem.l	d0-a7,-(sp)
	PAL_FadeOut	0,16
	movem.l	(sp)+,d0-a7
	rts

PAL_FadeOut1:
	movem.l	d0-a7,-(sp)
	PAL_FadeOut	16,16
	movem.l	(sp)+,d0-a7
	rts

PAL_FadeOut2:
	movem.l	d0-a7,-(sp)
	PAL_FadeOut	32,16
	movem.l	(sp)+,d0-a7
	rts

PAL_FadeOut3:
	movem.l	d0-a7,-(sp)
	PAL_FadeOut	48,16
	movem.l	(sp)+,d0-a7
	rts

PAL_FadeOut234:
	movem.l	d0-a7,-(sp)
	PAL_FadeOut	16,48
	movem.l	(sp)+,d0-a7
	rts

PAL_FadeOutCRAM:
	movem.l	d0-a7,-(sp)
	PAL_FadeOut	0,48
	movem.l	(sp)+,d0-a7
	rts

*******************************************************************************
* FUNCTION:	Pal_FadeIn0
* DESCRIPTION:	Fait un fade in de la palette 0
* PARAMETERS:	a0 Adresse de la palette
*******************************************************************************
PAL_FadeIn0:
	movem.l	d0-a7,-(sp)
	PAL_FadeInAll	0,16
	movem.l	(sp)+,d0-a7
	rts

PAL_FadeIn1:
	movem.l	d0-a7,-(sp)
	PAL_FadeInAll	1,16
	movem.l	(sp)+,d0-a7
	rts
	
PAL_FadeInCRAM:
	movem.l	d0-a7,-(sp)
	PAL_FadeInAll	0,48
	movem.l	(sp)+,d0-a7
	rts


