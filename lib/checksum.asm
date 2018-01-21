*******************************************************************************
* FILE:		checksum.asm
* DESCRIPTION:	
* CREATION:	lundi 15 janvier 2007 16:09:24
* CONTACT:	www.spoutnickteam.com
*******************************************************************************

*******************************************************************************
* FUNCTION:	
* DESCRIPTION:	
* PARAMETERS:	
*******************************************************************************
Checksum_Validate:
	movea.l	RomStartAdr,a0
	move.l	RomEndAdr,d1
	clr.w	d0
sum_loop:
	add.w	(a0)+,d0
	cmp.l	a0,d1
	bcc.s	sum_loop

* Vérifie le checksum calulé avec celui du header
	move.w	CheckSum,d1
	cmp.w	d0,d1
	bne	Bad_Checksum
	rts
*******************************************************************************
* Bad Checksum red screen of death
********************************************************************************
Bad_Checksum:
	lea	VDP_DATA,a0
	move.l	#$E000E,d1
	move.l	#$C0000000,(VDP_CTRL).l
	move.w	d1,(a0)
bad_loop
	bra	bad_loop
	
