*******************************************************************************
* FILE:		tabs.asm	
* DESCRIPTION:	définition des tableaux
*******************************************************************************

*******************************************************************************
	section M68Kcode
*******************************************************************************
	cnop	0,2
	
GFX_Femme
	; Femme #0
	dc.l	Femme0_00_Chars,(Femme0_00_Chars_End-Femme0_00_Chars),Femme0_00_Map,Femme0_00_Pal

	if !DEMO

	dc.l	Femme0_01_Chars,(Femme0_01_Chars_End-Femme0_01_Chars),Femme0_01_Map,Femme0_01_Pal
	dc.l	Femme0_02_Chars,(Femme0_02_Chars_End-Femme0_02_Chars),Femme0_02_Map,Femme0_02_Pal
	dc.l	Femme0_03_Chars,(Femme0_03_Chars_End-Femme0_03_Chars),Femme0_03_Map,Femme0_03_Pal
	dc.l	Femme0_04_Chars,(Femme0_04_Chars_End-Femme0_04_Chars),Femme0_04_Map,Femme0_04_Pal
	dc.l	Femme0_05_Chars,(Femme0_05_Chars_End-Femme0_05_Chars),Femme0_05_Map,Femme0_05_Pal
	dc.l	Femme0_06_Chars,(Femme0_06_Chars_End-Femme0_06_Chars),Femme0_06_Map,Femme0_06_Pal
	dc.l	Femme0_07_Chars,(Femme0_07_Chars_End-Femme0_07_Chars),Femme0_07_Map,Femme0_07_Pal
	dc.l	Femme0_08_Chars,(Femme0_08_Chars_End-Femme0_08_Chars),Femme0_08_Map,Femme0_08_Pal
	dc.l	Femme0_09_Chars,(Femme0_09_Chars_End-Femme0_09_Chars),Femme0_09_Map,Femme0_09_Pal
	dc.l	Femme0_10_Chars,(Femme0_10_Chars_End-Femme0_10_Chars),Femme0_10_Map,Femme0_10_Pal
	dc.l	Femme0_11_Chars,(Femme0_11_Chars_End-Femme0_11_Chars),Femme0_11_Map,Femme0_11_Pal
	
	endc

GFX_Femme_Entry_Size	equ	6

*******************************************************************************
* Tableau des messages
*******************************************************************************
	cnop	0,2
Messages
	dc.l	You_Win_Pot_Chars
	dc.l	I_Win_Pot_Chars
	dc.l	Change_Cards_Chars
	dc.l	I_Change_Cards_Chars
	dc.l	I_Bet_Cards_Chars
	dc.l	I_Call_Chars
	dc.l	I_Stay_Chars
	dc.l	I_Raise_Chars
	dc.l	I_Drop_Chars
	dc.l	Play_Again_Chars
	dc.l	0,0,0
	dc.l	Up_To_You_Chars
Messages_End

*******************************************************************************
* Icones
*******************************************************************************
ICONE_STAY_BET		equ	80
ICONE_CALL_RAISE_DROP	equ	90
ICONE_CALL_DROP		equ	100
ICONE_BET_CHOICE	equ	110
ICONE_MAIN		equ	120
	
	cnop	0,2
Icones
	dc.l	Icone_Stay_Bet_Chars	; 80
	dc.l	Icone_Stay_Bet1_Chars	; 81
	dc.l	0			; 82
	dc.l	0			; 83
	dc.l	0			; 84
	dc.l	0			; 85
	dc.l	0			; 86
	dc.l	0			; 87
	dc.l	0			; 88
	dc.l	0			; 89

	dc.l	Icone_Call_Raise_Drop	; 90
	dc.l	Icone_Call_Raise_Drop1	; 91
	dc.l	Icone_Call_Raise_Drop2	; 92
	dc.l	0			; 93
	dc.l	0			; 94
	dc.l	0			; 95
	dc.l	0			; 96
	dc.l	0			; 97
	dc.l	0			; 98
	dc.l	0			; 99

	dc.l	Icone_Call_Drop		; 100
	dc.l	Icone_Call_Drop1	; 101
	dc.l	0			; 102
	dc.l	0			; 103
	dc.l	0			; 104
	dc.l	0			; 105
	dc.l	0			; 106
	dc.l	0			; 107
	dc.l	0			; 108
	dc.l	0			; 109

	dc.l	Icone_Bet_Choice	; 110
	dc.l	Icone_Bet_Choice1	; 111
	dc.l	Icone_Bet_Choice2	; 112
	dc.l	Icone_Bet_Choice3	; 113
	dc.l	Icone_Bet_Choice4	; 114
	dc.l	0			; 115
	dc.l	0			; 116
	dc.l	0			; 117
	dc.l	0			; 118
	dc.l	0			; 119

	dc.l	Icone_Main		; 120
	dc.l	0			; 121
	dc.l	0			; 122
	dc.l	0			; 123
	dc.l	0			; 124
	dc.l	0			; 125
	dc.l	0			; 126
	dc.l	0			; 127
	dc.l	0			; 128
	dc.l	0			; 129
Icones_End

Icone_Cycle
	dc.w	$ee,$ae,$4e
	dc.w	$ee,$ae,$4e
	dc.w	$ee,$ae,$4e
*******************************************************************************
* Largeur des nombres
*******************************************************************************
	cnop	0,2
width_spr_numbers:	dc.w	9,6,8,9,8,9,9,7,9,9

	cnop	0,2
tab_crds_player_cards:
		dc.w	168,80+23
		dc.w	183,75+23
		dc.w	198,66+23
		dc.w	213,72+23
		dc.w	228,69+23
tab_crds_teen_cards:
		dc.w	-6,-51+23
		dc.w	26,-54+23
		dc.w	53,-59+23
		dc.w	83,-63+23
		dc.w	112,-66+23

*******************************************************************************
* Son
*******************************************************************************
Sounds:
	dc.l	Son00,Son00_End-Son00
	dc.l	Son01,Son01_End-Son01
	dc.l	Son02,Son02_End-Son02
	dc.l	Son03,Son03_End-Son03
	dc.l	Son04,Son04_End-Son04
	dc.l	Son05,Son05_End-Son05
	dc.l	Son06,Son06_End-Son06
	dc.l	Son07,Son07_End-Son07
	dc.l	Son08,Son08_End-Son08
	dc.l	Son09,Son09_End-Son09
	dc.l	Son10,Son10_End-Son10
	dc.l	Son11,Son11_End-Son11
	dc.l	Son12,Son12_End-Son12
	dc.l	Son13,Son13_End-Son13

