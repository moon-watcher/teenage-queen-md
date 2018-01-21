*******************************************************************************
* TEENAGE QUEEN MD *
********************
* Md	port		:	Pascal
* Atari reverengineering:	Foxy
*******************************************************************************
	org 0
*******************************************************************************
* Définition des variables
*******************************************************************************
	section Vars
Game_Vars_Start
Game_State	ds.b	1
txt		ds.b	8
score		ds.l	1

Game_Vars_End

*******************************************************************************
	section M68Kcode
*******************************************************************************
DEBUG		equ	0
SEGACD		equ	0
DEMO		equ	0
*******************************************************************************
* include du code
*******************************************************************************
Rom_Begin:
	include header.asm
	include lib/md.asm
	include sgccdac.asm
	include spklogo.asm
	include game.asm

*******************************************************************************
* Define et tableaux
*******************************************************************************
STATE_SPOUTNICKLOGO	equ	0
STATE_GAME		equ	1

State_JumpTable	dc.l	Game_SpoutnickLogo,Game_TeenageQueen

*******************************************************************************
* Init du jeu
*******************************************************************************
_main:
	;jsr	Checksum_Validate
	jsr	MD_Init				; Initialise la MD_Lib
	jsr	SGCCDAC_Init
	move.w	#$2300,sr
	clr.b	Game_State
	move.b	#STATE_SPOUTNICKLOGO,Game_State
	
*******************************************************************************
* Boucle principale qui redirige sur d'autres fonctions
*******************************************************************************

Game_MainLoop:
	lea	State_JumpTable,a0		; Lance la jump table
	clr.w	d0
	move.b	Game_State,d0
	lsl.l	#2,d0
	move.l	0(a0,d0.w),a0
	jmp	(a0)
	bra	Game_MainLoop

*******************************************************************************
* Data
*******************************************************************************
	include sound.asm
	include data.asm
Rom_End:
	end

