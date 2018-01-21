*******************************************************************************
* FILE:		lz77.asm	
* DESCRIPTION:	décompression
*******************************************************************************

	cnop	0,2
*******************************************************************************
* FUNCTION:	LZ77_Xtract2Mem
* DESCRIPTION:	
* PARAMETERS:	a0: source address
*		a1: destination address (RAM)
*******************************************************************************
LZ77_Xtract2Mem

	movem.l	d0-d5/a0-a2,-(sp)

	addq.l	#4,a0			; Skip original length
	bra.s	.loadtag
	
.literal
	move.b	(a0)+,(a1)+		; Copy 8 bytes literal string
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+

.loadtag
	move.b	(a0)+,d0	; Load compression TAG : d0=TAG
	beq.s	.literal	; 8 bytes literal string? Si TAG==0 alors on a 8 byte non compressé

	moveq.l	#8-1,d1		; Process TAG per byte/string d1= index (0->7)
.search		
	add.b	d0,d0		; TAG <<= 1
	bcs.s	.compressed

* output data non compressée
	move.b  (a0)+,(a1)+	; Copy another literal byte
	dbra	d1,.search

	bra.s	.loadtag

* output data compressée
.compressed	
	moveq.l	#0,d2
	move.b  (a0)+,d2	; Load compression specifier: d2
	beq.s	.break		; End of stream, exit

	moveq.l	#$0f,d3		; Mask out stringlength
	and.l	d2,d3		; d3= length

	lsl.w	#4,d2		; Compute string location
	move.b	(a0)+,d2	; d2 = 12 bits d'offset
	movea.l	a1,a2		; a2 = a1
	suba.l	d2,a2		; a2 = a1 - offset

	add.w	d3,d3		; Jump into unrolled string copy loop
	neg.w	d3
	jmp	.unroll(pc,d3.w)

	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+

	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+

	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
.unroll
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+

	dbra	d1,.search

	bra.s	.loadtag

.break	
	movem.l	(sp)+,d0-d5/a0-a2
	rts

*******************************************************************************
* MACRO:	LZ77_XTract2VRAM_Copy
* DESCRIPTION:	usage interne pour la decompression en vram
* PARAMETERS:	
*******************************************************************************
LZ77_XTract2VRAM_Copy 	macro
	nop
	clr.w	d7
	tst.b	d5
	bne.s	.impaire\@
	move.b	(\1)+,d4
	bra.s	.fin\@
.impaire\@
	move.b	d4,d7
	lsl.w	#8,d7
	move.b	(\1)+,d4
	or.w	d4,d7
	move.w	d7,VDP_DATA
.fin\@
	move.b	d4,(a1,d6)			; copie dans buffer cyclique
	addq	#1,d6
	and.w	#4095,d6
	eori.b	#1,d5
	endm

*******************************************************************************
* FUNCTION:	LZ77_Xtract2Mem
* DESCRIPTION:	
* PARAMETERS:	a0: source address
*		VDP Address Write doit être définit
*******************************************************************************
LZ77_Xtract2VRAM
	movem.l	d0-d7/a0-a3,-(sp)
	
	lea	LZ77_Buf,a1
	clr.l	d5
	clr.l	d6			; index dans de buffer
	clr.l	d7

	addq.l	#4,a0			; Skip original length
	bra	.loadtag1
.literal1
	LZ77_XTract2VRAM_Copy a0
	LZ77_XTract2VRAM_Copy a0
	LZ77_XTract2VRAM_Copy a0
	LZ77_XTract2VRAM_Copy a0
	LZ77_XTract2VRAM_Copy a0
	LZ77_XTract2VRAM_Copy a0
	LZ77_XTract2VRAM_Copy a0
	LZ77_XTract2VRAM_Copy a0

.loadtag1
	move.b	(a0)+,d0	; Load compression TAG : d0=TAG
	beq	.literal1	; 8 bytes literal string? Si TAG==0 alors on a 8 byte non compressé

	moveq.l	#8-1,d1		; Process TAG per byte/string d1= index (0->7)
.search1		
	add.b	d0,d0		; TAG <<= 1
	bcs.s	.compressed1

* output data non compressée
	LZ77_XTract2VRAM_Copy a0

	dbra	d1,.search1

	bra.s	.loadtag1

* output data compressée
.compressed1	
	moveq.l	#0,d2
	move.b  (a0)+,d2	; Load compression specifier: d2
	beq	.break1		; End of stream, exit

	moveq.l	#$0f,d3		; Mask out stringlength
	and.l	d2,d3		; d3= length

	lsl.w	#4,d2		; Compute string location
	move.b	(a0)+,d2	; d2 = 12 bits d'offset

	movea.l	a1,a2		; d6=index dans buffer
	move.w	d6,d7
	sub.w	d2,d7
	and.w	#4095,d7
	adda.w	d7,a2		; récupère l'adresse dans le buffer

	lea	.unroll1,a3
	move.w	d3,d7
	lsl.w	#5,d3
	lsl.w	#3,d7
	add.w	d7,d3
	suba	d3,a3
	jmp	(a3)
	
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2
.unroll1
	LZ77_XTract2VRAM_Copy a2
	LZ77_XTract2VRAM_Copy a2

	dbra	d1,.search1

	bra	.loadtag1

.break1	
	movem.l	(sp)+,d0-d7/a0-a3
	rts


