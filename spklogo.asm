*******************************************************************************
* FILE:		SpoutnickLogo.asm	
* DESCRIPTION:	Affiche le logo Spoutnick Team
*******************************************************************************

Game_SpoutnickLogo:
	
*******************************************************************************
* Defines
*******************************************************************************
SpoutnickLogo_PlaneA	equ	$E000

*******************************************************************************
* Init du VDP
*******************************************************************************
	VDP_SetRegister	$3,$38
	VDP_SetRegister	$5,$70
	VDP_SetBGColor 0,0
	VDP_SetRegister	$c,0			; met en mode 256
	VDP_SetRegister	$f,2			; auto increment
	VDP_SetRegister	$10,0			; Map Size 32x32
	VDP_SetPlaneA	SpoutnickLogo_PlaneA	; Plane A: $E000
	VDP_SetPlaneB	SpoutnickLogo_PlaneA	
		
	VDP_SetRegister $1,$74			; Turn on the display 
						; DMA On
						; VSYNC On
	VDP_SetBGColor 0,1

*******************************************************************************
* Charge les tiles
*******************************************************************************
	68K_DisableINT
	
	VDP_SetVRAMWriteAddr	$0,VDP_CTRL
	lea	SpoutnickLogo_Chars,a0
	jsr	Nemesis_XTract
	
	VDP_DMA_MEM2VRAM SpoutnickLogo_Map,SpoutnickLogo_PlaneA,1792

	68K_EnableINT

	PAL_Clear0 d0
	lea	SpoutnickLogo_Palette,a0
	bsr	PAL_FadeIn0

* joue le son	
	PlaySound SpoutnickSound

	move.w	#175,d0
@loop:
	bsr	VDP_WaitVSyncFct
	dbf	d0,@loop

	bsr	PAL_FadeOut0			; fade out
	move.b	#STATE_GAME,Game_State
	jmp	Game_MainLoop			; retourne a la boucle main

*******************************************************************************
* charset le logo spoutnick
*******************************************************************************
	cnop	0,2
SpoutnickLogo_Chars:
	incbin	data/spklogot.nem
SpoutnickLogo_End

*******************************************************************************
* Palette pour le logo spoutnick
*******************************************************************************
	cnop	0,2
SpoutnickLogo_Palette:
	incbin	data/spklogop.bin

*******************************************************************************
* Map logo spoutnick
*******************************************************************************
	cnop	0,2
SpoutnickLogo_Map:
	incbin	data/spklogom.bin
SpoutnickLogo_Map_End

