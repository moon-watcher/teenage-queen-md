*******************************************************************************
* FILE:		nemesis.mac
* DESCRIPTION:	Uncompress Nemesis packed binary to VRAM
* CREATION:	jeudi 4 janvier 2007 21:46:39
* CONTACT:	www.spoutnickteam.com
*******************************************************************************
	cnop	0,2
*******************************************************************************
* FUNCTION:	Nemesis_XTract
* DESCRIPTION:	Extract a nemesis packed binary to VRAM
* PARAMETERS:	a0: Address of the buffer to decompresss
*******************************************************************************
Nemesis_XTract:	
	movem.l	d0-a1/a3-a5,-(sp)
	lea	(loc_1502).l,a3
	lea	VDP_DATA,a4
	bra.s	NemDec_145C
	movem.l	d0-a1/a3-a5,-(sp)
	lea	(loc_1518).l,a3
NemDec_145C:
	lea	($FFFFAA00).w,a1
	move.w	(a0)+,d2
	lsl.w	#1,d2
	bcc.s	NemDec_146A
	adda.w	#$A,a3

NemDec_146A:
	lsl.w	#2,d2
	movea.w	d2,a5
	moveq	#8,d3
	moveq	#0,d2
	moveq	#0,d4

loc_1474:
	bsr.w	sub_152E
	move.b	(a0)+,d5
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#$10,d6
	bsr.s	sub_148A
	movem.l	(sp)+,d0-a1/a3-a5
	rts

sub_148A:
	move.w	d6,d7
	subq.w	#8,d7
	move.w	d5,d1
	lsr.w	d7,d1
	cmpi.b	#$FC,d1
	bcc.s	loc_14D6
	andi.w	#$FF,d1
	add.w	d1,d1
	move.b	(a1,d1.w),d0
	ext.w	d0
	sub.w	d0,d6
	cmpi.w	#9,d6
	bcc.s	loc_14B2
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5

loc_14B2:
	move.b	1(a1,d1.w),d1
	move.w	d1,d0
	andi.w	#$F,d1
	andi.w	#$F0,d0

loc_14C0:
	lsr.w	#4,d0

loc_14C2:
	lsl.l	#4,d4
	or.b	d1,d4
	subq.w	#1,d3
	bne.s	loc_14D0
	jmp	(a3)

sub_14CC:
	moveq	#0,d4
	moveq	#8,d3

loc_14D0:
	dbf	d0,loc_14C2
	bra.s	sub_148A

loc_14D6:
	subq.w	#6,d6
	cmpi.w	#9,d6
	bcc.s	loc_14E4
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5

loc_14E4:
	subq.w	#7,d6
	move.w	d5,d1
	lsr.w	d6,d1
	move.w	d1,d0
	andi.w	#$F,d1
	andi.w	#$70,d0	; 'p'
	cmpi.w	#9,d6
	bcc.s	loc_14C0
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5
	bra.s	loc_14C0

loc_1502:
	move.l	d4,(a4)
	subq.w	#1,a5
	move.w	a5,d4
	bne.s	sub_14CC
	rts	

	eor.l	d4,d2
	move.l	d2,(a4)
	subq.w	#1,a5
	move.w	a5,d4
	bne.s	sub_14CC
	rts	

loc_1518:
	move.l	d4,(a4)+
	subq.w	#1,a5
	move.w	a5,d4
	bne.s	sub_14CC
	rts	

	eor.l	d4,d2
	move.l	d2,(a4)+
	subq.w	#1,a5
	move.w	a5,d4
	bne.s	sub_14CC
	rts	

sub_152E:
	move.b	(a0)+,d0

loc_1530:
	cmpi.b	#-1,d0
	bne.s	loc_1538
	rts	

loc_1538:
	move.w	d0,d7

loc_153A:
	move.b	(a0)+,d0
	cmpi.b	#-$80,d0
	bcc.s	loc_1530
	move.b	d0,d1
	andi.w	#$F,d7
	andi.w	#$70,d1
	or.w	d1,d7
	andi.w	#$F,d0
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7
	moveq	#8,d1
	sub.w	d0,d1
	bne.s	loc_1568
	move.b	(a0)+,d0
	add.w	d0,d0
	move.w	d7,(a1,d0.w)
	bra.s	loc_153A

loc_1568:
	move.b	(a0)+,d0
	lsl.w	d1,d0
	add.w	d0,d0
	moveq	#1,d5
	lsl.w	d1,d5
	subq.w	#1,d5

loc_1574:
	move.w	d7,(a1,d0.w)
	addq.w	#2,d0
	dbf	d5,loc_1574
	bra.s	loc_153A


