*******************************************************************************
* FILE:		Enigma
* DESCRIPTION:	Uncompress Enigma packed binary to RAM
* CREATION:	jeudi 4 janvier 2007 21:46:39
* CONTACT:	www.spoutnickteam.com
*******************************************************************************
	cnop	0,2
*******************************************************************************
* FUNCTION:	Enigma_XTract
* DESCRIPTION:	Extract a Enigma packed binary to RAM
* PARAMETERS:	a0: Address of the buffer to decompresss
*		a1: Address in RAm To Decompress
*******************************************************************************
Enigma_XTract:
		lea	LZ77_Buf,a1
		move.w	#0,d0
		movem.l	d0-d7/a1-a5,-(sp)
		movea.w	d0,a3
		move.b	(a0)+,d0
		ext.w	d0
		movea.w	d0,a5
		move.b	(a0)+,d4
		lsl.b	#3,d4
		movea.w	(a0)+,a2
		adda.w	a3,a2
		movea.w	(a0)+,a4
		adda.w	a3,a4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6

loc_173E:
		moveq	#7,d0
		move.w	d6,d7
		sub.w	d0,d7
		move.w	d5,d1
		lsr.w	d7,d1

loc_1748:
		andi.w	#$7F,d1	; ''
		move.w	d1,d2
		cmpi.w	#$40,d1	; '@'
		bcc.s	loc_1758
		moveq	#6,d0
		lsr.w	#1,d2

loc_1758:
		bsr.w	loc_188C
		andi.w	#$F,d2
		lsr.w	#4,d1
		add.w	d1,d1
		jmp	loc_17B4(pc,d1.w)

*******************************************************************************
loc_1768:
		move.w	a2,(a1)+
		addq.w	#1,a2
		dbf	d2,loc_1768
		bra.s	loc_173E
*******************************************************************************
loc_1772:
		move.w	a4,(a1)+
		dbf	d2,loc_1772
		bra.s	loc_173E
*******************************************************************************
loc_177A:
		bsr.w	sub_17DC
loc_177E:
		move.w	d1,(a1)+
		dbf	d2,loc_177E
		bra.s	loc_173E
*******************************************************************************
loc_1786:
		bsr.w	sub_17DC

loc_178A:
		move.w	d1,(a1)+
		addq.w	#1,d1
		dbf	d2,loc_178A
		bra.s	loc_173E

loc_1794:
		bsr.w	sub_17DC

loc_1798:
		move.w	d1,(a1)+
		subq.w	#1,d1
		dbf	d2,loc_1798
		bra.s	loc_173E
*******************************************************************************
loc_17A2:
		cmpi.w	#$F,d2
		beq.s	loc_17C4

loc_17A8:
		bsr.w	sub_17DC
		move.w	d1,(a1)+
		dbf	d2,loc_17A8
		bra.s	loc_173E
*******************************************************************************
loc_17B4:
		bra.s	loc_1768
*******************************************************************************
		bra.s	loc_1768
*******************************************************************************
		bra.s	loc_1772
*******************************************************************************
		bra.s	loc_1772
*******************************************************************************
		bra.s	loc_177A
*******************************************************************************
		bra.s	loc_1786
*******************************************************************************
		bra.s	loc_1794
*******************************************************************************
		bra.s	loc_17A2
*******************************************************************************
loc_17C4:
		subq.w	#1,a0
		cmpi.w	#$10,d6
		bne.s	loc_17CE
		subq.w	#1,a0
loc_17CE:
		move.w	a0,d0
		lsr.w	#1,d0
		bcc.s	loc_17D6
		addq.w	#1,a0
loc_17D6:
		movem.l	(sp)+,d0-d7/a1-a5
		rts	

*******************************************************************************
* Subroutines
*******************************************************************************
sub_17DC:
		move.w	a3,d3
		move.b	d4,d1
		add.b	d1,d1
		bcc.s	loc_17EE
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17EE
		ori.w	#-$8000,d3

loc_17EE:
		add.b	d1,d1
		bcc.s	loc_17FC
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17FC
		addi.w	#$4000,d3

loc_17FC:
		add.b	d1,d1
		bcc.s	loc_180A
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_180A
		addi.w	#$2000,d3

loc_180A:
		add.b	d1,d1
		bcc.s	loc_1818
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1818
		ori.w	#$1000,d3

loc_1818:
		add.b	d1,d1
		bcc.s	loc_1826
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1826
		ori.w	#$800,d3

loc_1826:
		move.w	d5,d1
		move.w	d6,d7
		sub.w	a5,d7
		bcc.s	loc_1856
		move.w	d7,d6
		addi.w	#$10,d6
		neg.w	d7
		lsl.w	d7,d1
		move.b	(a0),d5
		rol.b	d7,d5
		add.w	d7,d7
		and.w	loc_186A(pc,d7.w),d5
		add.w	d5,d1

loc_1844:
		move.w	a5,d0
		add.w	d0,d0
		and.w	loc_186A(pc,d0.w),d1
		add.w	d3,d1
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5
		rts	
*******************************************************************************
loc_1856:
		beq.s	loc_1868
		lsr.w	d7,d1
		move.w	a5,d0
		add.w	d0,d0
		and.w	loc_186A(pc,d0.w),d1
		add.w	d3,d1
		move.w	a5,d0
		bra.s	loc_188C
*******************************************************************************
loc_1868:
		moveq	#$10,d6
loc_186A:
		bra.s	loc_1844

*******************************************************************************
word_186C:	dc.w	 1		; 0
		dc.w	 3		; 1
		dc.w	 7		; 2
		dc.w	$F		; 3
		dc.w   $1F		; 4
		dc.w   $3F		; 5
		dc.w   $7F		; 6
		dc.w   $FF		; 7
		dc.w  $1FF		; 8
		dc.w  $3FF		; 9
		dc.w  $7FF		; 10
		dc.w  $FFF		; 11
		dc.w $1FFF		; 12
		dc.w $3FFF		; 13
		dc.w $7FFF		; 14
		dc.w $FFFF		; 15
*******************************************************************************
loc_188C:
		sub.w	d0,d6
		cmpi.w	#9,d6
		bcc.s	locret_189A
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
locret_189A:
		rts

