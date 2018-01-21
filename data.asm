*******************************************************************************
* FILE:		data.asm
* DESCRIPTION:	Inclus les binaires de données
*******************************************************************************

*******************************************************************************
	section M68Kcode
*******************************************************************************

*******************************************************************************
* charset de l'écran titre
*******************************************************************************
	cnop	0,2
	
	if	!DEMO
	
Title_Chars:
	incbin	data/titlet.nem
Title_Chars_End

	cnop	0,2
Title_Map
	incbin	data/titlem.bin
Title_Map_End

	cnop	0,2
Title_Pal
	incbin	data/titlep.bin
Title_Pal_End

	else

Title_Chars:
	incbin	data/dtitlet.nem
Title_Chars_End

	cnop	0,2
Title_Map
	incbin	data/dtitlem.bin
Title_Map_End

	cnop	0,2
Title_Pal
	incbin	data/dtitlep.bin
Title_Pal_End

	endc

*******************************************************************************
* Game over
*******************************************************************************
	cnop	0,2
GameOver_Chars
	incbin	data/gameo2t.bin
GameOver_Chars_End

	cnop	0,2
GameOver_Map
	incbin	data/gameo2m.bin
GameOver_Map_End

*******************************************************************************
* Demo won
*******************************************************************************
	cnop	0,2
DemoWon_Chars
	incbin	data/dwont.bin
DemoWon_Chars_End

	cnop	0,2
DemoWon_Map
	incbin	data/dwonm.bin
DemoWon_Map_End

*******************************************************************************
* mains
*******************************************************************************
	cnop	0,2
Mains_Chars:
	incbin	data/mainst.bin
Mains_Chars_End

	cnop	0,2
Mains_Pal:
	incbin	data/mainsp.bin
Mains_Pal_End

	cnop	0,2
Mains_Map:
	incbin	data/mainsm.bin
Mains_Map_End

*******************************************************************************
* Teen cards
*******************************************************************************
	cnop	0,2
Teen_Jeu_Chars:
	incbin	data/teenjeut.bin
Teen_Jeu_Chars_End

	cnop	0,2
Teen_Jeu_Map:
	incbin	data/teenjeum.bin
Teen_Jeu_Map_End

*******************************************************************************
* Marker
*******************************************************************************
	cnop	0,2
Marker_Chars
	incbin	data/markert.bin
Marker_Chars_End

*******************************************************************************
* Nombres
*******************************************************************************
	cnop	0,2
Numbers_Chars	
	incbin	data/numberst.bin
Numbers_Chars_End

	cnop	0,2
Moins_Chars
	incbin	data/moinst.bin
Moins_Chars_End

*******************************************************************************
* Messages
*******************************************************************************
	cnop	0,2
You_Win_Pot_Chars
	incbin	data/ywinpott.bin
You_Win_Pot_Chars_End

	cnop	0,2
I_Win_Pot_Chars
	incbin	data/iwinpott.bin
I_Win_Pot_Chars_End

	cnop	0,2
Change_Cards_Chars
	incbin	data/chgcrdt.bin
Change_Cards_Chars_End

	cnop	0,2
I_Change_Cards_Chars
	incbin	data/ichgcrdt.bin
I_Change_Cards_Chars_End

	cnop	0,2
I_Bet_Cards_Chars
	incbin	data/ibett.bin
I_Bet_Cards_Chars_End

	cnop	0,2
I_Call_Chars
	incbin	data/icallt.bin
I_Call_Chars_End

	cnop	0,2
I_Stay_Chars
	incbin	data/istayt.bin
I_Stay_Chars_End

	cnop	0,2
I_Raise_Chars
	incbin	data/iraiset.bin
I_Raise_Chars_End

	cnop	0,2
I_Drop_Chars
	incbin	data/idropt.bin
I_Drop_Chars_End

	cnop	0,2
Play_Again_Chars
	incbin	data/pagaint.bin
Play_Again_Chars_End

	cnop	0,2
Up_To_You_Chars
	incbin	data/uptoyout.bin
Up_To_You_Chars_End


*******************************************************************************
* Femme #0
*******************************************************************************

*** NEO_00 ***
	cnop	0,2
Femme0_00_Chars
	incbin	data/neo00t.bin
Femme0_00_Chars_End

	cnop	0,2
Femme0_00_Map
	incbin	data/neo00m.bin
Femme0_00_Map_End

	cnop	0,2
Femme0_00_Pal
	incbin	data/neo00p.bin
Femme0_00_Pal_End

	if !DEMO

*** NEO_01 ***
	cnop	0,2
Femme0_01_Chars
	incbin	data/neo01t.bin
Femme0_01_Chars_End

	cnop	0,2
Femme0_01_Map
	incbin	data/neo01m.bin
Femme0_01_Map_End

	cnop	0,2
Femme0_01_Pal
	incbin	data/neo01p.bin
Femme0_01_Pal_End

*** NEO_02 ***
	cnop	0,2
Femme0_02_Chars
	incbin	data/neo02t.bin
Femme0_02_Chars_End

	cnop	0,2
Femme0_02_Map
	incbin	data/neo02m.bin
Femme0_02_Map_End

	cnop	0,2
Femme0_02_Pal
	incbin	data/neo02p.bin
Femme0_02_Pal_End

*** NEO_03 ***
	cnop	0,2
Femme0_03_Chars
	incbin	data/neo03t.bin
Femme0_03_Chars_End

	cnop	0,2
Femme0_03_Map
	incbin	data/neo03m.bin
Femme0_03_Map_End

	cnop	0,2
Femme0_03_Pal
	incbin	data/neo03p.bin
Femme0_03_Pal_End

*** NEO_04 ***
	cnop	0,2
Femme0_04_Chars
	incbin	data/neo04t.bin
Femme0_04_Chars_End

	cnop	0,2
Femme0_04_Map
	incbin	data/neo04m.bin
Femme0_04_Map_End

	cnop	0,2
Femme0_04_Pal
	incbin	data/neo04p.bin
Femme0_04_Pal_End

*** NEO_05 ***
	cnop	0,2
Femme0_05_Chars
	incbin	data/neo05t.bin
Femme0_05_Chars_End

	cnop	0,2
Femme0_05_Map
	incbin	data/neo05m.bin
Femme0_05_Map_End

	cnop	0,2
Femme0_05_Pal
	incbin	data/neo05p.bin
Femme0_05_Pal_End

*** NEO_06 ***
	cnop	0,2
Femme0_06_Chars
	incbin	data/neo06t.bin
Femme0_06_Chars_End

	cnop	0,2
Femme0_06_Map
	incbin	data/neo06m.bin
Femme0_06_Map_End

	cnop	0,2
Femme0_06_Pal
	incbin	data/neo06p.bin
Femme0_06_Pal_End

*** NEO_07 ***
	cnop	0,2
Femme0_07_Chars
	incbin	data/neo07t.bin
Femme0_07_Chars_End

	cnop	0,2
Femme0_07_Map
	incbin	data/neo07m.bin
Femme0_07_Map_End

	cnop	0,2
Femme0_07_Pal
	incbin	data/neo07p.bin
Femme0_07_Pal_End

*** NEO_08 ***
	cnop	0,2
Femme0_08_Chars
	incbin	data/neo08t.bin
Femme0_08_Chars_End

	cnop	0,2
Femme0_08_Map
	incbin	data/neo08m.bin
Femme0_08_Map_End

	cnop	0,2
Femme0_08_Pal
	incbin	data/neo08p.bin
Femme0_08_Pal_End

*** NEO_09 ***
	cnop	0,2
Femme0_09_Chars
	incbin	data/neo09t.bin
Femme0_09_Chars_End

	cnop	0,2
Femme0_09_Map
	incbin	data/neo09m.bin
Femme0_09_Map_End

	cnop	0,2
Femme0_09_Pal
	incbin	data/neo09p.bin
Femme0_09_Pal_End

*** NEO_10 ***
	cnop	0,2
Femme0_10_Chars
	incbin	data/neo10t.bin
Femme0_10_Chars_End

	cnop	0,2
Femme0_10_Map
	incbin	data/neo10m.bin
Femme0_10_Map_End

	cnop	0,2
Femme0_10_Pal
	incbin	data/neo10p.bin
Femme0_10_Pal_End

*** NEO_11 ***
	cnop	0,2
Femme0_11_Chars
	incbin	data/neo11t.bin
Femme0_11_Chars_End

	cnop	0,2
Femme0_11_Map
	incbin	data/neo11m.bin
Femme0_11_Map_End

	cnop	0,2
Femme0_11_Pal
	incbin	data/neo11p.bin
Femme0_11_Pal_End

	endc

*******************************************************************************
* Icones
*******************************************************************************
Icone_Pal
	cnop	0,2
	incbin	data/icon800p.bin
Icone_Pal_End

* Stay/Bet
	cnop	0,2
Icone_Stay_Bet_Chars
	incbin	data/icon800t.bin
Icone_Stay_Bet_End

	cnop	0,2
Icone_Stay_Bet1_Chars
	incbin	data/icon801t.bin
Icone_Stay_Bet1_End

	cnop	0,2
Icone_Call_Raise_Drop
	incbin	data/icon90t.bin
Icone_Call_Raise_Drop_End

	cnop	0,2
Icone_Call_Raise_Drop1
	incbin	data/icon91t.bin
Icone_Call_Raise_Drop1_End

	cnop	0,2
Icone_Call_Raise_Drop2
	incbin	data/icon92t.bin
Icone_Call_Raise_Drop2_End


	cnop	0,2
Icone_Call_Drop
	incbin	data/icon100t.bin
Icone_Call_Drop_End

	cnop	0,2
Icone_Call_Drop1
	incbin	data/icon101t.bin
Icone_Call_Drop1_End

	cnop	0,2
Icone_Bet_Choice
	incbin	data/icon110t.bin
Icone_Bet_Choice_End

	cnop	0,2
Icone_Bet_Choice1
	incbin	data/icon111t.bin
Icone_Bet_Choice1_End

	cnop	0,2
Icone_Bet_Choice2
	incbin	data/icon112t.bin
Icone_Bet_Choice2_End

	cnop	0,2
Icone_Bet_Choice3
	incbin	data/icon113t.bin
Icone_Bet_Choice3_End

	cnop	0,2
Icone_Bet_Choice4
	incbin	data/icon114t.bin
Icone_Bet_Choice4_End

	cnop	0,2
Icone_Main
	incbin	data/icon85t.bin
Icone_Main_End

*******************************************************************************
* Cartes
*******************************************************************************
	cnop	0,2
Carte_Chars:
	incbin data/cards/tl_t0.bin
	incbin data/cards/tr_t0.bin
	incbin data/cards/ml_t0.bin
	incbin data/cards/mr_t0.bin
	incbin data/cards/bl_t0.bin
	incbin data/cards/br_t0.bin
Carte_Chars_End

	incbin data/cards/tl_t1.bin
	incbin data/cards/tr_t1.bin
	incbin data/cards/ml_t1.bin
	incbin data/cards/mr_t1.bin
	incbin data/cards/bl_t1.bin
	incbin data/cards/br_t1.bin

	incbin data/cards/tl_t2.bin
	incbin data/cards/tr_t2.bin
	incbin data/cards/ml_t2.bin
	incbin data/cards/mr_t2.bin
	incbin data/cards/bl_t2.bin
	incbin data/cards/br_t2.bin

	incbin data/cards/tl_t3.bin
	incbin data/cards/tr_t3.bin
	incbin data/cards/ml_t3.bin
	incbin data/cards/mr_t3.bin
	incbin data/cards/bl_t3.bin
	incbin data/cards/br_t3.bin

	incbin data/cards/tl_t4.bin
	incbin data/cards/tr_t4.bin
	incbin data/cards/ml_t4.bin
	incbin data/cards/mr_t4.bin
	incbin data/cards/bl_t4.bin
	incbin data/cards/br_t4.bin

	incbin data/cards/tl_t5.bin
	incbin data/cards/tr_t5.bin
	incbin data/cards/ml_t5.bin
	incbin data/cards/mr_t5.bin
	incbin data/cards/bl_t5.bin
	incbin data/cards/br_t5.bin

	incbin data/cards/tl_t6.bin
	incbin data/cards/tr_t6.bin
	incbin data/cards/ml_t6.bin
	incbin data/cards/mr_t6.bin
	incbin data/cards/bl_t6.bin
	incbin data/cards/br_t6.bin

	incbin data/cards/tl_t7.bin
	incbin data/cards/tr_t7.bin
	incbin data/cards/ml_t7.bin
	incbin data/cards/mr_t7.bin
	incbin data/cards/bl_t7.bin
	incbin data/cards/br_t7.bin

	incbin data/cards/tl_t8.bin
	incbin data/cards/tr_t8.bin
	incbin data/cards/ml_t8.bin
	incbin data/cards/mr_t8.bin
	incbin data/cards/bl_t8.bin
	incbin data/cards/br_t8.bin

	incbin data/cards/tl_t9.bin
	incbin data/cards/tr_t9.bin
	incbin data/cards/ml_t9.bin
	incbin data/cards/mr_t9.bin
	incbin data/cards/bl_t9.bin
	incbin data/cards/br_t9.bin

	incbin data/cards/tl_t10.bin
	incbin data/cards/tr_t10.bin
	incbin data/cards/ml_t10.bin
	incbin data/cards/mr_t10.bin
	incbin data/cards/bl_t10.bin
	incbin data/cards/br_t10.bin

	incbin data/cards/tl_t11.bin
	incbin data/cards/tr_t11.bin
	incbin data/cards/ml_t11.bin
	incbin data/cards/mr_t11.bin
	incbin data/cards/bl_t11.bin
	incbin data/cards/br_t11.bin

	incbin data/cards/tl_t12.bin
	incbin data/cards/tr_t12.bin
	incbin data/cards/ml_t12.bin
	incbin data/cards/mr_t12.bin
	incbin data/cards/bl_t12.bin
	incbin data/cards/br_t12.bin

	incbin data/cards/tl_t13.bin
	incbin data/cards/tr_t13.bin
	incbin data/cards/ml_t13.bin
	incbin data/cards/mr_t13.bin
	incbin data/cards/bl_t13.bin
	incbin data/cards/br_t13.bin

	incbin data/cards/tl_t14.bin
	incbin data/cards/tr_t14.bin
	incbin data/cards/ml_t14.bin
	incbin data/cards/mr_t14.bin
	incbin data/cards/bl_t14.bin
	incbin data/cards/br_t14.bin

	incbin data/cards/tl_t15.bin
	incbin data/cards/tr_t15.bin
	incbin data/cards/ml_t15.bin
	incbin data/cards/mr_t15.bin
	incbin data/cards/bl_t15.bin
	incbin data/cards/br_t15.bin

	incbin data/cards/tl_t16.bin
	incbin data/cards/tr_t16.bin
	incbin data/cards/ml_t16.bin
	incbin data/cards/mr_t16.bin
	incbin data/cards/bl_t16.bin
	incbin data/cards/br_t16.bin

	incbin data/cards/tl_t17.bin
	incbin data/cards/tr_t17.bin
	incbin data/cards/ml_t17.bin
	incbin data/cards/mr_t17.bin
	incbin data/cards/bl_t17.bin
	incbin data/cards/br_t17.bin

	incbin data/cards/tl_t18.bin
	incbin data/cards/tr_t18.bin
	incbin data/cards/ml_t18.bin
	incbin data/cards/mr_t18.bin
	incbin data/cards/bl_t18.bin
	incbin data/cards/br_t18.bin

	incbin data/cards/tl_t19.bin
	incbin data/cards/tr_t19.bin
	incbin data/cards/ml_t19.bin
	incbin data/cards/mr_t19.bin
	incbin data/cards/bl_t19.bin
	incbin data/cards/br_t19.bin

	incbin data/cards/tl_t20.bin
	incbin data/cards/tr_t20.bin
	incbin data/cards/ml_t20.bin
	incbin data/cards/mr_t20.bin
	incbin data/cards/bl_t20.bin
	incbin data/cards/br_t20.bin

	incbin data/cards/tl_t21.bin
	incbin data/cards/tr_t21.bin
	incbin data/cards/ml_t21.bin
	incbin data/cards/mr_t21.bin
	incbin data/cards/bl_t21.bin
	incbin data/cards/br_t21.bin

	incbin data/cards/tl_t22.bin
	incbin data/cards/tr_t22.bin
	incbin data/cards/ml_t22.bin
	incbin data/cards/mr_t22.bin
	incbin data/cards/bl_t22.bin
	incbin data/cards/br_t22.bin

	incbin data/cards/tl_t23.bin
	incbin data/cards/tr_t23.bin
	incbin data/cards/ml_t23.bin
	incbin data/cards/mr_t23.bin
	incbin data/cards/bl_t23.bin
	incbin data/cards/br_t23.bin

	incbin data/cards/tl_t24.bin
	incbin data/cards/tr_t24.bin
	incbin data/cards/ml_t24.bin
	incbin data/cards/mr_t24.bin
	incbin data/cards/bl_t24.bin
	incbin data/cards/br_t24.bin

	incbin data/cards/tl_t25.bin
	incbin data/cards/tr_t25.bin
	incbin data/cards/ml_t25.bin
	incbin data/cards/mr_t25.bin
	incbin data/cards/bl_t25.bin
	incbin data/cards/br_t25.bin

	incbin data/cards/tl_t26.bin
	incbin data/cards/tr_t26.bin
	incbin data/cards/ml_t26.bin
	incbin data/cards/mr_t26.bin
	incbin data/cards/bl_t26.bin
	incbin data/cards/br_t26.bin

	incbin data/cards/tl_t27.bin
	incbin data/cards/tr_t27.bin
	incbin data/cards/ml_t27.bin
	incbin data/cards/mr_t27.bin
	incbin data/cards/bl_t27.bin
	incbin data/cards/br_t27.bin

	incbin data/cards/tl_t28.bin
	incbin data/cards/tr_t28.bin
	incbin data/cards/ml_t28.bin
	incbin data/cards/mr_t28.bin
	incbin data/cards/bl_t28.bin
	incbin data/cards/br_t28.bin

	incbin data/cards/tl_t29.bin
	incbin data/cards/tr_t29.bin
	incbin data/cards/ml_t29.bin
	incbin data/cards/mr_t29.bin
	incbin data/cards/bl_t29.bin
	incbin data/cards/br_t29.bin

	incbin data/cards/tl_t30.bin
	incbin data/cards/tr_t30.bin
	incbin data/cards/ml_t30.bin
	incbin data/cards/mr_t30.bin
	incbin data/cards/bl_t30.bin
	incbin data/cards/br_t30.bin

	incbin data/cards/tl_t31.bin
	incbin data/cards/tr_t31.bin
	incbin data/cards/ml_t31.bin
	incbin data/cards/mr_t31.bin
	incbin data/cards/bl_t31.bin
	incbin data/cards/br_t31.bin
	
BackCards_Chars

* Couché de soleil
	incbin data/cards/btl_t1.bin
	incbin data/cards/btr_t1.bin
	incbin data/cards/bml_t1.bin
	incbin data/cards/bmr_t1.bin
	incbin data/cards/bbl_t1.bin
	incbin data/cards/bbr_t1.bin
* Carotte
	incbin data/cards/btl_t2.bin
	incbin data/cards/btr_t2.bin
	incbin data/cards/bml_t2.bin
	incbin data/cards/bmr_t2.bin
	incbin data/cards/bbl_t2.bin
	incbin data/cards/bbr_t2.bin
* Building
	incbin data/cards/btl_t3.bin
	incbin data/cards/btr_t3.bin
	incbin data/cards/bml_t3.bin
	incbin data/cards/bmr_t3.bin
	incbin data/cards/bbl_t3.bin
	incbin data/cards/bbr_t3.bin


*******************************************************************************
* Sons
*******************************************************************************








