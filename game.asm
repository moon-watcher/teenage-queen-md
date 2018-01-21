*******************************************************************************
* FILE:	
* DESCRIPTION:	
*******************************************************************************

*******************************************************************************
* 
*******************************************************************************
* 1) Call Drop fonctionne pas ???
* 2) avec start les sprites continue ??? lors du call

*******************************************************************************
* Variables
*******************************************************************************
	section Vars
Vars_Begin
	
rand_seed	ds.l	1
rand_val	ds.l	1
user_seed	ds.l	1
game_cards:	ds.b	64			; flag de distribution des crd

player_cards	ds.w	5
teen_cards	ds.w	5

loaded_cards	ds.w	10			; flag de maj des cartes en vram

num_next_pic:	ds.w	1
num_cur_pic:	ds.w	1
poker_pot:	ds.w	1
teen_pot:	ds.w	1
player_pot:	ds.w	1
flag_bluff:	ds.w	1
game_turn	ds.w	1
first_player	ds.w	1
flag_redraw_main	ds.w	1
nb_calls	ds.w	1
nb_encheres	ds.w	1
game_action	ds.w	1
teen_last_bet	ds.w	1
player_last_bet	ds.w	1
player_expected_score	ds.w	1
flag_cards_changed	ds.w	1
teen_score	ds.w	1
player_score	ds.w	1

player_drops:		ds.w	5
unused_var_player	ds.w	1
calc_cards_player	ds.w	5

unused_var_teen	ds.w	1
calc_cards_teen	ds.w	5
teen_drops	ds.w	5

cards_Index	ds.w	1			; index de la carte (0->4)
cards_VRAMAddr	ds.w	1			; addresse des 5 cartes en ram
mains_VRAMAddr	ds.w	1
femme_VRAMAddr	ds.w	1
num_VRAMAddr	ds.w	1
moins_VRAMAddr	ds.w	1
msg_VRAMAddr	ds.w	1
icones_VRAMAddr	ds.w	1
marker_VRAMAddr	ds.w	1

teen_eval_modifier	ds.b	2
nb_player_chg_cards	ds.b	2

cache_palette	ds.w	64
femme_num	ds.w	1			; numero du level

aff_message_arg0	ds.w	1		; back up des parametres
aff_message_arg2	ds.w	1
asserted_msg0		ds.w	1
asserted_msg2		ds.w	1

*EngineSpriteBuf		ds.w	4*80	; buffer des sprites numbers
*EngineSpriteIndex	ds.w	1		; index du buffers des nbrs

cards_buf		ds.w	4*80		; overlap
cards_SpriteIndex	ds.w	1

num_buf			ds.w	4*40
num_SpriteIndex		ds.w	1

msg_buf			ds.w	4*5
msg_SpriteIndex		ds.w	1

byte_7D36:	ds.b 2
byte_7D38:	ds.b 2
mouse_btn:	ds.b 2
word_7D3C:	ds.w 1

byte_7D3E:	ds.b 4
byte_7D42:	ds.b 4

word_848C:	ds.b 10

cycle_cnt	ds.b 1
cycle_frame_cnt	ds.b 1

loaded_icone	ds.w 1
icone_idx	ds.w 1
prev_icone_idx	ds.w 1
force_icone	ds.w 1

*hide_panel	ds.w 1
reload_icon	ds.w 1
reload_msg0	ds.w 1
reload_msg2	ds.w 1
msg0		ds.w 1
msg2		ds.w 1
got_1_icone	ds.w 1

tutu		ds.w 1000

marker_buf	ds.w 10				; buffer sprite

flag_aff_mains	ds.b	1
flag_aff_teen	ds.b	1

deck_num	ds.w	1

Vars_End

*******************************************************************************
* Includes
*******************************************************************************
*	include tabs.asm
*******************************************************************************
* Code 68k
*******************************************************************************
	section M68Kcode
*******************************************************************************
* Defines
*******************************************************************************
Game_PlaneA	equ	$C000
Game_PlaneB	equ	$E000
*Game_Sprite	equ	$FC00
*Game_HScroll	equ	$F000
Game_Sprite	equ	$F000
Game_HScroll	equ	$FC00

NBNumSprite	equ	15
NBCardsSprite	equ	30
NBMsgSprite	equ	5
*******************************************************************************
* Macros
*******************************************************************************

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
LoadAllPalette:

	68K_DisableINT

	lea Mains_Pal,a3
	lea (cache_palette),a4
	lea (cache_palette+32),a6

*	move.w	#$0ee,cache_palette
	; copie la palette des icones
	lea	(cache_palette+64),a0
	lea	(cache_palette+96),a2
	lea	Icone_Pal,a1
	move.w	#15,d3
cpy_ico_pal1
	move.w	(a1),(a0)+
	move.w	(a1)+,(a2)+

	move.w	(a3),(a4)+
	move.w	(a3)+,(a6)+

	dbf	d3,cpy_ico_pal1

	68K_EnableINT
	rts
*******************************************************************************
* MACRO:	
* DESCRIPTION:	
* PARAMETERS:	\1: addresse a jumper si pas bon
*******************************************************************************
CheckPlayerInput	macro
	PAD3_CheckStart
	beq	pas_start\@

* affiche la femme
 	MD_InstallVBlankHandler #Dummy_VBlank
	
	bsr	PAL_FadeOutCRAM
	
	VDP_SetRegister 1,$34		; désactive display
	ClearMap Game_PlaneA
	ClearMap Game_PlaneB

	jsr	ClearAllSprites
	
	move.w	(num_cur_pic).l,-(sp)
	jsr	load_picture_full
	addq.w	#2,sp
	
	VDP_SetPlaneA Game_PlaneB

	VDP_SetRegister 1,$74
	lea	cache_palette,a0
	bsr	PAL_FadeInCRAM

loopfullscreen\@
	PAD3_CheckStart
	bne	outloopfullscreen\@
	jsr	VDP_WaitVSyncFct
	
	bra	loopfullscreen\@
	
outloopfullscreen\@
*	moveq	#1,d5
*	move.w	d5,hide_panel
	
*	bra	flipflop\@

aff_all\@
	bsr	PAL_FadeOutCRAM
	PAL_Clear3	d5
	
	move.w	#1,flag_redraw_main
	
	move.w	(num_cur_pic).l,-(sp)
	jsr	load_picture
	addq.w	#2,sp

	move.w	loaded_icone,reload_icon
	move.w	reload_msg0,msg0
	move.w	reload_msg2,msg2

	jsr	aff_pots
	jsr	aff_jeu_player2
	
	jsr	aff_allsprites
	VDP_DMA_MEM2VRAM	MD_OAM,Game_Sprite,80*4
	
	68K_DisableINT
	move.w	reload_icon,-(sp)
	jsr	aff_icone
	addq	#2,sp
	
	move.w	msg2,-(sp)			; changemmmmmmeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeent
	move.w	msg0,-(sp)
	jsr	aff_message
	addq.w	#4,sp

	68K_EnableINT	

	lea	cache_palette,a0
	bsr	PAL_FadeInCRAM	

	MD_InstallVBlankHandler #it_vbl	

flipflop\@
	nop

pas_start\@

* si je suis en mode femme fullscreen => pas d'inputs
*	move.w	hide_panel,d6
*	tst.w	d6
*	bne	\1

* Evalue les inputs
	PAD3_CheckA
	bne.s checkbtnok\@

	PAD3_CheckC
	beq \1

checkbtnok\@

	endm

*******************************************************************************
* MACRO:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
CheckPlayerValidation	macro

	PAD3_CheckB
	
	endm

*******************************************************************************
* MACRO:	PutSprite
* DESCRIPTION:	Affiche un sprite
* PARAMETERS:	\1: Y
*		\2: X
*		\3: VRAM_Addr
*		\4: Taille
*		\5: Flag priorite ??
*******************************************************************************
PutSprite	macro

	lea	MD_OAM,a2
	clr.l	d5
	clr.l	d4
	move.b	MD_OAMIndex,d5
	move.b	d5,d4
	lsl.w	#3,d5
	lea.l	(a2,d5.w),a2

	; Y
	move.w	\1,d5
	add.w	#16,d5				; différence Y MD & ST
	addi	#128,d5
	move.w	d5,(a2)+
	
	; Taille + Link
	add.b	#1,d4
	move.b	d4,MD_OAMIndex
	move.w	d4,d5
	or.w	#\4,d5
	move.w	d5,(a2)+

	; Sprite pattern
	move.w	\3,d5
	lsr.w	#5,d5
	or.w	#\5,d5
	move.w	d5,(a2)+

	; X
	move.w	\2,d5
	addi	#128,d5
	move.w	d5,(a2)+

	endm

*******************************************************************************
* MACRO:	PutSprite
* DESCRIPTION:	Affiche un sprite
* PARAMETERS:	\1: Y
*		\2: X
*		\3: VRAM_Addr
*		\4: Taille
*		\5: Flag priorite ??
*		\6: buffer
*		\7: index
*******************************************************************************
EnginePutSprite	macro

	lea	\6,a2				; numbuf
	clr.l	d5
	clr.l	d4
	move.b	\7,d5				; index
	move.b	d5,d4				
	lsl.w	#3,d5
	lea.l	(a2,d5.w),a2			; a2=adresse du index

	; Y
	move.w	\1,d5
	add.w	#16,d5				; différence Y MD & ST
	addi	#128,d5
	move.w	d5,(a2)+
	
	; Taille + Link
	add.b	#1,d4			; index sprite ++
	move.b	d4,\7			
	clr.w	d5			; d5=0
	or.w	#\4,d5			
	move.w	d5,(a2)+

	; Sprite pattern
	clr.l	d5
	move.w	\3,d5
	lsr.w	#5,d5

	or.w	#\5,d5
	move.w	d5,(a2)+

	; X
	move.w	\2,d5
	addi	#128,d5
	move.w	d5,(a2)+

	endm

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	\1 Nom du buffer
*		\2 Index du buffer
*		\3 le max
*******************************************************************************
ClearSpriteBuf	macro
	clr.b	\2
	lea.l	\1,a0
	move.w	#(\3-1),d0

clear_sr_buf\@:
	move.w	#$0,(a0)+
	move.w	#$0,(a0)+
	move.w	#$0,(a0)+
	move.w	#$0,(a0)+
	dbf	d0,clear_sr_buf\@
	endm

ClearMarkerBuf:
	ClearSpriteBuf	marker_buf,num_SpriteIndex,2

ClearNumBuf:
	ClearSpriteBuf	num_buf,num_SpriteIndex,NBNumSprite
	rts

ClearCardsBuf:
	ClearSpriteBuf	cards_buf,cards_SpriteIndex,NBCardsSprite
	rts

ClearMsgBuf:
	ClearSpriteBuf	msg_buf,msg_SpriteIndex,NBMsgSprite
	rts

ClearAllSprites
	jsr	ClearMsgBuf
	jsr	ClearNumBuf
	jsr	ClearCardsBuf
	jsr	ClearMarkerBuf
	rts

*******************************************************************************
* MACRO:	ClearMap
* DESCRIPTION:	
* PARAMETERS:	\1 Adresse en vram de la table
*******************************************************************************
ClearMap	macro
	VDP_SetVRAMWriteAddr \1,VDP_CTRL
	move.l	#((64*32*2)-1),d0
@clear_map\@
	move.w	#0,VDP_DATA
	dbf	d0,@clear_map\@
	endm

*******************************************************************************
* MACRO:	check input pour les icones
* DESCRIPTION:	
* PARAMETERS:	\1 nombre d'icones
*******************************************************************************
PlayerCheckInput	macro
	
*	move.w	hide_panel,d3
*	tst.w	d3
*	bne	no_input\@
	
	move.w	icone_idx,prev_icone_idx

	move.b	MD_Input1,d3
	tst.b	d3
	beq.s	no_input\@

	PAD3_CheckLeft
	beq.s	test_right\@

	cmpi.w	#0,icone_idx
	ble	test_right\@
	subi.w	#1,icone_idx

	clr.w	-(sp)
	move.w	#13,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

	bra	no_input\@

test_right\@:
	PAD3_CheckRight
	beq.s	no_input\@

	cmpi.w	#(\1-1),icone_idx
	bge.w	no_input\@
	addq.w	#1,icone_idx

	clr.w	-(sp)
	move.w	#13,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

no_input\@:
	endm

*******************************************************************************
* MACRO:	
* DESCRIPTION:	appelé a chaque VSYNC
* PARAMETERS:	
*******************************************************************************
Cycle_CouleurSelection	macro

	clr.l	d4
	move.b	cycle_frame_cnt,d4
	and.b	#7,d4
	bne.s	cyc_reset\@
	
	VDP_SetCRAMWriteAddr 74,VDP_CTRL
	lea	Icone_Cycle,a0
	move.b	cycle_cnt,d3
	lsl.w	#1,d3
	adda	d3,a0
	move.w	(a0)+,VDP_DATA
	move.w	(a0)+,VDP_DATA
	move.w	(a0)+,VDP_DATA

	addq.b	#1,cycle_cnt
	cmpi.b	#3,cycle_cnt
	blt.s	cyc_reset\@
	move.b	#0,cycle_cnt

cyc_reset\@:
	addq.b	#1,cycle_frame_cnt

	endm

*******************************************************************************
* Game entry
*******************************************************************************
Game_TeenageQueen:

	lea	Vars_Begin,a0
	move.l	#(Vars_End-Vars_Begin),d0
clear_userram:
	move.l	#0,(a0)+
	dbf	d0,clear_userram
	
	VDP_SetBGColor 0,0
*	VDP_SetRegister	$c,$81			; met en mode 256
	VDP_SetRegister	$c,$81			; met en mode 256
	VDP_SetRegister	$3,$3c			; met en mode 256
	VDP_SetRegister	$f,2			; auto increment
	VDP_SetRegister	$10,$1			; Map Size 64x32
	VDP_SetPlaneA	Game_PlaneA		; Plane A: $E000
	VDP_SetPlaneB	Game_PlaneA	
	VDP_SetSprite	Game_Sprite
	VDP_SetHScroll	Game_HScroll
	VDP_SetRegister $1,$74			; Turn on the display 
						; DMA On
						; VSYNC On

*******************************************************************************
* Title screen
*******************************************************************************
	68K_DisableINT	

	VDP_SetVRAMWriteAddr	$0,VDP_CTRL
	lea	Title_Chars,a0
	jsr	Nemesis_XTract

*	VDP_DMA_MEM2VRAM Title_Chars,$0,(Title_Chars_End-Title_Chars)
	lea.l Title_Map,a0
	VDP_SetVRAMWriteAddr Game_PlaneA,d1
	move.w	#27,d3				; 28 lignes
title_y_loop	
	move.l	d1,VDP_CTRL
	move.w	#39,d2				; 40 lignes
title_x_loop	
	move.w	(a0)+,VDP_DATA
	dbf	d2,title_x_loop
	add.l	#$800000,d1
	dbf d3,title_y_loop
	68K_EnableINT

	lea Title_Pal,a0
	bsr PAL_FadeIn0
	
	clr.w	-(sp)
	move.w	#8,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

title_loop					; loop
	PAD3_CheckStart
	bne @sortie_title

	VDP_WaitVSync d0

	jmp title_loop

@sortie_title

*	VDP_SetRegister 1,$34	

	68K_DisableINT

	move.l	MD_VBlank_Cnt,user_seed

	; update des pointeurs vers la vram
	MD_ResetVRAMIndex
	clr.w	mains_VRAMAddr
	clr.w	cards_VRAMAddr
	clr.w	femme_VRAMAddr
	clr.w	num_VRAMAddr
	clr.w	moins_VRAMAddr
	clr.w	msg_VRAMAddr
	clr.w	icones_VRAMAddr
	clr.w	marker_VRAMAddr

*	clr.w	hide_panel
	clr.w	reload_icon
	clr.w	reload_msg0
	clr.w	reload_msg2
	clr.w	loaded_icone
	clr.w	got_1_icone
	clr.w	msg0
	clr.w	msg2

	clr.w	asserted_msg0
	clr.w	asserted_msg2
	clr.w	icone_idx

	; init du buffer des 
*	jsr	ClearEngineSprite
	jsr	ClearAllSprites
	
	MD_InstallVBlankHandler #it_vbl

	68K_EnableINT
	
	bsr PAL_FadeOut0

	68K_DisableINT

	VDP_SetRegister	$c,$89			; active shadow hi

	; alloue un espace pour les nombres & messages
	move.w	MD_VRAMIndex,msg_VRAMAddr
	MD_IncrementVRAMIndex	#960
	
	; charge les nombres
	move.w	MD_VRAMIndex,num_VRAMAddr
	move.l	#Numbers_Chars,d0
	move.w	MD_VRAMIndex,d1
	move.l	#((Numbers_Chars_End-Numbers_Chars)/2),d2
	jsr	VDP_DMA_MEM2VRAMFct
	add.w	#(Numbers_Chars_End-Numbers_Chars),MD_VRAMIndex

	; charge le moins
	move.w	MD_VRAMIndex,moins_VRAMAddr
	move.l	#Moins_Chars,d0
	move.w	MD_VRAMIndex,d1
	move.l	#((Moins_Chars_End-Moins_Chars)/2),d2
	jsr	VDP_DMA_MEM2VRAMFct
	add.w	#(Moins_Chars_End-Moins_Chars),MD_VRAMIndex

	; charge le marker
	move.w	MD_VRAMIndex,marker_VRAMAddr
	move.l	#Marker_Chars,d0
	move.w	MD_VRAMIndex,d1
	move.l	#((Marker_Chars_End-Marker_Chars)/2),d2
	jsr	VDP_DMA_MEM2VRAMFct
	add.w	#(Marker_Chars_End-Marker_Chars),MD_VRAMIndex

	; alloue espace pour les cartes
	move.w	MD_VRAMIndex,cards_VRAMAddr
	MD_Add2VRAMIndex #((Carte_Chars_End-Carte_Chars)*5)

	; alloue de la place pour la fenetre d'icones
	move.w	MD_VRAMIndex,icones_VRAMAddr
	MD_Add2VRAMIndex #((16*5)*32)

	; alloue de l'espace pour les mains
	move.w	MD_VRAMIndex,mains_VRAMAddr
	MD_Add2VRAMIndex #(Mains_Chars_End-Mains_Chars)

	; alloue le vramindex pour la femme
	move.w	MD_VRAMIndex,femme_VRAMAddr

	68K_EnableINT

*******************************************************************************
* FUNCTION:	Play_Game
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
play_game:

action_teen421C		equ -6
action_player421C	equ -4
exit_game421C		equ -2
flag_endgame421C	equ -1
	
	ClearMap Game_PlaneA
	ClearMap Game_PlaneB
	
	VDP_SetPlaneA	Game_PlaneA
	VDP_SetPlaneB	Game_PlaneB

	VDP_SetRegister 1,$74

	jsr	init_random
	
	link	a5,#-6
	clr.b	exit_game421C(a5)
main_loop:
	tst.b	exit_game421C(a5)
	bne.w	loc_4AF4
	clr.b	flag_endgame421C(a5)

	; charge l'image 0
	clr.w	-(sp)
	jsr	load_picture
	addq.w	#2,sp

	jsr	reset_mouse

	; charge la palette 0
	68K_DisableINT

	lea Mains_Pal,a3
	lea (cache_palette),a4
	lea (cache_palette+32),a6

*	move.w	#$0ee,cache_palette
	; copie la palette des icones
	lea	(cache_palette+64),a0
	lea	(cache_palette+96),a2
	lea	Icone_Pal,a1
	move.w	#15,d3
cpy_ico_pal
	move.w	(a1),(a0)+
	move.w	(a1)+,(a2)+

	move.w	(a3),(a4)+
	move.w	(a3)+,(a6)+

	dbf	d3,cpy_ico_pal

	68K_EnableINT
	
	VDP_SetPlaneA	Game_PlaneB
	VDP_SetPlaneB	Game_PlaneB

	; fade palette 0
	lea	cache_palette,a0
	jsr	PAL_FadeInCRAM
	
	; recopie toute la palette des icones (bug md1 ??)
	VDP_SetCRAMWriteAddr	64,VDP_CTRL
	lea	Icone_Pal,a1
	move.w	#15,d3
cpy_ico_pal2
	move.w	(a1)+,VDP_DATA
	dbf	d3,cpy_ico_pal2

	; play sample 10
*	clr.w	-(sp)
*	move.w	#10,-(sp)
*	jsr	(play_sample).l
*	addq.w	#4,sp
*	
*	move.w	#50,-(sp)
*	jsr	wait_n_vbl
*	addq.w	#2,sp

	; init variable
	clr.w	(poker_pot).l
	move.w	#1,deck_num
	move.w	#100,(player_pot).l						; score a #100
	move.w	#100,(teen_pot).l
	clr.w	(game_turn).l
	clr.w	(first_player).l
	clr.w	(num_cur_pic).l
*	move.w	#3,num_cur_pic
*	move.w	#2,num_next_pic
	clr.w	(num_next_pic).l		

game_loop:
	tst.b	flag_endgame421C(a5)			; TODO FIN DU JEU !
	bne.w	loc_4A28				; affichage logo ERE: Game Over
	tst.w	(game_turn).l
	bne.w	loc_4492

	jsr	reset_mouse

	move.w	#111,asserted_msg0
	clr.w	asserted_msg2
	
	move.w	#1,(flag_redraw_main).l
	jsr	aff_pots
	
	eori.w	#1,(first_player).l
	clr.w	(nb_calls).l
	clr.w	(nb_encheres).l
	clr.w	(game_action).l
	clr.w	(flag_bluff).l
	clr.w	(flag_redraw_main).l
	clr.w	(teen_last_bet).l
	clr.w	(player_last_bet).l
	move.w	#9,(player_expected_score).l
	clr.w	(flag_cards_changed).l
	clr.w	action_teen421C(a5)
	clr.w	action_player421C(a5)

*	tst.w	(flag_protect).l
	bra.s	loc_434A
*	jsr	sub_4E90
	nop

loc_434A:
	jsr	init_cards
	jsr	distribue_cards
	jsr	calc_player_score
	jsr	calc_teen_score

	cmpi.w	#6,(teen_score).l
	bgt.s	loc_437C

	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#2,d1
	jsr	(modulo32).l
	tst.l	d0
	beq.s	loc_43CA

loc_437C:
	cmpi.w	#8,(teen_score).l
	bne.s	loc_43A8
	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#6,d1
	jsr	(modulo32).l
	tst.l	d0
	bne.s	loc_43A8
	cmpi.w	#5,(calc_cards_teen).l
	bgt.s	loc_43CA
loc_43A8:
	cmpi.w	#7,(teen_score).l
	bne.s	loc_43D2
	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#3,d1
	jsr	(modulo32).l
	tst.l	d0
	bne.s	loc_43D2

loc_43CA:
	move.w	#1,(flag_bluff).l

loc_43D2:
	jsr	aff_jeu_player
	move.w	#25,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	addq.w	#5,(poker_pot).l
	subq.w	#5,(player_pot).l

	jsr	aff_pots
	move.w	#25,-(sp)
	jsr	wait_n_vbl
	
	addq.w	#2,sp
	addq.w	#5,(poker_pot).l
	subq.w	#5,(teen_pot).l
	jsr	aff_pots
	
	move.w	#25,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	tst.w	(first_player).l
	beq.s	loc_4456

	jsr	player_play
	move.w	d0,action_player421C(a5)
	jsr	teen_play

	move.w	d0,action_teen421C(a5)
	cmpi.w	#1,action_teen421C(a5)
	bne.s	loc_4454
	cmpi.w	#2,action_player421C(a5)
	bne.s	loc_4454
	jsr	player_play
	move.w	d0,action_player421C(a5)
	cmpi.w	#1,action_player421C(a5)
	beq.s	loc_4454
	jsr	teen_play
	move.w	d0,action_teen421C(a5)

loc_4454:
	bra.s	loc_448E

loc_4456:
	jsr	teen_play
	move.w	d0,action_teen421C(a5)
	jsr	player_play
	move.w	d0,action_player421C(a5)
	cmpi.w	#1,action_player421C(a5)
	bne.s	loc_448E
	cmpi.w	#2,action_teen421C(a5)
	bne.s	loc_448E
	jsr	teen_play
	move.w	d0,action_teen421C(a5)
	cmpi.w	#1,action_teen421C(a5)
	beq.s	loc_448E
	jsr	player_play
	move.w	d0,action_player421C(a5)

loc_448E:
	bra.w	loc_4582

loc_4492:
	clr.w	action_teen421C(a5)
	clr.w	action_player421C(a5)
	cmpi.w	#5,(game_turn).l
	bne.s	loc_44C8
	tst.w	(teen_last_bet).l
	beq.s	loc_44B4
	jsr	player_play
	move.w	d0,action_player421C(a5)

loc_44B4:
	tst.w	(player_last_bet).l
	beq.s	loc_44C4
	jsr	teen_play
	move.w	d0,action_teen421C(a5)

loc_44C4:
	bra.w	loc_4582

loc_44C8:
	tst.w	(first_player).l
	beq.s	loc_452A
	jsr	player_play
	move.w	d0,action_player421C(a5)
	cmpi.w	#4,action_player421C(a5)
	beq.s	loc_44F8
	tst.w	(nb_encheres).l
	beq.s	loc_44F8
	tst.w	(nb_calls).l
	beq.s	loc_4528
	cmpi.w	#2,action_player421C(a5)
	bne.s	loc_4528

loc_44F8:
	jsr	teen_play
	move.w	d0,action_teen421C(a5)
	cmpi.w	#1,action_teen421C(a5)
	bne.s	loc_4528
	cmpi.w	#1,action_player421C(a5)
	beq.s	loc_4528
	jsr	player_play
	move.w	d0,action_player421C(a5)
	cmpi.w	#1,action_player421C(a5)
	beq.s	loc_4528
	jsr	teen_play
	move.w	d0,action_teen421C(a5)

loc_4528:
	bra.s	loc_4582

loc_452A:
	jsr	teen_play
	move.w	d0,action_teen421C(a5)
	cmpi.w	#4,action_teen421C(a5)
	beq.s	loc_4552
	tst.w	(nb_encheres).l
	beq.s	loc_4552
	tst.w	(nb_calls).l
	beq.s	loc_4582
	cmpi.w	#2,action_teen421C(a5)
	bne.s	loc_4582

loc_4552:
	jsr	player_play
	move.w	d0,action_player421C(a5)
	cmpi.w	#1,action_player421C(a5)
	bne.s	loc_4582
	cmpi.w	#1,action_teen421C(a5)
	beq.s	loc_4582
	jsr	teen_play
	move.w	d0,action_teen421C(a5)
	cmpi.w	#1,action_teen421C(a5)
	beq.s	loc_4582
	jsr	player_play
	move.w	d0,action_player421C(a5)

loc_4582:
	cmpi.w	#1,action_player421C(a5)
	bne.s	loc_45BC
	cmpi.w	#1,action_teen421C(a5)
	bne.s	loc_45BC
	tst.w	(game_turn).l
	bne.s	loc_45B2

	68K_DisableINT
	clr.w	-(sp)
	move.w	#111,-(sp)	; "Play	again"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	bra.s	loc_45BA

loc_45B2:
	move.w	#3,(game_action).l

loc_45BA:
	bra.s	loc_45F6

loc_45BC:
	cmpi.w	#5,action_player421C(a5)
	beq.s	loc_45CC
	cmpi.w	#5,action_teen421C(a5)
	bne.s	loc_45D6

loc_45CC:
	move.w	#5,(game_action).l
	bra.s	loc_45F6

loc_45D6:
	cmpi.w	#3,action_player421C(a5)
	beq.s	loc_45E6
	cmpi.w	#3,action_teen421C(a5)
	bne.s	loc_45F0

loc_45E6:
	move.w	#3,(game_action).l
	bra.s	loc_45F6

loc_45F0:
	addq.w	#1,(game_turn).l

loc_45F6:
	cmpi.w	#3,(game_action).l
	bne.s	loc_4668
	move.w	(player_score).l,d3
	sub.w	(player_expected_score).l,d3
	cmp.w	#1,d3
	ble.s	loc_461A
	move.w	#1,(teen_eval_modifier).l ; Bug	!!! Jamais remis … zero

loc_461A:
	jsr	aff_teen_cards							; affiche les score de la teen & calcule
	jsr	calc_winner
	move.w	d0,(game_action).l
	cmpi.w	#12,(game_action).l ; Egalit‚ ??
	bne.s	loc_4666
	move.w	(poker_pot).l,d3
	ext.l	d3
	divs.w	#2,d3
	subq.w	#5,d3
	add.w	d3,(player_pot).l
	move.w	(poker_pot).l,d3
	ext.l	d3
	divs.w	#2,d3
	subq.w	#5,d3
	add.w	d3,(teen_pot).l
	move.w	#10,(poker_pot).l

loc_4666:
	bra.s	loc_468C

loc_4668:
	cmpi.w	#5,(game_action).l
	bne.s	loc_468C
	cmpi.w	#5,action_player421C(a5)
	bne.s	loc_4684
	move.w	#10,(game_action).l
	bra.s	loc_468C

loc_4684:
	move.w	#11,(game_action).l

loc_468C:
	cmpi.w	#11,(game_action).l
	bne.s	loc_46EE

	68K_DisableINT
	clr.w	-(sp)
	move.w	#102,-(sp)	; "You win the pot"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#2,d1
	jsr	(modulo32).l
	tst.l	d0
	bne.s	loc_46C8
	clr.w	-(sp)
	move.w	#10,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

loc_46C8:
	move.w	#120,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	
	jsr	ClearCardsBuf			; rajout pbo
	move.w	#1,flag_redraw_main
*	VDP_SetPlaneA	Game_PlaneB		; Plane A: $E000
*	jsr	aff_jeu_player
*	jsr	aff_pots
*	VDP_SetPlaneA	Game_PlaneB
	
	move.w	(poker_pot).l,d3
	add.w	d3,(player_pot).l
	clr.w	(poker_pot).l
	clr.w	(game_turn).l
	bra.w	loc_47A6

loc_46EE:
	cmpi.w	#10,(game_action).l
	bne	loc_4772

	68K_DisableINT
	clr.w	-(sp)
	move.w	#103,-(sp)	; "I win the pot"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#2,d1
	jsr	(modulo32).l
	tst.l	d0
	bne.s	loc_4742
	clr.w	-(sp)
	move.w	#4,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	clr.w	-(sp)
	move.w	#10,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

loc_4742:
	move.w	#120,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	move.b	flag_aff_teen,d3		; si vient de l'écran teen
	beq	noclear
	
	cmpi.w	#0,(player_pot).l		; si gameover pas de clear
	ble.s	noclear
	jsr	ClearCardsBuf							; Fait foirer la transition de gameover
	jsr	aff_allsprites
	VDP_DMA_MEM2VRAM	MD_OAM,Game_Sprite,80*4
*	VDP_SetPlaneA	Game_PlaneB
noclear
	move.w	#1,flag_redraw_main						; probleme ici, affiche direct les mains ?????

	move.w	(poker_pot).l,d3
	add.w	d3,(teen_pot).l
	clr.w	(poker_pot).l
	clr.w	(game_turn).l
	
	bra	loc_47A6_2

loc_4770:
	bra.s	loc_47A6

loc_4772:
	cmpi.w	#12,(game_action).l
	bne.s	loc_47A6

	68K_DisableINT
	clr.w	-(sp)
	move.w	#111,-(sp)	; "Play	again"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	clr.w	-(sp)
	move.w	#10,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	clr.w	(game_turn).l
	
loc_47A6:
	jsr	aff_pots
	jsr	aff_allsprites
	VDP_DMA_MEM2VRAM	MD_OAM,Game_Sprite,80*4
*	tst.w	(game_action).l
*	beq.s	loc_47BC
*	move.w	#100,-(sp)			; avant était commenté pq ??
*	jsr	wait_n_vbl			; réponse affiche le pots sans les cartes pendant 3 secs
*	addq.w	#2,sp
*	
* Hack PBO
loc_47A6_2:
	tst.w	(game_action).l
	beq.s	loc_47BC
	nop
* fin hack


loc_47BC:
	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#2,d1
	jsr	(modulo32).l
	tst.l	d0
	bne.s	loc_4818
	cmpi.w	#100,(poker_pot).l
	ble.s	loc_4818
	cmpi.w	#8,(num_cur_pic).l
	ble.s	loc_4818
	clr.w	-(sp)
	move.w	#6,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	clr.w	-(sp)
	move.w	#5,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_4818:
	cmpi.w	#9,(game_action).l
	ble.w	loc_4A24
	cmpi.w	#0,(player_pot).l
	bge.s	loc_4856
	move.w	#64,-(sp)
	jsr	(hide_mouse).l
	addq.w	#2,sp
	clr.w	(word_848C).l
	move.b	#1,flag_endgame421C(a5)
	jsr	reset_mouse
	jsr	wait_10s_or_clic

loc_4856:

	tst.w	(num_cur_pic).l
	beq.s	loc_4890
	move.w	(num_cur_pic).l,d3
	mulu.w	#30,d3
	add.w	#100,d3
	move.w	(teen_pot).l,d2
	cmp.w	d3,d2
	ble.s	loc_4890
	move.w	(num_cur_pic).l,d3
	mulu.w	#30,d3
	add.w	#100,d3
	sub.w	d3,(teen_pot).l
	subq.w	#1,(num_next_pic).l

loc_4890:
*	tst.w	(flag_protect).l
*	bra.s	loc_489C
*; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*		jsr	sub_4E90

loc_489C:
	move.w	(num_cur_pic).l,d3
	cmp.w	(num_next_pic).l,d3
	beq.w	loc_4A24
	move.w	#64,-(sp)
	jsr	(hide_mouse).l
	addq.w	#2,sp
	clr.w	(word_848C).l
	move.w	(num_next_pic).l,(num_cur_pic).l
*		clr.w	-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	jsr	reset_mouse
	move.w	(num_cur_pic).l,d3
	cmp.w	(num_next_pic).l,d3 ; !? Bug !?	Toujours vrai
	bge.s	loc_4904
	cmpi.w	#8,(num_cur_pic).l
	ble.s	loc_4904
	clr.w	-(sp)
	move.w	#11,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_4904:
*		move.w	#2,-(sp)								???????????????????????????????????????????????
*		clr.w	-(sp)
*		pea	(tmp_palette).l
*		jsr	fade_pal
*		addq.w	#8,sp
*		

	move.w	(num_cur_pic).l,-(sp)						; MOFIF PBO ATTENTION PQ RELOAD ????? progression du niveau
	jsr	load_picture
	addq.w	#2,sp
	
after_reload:
	move.b	flag_endgame421C(a5),d3
	cmpi.w	#12,(num_cur_pic).l
	bne.s	loc_4932
	move.b	#1,flag_endgame421C(a5)

loc_4932:
	jsr	reset_mouse
*		clr.w	-(sp)									??????????????????????????????????????????????
*		jsr	copy_screen
*		addq.w	#2,sp
*		move.w	#2,-(sp)
**		move.w	#1,-(sp)
*		pea	(tmp_palette).l
*		jsr	fade_pal
*		addq.w	#8,sp
	cmpi.w	#8,(num_cur_pic).l
	ble.w	loc_49E4
	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#2,d1
	jsr	(modulo32).l
	tst.l	d0
	beq.s	loc_4990
	clr.w	-(sp)
	move.w	#5,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	bra.s	loc_49A8

loc_4990:
	clr.w	-(sp)
	move.w	#6,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_49A8:
	move.w	#10,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#4,d1
	jsr	(modulo32).l
	move.w	d0,action_player421C(a5)
	clr.w	-(sp)
	move.w	action_player421C(a5),-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	bra.s	loc_49FC

loc_49E4:
	clr.w	-(sp)
	move.w	#10,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_49FC:
	moveq	#0,d3
	move.b	flag_endgame421C(a5),d3
	cmp.w	#1,d3
	bne.s	loc_4A0E
	jsr	wait_clic
	bra.s	loc_4A12


loc_4A0E:
	jsr	wait_10s_or_clic

loc_4A12:
	clr.w	-(sp)
	jsr	(hide_mouse).l
	addq.w	#2,sp
	move.w	#1,(word_848C).l

loc_4A24:
	bra.w	game_loop

******************************************************************************** LOGO ERE
loc_4A28:

	; logo ERE
	move.w	#64,-(sp)
	jsr	(hide_mouse).l
	addq.w	#2,sp
	
	clr.w	(word_848C).l
	
	MD_InstallVBlankHandler #Dummy_VBlank
	
	bsr	PAL_FadeOutCRAM
	
	VDP_SetRegister 1,$34		; désactive display
	ClearMap Game_PlaneA
	ClearMap Game_PlaneB

	move.w	femme_VRAMAddr,d0
	move.w	d0,d7
	lsr.w	#5,d7
	
	jsr	VDP_SetVRAMWriteAddrFct
	lea	GameOver_Chars,a0
*	jsr	LZ77_Xtract2VRAM
	move.l	#(((GameOver_Chars_End-GameOver_Chars)/2)-1),d2
fill_tile_w2:
	move.w	(a0)+,VDP_DATA
	dbf	d2,fill_tile_w2	
	
	lea.l GameOver_Map,a0
	VDP_SetVRAMWriteAddr Game_PlaneB,d1
	move.w	#27,d3				; 28 lignes
go_y_loop	
	move.l	d1,VDP_CTRL
	move.w	#39,d2				; 40 lignes
go_x_loop	
	move.w	(a0)+,d0
	add.w	d7,d0
	or.w	#$8000,d0
	move.w	d0,VDP_DATA
*	move.w	(a0)+,VDP_DATA
	dbf	d2,go_x_loop
	add.l	#$800000,d1
	dbf d3,go_y_loop

	VDP_SetPlaneA Game_PlaneB

	VDP_SetRegister 1,$74
	lea	cache_palette,a0
	bsr	PAL_FadeInCRAM

* Temporisation	
	move.w	#240,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	
	bsr	PAL_FadeOutCRAM
	PAL_Clear3	d5

	ClearMap Game_PlaneA
	ClearMap Game_PlaneB
	
*	jsr	ClearCardsBuf
*	jsr	aff_allsprites
*	VDP_DMA_MEM2VRAM	MD_OAM,Game_Sprite,80*4

*	MD_InstallVBlankHandler #it_vbl

	move.w	#1,(word_848C).l
	
	
	bra	Game_TeenageQueen
	
* tu viens jouer avec moi
*	clr.w	-(sp)
*	move.w	#8,-(sp)
*	jsr	(play_sample).l
*	addq.w	#4,sp
	
*	move.w	#100,-(sp)
*	jsr	wait_n_vbl
*	addq.w	#2,sp

*	clr.w	-(sp)
*	move.w	#10,-(sp)
*	jsr	(play_sample).l
*	addq.w	#4,sp
*	
*	VDP_SetPlaneA	Game_PlaneB
*	VDP_SetPlaneB	Game_PlaneB
*	
*	
*	bsr PAL_FadeOutCRAM
*	
*	bsr	ClearAllSprites
*
*	68K_DisableINT
	
*		move.w	#100,-(sp)
*		jsr	wait_n_vbl
*		addq.w	#2,sp
*		
*		move.w	#2,-(sp)
*		clr.w	-(sp)
*		pea	(tmp_palette).l
*		jsr	fade_pal
*		addq.w	#8,sp
*		
*		jsr	(clear_physcreen).l
*		move.w	#66,-(sp)
*		move.w	#91,-(sp)
*		move.w	#118,-(sp)	; Logo ERE part1
*		jsr	aff_sprite
*		addq.w	#6,sp
*		
*		move.w	#66,-(sp)
*		move.w	#219,-(sp)
*		move.w	#119,-(sp)	; Logo ERE part2
*		jsr	aff_sprite
*		addq.w	#6,sp
*		
*		jsr	reset_mouse
*		
*		move.w	#2,-(sp)
*		move.w	#1,-(sp)
*		pea	(word_79B8).l
*		jsr	fade_pal
*		addq.w	#8,sp
*		
*		move.w	#2,-(sp)
*		jsr	sub_1540
*		addq.w	#2,sp
*		
*		jsr	wait_10s_or_clic
*		
*		move.w	#2,-(sp)
*		clr.w	-(sp)
*		pea	(word_79B8).l
*		jsr	fade_pal
*		addq.w	#8,sp
*		
*		clr.w	-(sp)
*		jsr	(hide_mouse).l
*		addq.w	#2,sp
*		
	move.w	#1,(word_848C).l
	bra.w	main_loop

* Boucle infinie
loop
	jmp loop


loc_4AF4:
	unlk	a5
	rts	

*******************************************************************************
* Inclus les tableaux ici histoire de compliqué la vie des hackers éventuel
*******************************************************************************
	include tabs.asm
*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
demo_won:

	move.w	#64,-(sp)
	jsr	(hide_mouse).l
	addq.w	#2,sp
	
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	
	clr.w	(word_848C).l
	
	MD_InstallVBlankHandler #Dummy_VBlank
	
	bsr	PAL_FadeOutCRAM
	
	VDP_SetRegister 1,$34		; désactive display
	ClearMap Game_PlaneA
	ClearMap Game_PlaneB

	move.w	femme_VRAMAddr,d0
	move.w	d0,d7
	lsr.w	#5,d7
	jsr	VDP_SetVRAMWriteAddrFct
	lea	DemoWon_Chars,a0
*	jsr	LZ77_Xtract2VRAM
	move.l	#(((DemoWon_Chars_End-DemoWon_Chars)/2)-1),d2
fill_tile_w:
	move.w	(a0)+,VDP_DATA
	dbf	d2,fill_tile_w

	lea.l DemoWon_Map,a0
	VDP_SetVRAMWriteAddr Game_PlaneB,d1
	move.w	#25,d3				; 28 lignes
won_y_loop	
	move.l	d1,VDP_CTRL
	move.w	#39,d2				; 40 lignes
won_x_loop	
	move.w	(a0)+,d0
	add.w	d7,d0
	or.w	#$8000,d0
	move.w	d0,VDP_DATA
*	move.w	(a0)+,VDP_DATA
	dbf	d2,won_x_loop
	add.l	#$800000,d1
	dbf d3,won_y_loop

	VDP_SetPlaneA Game_PlaneB

	VDP_SetRegister 1,$74
	lea	cache_palette,a0
	bsr	PAL_FadeInCRAM

* Temporisation	
*	move.w	#240,-(sp)
*	jsr	wait_n_vbl
*	addq.w	#2,sp

	move.w	#240,d0
	
boucle_demo_won:
	PAD3_CheckStart
	bne	fin_demo
	jsr	VDP_WaitVSyncFct
	
	bra	boucle_demo_won


fin_demo:
	bsr	PAL_FadeOutCRAM
	PAL_Clear3	d5

	ClearMap Game_PlaneA
	ClearMap Game_PlaneB
	
	move.w	#1,(word_848C).l
	
	bra	Game_TeenageQueen

*******************************************************************************
* FUNCTION:	load_picture
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
load_picture:

arg_01728	equ 8
	
	link	a5,#0
	
	68K_DisableINT
	
	;BRK
	
	ClearMap Game_PlaneB
	move.w	arg_01728(a5),d0
	
	; charge les tiles
	lea	GFX_Femme,a0
	ext.w	d0
	lsl.w	#4,d0
	add.w	d0,a0
	move.l	(a0)+,d0			; source

	clr.l	d1
	clr.l	d2
	clr.l	d3
	
	
	move.w	femme_VRAMAddr,d1		; destination

	move.l	(a0),d2
	
	move.w	#Game_PlaneA,d3			; clip la taille (évite un overflow sur la ram)
	sub.w	femme_VRAMAddr,d3
	cmp.w	d3,d2
	ble.s	pas_crop
	move.w	d3,d2

pas_crop:
	lsr.l	#1,d2
	exg	d0,d1
	; d1 = destination, d2=tailles en bytes, d0 = source
	bsr	VDP_SetVRAMWriteAddrFct
	movea.l	d1,a3
fill_tile:
	move.w	(a3)+,VDP_DATA
	dbf	d2,fill_tile

	clr.l	d1
	clr.l	d2
	clr.l	d3
	
	move.l	(a0)+,d2

	; ecriture de la map
	movea.l (a0)+,a1
	VDP_SetVRAMWriteAddr (Game_PlaneB),d1
	move.w	#20,d3				; 25 lignes = 24 ; 21 = crop 3 lignes
	clr.w	d4
	move.w	femme_VRAMAddr,d4
	lsr.w	#5,d4
pic_y_loop	
	move.l	d1,VDP_CTRL
	move.w	#39,d2				; 40 colonnes
pic_x_loop	
	move.w	(a1)+,d5
	add.w	d4,d5
	move.w	d5,VDP_DATA
	dbf	d2,pic_x_loop
	add.l	#$800000,d1
	dbf d3,pic_y_loop

	; charge la palette
	move.l	(a0),a0
	lea	cache_palette,a1
	move.w	#15,d0
@pic_pal_loop
	move.w	(a0)+,(a1)+
	dbf	d0,@pic_pal_loop

fin_load_picture
	68K_EnableINT
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	load_picture
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
load_picture_full:

arg_01728f	equ 8
	link	a5,#0
	move.w	arg_01728f(a5),d0

	68K_DisableINT
	
	; charge les tiles
	lea	GFX_Femme,a0
	ext.w	d0
	lsl.w	#4,d0
	add.w	d0,a0
	move.l	(a0)+,d0			; source
	
	clr.l	d1
	clr.l	d2

	move.w	femme_VRAMAddr,d1		; destination

	move.l	(a0),d2
*pas_cropf:
	lsr.l	#1,d2
*	jsr	VDP_DMA_MEM2VRAMFct

	; d1 = destination, d2=tailles en bytes, d0 = source
	exg	d0,d1
	bsr	VDP_SetVRAMWriteAddrFct
	movea.l	d1,a3
fill_tile2:
	move.w	(a3)+,VDP_DATA
	dbf	d2,fill_tile2

	move.l	(a0)+,d2

	; ecriture de la map
	movea.l (a0)+,a1
	VDP_SetVRAMWriteAddr (Game_PlaneB),d1

	move.w	#24,d3				; 25 lignes = 24
*	clr.l	d4
	move.w	femme_VRAMAddr,d4
	lsr.w	#5,d4
pic_y_loopf	
	move.l	d1,VDP_CTRL
	move.w	#39,d2				; 40 colonnes
pic_x_loopf	
	move.w	(a1)+,d5
	add.w	d4,d5
	or.w	#$8000,d5
	move.w	d5,VDP_DATA
	dbf	d2,pic_x_loopf
	add.l	#$800000,d1
	dbf d3,pic_y_loopf

	; charge la palette
	move.l	(a0),a0
	lea	cache_palette,a1
	move.w	#15,d0
@pic_pal_loop
	move.w	(a0)+,(a1)+
	dbf	d0,@pic_pal_loop

	68K_EnableINT

	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	it_vbl
* DESCRIPTION:	routine de vblank
* PARAMETERS:	
*******************************************************************************
it_vbl:	
	Cycle_CouleurSelection
	jsr	aff_allsprites
	VDP_DMA_MEM2VRAM	MD_OAM,Game_Sprite,80*4
	rts

*******************************************************************************
* FUNCTION:	affiche tous les sprites
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_allsprites:
	; sprite de l'engine (bouge peux)
	lea.l	MD_OAM,a4
	clr.b	MD_OAMIndex
	
; affiche les sprites de numéros
	clr.l	d6
	move.w	#(NBNumSprite-1),d6
	lea.l	num_buf,a3
aff_spr_num:
	tst.w	(a3)
	beq	ajoute_pas_sprite_num
	move.w	(a3)+,(a4)+
	move.w	(a3)+,d0
	addq.b	#1,MD_OAMIndex
	move.b	MD_OAMIndex,d1
	move.b	d1,d0
	move.w	d0,(a4)+
	move.w	(a3)+,(a4)+
	move.w	(a3)+,(a4)+
	bra	fin_ajout_num
ajoute_pas_sprite_num
	addq.w	#4,a3
fin_ajout_num
	dbf	d6,aff_spr_num

; affiche le marker si dispo
	lea.l	marker_buf,a3
	tst	(a3)
	beq.s	@pas_marker
	move.w	(a3)+,(a4)+

	move.w	(a3)+,d0
	addq.b	#1,MD_OAMIndex
	move.b	MD_OAMIndex,d1
	move.b	d1,d0
	move.w	d0,(a4)+

	move.w	(a3)+,(a4)+
	move.w	(a3),(a4)+
@pas_marker

; affiche les sprites de carte
	move.w	#(NBCardsSprite-1),d6
	lea.l	cards_buf,a3
aff_spr:
	tst.w	(a3)
	beq	ajoute_pas_sprite
	move.w	(a3)+,(a4)+
	move.w	(a3)+,d0
	addq.b	#1,MD_OAMIndex
	move.b	MD_OAMIndex,d1
	move.b	d1,d0
	move.w	d0,(a4)+
	move.w	(a3)+,(a4)+
	move.w	(a3)+,(a4)+
	bra	fin_ajout
ajoute_pas_sprite
	addq.w	#4,a3
fin_ajout
	dbf	d6,aff_spr

; affiche les sprites de messages
	clr.l	d6
	move.w	#(NBMsgSprite-1),d6
	lea.l	msg_buf,a3
aff_spr_Msg:
	tst.w	(a3)
	beq	ajoute_pas_sprite_Msg
	move.w	(a3)+,(a4)+
	move.w	(a3)+,d0
	addq.b	#1,MD_OAMIndex
	move.b	MD_OAMIndex,d1
	move.b	d1,d0
	move.w	d0,(a4)+
	move.w	(a3)+,(a4)+
	move.w	(a3)+,(a4)+
	bra	fin_ajout_Msg
ajoute_pas_sprite_Msg
	addq.w	#4,a3
fin_ajout_Msg
	dbf	d6,aff_spr_Msg

; clear le reste de l'oam
	clr.l	d1
	move.b	MD_OAMIndex,d1
debut_clear
	cmpi.b	#79,d1
	bgt	fin_clear
	clr.l	(a4)+
	clr.l	(a4)+
	addi.b	#1,d1
	bra	debut_clear
fin_clear

	rts

*******************************************************************************
* FUNCTION:	reset_mousse
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
reset_mouse:
	rts

*******************************************************************************
* FUNCTION:	init_random
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
init_random:
*	movem.l	d6-d7,-(sp)
	move.l	#369432934,d7
	move.l	#152181095,d6
	add.l	user_seed,d6
	asl.l	#8,d6
	move.w	d6,d7
	subq.w	#7,d7
	eor.w	d7,d6
	move.l	d6,rand_seed
	move.l	d7,rand_val
*	movem.l	(sp)+,d6-d7
	rts

*******************************************************************************
* FUNCTION:	random
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
random:
*	movem.l	d6-d7,-(sp)
	move.l	rand_seed,d6
	move.l	rand_val,d7
	exg	d6,d7
	rol.l	#3,d7
	subq.w	#7,d7
	eor.w	d6,d7
	move.l	d6,rand_seed
	move.l	d7,rand_val
*	movem.l	(sp)+,d6-d7
	rts

*******************************************************************************
* FUNCTION:	trap_14 service 11 de l'atari ST
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
call_trap14
	jsr	random
	move.l	rand_val,d0
	and.l	#$FFFF,d0
	rts

*******************************************************************************
* FUNCTION:	distribue cards
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
distribue_cards:

var_426EC	equ	-4
var_226EC	equ	-2

	link	a5,#-4
	clr.w	var_226EC(a5)

loc_26F4:
	move.w	var_226EC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	tst.w	(a6,d3.l)
	bne.s	loc_272A
	jsr	get_random_gamecard
	move.w	d0,var_426EC(a5)
	tst.w	var_426EC(a5)
	beq.s	loc_272A
	move.w	var_226EC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	var_426EC(a5),(a6,d3.l)

loc_272A:
	move.w	var_226EC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	tst.w	(a6,d3.l)
	bne.s	loc_2760
	jsr	get_random_gamecard
	move.w	d0,var_426EC(a5)
	tst.w	var_426EC(a5)
	beq.s	loc_2760
	move.w	var_226EC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	var_426EC(a5),(a6,d3.l)

loc_2760:
	addq.w	#1,var_226EC(a5)
	cmpi.w	#5,var_226EC(a5)
	blt.s	loc_26F4
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	init_cards
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
init_cards:

var_425B0	equ	-4
var_225B0	equ	-2

	link	a5,#-4
	clr.w	var_225B0(a5)

loc_25B8:
	clr.w	var_425B0(a5)

loc_25BC:
	move.w	var_225B0(a5),d3
	ext.l	d3
	asl.l	#3,d3
	move.w	var_425B0(a5),d2
	ext.l	d2
	asl.l	#1,d2
	add.l	d2,d3
	lea	(game_cards).l,a6
	move.w	#1,(a6,d3.l)
	addq.w	#1,var_425B0(a5)
	cmpi.w	#4,var_425B0(a5)
	blt.s	loc_25BC
	addq.w	#1,var_225B0(a5)
	cmpi.w	#8,var_225B0(a5)
	blt.s	loc_25B8
	clr.w	var_225B0(a5)

loc_25F6:
	move.w	var_225B0(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	clr.w	(a6,d3.l)
	move.w	var_225B0(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	clr.w	(a6,d3.l)
	addq.w	#1,var_225B0(a5)
	cmpi.w	#5,var_225B0(a5)
	blt.s	loc_25F6
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	get_random_gamecard
* DESCRIPTION:	obtient une @carte au hasard
* PARAMETERS:	a6 adresse du jeux (teen ou player)
*******************************************************************************
get_random_gamecard:

card_num262A	equ -$A
couleur262A	equ -8
carte262A	equ -6
iteration262A	equ -4
carte_ok262A	equ -2
	
	link	a5,#-$A
	clr.w	carte_ok262A(a5)
	move.w	#200,iteration262A(a5)

loc_2638:
	tst.w	carte_ok262A(a5)
	bne.w	loc_26DA
	tst.w	iteration262A(a5)
	beq.w	loc_26DA
	move.w	#$11,-(sp)
	jsr	call_trap14
	addq.w	#2,sp
	moveq	#8,d1
	jsr	(modulo32).l
	move.w	d0,carte262A(a5)
	move.w	#$11,-(sp)
	jsr	call_trap14
	addq.w	#2,sp
	moveq	#4,d1
	jsr	(modulo32).l
	move.w	d0,couleur262A(a5)
	move.w	carte262A(a5),d3
	ext.l	d3
	asl.l	#3,d3
	move.w	couleur262A(a5),d2
	ext.l	d2
	asl.l	#1,d2
	add.l	d2,d3
	lea	(game_cards).l,a6
	tst.w	(a6,d3.l)
	beq.s	loc_26CE
	move.w	carte262A(a5),d3
	ext.l	d3
	asl.l	#3,d3
	move.w	couleur262A(a5),d2
	ext.l	d2
	asl.l	#1,d2
	add.l	d2,d3
	lea	(game_cards).l,a6
	clr.w	(a6,d3.l)
	addq.w	#1,couleur262A(a5)
	move.w	couleur262A(a5),d3
	mulu.w	#10,d3
	add.w	carte262A(a5),d3
	move.w	d3,card_num262A(a5)
	move.w	#1,carte_ok262A(a5)
	bra.s	loc_26D6

loc_26CE:
	subq.w	#1,iteration262A(a5)
	clr.w	carte_ok262A(a5)

loc_26D6:
	bra.w	loc_2638

loc_26DA:
	tst.w	iteration262A(a5)
	bne.s	loc_26E4
	clr.w	card_num262A(a5)

loc_26E4:
	move.w	card_num262A(a5),d0
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	modulo32
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
modulo32:
	move.l	d4,-(sp)
	clr.l	d4
	tst.l	d0
	bpl.s	loc_78F8
	neg.l	d0
	addq.w	#1,d4

loc_78F8:
	tst.l	d1
	bpl.s	loc_7902
	neg.l	d1
	eori.w	#1,d4

loc_7902:
	bsr.s	sub_790E
	move.l	d1,d0
	bra.s	loc_78E2

	bsr.s	sub_790E
	move.l	d1,d0
	rts	

sub_790E:
	movem.l	d2-d3,-(sp)
	swap	d1
	tst.w	d1
	bne.s	loc_7940
	swap	d1
	clr.w	d3
	divu.w	d1,d0
	bvc.s	loc_792E
	move.w	d0,d2
	clr.w	d0
	swap	d0
	divu.w	d1,d0
	move.w	d0,d3
	move.w	d2,d0
	divu.w	d1,d0

loc_792E:
	move.l	d0,d1
	swap	d0
	move.w	d3,d0
	swap	d0
	clr.w	d1
	swap	d1
	movem.l	(sp)+,d2-d3
	rts	

loc_7940:
	swap	d1
	clr.l	d2
	moveq	#31,d3

loc_7946:
	asl.l	#1,d0
	roxl.l	#1,d2
	sub.l	d1,d2
	bmi.s	loc_795E

loc_794E:
	addq.l	#1,d0
	dbf	d3,loc_7946
	bra.s	loc_7964

loc_7956:
	asl.l	#1,d0
	roxl.l	#1,d2
	add.l	d1,d2
	bpl.s	loc_794E

loc_795E:
	dbf	d3,loc_7956
	add.l	d1,d2

loc_7964:
	move.l	d2,d1
	movem.l	(sp)+,d2-d3
	rts	

loc_78E2:
	tst.w	d4
	beq.s	loc_78E8
	neg.l	d0

loc_78E8:
	move.l	(sp)+,d4
	rts

*******************************************************************************
* FUNCTION:	get_width_spr_num
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
get_width_spr_num:
	
arg_021B8	equ 8

	link	a5,#0
	clr.l	d3
	move.w	arg_021B8(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(width_spr_numbers).l,a6
	move.w	(a6,d3.l),d0
	unlk	a5

	rts

*******************************************************************************
* FUNCTION:	aff_spr_number
* DESCRIPTION:	affiche un nombre
* PARAMETERS:	
*******************************************************************************
aff_spr_number:	

var_221F8	equ -2
number21F8	equ 8
crdx21F8	equ $A
crdy21F8	equ $C
	
	link	a5,#-2

	addi.w	#8,crdy21F8(a5)			; rajoute une ligne de Y

	cmpi.w	#0,number21F8(a5)
	bge.s	loc_21F8

	; affiche le moins
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),moins_VRAMAddr,%000100000000,$8000,num_buf,num_SpriteIndex
	addq.w	#8,crdx21F8(a5)

loc_21F8:
	cmpi.w	#0,number21F8(a5)
	bge.s	loc_220C
	move.w	number21F8(a5),d3
	neg.w	d3
	move.w	d3,number21F8(a5)
	bra.s	loc_2212

loc_220C:
	move.w	number21F8(a5),number21F8(a5)

loc_2212:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#1000,d3
	move.w	d3,var_221F8(a5)
	tst.w	d3
	beq.w	loc_22BE
	
	; si a des milliers
	move.w	var_221F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3
	add.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,num_buf,num_SpriteIndex

	; obtient la largeur + incrémente X
	move.w	var_221F8(a5),d3
	move.w	d3,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)
	
	; centaine
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#1000,d3
	swap	d3
	ext.l	d3
	divs.w	#100,d3
	tst.w	d3
	bne	loc_22BE

	; affiche 0 si le reste est a 0
	move.w	num_VRAMAddr,d3
*	add.w	cards_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,num_buf,num_SpriteIndex

	; ajoute la largeur
	move.w	#0,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	swap	d3
	ext.l	d3
	divs.w	#10,d3
	tst.w	d3
	bne.s	loc_22BE
	
	; affiche 0 si le reste est a 0
	move.w	num_VRAMAddr,d3
*	add.w	cards_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,num_buf,num_SpriteIndex

	; ajoute la largeur
	move.w	#0,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

loc_22BE:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#1000,d3
	swap	d3
	move.w	d3,number21F8(a5)
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	move.w	d3,var_221F8(a5)
	tst.w	d3
	beq	loc_2342

	; affiche les centaines !=0
	move.w	var_221F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3
	add.w	num_VRAMAddr,d3
*	add.w	cards_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,num_buf,num_SpriteIndex
	
	; ajoute la largeur
	move.w	var_221F8(a5),-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	swap	d3
	ext.l	d3
	divs.w	#10,d3
	tst.w	d3
	bne.s	loc_2342

	; Affiche les dixaines ==0
	move.w	num_VRAMAddr,d3
*	add.w	cards_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,num_buf,num_SpriteIndex

	; ajoute la largeur
	move.w	#0,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

loc_2342:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	swap	d3
	move.w	d3,number21F8(a5)
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#$A,d3
	move.w	d3,var_221F8(a5)
	tst.w	d3
	beq.s	loc_2390
	
	; affiche dixaine !=0
	move.w	var_221F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3	
	
	add.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,num_buf,num_SpriteIndex

	; ajoute la largeur
	move.w	var_221F8(a5),-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

loc_2390:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#$A,d3
	swap	d3
	move.w	d3,number21F8(a5)

	move.w	number21F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3
	add.w	num_VRAMAddr,d3
*	add.w	cards_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,num_buf,num_SpriteIndex
	unlk	a5

	rts	

*******************************************************************************
* FUNCTION:	aff_spr_number
* DESCRIPTION:	affiche un nombre
* PARAMETERS:	
*******************************************************************************
aff_msg_number:	

var_221F8	equ -2
number21F8	equ 8
crdx21F8	equ $A
crdy21F8	equ $C
	
	link	a5,#-2

	addi.w	#8,crdy21F8(a5)			; rajoute une ligne de Y

	cmpi.w	#0,number21F8(a5)
	bge.s	_loc_21F8

	; affiche le moins
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),moins_VRAMAddr,%000100000000,$8000,msg_buf,msg_SpriteIndex
	addq.w	#8,crdx21F8(a5)

_loc_21F8:
	cmpi.w	#0,number21F8(a5)
	bge.s	_loc_220C
	move.w	number21F8(a5),d3
	neg.w	d3
	move.w	d3,number21F8(a5)
	bra.s	_loc_2212

_loc_220C:
	move.w	number21F8(a5),number21F8(a5)

_loc_2212:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#1000,d3
	move.w	d3,var_221F8(a5)
	tst.w	d3
	beq.w	_loc_22BE
	
	; si a des milliers
	move.w	var_221F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3
	add.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,msg_buf,msg_SpriteIndex

	; obtient la largeur + incrémente X
	move.w	var_221F8(a5),d3
	move.w	d3,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)
	
	; centaine
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#1000,d3
	swap	d3
	ext.l	d3
	divs.w	#100,d3
	tst.w	d3
	bne	_loc_22BE

	; affiche 0 si le reste est a 0
	move.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,msg_buf,msg_SpriteIndex

	; ajoute la largeur
	move.w	#0,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	swap	d3
	ext.l	d3
	divs.w	#10,d3
	tst.w	d3
	bne.s	_loc_22BE
	
	; affiche 0 si le reste est a 0
	move.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,msg_buf,msg_SpriteIndex

	; ajoute la largeur
	move.w	#0,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

_loc_22BE:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#1000,d3
	swap	d3
	move.w	d3,number21F8(a5)
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	move.w	d3,var_221F8(a5)
	tst.w	d3
	beq	_loc_2342

	; affiche les centaines !=0
	move.w	var_221F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3
	add.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,msg_buf,msg_SpriteIndex
	
	; ajoute la largeur
	move.w	var_221F8(a5),-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	swap	d3
	ext.l	d3
	divs.w	#10,d3
	tst.w	d3
	bne.s	_loc_2342

	; Affiche les dixaines ==0
	move.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,msg_buf,msg_SpriteIndex

	; ajoute la largeur
	move.w	#0,-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

_loc_2342:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#100,d3
	swap	d3
	move.w	d3,number21F8(a5)
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#$A,d3
	move.w	d3,var_221F8(a5)
	tst.w	d3
	beq.s	_loc_2390

	; affiche dixaine !=0
	move.w	var_221F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3
	add.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,msg_buf,msg_SpriteIndex

	; ajoute la largeur
	move.w	var_221F8(a5),-(sp)
	jsr	get_width_spr_num
	addq.w	#2,sp
	add.w	d0,crdx21F8(a5)

_loc_2390:
	move.w	number21F8(a5),d3
	ext.l	d3
	divs.w	#$A,d3
	swap	d3
	move.w	d3,number21F8(a5)

	move.w	number21F8(a5),d3
	ext.l	d3
	lsl.w	#6,d3
	add.w	num_VRAMAddr,d3
	EnginePutSprite crdy21F8(a5),crdx21F8(a5),d3,%000100000000,$8000,msg_buf,msg_SpriteIndex
	unlk	a5

	rts

*******************************************************************************
* FUNCTION:	Play_Sample 
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
play_sample:

arg_05E48	equ 8
arg_25E48	equ $A

	link	a5,#0
	
	jsr	SGCCDAC_Reset
	
	clr.l	d3
	lea.l	Sounds,a0
	move.w	arg_05E48(a5),d3
	lsl.w	#3,d3
	adda.l	d3,a0

	move.l	(a0)+,d0
	move.l	(a0),d1
	bsr	SGCCDAC_Play


*	move.l	#\1,d0
*	move.l	#(\1_End-\1),d1
*	bsr	SGCCDAC_Play
*	nop


	unlk	a5
	rts

*******************************************************************************
* FUNCTION:	aff_card
* DESCRIPTION:	affiche une carte attention de spécifier le cards_Index avant
* PARAMETERS:	
*******************************************************************************
aff_cards:
	
couleur1AB2	equ -2
num_carte1AB2	equ 8
crdx1AB2	equ $A
crdy1AB2	equ $C

	link	a5,#-2

	clr.l	d3
	clr.l	d4
	clr.l	d5

	move.w	num_carte1AB2(a5),d3
	ext.l	d3
	sub.w	#10,d3
	divs.w	#10,d3
	move.w	d3,couleur1AB2(a5)
	move.w	num_carte1AB2(a5),d3
	ext.l	d3
	divs.w	#10,d3
	swap	d3
	move.w	d3,num_carte1AB2(a5)

	; calcule la position dans le buffer OAM
	lea	cards_buf,a2
	clr.l	d3
	move.b	cards_SpriteIndex,d3
	move.b	d3,d4
	lsl.w	#3,d3
	lea.l	(a2,d3.w),a2

	;*** Sprite #1 ***
	; Y
	move.w	crdy1AB2(a5),d3
	addi	#128,d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%111100000000,d3		; 32x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3

	lsr.w	#5,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2(a5),d3
	addi	#128,d3
	move.w	d3,(a2)+

	;*** Sprite #2 ***
	; Y
	move.w	crdy1AB2(a5),d3
	addi	#128,d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%101100000000,d3		; 24x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#(16*32),d3
	lsr.w	#5,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	;*** Sprite #3 ***
	; Y
	move.w	crdy1AB2(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%111100000000,d3		; 32x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12)*32),d3
	lsr.w	#5,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2(a5),d3
	addi	#(128),d3
	move.w	d3,(a2)+

	;*** Sprite #4 ***
	; Y
	move.w	crdy1AB2(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%101100000000,d3		; 24x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12+16)*32),d3
	lsr.w	#5,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+


	;*** Sprite #5 ***
	; Y
	move.w	crdy1AB2(a5),d3
	addi	#(128+32+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%110100000000,d3		; 32x16
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12+16+12)*32),d3
	lsr.w	#5,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2(a5),d3
	addi	#(128),d3
	move.w	d3,(a2)+

	;*** Sprite #6 ***
	; Y
	move.w	crdy1AB2(a5),d3
	addi	#(128+32+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%100100000000,d3		; 24x16
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12+16+12+8)*32),d3
	lsr.w	#5,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	unlk	a5
	rts

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_cards_teen:
	
couleur1AB2_teen	equ -2
num_carte1AB2_teen	equ 8
crdx1AB2_teen	equ $A
crdy1AB2_teen	equ $C

	link	a5,#-2

	clr.l	d3
	clr.l	d4
	clr.l	d5

	move.w	num_carte1AB2_teen(a5),d3
	ext.l	d3
	sub.w	#10,d3
	divs.w	#10,d3
	move.w	d3,couleur1AB2_teen(a5)
	move.w	num_carte1AB2_teen(a5),d3
	ext.l	d3
	divs.w	#10,d3
	swap	d3
	move.w	d3,num_carte1AB2_teen(a5)

	; calcule la position dans le buffer OAM
*	lea	MD_OAM,a2
	lea	cards_buf,a2
	clr.l	d3
*	move.b	MD_OAMIndex,d3
	move.b	cards_SpriteIndex,d3
	move.b	d3,d4
	lsl.w	#3,d3
	lea.l	(a2,d3.w),a2

	;*** Sprite #1 ***
	; Y
	move.w	crdy1AB2_teen(a5),d3
	addi	#128,d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%111100000000,d3		; 32x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	lsr.w	#5,d3
	or.w	#$8000,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2_teen(a5),d3
	addi	#128,d3
	move.w	d3,(a2)+

	;*** Sprite #2 ***
	; Y
	move.w	crdy1AB2_teen(a5),d3
	addi	#128,d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%101100000000,d3		; 24x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#(16*32),d3
	lsr.w	#5,d3
	or.w	#$8000,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2_teen(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	;*** Sprite #3 ***
	; Y
	move.w	crdy1AB2_teen(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%111100000000,d3		; 32x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12)*32),d3
	lsr.w	#5,d3
	or.w	#$8000,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2_teen(a5),d3
	addi	#(128),d3
	move.w	d3,(a2)+

	;*** Sprite #4 ***
	; Y
	move.w	crdy1AB2_teen(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%101100000000,d3		; 24x32
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12+16)*32),d3
	lsr.w	#5,d3
	or.w	#$8000,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2_teen(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+


	;*** Sprite #5 ***
	; Y
	move.w	crdy1AB2_teen(a5),d3
	addi	#(128+32+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%110100000000,d3		; 32x16
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12+16+12)*32),d3
	lsr.w	#5,d3
	or.w	#$8000,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2_teen(a5),d3
	addi	#(128),d3
	move.w	d3,(a2)+

	;*** Sprite #6 ***
	; Y
	move.w	crdy1AB2_teen(a5),d3
	addi	#(128+32+32),d3
	move.w	d3,(a2)+

	; Taille + Link
	add.b	#1,d4
	move.b	d4,cards_SpriteIndex
	move.w	d4,d3
	or.w	#%100100000000,d3		; 24x16
	move.w	d3,(a2)+

	; Sprite pattern
	move.w	cards_Index,d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	cards_VRAMAddr,d3
	add.w	#((16+12+16+12+8)*32),d3
	lsr.w	#5,d3
	or.w	#$8000,d3
	move.w	d3,(a2)+

	; X
	move.w	crdx1AB2_teen(a5),d3
	addi	#(128+32),d3
	move.w	d3,(a2)+

	unlk	a5
	rts

*******************************************************************************
* FUNCTION:	aff_icone
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_icone:

icone_num	equ 8

	link	a5,#0
	
	clr.b	cycle_cnt
	clr.l	d1
	clr.l	d3
	move.w	icone_num(a5),d3
	move.w	loaded_icone,d4
	cmp.w	d4,d3
	beq.s	icone_map

	move.w	d3,loaded_icone

	subi.w	#80,d3	
	asl.l	#2,d3
	lea.l	Icones,a0
	move.l	(a0,d3.w),d0
	move.w	icones_VRAMAddr,d1
	move.w	#((Icone_Stay_Bet_End-Icone_Stay_Bet_Chars)/2),d2
	jsr	VDP_DMA_MEM2VRAMFct
*	exg	d0,d1
*	bsr	VDP_SetVRAMWriteAddrFct
*	movea.l	d1,a3
*fill_icone:
*	move.w	(a3)+,VDP_DATA
*	dbf	d2,fill_icone
	

	; affiche la map du message
icone_map:
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	
	VDP_SetVRAMWriteAddr (Game_PlaneA+(((64*23)+19)*2)),d1
	move.w	#4,d3				; nb lignes

	move.w	icones_VRAMAddr,d4
	lsr.w	#5,d4
icone_loop_y:
	move.w	#((128/8)-1),d2
	move.l	d1,VDP_CTRL
icone_loop_x:
	clr.w	d5
	move.w	d4,d5
*	or.w	#(2<<13),d5
	or.w	#$C000,d5
	move.w	d5,VDP_DATA
	addq	#1,d4
	dbf	d2,icone_loop_x
	add.l	#$800000,d1
	dbf	d3,icone_loop_y

fin_aff_icone:
	move.w	#1,got_1_icone

	unlk	a5
	
	rts

*******************************************************************************
* FUNCTION:	aff_message
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_message:
arg_02528	equ 8
arg_22528	equ $A

	link	a5,#0
	
	jsr	ClearMsgBuf
	
	move.w	arg_02528(a5),d3
	cmp.w	aff_message_arg0,d3
	beq	loc_25A8

	;backup des parametres
	move.w	arg_02528(a5),aff_message_arg0
	move.w	arg_22528(a5),aff_message_arg2

	move.w	aff_message_arg0,reload_msg0
	move.w	aff_message_arg2,reload_msg2

	; charge les tiles
	clr.l	d3
	clr.l	d2
	clr.l	d1
	clr.l	d0
	move.w	arg_02528(a5),d3
	sub.w	#102,d3
	asl.l	#2,d3
	lea.l	Messages,a0
	move.l	(a0,d3.w),d0
	move.w	msg_VRAMAddr,d1
	move.w	#(960/2),d2
*	jsr	VDP_DMA_MEM2VRAMFct

	sub.w	#1,d2
	exg	d0,d1
	jsr	VDP_SetVRAMWriteAddrFct
	movea.l	d1,a6
aff_ss
	move.w	(a6)+,VDP_DATA
	dbra	d2,aff_ss

	; affiche la map du message
	VDP_SetVRAMWriteAddr (Game_PlaneA+((64*19)*2)),d1
	move.w	#1,d3				; nb lignes
	clr.l	d4
	move.w	msg_VRAMAddr,d4
	lsr.w	#5,d4
	clr.w	d5
msg_loop_y:
	move.w	#((120/8)-1),d2
	move.l	d1,VDP_CTRL
msg_loop_x:
	move.w	d4,d5
	or.w	#$8000,d5
	move.w	d5,VDP_DATA
	addq	#1,d4
	dbf	d2,msg_loop_x
	add.l	#$800000,d1
	dbf	d3,msg_loop_y

	; message avec nombres a afficher
	cmpi.w	#105,arg_02528(a5)	; "I change n Cards"
	bne.s	loc_2572
	
	move.w	#(131),-(sp)
	move.w	#64,-(sp)
	move.w	arg_22528(a5),-(sp)
	jsr	aff_msg_number
	addq.w	#6,sp

	bra.s	loc_25A8
loc_2572:
	cmpi.w	#106,arg_02528(a5)	; "I Bet n"
	bne.s	loc_258E

	move.w	#131,-(sp)
	move.w	#36,-(sp)
	move.w	arg_22528(a5),-(sp)
	jsr	aff_msg_number
	addq.w	#6,sp

	bra.s	loc_25A8

loc_258E:
	cmpi.w	#109,arg_02528(a5)	; "I Raise n"
	bne.s	loc_25A8
	nop
	move.w	#131,-(sp)
	move.w	#50,-(sp)
	move.w	arg_22528(a5),-(sp)
	jsr	aff_msg_number
	addq.w	#6,sp

loc_25A8:

	jsr	reset_mouse
	unlk	a5
	rts

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_mains:
	tst.w	(flag_redraw_main).l
	beq	fin_main
	clr.w	(flag_redraw_main).l
	
	move.b	#1,flag_aff_mains
	clr.b	flag_aff_teen
	
	68K_DisableINT
	
	clr.l	d1
	clr.l	d3
	clr.l	d2
	clr.l	d4
	clr.l	d5
	move.w	mains_VRAMAddr,d4
	lsr.w	#5,d4
	
	move.l	#Mains_Chars,d0			; source
	move.w	mains_VRAMAddr,d1		; dest
	move.w	#((Mains_Chars_End-Mains_Chars)/2),d2
	jsr	VDP_DMA_MEM2VRAMFct
	
	lea.l Mains_Map,a0
	VDP_SetVRAMWriteAddr (Game_PlaneA+(64*0)),d1
	move.w	#27,d3				; 28 lignes
Mains_y_loop	
	move.l	d1,VDP_CTRL
	move.w	#39,d2				; 40 lignes
Mains_x_loop	
	move.w	(a0)+,d5
	add.w	d4,d5
	move.w	d5,VDP_DATA
	dbf	d2,Mains_x_loop
	add.l	#$800000,d1
	dbf d3,Mains_y_loop

	tst.w	got_1_icone
	beq.s	force_main	
	move.w	loaded_icone,-(sp)
	bra	dsp_icon
force_main
	move.w	#ICONE_MAIN,-(sp)
dsp_icon	
	jsr	aff_icone
	addq	#2,sp
	68K_EnableINT
fin_main:
	
	68K_DisableINT
	move.w	asserted_msg2,-(sp)
	move.w	asserted_msg0,-(sp)
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT
	
	
	
	rts

*******************************************************************************
* FUNCTION:	aff_pots
* DESCRIPTION:	
* PARAMETERS:	/
*******************************************************************************
aff_pots:

crdx23BC	equ -2

	clr.b	num_SpriteIndex

	link	a5,#-2
	cmpi.w	#0,(teen_pot).l
	bge.s	loc_23E6
	move.w	(num_cur_pic).l,d3
	mulu.w	#30,d3
	add.w	#100,d3
	add.w	d3,(teen_pot).l
	addq.w	#1,(num_next_pic).l
	bra.s	loc_2426
	
loc_23E6:
	move.w	(num_next_pic).l,d3
	cmp.w	(num_cur_pic).l,d3
	ble.s	loc_2426
	move.w	(num_cur_pic).l,d3
	mulu.w	#30,d3
	add.w	#100,d3
	move.w	(teen_pot).l,d2
	cmp.w	d3,d2
	ble.s	loc_2426
	move.w	(num_cur_pic).l,d3
	mulu.w	#30,d3
	add.w	#100,d3
	sub.w	d3,(teen_pot).l
	subq.w	#1,(num_next_pic).l

loc_2426:
	jsr	aff_mains

	clr.w	crdx23BC(a5)
	cmpi.w	#1000,(player_pot).l
	bge.s	loc_245C
	cmpi.w	#-10,(player_pot).l
	ble.s	loc_245C
	addq.w	#8,crdx23BC(a5)

loc_245C:
	cmpi.w	#10,(player_pot).l
	bge.s	loc_2476
	cmpi.w	#0,(player_pot).l
	blt.s	loc_2476
	addi.w	#10,crdx23BC(a5)

loc_2476:
	move.w	#168,-(sp)
	move.w	crdx23BC(a5),-(sp)
	move.w	(player_pot).l,-(sp)
	jsr	aff_spr_number
	addq.w	#6,sp
	clr.w	crdx23BC(a5)
	cmpi.w	#1000,(poker_pot).l
	bge.s	loc_249E
	addi.w	#10,crdx23BC(a5)

loc_249E:
	cmpi.w	#10,(poker_pot).l
	bge.s	loc_24AE
	addi.w	#10,crdx23BC(a5)

loc_24AE:
	move.w	#168,-(sp)
	move.w	crdx23BC(a5),d3
	add.w	#37,d3
	move.w	d3,-(sp)
	move.w	(poker_pot).l,-(sp)
	jsr	aff_spr_number
	addq.w	#6,sp
	clr.w	crdx23BC(a5)
	cmpi.w	#1000,(teen_pot).l
	bge.s	loc_24DC
	addi.w	#10,crdx23BC(a5)

loc_24DC:
	cmpi.w	#10,(teen_pot).l
	bge.s	loc_24EC
	addi.w	#10,crdx23BC(a5)

loc_24EC:
	move.w	#168,-(sp)
	move.w	crdx23BC(a5),d3
	add.w	#75,d3
	move.w	d3,-(sp)
	move.w	(teen_pot).l,-(sp)
	jsr	aff_spr_number
	addq.w	#6,sp

*	tst.w	(flag_redraw_main).l
*	bne.s	loc_2520
*	move.w	#97,-(sp)
*	move.w	#87,-(sp)
*	move.w	#75,-(sp)	; main gauche
*	jsr	aff_sprite
*	addq.w	#6,sp

loc_2520:
	jsr	reset_mouse

* clear le reste du buffer							; <TODO> PBO POURQUOIIIIIIIIIIIIIIIIIII
	clr.l	d3
	lea	num_buf,a6
	move.b	num_SpriteIndex,d3
	asl	#3,d3
	adda.l	d3,a6
	clr.l	d0
	move.b	#NBNumSprite,d0
	move.b	num_SpriteIndex,d1
	sub.b	d1,d0	
	subq.b	#1,d0
cbuf:	
	clr.l	(a6)+
	clr.l	(a6)+
	dbf	d0,cbuf

	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	calc_player_score
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
calc_player_score:

var_l277A	equ -8
var_k277A	equ -6
var_j277A	equ -4
var_i277A	equ -2

	link	a5,#-8
	clr.w	(player_score).l
	clr.w	(unused_var_player).l
	clr.w	var_i277A(a5)

loc_2784:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_player).l,a6
	clr.w	(a6,d3.l)
	addq.w	#1,var_i277A(a5)
	cmpi.w	#5,var_i277A(a5)
	blt.s	loc_2784
	clr.w	var_j277A(a5)

loc_27A6:
	clr.w	var_i277A(a5)

loc_27AA:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	var_i277A(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	cmp.w	d1,d2
	bge.s	loc_2832
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),var_k277A(a5)
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	var_i277A(a5),d2
	addq.w	#1,d2
	ext.l	d2
	asl.l	#1,d2
	lea	(player_cards).l,a1
	move.w	(a1,d2.l),(a6,d3.l)
	move.w	var_i277A(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	var_k277A(a5),(a6,d3.l)

loc_2832:
	addq.w	#1,var_i277A(a5)
	cmpi.w	#4,var_i277A(a5)
	blt.w	loc_27AA
	addq.w	#1,var_j277A(a5)
	cmpi.w	#4,var_j277A(a5)
	blt.w	loc_27A6
	clr.w	var_l277A(a5)
	clr.w	var_k277A(a5)
	clr.w	var_j277A(a5)
	clr.w	var_i277A(a5)

loc_285E:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	var_i277A(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	cmp.w	d1,d2
	bne.s	loc_28EA
	tst.w	var_l277A(a5)
	bne.s	loc_28C4
	addq.w	#1,var_j277A(a5)
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	d2,(calc_cards_player).l
	bra.s	loc_28E8

loc_28C4:
	addq.w	#1,var_k277A(a5)
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	d2,(calc_cards_player+2).l

loc_28E8:
	bra.s	loc_28F4

loc_28EA:
	tst.w	var_j277A(a5)
	beq.s	loc_28F4
	addq.w	#1,var_l277A(a5)

loc_28F4:
	addq.w	#1,var_i277A(a5)
	cmpi.w	#4,var_i277A(a5)
	blt.w	loc_285E
	tst.w	var_k277A(a5)
	bne.w	loc_29F0
	tst.w	var_j277A(a5)
	beq.w	loc_29A8
	cmpi.w	#1,var_j277A(a5)
	bne.s	loc_2924
	move.w	#8,(player_score).l
	bra.s	loc_293E


loc_2924:
	cmpi.w	#2,var_j277A(a5)
	bne.s	loc_2936
	move.w	#6,(player_score).l
	bra.s	loc_293E

loc_2936:
	move.w	#2,(player_score).l

loc_293E:
	move.w	#1,var_j277A(a5)
	clr.w	var_i277A(a5)

loc_2948:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	cmp.w	(calc_cards_player).l,d2
	beq.s	loc_299A
	move.w	var_j277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_player).l,a6
	move.w	var_i277A(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(player_cards).l,a1
	move.w	(a1,d2.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	move.w	d1,(a6,d3.l)
	addq.w	#1,var_j277A(a5)

loc_299A:
	addq.w	#1,var_i277A(a5)
	cmpi.w	#5,var_i277A(a5)
	blt.s	loc_2948
	bra.s	loc_29EC


loc_29A8:
	move.w	#9,(player_score).l
	clr.w	var_i277A(a5)

loc_29B4:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_player).l,a6
	move.w	var_i277A(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(player_cards).l,a1
	move.w	(a1,d2.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	move.w	d1,(a6,d3.l)
	addq.w	#1,var_i277A(a5)
	cmpi.w	#5,var_i277A(a5)
	blt.s	loc_29B4

loc_29EC:
	bra.w	loc_2AD4

loc_29F0:
	move.w	var_j277A(a5),d3
	cmp.w	var_k277A(a5),d3
	bne.w	loc_2AA8
	move.w	#7,(player_score).l
	move.w	(calc_cards_player).l,d3
	cmp.w	(calc_cards_player+2).l,d3
	bge.s	loc_2A2C
	move.w	(calc_cards_player).l,var_l277A(a5)
	move.w	(calc_cards_player+2).l,(calc_cards_player).l
	move.w	var_l277A(a5),(calc_cards_player+2).l

loc_2A2C:
	clr.w	var_i277A(a5)

loc_2A30:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	cmp.w	(calc_cards_player).l,d2
	beq.s	loc_2A9A
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	cmp.w	(calc_cards_player+2).l,d2
	beq.s	loc_2A9A
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	d2,(calc_cards_player+4).l
	move.w	#5,var_i277A(a5)

loc_2A9A:
	addq.w	#1,var_i277A(a5)
	cmpi.w	#5,var_i277A(a5)
	blt.s	loc_2A30
	bra.s	loc_2AD4

loc_2AA8:
	move.w	#3,(player_score).l
	move.w	var_j277A(a5),d3
	cmp.w	var_k277A(a5),d3
	bge.s	loc_2AD4
	move.w	(calc_cards_player).l,var_l277A(a5)
	move.w	(calc_cards_player+2).l,(calc_cards_player).l
	move.w	var_l277A(a5),(calc_cards_player+2).l

loc_2AD4:
	clr.w	var_i277A(a5)

loc_2AD8:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	move.w	var_i277A(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#10,d1
	cmp.w	d1,d2
	bne.s	loc_2B32
	cmpi.w	#3,var_i277A(a5)
	bne.s	loc_2B30
	move.w	#4,(player_score).l
	move.w	(player_cards).l,d3
	ext.l	d3
	divs.w	#10,d3
	move.w	d3,(unused_var_player).l

loc_2B30:
	bra.s	loc_2B38

loc_2B32:
	move.w	#5,var_i277A(a5)

loc_2B38:
	addq.w	#1,var_i277A(a5)
	cmpi.w	#4,var_i277A(a5)
	blt.s	loc_2AD8
	clr.w	var_i277A(a5)

loc_2B48:
	move.w	var_i277A(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	var_i277A(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	addq.w	#1,d1
	cmp.w	d1,d2
	bne.s	loc_2BBE
	cmpi.w	#3,var_i277A(a5)
	bne.s	loc_2BBC
	cmpi.w	#4,(player_score).l
	bne.s	loc_2BA0
	move.w	#1,(player_score).l
	bra.s	loc_2BA8

loc_2BA0:
	move.w	#5,(player_score).l

loc_2BA8:
	move.w	(player_cards).l,d3
	ext.l	d3
	divs.w	#10,d3
	swap	d3
	move.w	d3,(calc_cards_player).l

loc_2BBC:
	bra.s	loc_2BC4


loc_2BBE:
	move.w	#5,var_i277A(a5)

loc_2BC4:
	addq.w	#1,var_i277A(a5)
	cmpi.w	#4,var_i277A(a5)
	blt.w	loc_2B48
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
calc_teen_score:

var_l2BD6	equ -8
var_k2BD6	equ -6
var_j2BD6	equ -4
var_i2BD6	equ -2

	link	a5,#-8
	clr.w	(teen_score).l
	clr.w	(unused_var_teen).l
	clr.w	var_i2BD6(a5)

loc_2BEA:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_teen).l,a6
	clr.w	(a6,d3.l)
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	clr.w	(a6,d3.l)
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#5,var_i2BD6(a5)
	blt.s	loc_2BEA
	clr.w	var_j2BD6(a5)

loc_2C1E:
	clr.w	var_i2BD6(a5)

loc_2C22:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#$A,d2
	swap	d2
	move.w	var_i2BD6(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	cmp.w	d1,d2
	bge.s	loc_2CAA
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),var_k2BD6(a5)
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	var_i2BD6(a5),d2
	addq.w	#1,d2
	ext.l	d2
	asl.l	#1,d2
	lea	(teen_cards).l,a1
	move.w	(a1,d2.l),(a6,d3.l)
	move.w	var_i2BD6(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	var_k2BD6(a5),(a6,d3.l)

loc_2CAA:
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#4,var_i2BD6(a5)
	blt.w	loc_2C22
	addq.w	#1,var_j2BD6(a5)
	cmpi.w	#4,var_j2BD6(a5)
	blt.w	loc_2C1E
	clr.w	var_l2BD6(a5)
	clr.w	var_k2BD6(a5)
	clr.w	var_j2BD6(a5)
	clr.w	var_i2BD6(a5)

loc_2CD6:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	var_i2BD6(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	cmp.w	d1,d2
	bne.s	loc_2D62
	tst.w	var_l2BD6(a5)
	bne.s	loc_2D3C
	addq.w	#1,var_j2BD6(a5)
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	d2,(calc_cards_teen).l
	bra.s	loc_2D60

loc_2D3C:
	addq.w	#1,var_k2BD6(a5)
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	d2,(calc_cards_teen+2).l

loc_2D60:
	bra.s	loc_2D6C


loc_2D62:
	tst.w	var_j2BD6(a5)
	beq.s	loc_2D6C
	addq.w	#1,var_l2BD6(a5)

loc_2D6C:
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#4,var_i2BD6(a5)
	blt.w	loc_2CD6
	tst.w	var_k2BD6(a5)
	bne.w	loc_2E90
	tst.w	var_j2BD6(a5)
	beq.w	loc_2E34
	cmpi.w	#1,var_j2BD6(a5)
	bne.s	loc_2D9C
	move.w	#8,(teen_score).l
	bra.s	loc_2DB6

loc_2D9C:
	cmpi.w	#2,var_j2BD6(a5)
	bne.s	loc_2DAE
	move.w	#6,(teen_score).l
	bra.s	loc_2DB6


loc_2DAE:
	move.w	#2,(teen_score).l

loc_2DB6:
	move.w	#1,var_j2BD6(a5)
	clr.w	var_i2BD6(a5)

loc_2DC0:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	cmp.w	(calc_cards_teen).l,d2
	beq.s	loc_2E26
	move.w	var_j2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_teen).l,a6
	move.w	var_i2BD6(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(teen_cards).l,a1
	move.w	(a1,d2.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	move.w	d1,(a6,d3.l)
	addq.w	#1,var_j2BD6(a5)
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	move.w	#1,(a6,d3.l)

loc_2E26:
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#5,var_i2BD6(a5)
	blt.s	loc_2DC0
	bra.s	loc_2E8C

loc_2E34:
	move.w	#9,(teen_score).l
	clr.w	var_i2BD6(a5)

loc_2E40:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_teen).l,a6
	move.w	var_i2BD6(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(teen_cards).l,a1
	move.w	(a1,d2.l),d1
	ext.l	d1
	divs.w	#10,d1
	swap	d1
	move.w	d1,(a6,d3.l)
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	move.w	#1,(a6,d3.l)
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#5,var_i2BD6(a5)
	blt.s	loc_2E40

loc_2E8C:
	bra.w	loc_2F8A

loc_2E90:
	move.w	var_j2BD6(a5),d3
	cmp.w	var_k2BD6(a5),d3
	bne.w	loc_2F5E
	move.w	#7,(teen_score).l
	move.w	(calc_cards_teen).l,d3
	cmp.w	(calc_cards_teen+2).l,d3
	bge.s	loc_2ECC
	move.w	(calc_cards_teen).l,var_l2BD6(a5)
	move.w	(calc_cards_teen+2).l,(calc_cards_teen).l
	move.w	var_l2BD6(a5),(calc_cards_teen+2).l

loc_2ECC:
	clr.w	var_i2BD6(a5)

loc_2ED0:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	cmp.w	(calc_cards_teen).l,d2
	beq.s	loc_2F4E
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	cmp.w	(calc_cards_teen+2).l,d2
	beq.s	loc_2F4E
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	d2,(calc_cards_teen+4).l
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	move.w	#1,(a6,d3.l)
	move.w	#5,var_i2BD6(a5)

loc_2F4E:
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#5,var_i2BD6(a5)
	blt.w	loc_2ED0
	bra.s	loc_2F8A

loc_2F5E:
	move.w	#3,(teen_score).l
	move.w	var_j2BD6(a5),d3
	cmp.w	var_k2BD6(a5),d3
	bge.s	loc_2F8A
	move.w	(calc_cards_teen).l,var_l2BD6(a5)
	move.w	(calc_cards_teen+2).l,(calc_cards_teen).l
	move.w	var_l2BD6(a5),(calc_cards_teen+2).l

loc_2F8A:
	clr.w	var_i2BD6(a5)

loc_2F8E:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#$A,d2
	move.w	var_i2BD6(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#$A,d1
	cmp.w	d1,d2
	bne.s	loc_2FE8
	cmpi.w	#3,var_i2BD6(a5)
	bne.s	loc_2FE6
	move.w	#4,(teen_score).l
	move.w	(teen_cards).l,d3
	ext.l	d3
	divs.w	#$A,d3
	move.w	d3,(unused_var_teen).l

loc_2FE6:
	bra.s	loc_2FEE

loc_2FE8:
	move.w	#5,var_i2BD6(a5)

loc_2FEE:
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#4,var_i2BD6(a5)
	blt.s	loc_2F8E
	clr.w	var_i2BD6(a5)

loc_2FFE:
	move.w	var_i2BD6(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#$A,d2
	swap	d2
	move.w	var_i2BD6(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d1
	ext.l	d1
	divs.w	#$A,d1
	swap	d1
	addq.w	#1,d1
	cmp.w	d1,d2
	bne.s	loc_3074
	cmpi.w	#3,var_i2BD6(a5)
	bne.s	loc_3072
	cmpi.w	#4,(teen_score).l
	bne.s	loc_3056
	move.w	#1,(teen_score).l
	bra.s	loc_305E

loc_3056:
	move.w	#5,(teen_score).l

loc_305E:
	move.w	(teen_cards).l,d3
	ext.l	d3
	divs.w	#$A,d3
	swap	d3
	move.w	d3,(calc_cards_teen).l

loc_3072:
	bra.s	loc_307A

loc_3074:
	move.w	#5,var_i2BD6(a5)

loc_307A:
	addq.w	#1,var_i2BD6(a5)
	cmpi.w	#4,var_i2BD6(a5)
	blt.w	loc_2FFE
	unlk	a5
	rts

*******************************************************************************
* FUNCTION:	wait_n_vbl
* DESCRIPTION:	
* PARAMETERS:	-(sp): nombres de frame a attendre
*******************************************************************************
wait_n_vbl:

var_2116A	equ -2
arg_0116A	equ 8

	link	a5,#-2
	clr.w	var_2116A(a5)
	bra.s	loc_1184

loc_1174:
	jsr	VDP_WaitVSyncFct
	addq.w	#1,var_2116A(a5)

loc_1184:
	move.w	var_2116A(a5),d3
	cmp.w	arg_0116A(a5),d3
	blt.s	loc_1174

	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	load_card
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
load_card:
	
couleurlc	equ -2

num_cartelc	equ 8
index_cartelc	equ $A

	link	a5,#-2

	clr.l	d3
	clr.l	d4
	clr.l	d1
	clr.l	d0
	clr.l	d2

* force la carte a retourné si elle vaut 0	
	move.w	num_cartelc(a5),d3
	tst.w	d3
	bne	card_normale
	
	move.w	#50,d3
	add.w	deck_num,d3
	move.w	d3,num_cartelc(a5)
	
card_normale:	
	move.w	num_cartelc(a5),d3
	ext.l	d3
	sub.w	#10,d3
	divs.w	#10,d3
	move.w	d3,couleurlc(a5)
	move.w	num_cartelc(a5),d3
	ext.l	d3
	divs.w	#10,d3
	swap	d3
	move.w	d3,num_cartelc(a5)

	; calcul l'addresse source des tiles
	clr.l	d4
	move.w	couleurlc(a5),d3
	mulu	#((Carte_Chars_End-Carte_Chars)*8),d3
	move.l	d3,d4

	move.w	num_cartelc(a5),d3
	mulu	#(Carte_Chars_End-Carte_Chars),d3
	add.l	d3,d4
	
	move.l	#Carte_Chars,d0
	add.l	d4,d0				; d0 = addresse source

	; calcule vram addr
	move.w	cards_VRAMAddr,d1
	move.w	index_cartelc(a5),d3
	mulu.w	#(Carte_Chars_End-Carte_Chars),d3
	add.w	d3,d1
	
	move.w	#((Carte_Chars_End-Carte_Chars)/2),d2	

	sub.w	#1,d2
	exg	d0,d1
	jsr	VDP_SetVRAMWriteAddrFct
	movea.l	d1,a6
aff_ss2
	move.w	(a6)+,VDP_DATA
	dbf	d2,aff_ss2

	unlk	a5
	rts


*******************************************************************************
* FUNCTION:	load_cards
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
load_cards:
	
*couleur1AB2	equ -2
PlayerID	equ 8				; 0 player 1 teen

	link	a5,#-2

	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7

	; Calcule l'adresse du tableau
	move.w	PlayerID(a5),d3
	ext.l	d3
	move.w	d3,d4
	lsl.l	#3,d4
	lsl.l	#1,d3
	add.w	d4,d3
	lea.l	loaded_cards,a1
	adda.l	d3,a1

	lea.l	player_cards,a0
	adda.l	d3,a0

	; test carte #1
	move.w	(a0)+,d4			; a0 = carte
	move.w	(a1),d5				; d5 = loaded buf

	cmp.w	d4,d5				; d3 = carte a chargé
	beq	Pas_Test1

	move.w	d4,(a1)+			; sauvegarde
	
	; charche la carte 0
	move.w	#0,-(sp)
	move.w	d4,-(sp)
	jsr	load_card
	addq	#4,sp

Pas_Test1

	; test carte #1
	move.w	(a0)+,d4			; a0 = carte
	move.w	(a1),d5				; d5 = loaded buf

	cmp.w	d4,d5				; d3 = carte a chargé
	beq	Pas_Test2

	move.w	d4,(a1)+			; sauvegarde
	
	; charche la carte 0
	move.w	#1,-(sp)
	move.w	d4,-(sp)
	jsr	load_card
	addq	#4,sp

Pas_Test2

	; test carte #1
	move.w	(a0)+,d4			; a0 = carte
	move.w	(a1),d5				; d5 = loaded buf

	cmp.w	d4,d5				; d3 = carte a chargé
	beq	Pas_Test3

	move.w	d4,(a1)+			; sauvegarde
	
	; charche la carte 0
	move.w	#2,-(sp)
	move.w	d4,-(sp)
	jsr	load_card
	addq	#4,sp

Pas_Test3

	; test carte #1
	move.w	(a0)+,d4			; a0 = carte
	move.w	(a1),d5				; d5 = loaded buf

	cmp.w	d4,d5				; d3 = carte a chargé
	beq	Pas_Test4

	move.w	d4,(a1)+			; sauvegarde
	
	; charche la carte 0
	move.w	#3,-(sp)
	move.w	d4,-(sp)
	jsr	load_card
	addq	#4,sp

Pas_Test4

	; test carte #1
	move.w	(a0)+,d4			; a0 = carte
	move.w	(a1),d5				; d5 = loaded buf

	cmp.w	d4,d5				; d3 = carte a chargé
	beq	Pas_Test5

	move.w	d4,(a1)+			; sauvegarde
	
	; charche la carte 0
	move.w	#4,-(sp)
	move.w	d4,-(sp)
	jsr	load_card
	addq	#4,sp

Pas_Test5

	unlk	a5
	rts

*******************************************************************************
* FUNCTION:	affiche le jeu du joueur
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_jeu_player:

var_21E56	equ -2

	link	a5,#-2

	clr.b	cards_SpriteIndex
		
	68K_DisableINT
	clr.w	-(sp)
	jsr	load_cards
	addq.w	#2,sp
	68K_EnableINT

	move.w	#4,var_21E56(a5)
	move.w	#4,d6
loc_1E68:
	
	move.w	var_21E56(a5),d3
	ext.l	d3
	asl.l	#2,d3

	lea	(tab_crds_player_cards+2).l,a6
	move.w	(a6,d3.l),-(sp)

	move.w	var_21E56(a5),d3
	ext.l	d3
	asl.l	#2,d3
	lea	(tab_crds_player_cards).l,a6
	move.w	(a6,d3.l),-(sp)

	move.w	var_21E56(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),-(sp)
	
	move.w	var_21E56(a5),cards_Index
	jsr	aff_cards
	addq.w	#6,sp
	
	subq.w	#1,var_21E56(a5)
	dbf	d6,loc_1E68

	jsr	reset_mouse

	clr.w	-(sp)
	move.w	#12,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

	VDP_SetPlaneA	Game_PlaneA
	VDP_SetPlaneB	Game_PlaneB

	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	affiche le jeu du joueur
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_jeu_player2:

var_21E56_2	equ -2

	link	a5,#-2

	clr.b	cards_SpriteIndex
		
*	68K_DisableINT
	clr.w	-(sp)
	jsr	load_cards
	addq.w	#2,sp
*	68K_EnableINT

	move.w	#4,var_21E56_2(a5)
	move.w	#4,d6
loc_1E68_2:
	
	move.w	var_21E56_2(a5),d3
	ext.l	d3
	asl.l	#2,d3

	lea	(tab_crds_player_cards+2).l,a6
	move.w	(a6,d3.l),-(sp)

	move.w	var_21E56_2(a5),d3
	ext.l	d3
	asl.l	#2,d3
	lea	(tab_crds_player_cards).l,a6
	move.w	(a6,d3.l),-(sp)

	move.w	var_21E56_2(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	(a6,d3.l),-(sp)
	
	move.w	var_21E56_2(a5),cards_Index
	jsr	aff_cards
	addq.w	#6,sp
	
	subq.w	#1,var_21E56_2(a5)
	dbf	d6,loc_1E68_2

	jsr	reset_mouse

	clr.w	-(sp)
	move.w	#12,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

	VDP_SetPlaneA	Game_PlaneA
	VDP_SetPlaneB	Game_PlaneB

	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	player_play
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
player_play:

var_2C3B16	equ -$2C
var_283B16	equ -$28
var_203B16	equ -$20
var_183B16	equ -$18
var_143B16	equ -$14
timer_idle3B16	equ -$A
action_res3B16	equ -6
icone_clic3B16	equ -4
wait_clic3B16	equ -2
flag_ok3B16	equ -1

	link	a5,#-$A
	clr.w	icone_idx
	clr.b	flag_ok3B16(a5)
	clr.b	wait_clic3B16(a5)
	clr.w	action_res3B16(a5)
	clr.l	timer_idle3B16(a5)

	68K_DisableINT
	clr.w	-(sp)
	move.w	#115,-(sp)	; "It's up to you"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

loc_3B3E:
	move.w	action_res3B16(a5),d0
	tst.w	action_res3B16(a5)
	bne.w	loc_4214

loc_3B46:
	tst.b	flag_ok3B16(a5)
	bne.w	loc_418E
	cmpi.l	#600001,timer_idle3B16(a5)
	bge.s	loc_3B5C
	addq.l	#1,timer_idle3B16(a5)

loc_3B5C:
	tst.w	action_res3B16(a5)
	bne.w	loc_3E16
	tst.w	(nb_encheres).l
	bne.w	loc_3C32
	tst.b	wait_clic3B16(a5)
	bne.s	loc_3B90
	clr.w	icone_idx
	
	68K_DisableINT
	move.w	#ICONE_STAY_BET,-(sp)	; Icones "Stay / Bet"
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	jsr	reset_mouse
	move.b	#80,wait_clic3B16(a5)

loc_3B90:
	; ******** STAY BET **********

	;*** Test des inputs  STAY BET : 2 Icone ***
	PlayerCheckInput 2
	VDP_WaitVSync d0

	move.w	icone_idx,d3
	sub.w	prev_icone_idx,d3
	beq.s	pas_chg_icone
	
	move.w	#ICONE_STAY_BET,d3
	add.w	icone_idx,d3
	
	68K_DisableINT
	move.w	d3,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	

pas_chg_icone:
	
	CheckPlayerInput loc_3C2E

	clr.l	d0
	move.w	icone_idx,d0			; attribue l'icone attention, c base 1
	addq	#1,d0	
	move.w	d0,icone_clic3B16(a5)
	
	68K_DisableINT
	move.w	#ICONE_MAIN,-(sp)		; réaffiche les mains
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	clr.w	icone_idx
	move.w	#1,force_icone

	tst.w	icone_clic3B16(a5)
	beq.s	loc_3C2E			; STAY
	clr.b	wait_clic3B16(a5)
	cmpi.w	#1,icone_clic3B16(a5)
	bne.s	loc_3BF6
	move.w	#1,action_res3B16(a5)
	clr.w	(player_last_bet).l
	move.b	#1,flag_ok3B16(a5)
	bra.s	loc_3C16			; BET

loc_3BF6:
	tst.w	(game_turn).l
	bne.s	loc_3C06
	move.w	#2,action_res3B16(a5)
	bra.s	loc_3C0C

loc_3C06:
	move.w	#4,action_res3B16(a5)

loc_3C0C:
	addq.w	#1,(nb_encheres).l
	clr.l	timer_idle3B16(a5)

loc_3C16:
	jsr	reset_mouse
*	move.w	#3,-(sp)
*	jsr	copy_screen
*	addq.w	#2,sp
	move.w	#20,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_3C2E:
	bra.w	loc_3E12
	
	;*** CALL DROP **********************************************				; VA PAs ca !!!!
loc_3C32:
	cmpi.w	#5,(game_turn).l
	bne.w	loc_3D28
	tst.b	wait_clic3B16(a5)
	bne	loc_3C60

loc_3C60:

tutu0:
	PlayerCheckInput 2
	VDP_WaitVSync d0

	; on force le load ?
	tst.w	force_icone
	bne.s	force_load_cr

	; test si icone est différente
	move.w	icone_idx,d3
	sub.w	prev_icone_idx,d3
	beq.s	pas_chg_icone_cr
		
force_load_cr:
	move.w	#ICONE_CALL_DROP,d3
	add.w	icone_idx,d3
	68K_DisableINT
	move.w	d3,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	clr.w	force_icone

pas_chg_icone_cr:
	jsr	reset_mouse
	move.b	#82,wait_clic3B16(a5)	
	
	CheckPlayerInput loc_3D24
*	lea	$1A+timer_idle3B16(sp),sp
	clr.l	d0
	move.w	icone_idx,d0			; attribue l'icone attention, c base 1
	addq	#1,d0	
	move.w	d0,icone_clic3B16(a5)

	
	68K_DisableINT
	move.w	#ICONE_MAIN,-(sp)		; réaffiche les mains
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT	
	
	clr.w	icone_idx
	move.w	#1,force_icone

	tst.w	icone_clic3B16(a5)
	beq.s	loc_3D24
	clr.b	wait_clic3B16(a5)
	cmpi.w	#2,icone_clic3B16(a5)
	bne.s	loc_3CC6
	move.w	#5,action_res3B16(a5)
	clr.w	(player_last_bet).l
	move.b	#1,flag_ok3B16(a5)
	bra.s	loc_3D0C


loc_3CC6:
	tst.w	(nb_calls).l
	bne.s	loc_3CD4
	subq.w	#3,(game_turn).l

loc_3CD4:
	move.w	#3,action_res3B16(a5)
	clr.w	(player_last_bet).l
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3
	sub.w	d3,(player_pot).l
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3
	add.w	d3,(poker_pot).l
	clr.w	(teen_last_bet).l
	move.b	#1,flag_ok3B16(a5)

loc_3D0C:
	jsr	reset_mouse
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	move.w	#$14,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_3D24:
	bra.w	loc_3E12
loc_3D28:
	
	; *** CALL RAISE DROP ***************************************
	PlayerCheckInput 3
	VDP_WaitVSync d0

	; on force le load ?
	tst.w	force_icone
	bne.s	force_load_crd

	; test si icone est différente
	move.w	icone_idx,d3
	sub.w	prev_icone_idx,d3
	beq.s	pas_chg_icone_crd
		
force_load_crd:
	move.w	#ICONE_CALL_RAISE_DROP,d3		; call raise drop
	add.w	icone_idx,d3
	
	68K_DisableINT
	move.w	d3,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	clr.w	force_icone

pas_chg_icone_crd:
	jsr	reset_mouse
	move.b	#81,wait_clic3B16(a5)

loc_3D4A
	CheckPlayerInput loc_3E12

*	lea	$1A+timer_idle3B16(sp),sp

	clr.l	d0
	move.w	icone_idx,d0			; attribue l'icone attention, c base 1
	addq	#1,d0	
	move.w	d0,icone_clic3B16(a5)

	
	68K_DisableINT
	move.w	#ICONE_MAIN,-(sp)		; réaffiche les mains
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	clr.w	icone_idx
	move.w	#1,force_icone

	tst.w	icone_clic3B16(a5)
	beq.w	loc_3E12
	clr.b	wait_clic3B16(a5)
	cmpi.w	#1,icone_clic3B16(a5)
	bne.s	loc_3DD8
	move.w	#3,action_res3B16(a5)
	clr.w	(player_last_bet).l
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3
	sub.w	d3,(player_pot).l
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3
	add.w	d3,(poker_pot).l
	clr.w	(teen_last_bet).l
	move.b	#1,flag_ok3B16(a5)
	bra.s	loc_3DFA


loc_3DD8:
	cmpi.w	#2,icone_clic3B16(a5)
	bne.s	loc_3DE8
	move.w	#4,action_res3B16(a5)
	bra.s	loc_3DFA

loc_3DE8:
	move.w	#5,action_res3B16(a5)
	clr.w	(player_last_bet).l
	move.b	#1,flag_ok3B16(a5)

loc_3DFA:
	jsr	reset_mouse
*		move.w	#3,-(sp)
*		jsr	copy_screen
*	addq.w	#2,sp
	move.w	#$14,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_3E12:
	bra.w	loc_3EE8

loc_3E16:
	cmpi.w	#2,action_res3B16(a5)
	beq.s	loc_3E28
	cmpi.w	#4,action_res3B16(a5)
	bne.w	loc_3EE8

loc_3E28:
	; *** BET ******************************************
	PlayerCheckInput 5
	VDP_WaitVSync d0

	; on force le load ?
	tst.w	force_icone
	bne.s	force_load_bet

	; test si icone est différente
	move.w	icone_idx,d3
	sub.w	prev_icone_idx,d3
	beq.s	pas_chg_icone_bet
		
force_load_bet:
	move.w	#ICONE_BET_CHOICE,d3
	add.w	icone_idx,d3
	
	68K_DisableINT
	move.w	d3,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	clr.w	force_icone

pas_chg_icone_bet:
	jsr	reset_mouse
	move.b	#114,wait_clic3B16(a5)

loc_3E4A
	CheckPlayerInput loc_3EE8

*	lea	$1A+timer_idle3B16(sp),sp			; SUPER ZARBI CE TRUUUUUUC
	clr.l	d0
	move.w	icone_idx,d0			; attribue l'icone attention, c base 1
	addq	#1,d0	
	move.w	d0,icone_clic3B16(a5)

	
	68K_DisableINT
	move.w	#ICONE_MAIN,-(sp)		; réaffiche les mains
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	clr.w	icone_idx
	move.w	#1,force_icone

	tst.w	icone_clic3B16(a5)
	beq.s	loc_3EE8
	clr.b	wait_clic3B16(a5)
	move.w	icone_clic3B16(a5),(player_last_bet).l
	move.w	(teen_last_bet).l,d3
	add.w	icone_clic3B16(a5),d3
	mulu.w	#5,d3
	sub.w	d3,(player_pot).l
	move.w	(teen_last_bet).l,d3
	add.w	icone_clic3B16(a5),d3
	mulu.w	#5,d3
	add.w	d3,(poker_pot).l
	clr.w	(teen_last_bet).l
	move.b	#1,flag_ok3B16(a5)
	jsr	reset_mouse
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	move.w	#20,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_3EE8:
	moveq	#0,d3
	move.b	(byte_7D42).l,d3
	moveq	#0,d2
	move.b	(byte_7D3E).l,d2
	or.w	d2,d3
	and.w	#$80,d3	; '€'
	moveq	#0,d2
	move.b	(byte_7D36).l,d2
	or.w	d2,d3
	tst.w	d3
	beq.w	loc_3FF0
	moveq	#0,d3
	move.b	(mouse_btn).l,d3
	tst.w	d3
	bne.w	loc_3FF0
	jsr	reset_mouse
*	clr.w	-(sp)
*	jsr	copy_screen
*	addq.w	#2,sp
	clr.w	(word_848C).l
	jsr	reset_mouse
	cmpi.w	#8,(num_cur_pic).l
	ble.s	loc_3F62
	move.w	#$11,-(sp)
	jsr	(call_trap14).l
	addq.w	#2,sp
	moveq	#4,d1
	jsr	(modulo32).l
	move.w	d0,icone_clic3B16(a5)
	clr.w	-(sp)
	move.w	icone_clic3B16(a5),-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

loc_3F62:
	jsr	wait_10s_or_clic
	move.w	#1,(word_848C).l
	jsr	reset_mouse
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	moveq	#0,d0
	move.b	wait_clic3B16(a5),d0
	bra.s	loc_3FD4


loc_3F84:
	
	68K_DisableINT
	move.w	#ICONE_STAY_BET,-(sp)	; Icones "Stay/Bet"
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_3FEC


loc_3F98:
	
	68K_DisableINT
	move.w	#ICONE_CALL_RAISE_DROP,-(sp)	; Icones "Call/Raise/Drop"
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_3FEC

loc_3FAC:
	
	68K_DisableINT
	move.w	#ICONE_CALL_DROP,-(sp)	; Icones "Call/Drop"
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_3FEC

loc_3FC0:
	
	68K_DisableINT
	move.w	#ICONE_BET_CHOICE,-(sp)	; Icones mises "5..25"
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_3FEC

loc_3FD4:
	sub.l	#80,d0
	beq.s	loc_3F84
	subq.l	#1,d0
	beq.s	loc_3F98
	subq.l	#1,d0
	beq.s	loc_3FAC
	sub.l	#32,d0
	beq.s	loc_3FC0
	nop
loc_3FEC:
	jsr	reset_mouse

loc_3FF0:
	cmpi.l	#600000,timer_idle3B16(a5)
	bne.w	loc_418A
	clr.w	icone_clic3B16(a5)

*loc_4000:				; CODE XREF: player_play+510j
*		move.w	#4,-(sp)
*		move.w	icone_clic3B16(a5),-(sp)
*		move.w	#319,-(sp)
*		move.w	icone_clic3B16(a5),-(sp)
*		clr.w	-(sp)
*		jsr	(sub_4FE2).l
*		lea	$1E+var_143B16(sp),sp
*		addq.w	#1,icone_clic3B16(a5)
*		cmpi.w	#200,icone_clic3B16(a5)
*		blt.s	loc_4000
*		move.w	#2,-(sp)
*		clr.w	-(sp)
*		move.w	#319,-(sp)
*		clr.w	-(sp)
*		clr.w	-(sp)
*		jsr	(sub_4FE2).l
*		lea	$22+var_183B16(sp),sp
*		move.w	#2,-(sp)
*		move.w	#199,-(sp)
*		move.w	#319,-(sp)
*		clr.w	-(sp)
*		move.w	#319,-(sp)
*		jsr	(sub_4FE2).l
*		lea	$2A+var_203B16(sp),sp
*		move.w	#2,-(sp)
*		move.w	#199,-(sp)
*		clr.w	-(sp)
*		move.w	#199,-(sp)
*		move.w	#319,-(sp)
*		jsr	(sub_4FE2).l
*		lea	$32+var_283B16(sp),sp
*		move.w	#2,-(sp)
*		clr.w	-(sp)
*		clr.w	-(sp)
*		move.w	#199,-(sp)
*		clr.w	-(sp)
*		jsr	(sub_4FE2).l
*		lea	$36+var_2C3B16(sp),sp
*		move.w	#1,-(sp)
*		clr.w	-(sp)
*		move.w	#127,-(sp)	; Image	pause part1
*		jsr	aff_sprite
*		addq.w	#6,sp
*		move.w	#1,-(sp)
*		move.w	#128,-(sp)
*		move.w	#128,-(sp)	; Image	pause part2
*		jsr	aff_sprite
*		addq.w	#6,sp
*		move.w	#145,-(sp)
*		clr.w	-(sp)
*		move.w	#124,-(sp)	; Bandeau 1
*		jsr	aff_sprite
*		addq.w	#6,sp
*		move.w	#145,-(sp)
*		move.w	#128,-(sp)
*		move.w	#125,-(sp)	; Bandeau 2
*		jsr	aff_sprite
*		addq.w	#6,sp
*		move.w	#145,-(sp)
*		move.w	#256,-(sp)
*		move.w	#126,-(sp)	; Bandeau 3
*		jsr	aff_sprite
*		addq.w	#6,sp
*		jsr	reset_mouse
*		clr.w	-(sp)
*		move.w	#115,-(sp)	; "It's up to you"
*		jsr	aff_message
*		addq.w	#4,sp
*		jsr	aff_jeu_player
*		jsr	aff_pots
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
*		moveq	#0,d0
*		move.b	wait_clic3B16(a5),d0
*		bra.s	loc_4160

loc_4110:
	
	68K_DisableINT
	move.w	#ICONE_STAY_BET,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_4178

loc_4124:
	
	68K_DisableINT
	move.w	#ICONE_CALL_RAISE_DROP,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_4178

loc_4138
	
	68K_DisableINT
	move.w	#ICONE_CALL_DROP,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_4178

loc_414C:
	
	68K_DisableINT
	move.w	#ICONE_BET_CHOICE,-(sp)
	jsr	aff_icone
	addq.w	#2,sp
	68K_EnableINT
	
	bra.s	loc_4178

loc_4160:
	sub.l	#80,d0
	beq.s	loc_4110
	subq.l	#1,d0
	beq.s	loc_4124
	subq.l	#1,d0
	beq.s	loc_4138
	sub.l	#32,d0
	beq.s	loc_414C

loc_4178:
	jsr	reset_mouse
	clr.w	-(sp)
	move.w	#8,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

loc_418A:
	bra.w	loc_3B46

loc_418E:
	jsr	aff_pots
	cmpi.w	#5,action_res3B16(a5)
	beq.s	loc_41AC
	cmpi.w	#1,action_res3B16(a5)
	beq.s	loc_41AC
	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_41AC:
	cmpi.w	#3,action_res3B16(a5)
	bne.s	loc_4210
	tst.w	(nb_calls).l
	bne.s	loc_4210
	cmpi.w	#5,(game_turn).l
	beq.s	loc_4210
	jsr	player_chg_cards
	jsr	aff_player_new_cards
	jsr	teen_chg_cards
	
	68K_DisableINT
	clr.w	-(sp)
	move.w	#115,-(sp)	; "It's up to you"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	addq.w	#1,(game_turn).l
	addq.w	#1,(nb_calls).l
	jsr	distribue_cards
	jsr	calc_teen_score
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	move.w	#1,(flag_cards_changed).l
	clr.w	(nb_encheres).l
	clr.b	flag_ok3B16(a5)
	clr.w	action_res3B16(a5)

loc_4210:
	bra.w	loc_3B3E

loc_4214:
	move.w	action_res3B16(a5),d0
	unlk	a5
	rts	


*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
teen_chg_cards:

var_l3160	equ -8
var_k3160	equ -6
var_j3160	equ -4
compteur3160	equ -2

	link	a5,#-8
	cmpi.w	#9,(teen_score).l
	bne.w	loc_32A6
	move.w	(teen_cards).l,d3
	ext.l	d3
	divs.w	#10,d3
	swap	d3
	move.w	d3,var_j3160(a5)
	clr.w	var_k3160(a5)
	clr.w	compteur3160(a5)

loc_318A:
	move.w	compteur3160(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	addq.w	#1,d2
	cmp.w	var_j3160(a5),d2
	bne.s	loc_31D4
	addq.w	#1,var_k3160(a5)
	move.w	compteur3160(a5),d3
	addq.w	#1,d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),d2
	ext.l	d2
	divs.w	#10,d2
	swap	d2
	move.w	d2,var_j3160(a5)
	bra.s	loc_31EC

loc_31D4:
	tst.w	var_k3160(a5)
	beq.s	loc_31E6
	move.w	compteur3160(a5),d3
	addq.w	#1,d3
	move.w	d3,var_l3160(a5)
	bra.s	loc_31EC


loc_31E6:
	move.w	compteur3160(a5),var_l3160(a5)

loc_31EC:
	addq.w	#1,compteur3160(a5)
	cmpi.w	#4,compteur3160(a5)
	blt.s	loc_318A
	cmpi.w	#3,var_k3160(a5)
	bne.s	loc_3238
	clr.w	compteur3160(a5)

loc_3204:
	move.w	compteur3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	clr.w	(a6,d3.l)
	addq.w	#1,compteur3160(a5)
	cmpi.w	#5,compteur3160(a5)
	blt.s	loc_3204
	move.w	var_l3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	move.w	#1,(a6,d3.l)
	bra.s	loc_32A2

loc_3238:
	clr.w	var_j3160(a5)
	move.w	#1,compteur3160(a5)

loc_3242:
	move.w	compteur3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	var_j3160(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(teen_cards).l,a1
	move.w	(a6,d3.l),d1
	cmp.w	(a1,d2.l),d1
	ble.s	loc_326E
	move.w	compteur3160(a5),var_j3160(a5)

loc_326E:
	addq.w	#1,compteur3160(a5)
	cmpi.w	#5,compteur3160(a5)
	blt.s	loc_3242
	move.w	var_j3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	cmpi.w	#5,(a6,d3.l)
	ble.s	loc_32A2
	move.w	var_j3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	clr.w	(a6,d3.l)

loc_32A2:
	bra.w	loc_3356

loc_32A6:
	cmpi.w	#4,(teen_score).l
	beq.s	loc_32C4
	cmpi.w	#5,(teen_score).l
	beq.s	loc_32C4
	cmpi.w	#1,(teen_score).l
	bne.s	loc_32E8

loc_32C4:
	clr.w	compteur3160(a5)

loc_32C8:
	move.w	compteur3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	clr.w	(a6,d3.l)
	addq.w	#1,compteur3160(a5)
	cmpi.w	#5,compteur3160(a5)
	blt.s	loc_32C8
	bra.s	loc_3356

loc_32E8:
	cmpi.w	#7,(teen_score).l
	beq.s	loc_3306
	cmpi.w	#8,(teen_score).l
	beq.s	loc_3306
	cmpi.w	#6,(teen_score).l
	bne.s	loc_3356

loc_3306:
	tst.w	(flag_bluff).l
	beq.s	loc_3356
	clr.w	var_j3160(a5)
	move.w	#1,compteur3160(a5)

loc_3318:
	move.w	compteur3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	tst.w	(a6,d3.l)
	beq.s	loc_3332
	move.w	compteur3160(a5),var_j3160(a5)

loc_3332:
	addq.w	#1,compteur3160(a5)
	cmpi.w	#5,compteur3160(a5)
	blt.s	loc_3318
	tst.w	var_j3160(a5)
	beq.s	loc_3356
	move.w	var_j3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	clr.w	(a6,d3.l)

loc_3356:
	clr.w	var_j3160(a5)
	clr.w	compteur3160(a5)

loc_335E:
	move.w	compteur3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_drops).l,a6
	tst.w	(a6,d3.l)
	beq.s	loc_3388
	addq.w	#1,var_j3160(a5)
	move.w	compteur3160(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	clr.w	(a6,d3.l)

loc_3388:
	addq.w	#1,compteur3160(a5)
	cmpi.w	#5,compteur3160(a5)
	blt.s	loc_335E

	68K_DisableINT
	move.w	var_j3160(a5),-(sp)
	move.w	#105,-(sp)	; "I change n cards"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
teen_play:

flag33B0	equ -4
action33B0	equ -2

	link	a5,#-4
	clr.w	action33B0(a5)

loc_33B8:
	tst.w	action33B0(a5)
	bne.w	loc_39B4
	tst.w	(game_turn).l
	bne	loc_3438
	
	move.w	(player_last_bet).l,d0
	ext.l	d0
	bra.s	loc_3422

loc_33D2:
	move.w	#8,(player_expected_score).l
	bra.s	loc_3434

loc_33DC:
	move.w	#8,(player_expected_score).l
	bra.s	loc_3434

loc_33E6:
	move.w	(teen_eval_modifier).l,d3
	addq.w	#7,d3
	move.w	d3,(player_expected_score).l
	bra.s	loc_3434

loc_33F6:
	move.w	(teen_eval_modifier).l,d3
	addq.w	#6,d3
	move.w	d3,(player_expected_score).l
	bra.s	loc_3434

loc_3406:	
	move.w	(teen_eval_modifier).l,d3
	addq.w	#6,d3
	move.w	d3,(player_expected_score).l
	bra.s	loc_3434

word_3416:
	dc.l loc_3434
	dc.l loc_33D2
	dc.l loc_33DC
	dc.l loc_33E6
	dc.l loc_33F6
	dc.l loc_3406

loc_3422:
	cmp.l	#6,d0
	bcc.s	loc_3434
	asl.l	#2,d0
	lea.l	word_3416,a0
	move.l	0(a0,d0.w),a0
	jmp (a0)

loc_3434:
	bra.w	loc_34FC

loc_3438:
	cmpi.w	#1,(game_turn).l
	bne	loc_34B6
	move.w	(player_last_bet).l,d0
	ext.l	d0
	bra.s	loc_34A2

loc_344C:
	move.w	#8,(player_expected_score).l
	bra.s	loc_34B4

loc_3456:
	move.w	(teen_eval_modifier).l,d3
	addq.w	#7,d3
	move.w	d3,(player_expected_score).l
	bra.s	loc_34B4

loc_3466:
	move.w	(teen_eval_modifier).l,d3
	addq.w	#7,d3
	move.w	d3,(player_expected_score).l
	bra.s	loc_34B4

loc_3476:
	move.w	(teen_eval_modifier).l,d3
	addq.w	#6,d3
	move.w	d3,(player_expected_score).l
	bra.s	loc_34B4

loc_3486
	move.w	(teen_eval_modifier).l,d3
	addq.w	#5,d3
	move.w	d3,(player_expected_score).l
	bra.s	loc_34B4

word_3496:
	dc.l loc_34B4
	dc.l loc_344C
	dc.l loc_3456
	dc.l loc_3466
	dc.l loc_3476
	dc.l loc_3486

loc_34A2:
	cmp.l	#6,d0
	bcc.s	loc_34B4
	asl.l	#2,d0
	lea.l	word_3496,a0
	move.l	0(a0,d0.w),a0
	jmp (a0)

loc_34B4:
	bra.s	loc_34FC

loc_34B6:
	move.w	(player_last_bet).l,d0
	ext.l	d0
	bra.s	loc_34F0

loc_34C0:
	move.w	(flag_bluff).l,d3
	addq.w	#1,d3
	sub.w	d3,(player_expected_score).l
	bra.s	loc_34FC

loc_34D0:
	move.w	(flag_bluff).l,d3
	addq.w	#1,d3
	sub.w	d3,(player_expected_score).l
	bra.s	loc_34FC

loc_34E0:
	move.w	(flag_bluff).l,d3
	addq.w	#1,d3
	sub.w	d3,(player_expected_score).l
	bra.s	loc_34FC

loc_34F0:
	subq.l	#3,d0
	beq.s	loc_34C0
	subq.l	#1,d0
	beq.s	loc_34D0
	subq.l	#1,d0
	beq.s	loc_34E0

loc_34FC:
	cmpi.w	#1,(nb_calls).l
	bne.w	loc_358C
	addq.w	#1,(nb_calls).l
	move.w	(nb_player_chg_cards).l,d0
	ext.l	d0
	bra.s	loc_357A

loc_3518:
	tst.w	(flag_cards_changed).l
	bne.s	loc_352E
	move.w	(teen_eval_modifier).l,d3
	addq.w	#3,d3
	move.w	d3,(player_expected_score).l
loc_352E:
	bra.s	loc_358C

loc_3530:
	tst.w	(flag_cards_changed).l
	bne.s	loc_3546
	moveq	#7,d3
	sub.w	(teen_eval_modifier).l,d3
	move.w	d3,(player_expected_score).l

loc_3546:
	bra.s	loc_358C

loc_3548:
	tst.w	(flag_cards_changed).l
	bne.s	loc_3558
	move.w	#6,(player_expected_score).l

loc_3558:
	bra.s	loc_358C

loc_355A:
	move.w	#8,(player_expected_score).l
	bra.s	loc_358C

loc_3564:
	move.w	#9,(player_expected_score).l
	bra.s	loc_358C

word_356E:	
	dc.l loc_3518
	dc.l loc_3530
	dc.l loc_3548
	dc.l loc_355A
	dc.l loc_3564
	dc.l loc_3564

loc_357A:
	cmp.l	#6,d0
	bcc.s	loc_358C
	asl.l	#2,d0
	lea.l	word_356E,a0
	move.l	0(a0,d0.w),a0
	jmp (a0)

loc_358C:
	tst.w	(nb_encheres).l
	beq.w	loc_375A
	cmpi.w	#5,(game_turn).l
	bne.s	loc_3600
	move.w	(teen_score).l,d3
	cmp.w	(player_expected_score).l,d3
	bgt.s	loc_35F0
	tst.w	(nb_calls).l
	bne.s	loc_35BC
	subq.w	#3,(game_turn).l

loc_35BC:
	move.w	#3,action33B0(a5)
	clr.w	(teen_last_bet).l
	move.w	(player_last_bet).l,d3
	mulu.w	#5,d3
	sub.w	d3,(teen_pot).l
	move.w	(player_last_bet).l,d3
	mulu.w	#5,d3
	add.w	d3,(poker_pot).l
	clr.w	(player_last_bet).l
	bra.s	loc_35FC

loc_35F0:
	move.w	#5,action33B0(a5)
	clr.w	(teen_last_bet).l

loc_35FC:
	bra.w	loc_3756

loc_3600:
	tst.w	(flag_bluff).l
	beq.s	loc_360E
	addq.w	#1,(player_expected_score).l

loc_360E:
	cmpi.w	#1,(game_turn).l
	ble.s	loc_3620
	move.w	#1,flag33B0(a5)
	bra.s	loc_3624

loc_3620:
	clr.w	flag33B0(a5)

loc_3624:
	move.w	(teen_score).l,d3
	cmp.w	(player_expected_score).l,d3
	beq.s	loc_367A
	move.w	(teen_score).l,d3
	cmp.w	(player_expected_score).l,d3
	ble.s	loc_3650
	moveq	#8,d3
	sub.w	flag33B0(a5),d3
	move.w	(teen_score).l,d2
	cmp.w	d3,d2
	blt.s	loc_367A

loc_3650:
	move.w	(teen_score).l,d3
	cmp.w	(player_expected_score).l,d3
	ble.s	loc_3666
	tst.w	(flag_bluff).l
	bne.s	loc_367A

loc_3666:
	cmpi.w	#9,(teen_score).l
	bne.s	loc_36B0
	cmpi.w	#15,(poker_pot).l
	bne.s	loc_36B0

loc_367A:
	move.w	#3,action33B0(a5)
	clr.w	(teen_last_bet).l
	move.w	(player_last_bet).l,d3
	mulu.w	#5,d3
	sub.w	d3,(teen_pot).l
	move.w	(player_last_bet).l,d3
	mulu.w	#5,d3
	add.w	d3,(poker_pot).l
	clr.w	(player_last_bet).l
	bra.w	loc_3756

loc_36B0:
	move.w	(teen_score).l,d3
	cmp.w	(player_expected_score).l,d3
	bge.w	loc_374A
	move.w	#4,action33B0(a5)
	tst.w	(flag_bluff).l
	beq.s	loc_3700
	cmpi.w	#7,(teen_score).l
	bne.s	loc_36E2
	move.w	#5,(teen_last_bet).l
	bra.s	loc_36FE

loc_36E2:
	cmpi.w	#8,(teen_score).l
	bne.s	loc_36F6
	move.w	#4,(teen_last_bet).l
	bra.s	loc_36FE

loc_36F6:
	move.w	#3,(teen_last_bet).l

loc_36FE:
	bra.s	loc_3716

loc_3700:
	moveq	#10,d3
	sub.w	(teen_score).l,d3
	ext.l	d3
	divs.w	#3,d3
	addq.w	#1,d3
	move.w	d3,(teen_last_bet).l

loc_3716:
	move.w	(teen_last_bet).l,d3
	add.w	(player_last_bet).l,d3
	mulu.w	#5,d3
	sub.w	d3,(teen_pot).l
	move.w	(teen_last_bet).l,d3
	add.w	(player_last_bet).l,d3
	mulu.w	#5,d3
	add.w	d3,(poker_pot).l
	clr.w	(player_last_bet).l
	bra.s	loc_3756

loc_374A:
	move.w	#5,action33B0(a5)
	clr.w	(teen_last_bet).l

loc_3756:
	bra.w	loc_3892

loc_375A:
	move.w	(teen_score).l,d3
	cmp.w	(player_expected_score).l,d3
	blt.s	loc_37BA
	tst.w	(game_turn).l
	beq.s	loc_377E
	move.w	#1,action33B0(a5)
	clr.w	(teen_last_bet).l
	bra.s	loc_37B6

loc_377E:
	cmpi.w	#10,(poker_pot).l
	bgt.s	loc_3796
	move.w	#1,action33B0(a5)
	clr.w	(teen_last_bet).l
	bra.s	loc_37B6

loc_3796:
	move.w	#2,action33B0(a5)
	move.w	#1,(teen_last_bet).l
	subq.w	#5,(teen_pot).l
	addq.w	#5,(poker_pot).l
	addq.w	#1,(nb_encheres).l

loc_37B6:
	bra.w	loc_3892

loc_37BA:
	cmpi.w	#9,(teen_score).l
	bge.w	loc_3892
	tst.w	(game_turn).l
	bne.s	loc_37D6
	move.w	#2,action33B0(a5)
	bra.s	loc_37DC

loc_37D6:
	move.w	#4,action33B0(a5)

loc_37DC:
	addq.w	#1,(nb_encheres).l
	tst.w	(flag_bluff).l
	beq.s	loc_381C
	cmpi.w	#6,(teen_score).l
	bgt.s	loc_37FE
	move.w	#2,(teen_last_bet).l
	bra.s	loc_381A

loc_37FE:
	cmpi.w	#8,(teen_score).l
	bne.s	loc_3812
	move.w	#3,(teen_last_bet).l
	bra.s	loc_381A

loc_3812:
	move.w	#4,(teen_last_bet).l

loc_381A:
	bra.s	loc_3872

loc_381C:
	cmpi.w	#6,(teen_score).l
	bge.s	loc_3842
	tst.w	(flag_bluff).l
	beq.s	loc_3838
	move.w	#2,(teen_last_bet).l
	bra.s	loc_3840

loc_3838:
	move.w	#4,(teen_last_bet).l

loc_3840:
	bra.s	loc_3872

loc_3842:
	cmpi.w	#7,(teen_score).l
	bge.s	loc_3856
	move.w	#3,(teen_last_bet).l
	bra.s	loc_3872

loc_3856:
	cmpi.w	#8,(teen_score).l
	bge.s	loc_386A
	move.w	#2,(teen_last_bet).l
	bra.s	loc_3872

loc_386A:
	move.w	#1,(teen_last_bet).l

loc_3872:
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3
	sub.w	d3,(teen_pot).l
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3
	add.w	d3,(poker_pot).l

loc_3892:
	cmpi.w	#3,action33B0(a5)
	bne.s	loc_3908

	68K_DisableINT
	clr.w	-(sp)
	move.w	#107,-(sp)	; "I call"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	jsr	aff_pots

	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	tst.w	(nb_calls).l
	bne.s	loc_3904
	cmpi.w	#5,(game_turn).l
	beq.s	loc_3904
	jsr	teen_chg_cards
	jsr	player_chg_cards
	jsr	aff_player_new_cards
	addq.w	#1,(game_turn).l
	addq.w	#1,(nb_calls).l
	jsr	distribue_cards
	jsr	calc_teen_score
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	clr.w	(nb_encheres).l
	clr.w	action33B0(a5)

loc_3904:
	bra.w	loc_39B0

loc_3908:
	cmpi.w	#1,action33B0(a5)
	bne.s	loc_392A

	68K_DisableINT
	clr.w	-(sp)
	move.w	#108,-(sp)	; "I stay"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp
	bra.w	loc_39B0

loc_392A:
	cmpi.w	#5,action33B0(a5)
	bne.s	loc_394A

	68K_DisableINT
	clr.w	-(sp)
	move.w	#110,-(sp)	; "I drop"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#100,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	bra	loc_39B0

loc_394A:
	cmpi.w	#2,action33B0(a5)
	bne.s	loc_3982
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3

	68K_DisableINT
	move.w	d3,-(sp)
	move.w	#106,-(sp)	; "I bet"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	jsr	aff_pots
	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	bra.s	loc_39B0


loc_3982:
	move.w	(teen_last_bet).l,d3
	mulu.w	#5,d3

	68K_DisableINT
	move.w	d3,-(sp)
	move.w	#109,-(sp)	; "I raise"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT

	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

	jsr	aff_pots
	
	move.w	#50,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_39B0:
	bra.w	loc_33B8

loc_39B4:
	move.w	action33B0(a5),d0
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
calc_winner:

winner3118	equ -2
	link	a5,#-2
	clr.w	winner3118(a5)
	jsr	calc_player_score
	move.w	(teen_score).l,d3
	cmp.w	(player_score).l,d3
	bge.s	loc_313A
	move.w	#10,winner3118(a5)	; Teen win
	bra.s	loc_3158

loc_313A:
	move.w	(teen_score).l,d3
	cmp.w	(player_score).l,d3
	ble.s	loc_3150
	move.w	#11,winner3118(a5)	; Player win
	bra.s	loc_3158

loc_3150:
	jsr	sub_308C
	move.w	d0,winner3118(a5)

loc_3158:
	move.w	winner3118(a5),d0
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	appelée par calc_winner
* PARAMETERS:	
*******************************************************************************
sub_308C:

compteur308C	equ -4
winner308C	equ -2

	link	a5,#-4
	clr.w	winner308C(a5)
	clr.w	compteur308C(a5)

loc_3098:
	tst.w	winner308C(a5)
	bne.s	loc_30F8
	move.w	compteur308C(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_teen).l,a6
	move.w	compteur308C(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(calc_cards_player).l,a1
	move.w	(a6,d3.l),d1
	cmp.w	(a1,d2.l),d1
	ble.s	loc_30CC
	move.w	#10,winner308C(a5)
	bra.s	loc_30F8


loc_30CC:
	move.w	compteur308C(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(calc_cards_teen).l,a6
	move.w	compteur308C(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(calc_cards_player).l,a1
	move.w	(a6,d3.l),d1
	cmp.w	(a1,d2.l),d1
	bge.s	loc_30F8
	move.w	#11,winner308C(a5)

loc_30F8:
	addq.w	#1,compteur308C(a5)
	cmpi.w	#5,compteur308C(a5)
	blt.s	loc_3098
	tst.w	winner308C(a5)
	bne.s	loc_3110
	move.w	#12,winner308C(a5)

loc_3110:
	move.w	winner308C(a5),d0
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
player_chg_cards:

carte39BC		equ -4
flag_right_clic39BC	equ -1

	link	a5,#-4
	clr.b	flag_right_clic39BC(a5)

	68K_DisableINT
	clr.w	-(sp)
	move.w	#104,-(sp)	; "Change cards"
	jsr	aff_message
	addq.w	#4,sp
	68K_EnableINT
	
	clr.w	icone_idx

loc_39D8:

	PlayerCheckInput 5
	VDP_WaitVSync d0

;*** affiche le marker ***

	; calcule X & Y
	move.w	icone_idx,d3
	ext.l	d3
	asl.l	#2,d3
	lea	(tab_crds_player_cards+2).l,a6
	move.w	(a6,d3.l),d2
	sub.w	#26,d2
	move.w	d2,d0				; d0=Y
	move.w	icone_idx,d3
	ext.l	d3
	asl.l	#2,d3
	lea	(tab_crds_player_cards).l,a6
	move.w	(a6,d3.l),d2
	addq.w	#3,d2
	move.w	d2,d1				; d1=X

	; insere le sprite maintenant
*	move.w	hide_panel,d5
*	tst.w	d5
*	bne	no_marker
	
	lea	marker_buf,a2

	move.w	d0,d5
*	add.w	#16,d5				; différence Y MD & ST
	addi	#128,d5
	move.w	d5,(a2)+
	
	; Taille + Link
	clr.w	d5
	or.w	#%011100000000,d5
	move.w	d5,(a2)+

	; Sprite pattern
	move.w	marker_VRAMAddr,d5
	lsr.w	#5,d5
	or.w	#$C000,d5			; Priority bit + Palette #2 #1 10 0
	move.w	d5,(a2)+

	; X
	move.w	d1,d5
	addi	#128,d5
	move.w	d5,(a2)+

	; test si on a appuier
	tst.b	flag_right_clic39BC(a5)
	bne.w	loc_3AE2			; sortie du mode chg cartes
	moveq	#0,d3

no_marker:


	CheckPlayerInput loc_3ACA

	move.w	icone_idx,d0
	addq.w	#1,d0

	move.w	d0,carte39BC(a5)		; contient la carte sur laquelle on a cliqué
	tst.w	carte39BC(a5)
	beq.w	loc_3AC8

	cmpi.w	#5,carte39BC(a5)
	bge.s	loc_3A36
	subq.w	#1,carte39BC(a5)		; 0 -> 4
	bra.s	loc_3A3C

loc_3A36:
	move.w	#4,carte39BC(a5)

loc_3A3C:
	move.w	carte39BC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6

	tst.w	(a6,d3.l)
	bne.s	loc_3A86
		
	move.w	carte39BC(a5),d3			; si carte=0 la carte était deja en drop
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	move.w	carte39BC(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(player_drops).l,a1
	move.w	(a1,d2.l),(a6,d3.l)			; copie player_drop->player_cards[carte]=0

	move.w	carte39BC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_drops).l,a6


*	lea.l	loaded_cards,a4
*	move.w	icone_idx,d5
*	asl.l	#1,d5
*	clr.w	(a4,d5.w)

	move.w	icone_idx,-(sp)
	move.w	(a6,d3.l),-(sp)
	jsr	load_card
	addq	#4,sp

	clr.w	(a6,d3.l)				; efface player_drops
	bra.s	loc_3ABA

loc_3A86:						; carte>0
	
	move.w	icone_idx,-(sp)				; retourne la carte
	move.w	#50,d3
	add.w	deck_num,d3
	move.w	d3,-(sp)
	jsr	load_card
	addq	#4,sp

	move.w	carte39BC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_drops).l,a6
	move.w	carte39BC(a5),d2
	ext.l	d2
	asl.l	#1,d2
	lea	(player_cards).l,a1
	move.w	(a1,d2.l),(a6,d3.l)			; player_drops = player_cards
	move.w	carte39BC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	clr.w	(a6,d3.l)				; efface player_cards

loc_3ABA:
	nop
*	jsr	aff_cards_markers
*	move.w	#20,-(sp)				; fait foirer la sélection 
*	jsr	wait_n_vbl
*	addq.w	#2,sp

loc_3AC8:
	bra.s	loc_3ADE

loc_3ACA:
	moveq	#0,d3
*	move.b	(mouse_btn).l,d3
*	cmp.w	#1,d3
	CheckPlayerValidation
	beq.s	loc_3ADE
	move.b	#1,flag_right_clic39BC(a5)

loc_3ADE:	
	bra.w	loc_39D8

loc_3AE2:
	clr.w	(nb_player_chg_cards).l
	clr.w	carte39BC(a5)

; calcule le nb de cartes changee
loc_3AEC:
	move.w	carte39BC(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	tst.w	(a6,d3.l)
	bne.s	loc_3B06
	addq.w	#1,(nb_player_chg_cards).l

loc_3B06:
	addq.w	#1,carte39BC(a5)
	cmpi.w	#5,carte39BC(a5)
	blt.s	loc_3AEC

; efface le marker
	lea	marker_buf,a6
	clr.l	(a6)+
	clr.l	(a6)+

	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_player_new_cards:

flag_changed1F60	equ -6
compteur21F60		equ -4
compteur11F60		equ -2

	link	a5,#-6
	clr.w	flag_changed1F60(a5)
	
	clr.w	-(sp)
	move.w	#7,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

	clr.w	compteur11F60(a5)

loc_1F7A:
	clr.w	compteur21F60(a5)

loc_1F7E:	
	move.w	compteur21F60(a5),d3		; index de player_cards
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	tst.w	(a6,d3.l)
	bne.s	loc_1FBC

; change la carte 
	move.w	compteur21F60(a5),d3	
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6

	move.l	d3,-(sp)
	move.l	a6,-(sp)
	jsr	get_random_gamecard
	movea.l	(sp)+,a6
	move.l	(sp)+,d3
	move.w	d0,(a6,d3.l)

	move.w	#10,compteur21F60(a5)		; nb frame 
	move.w	#1,flag_changed1F60(a5)

; on a tjrs une carte (cas normal)
loc_1FBC:
	addq.w	#1,compteur21F60(a5)
	cmpi.w	#5,compteur21F60(a5)		; si changé, alors continue
	blt.s	loc_1F7E
	tst.w	flag_changed1F60(a5)
	beq.w	loc_20CC
	jsr	reset_mouse
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	clr.w	compteur21F60(a5)

loc_1FE2:
	move.w	compteur21F60(a5),d3		; boucle 0->5
	ext.l	d3
	asl.l	#1,d3
	lea	(player_cards).l,a6
	tst.w	(a6,d3.l)
	beq.s	loc_2034
	
	move.w	compteur21F60(a5),-(sp)		; retourne la carte
	move.w	(a6,d3.l),-(sp)
	jsr	load_card
	addq	#4,sp

*	move.w	compteur21F60(a5),d3
*	ext.l	d3
*	asl.l	#2,d3
*	lea	(tab_crds_player_cards+2).l,a6
*	move.w	(a6,d3.l),-(sp)			; -sp = Y
*	move.w	compteur21F60(a5),d3
*	ext.l	d3
*	asl.l	#2,d3
*	lea	(tab_crds_player_cards).l,a6
*	move.w	(a6,d3.l),-(sp)			; -sp = X
*
*	move.w	compteur21F60(a5),d3
*	ext.l	d3
*	asl.l	#1,d3
*	lea	(player_cards).l,a6
*	move.w	(a6,d3.l),-(sp)
*	jsr	aff_cards
*	addq.w	#6,sp

	bra.s	loc_2070

; Carte =0
loc_2034:
*	move.w	compteur21F60(a5),d3
*	ext.l	d3
*	asl.l	#2,d3
*	lea	(tab_crds_player_cards+2).l,a6
*	move.w	(a6,d3.l),-(sp)
*	move.w	compteur21F60(a5),d3
*	ext.l	d3
*	asl.l	#2,d3
*	lea	(tab_crds_player_cards).l,a6
*	move.w	(a6,d3.l),-(sp)
	move.w	compteur21F60(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(player_drops).l,a6
*	move.w	(a6,d3.l),-(sp)
*	jsr	aff_cards
*	addq.w	#6,sp

*	move.w	compteur21F60(a5),-(sp)		; retourne la carte
*	move.w	(a6,d3.l),-(sp)
*	jsr	load_card
*	addq	#4,sp



loc_2070:
	addq.w	#1,compteur21F60(a5)
	cmpi.w	#5,compteur21F60(a5)
	blt.w	loc_1FE2
	
*		move.w	#97,-(sp)
*		move.w	#87,-(sp)
*		move.w	#75,-(sp)	; Main gauche
*		jsr	aff_sprite
*		addq.w	#6,sp
*		move.w	#97,-(sp)
*		move.w	#215,-(sp)
*		move.w	#76,-(sp)	; Main droite
*		jsr	aff_sprite
*		addq.w	#6,sp
	jsr	reset_mouse
*		move.w	#3,-(sp)
*		jsr	copy_screen
*		addq.w	#2,sp
	clr.w	flag_changed1F60(a5)
	clr.w	-(sp)
	move.w	#9,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp
	move.w	#25,-(sp)
	jsr	wait_n_vbl
	addq.w	#2,sp

loc_20CC:
	addq.w	#1,compteur11F60(a5)
	cmpi.w	#5,compteur11F60(a5)
	blt.w	loc_1F7A
	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_marker

	rts

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
hide_mouse:

	rts

wait_clic:
	rts

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
wait_10s_or_clic:
	nop
	rts

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
aff_teen_cards:

var_220DE	equ -2

	link	a5,#-2
*	bsr	PAL_FadeOut2
*	
	move.b	#1,flag_aff_teen
	clr.b	flag_aff_mains

	VDP_SetPlaneA	Game_PlaneB

	jsr	ClearCardsBuf

	68K_DisableINT

	VDP_SetPlaneA	Game_PlaneB

	clr.w	flag_redraw_main

	clr.l	d1
	clr.l	d3
	clr.l	d2
	clr.l	d4
	clr.l	d5
	move.w	mains_VRAMAddr,d4
	lsr.w	#5,d4
	
	move.l	#Teen_Jeu_Chars,d0		; source
	move.w	mains_VRAMAddr,d1		; dest
	move.w	#((Teen_Jeu_Chars_End-Teen_Jeu_Chars)/2),d2
	jsr	VDP_DMA_MEM2VRAMFct
	
	lea.l Teen_Jeu_Map,a0
	VDP_SetVRAMWriteAddr (Game_PlaneA+(64*0)),d1
	move.w	#27,d3				; 28 lignes
Teen_y_loop	
	move.l	d1,VDP_CTRL
	move.w	#39,d2				; 40 lignes
Teen_x_loop	
	move.w	(a0)+,d5
	add.w	d4,d5
	move.w	d5,VDP_DATA
	dbf	d2,Teen_x_loop
	add.l	#$800000,d1
	dbf d3,Teen_y_loop

	

finjeu:
	move.w	asserted_msg2,-(sp)
	move.w	asserted_msg0,-(sp)
	jsr	aff_message
	addq.w	#4,sp

; charge les cartes en vram
	move.w	#1,-(sp)
	jsr	load_cards
	addq.w	#2,sp
	68K_EnableINT

; affiche les carte
	clr.w	d6
	clr.w	var_220DE(a5)
	move.w	#4,var_220DE(a5)
	move.w	#4,d6
loc_2146:
	move.w	var_220DE(a5),d3
	ext.l	d3
	asl.l	#2,d3
	lea	(tab_crds_teen_cards+2).l,a6
	move.w	(a6,d3.l),d2
	add.w	#145,d2
	move.w	d2,-(sp)
	move.w	var_220DE(a5),d3
	ext.l	d3
	asl.l	#2,d3
	lea	(tab_crds_teen_cards).l,a6
	move.w	(a6,d3.l),d2
	add.w	#157,d2
	move.w	d2,-(sp)
	move.w	var_220DE(a5),d3
	ext.l	d3
	asl.l	#1,d3
	lea	(teen_cards).l,a6
	move.w	(a6,d3.l),-(sp)
	move.w	var_220DE(a5),cards_Index
	jsr	aff_cards_teen
	addq.w	#6,sp

	subq.w	#1,var_220DE(a5)
	dbf	d6,loc_2146
	;addq.w	#1,var_220DE(a5)
	;cmpi.w	#5,var_220DE(a5)
	;blt.s	loc_2146
	
	jsr	reset_mouse

	clr.w	-(sp)
	move.w	#12,-(sp)
	jsr	(play_sample).l
	addq.w	#4,sp

	move.w	#1,(flag_redraw_main).l	

	VDP_SetPlaneA	Game_PlaneA

*	lea	cache_palette,a0
*	bsr	PAL_FadeIn1	

	unlk	a5
	rts	

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
update_player_sprites:

*	clr.b	cards_SpriteIndex
*	clr.b	num_SpriteIndex
*	jsr	ClearEngineSprite
*	clr.w	-(sp)
*	jsr	aff_jeu_player
*	addq.w	#2,sp

	rts


