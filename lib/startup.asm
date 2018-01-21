	bra	MD_Startup_Code
	cnop	0,2
	if DEMO
	cnop	0,2
	dc.b	'this is a free project,'
	dc.b	'what you are looking for was not compiled in this rom.'
	dc.b	'you surely have better to do than trying to hack this rom.'	
	dc.b	'thanks :) www.spoutnickteam.com',0,0,0,0,0,0,0,0,0,0
	endc
	cnop	0,2
MD_Startup_Code:
	move.w	#$2700,sr		; rajout pbo: désactive les INT

	tst.l	$a10008
	bne	SkipJoyDetect
	tst.w	$a1000c
SkipJoyDetect:
*	bne	SkipSetup
	lea	Table,a5
	movem.w	(a5)+,d5-d7
	movem.l	(a5)+,a0-a4
	move.b	-$10ff(a1),d0		;Check Version Number
	andi.b	#$0f,d0
	beq	WrongVersion
	move.l  #$53454741,$2f00(a1)	;Sega Security Code (SEGA)
WrongVersion:
	move.w  (a4),d0
	moveq   #$00,d0
	movea.l d0,a6
	move    a6,usp
	moveq   #$17,d1			;Set VDP registers
FillLoop:
	move.b  (a5)+,d5
	move.w  d5,(a4)
	add.w   d7,d5
	dbra    d1,FillLoop                           
	move.l  (a5)+,(a4)                            
	move.w  d0,(a3)                                 
	move.w  d7,(a1)                                 
	move.w  d7,(a2)                                 
L0250:
	btst    d0,(a1)
	bne     L0250                                   
	moveq   #$25,d2                ; Put initial vaules into a00000                
Filla:                                 
	move.b  (a5)+,(a0)+
	dbra    d2,Filla
	move.w  d0,(a2)                                 
	move.w  d0,(a1)                                 
	move.w  d7,(a2)                                 
L0262:
	move.l  d0,-(a6)
	dbra    d6,L0262                            
	move.l  (a5)+,(a4)                              
	move.l  (a5)+,(a4)                              
	moveq   #$1f,d3                ; Put initial values into c00000                  
Filc0:                             
	move.l  d0,(a3)
	dbra    d3,Filc0
	move.l  (a5)+,(a4)                              
	moveq   #$13,d4                ; Put initial values into c00000                 
Fillc1:                            
	move.l  d0,(a3)
	dbra    d4,Fillc1
	moveq   #$03,d5                ; Put initial values into c00011                 
Fillc2:                            
	move.b  (a5)+,$0011(a3)        
	dbra    d5,Fillc2                            
	move.w  d0,(a2)                                 
	movem.l (a6),d0-d7/a0-a6                    
*	move    #$2700,sr
SkipSetup:
	bra     Continue
Table:
	dc.w    $8000, $3fff, $0100, $00a0, $0000, $00a1, $1100, $00a1
	dc.w    $1200, $00c0, $0000, $00c0, $0004, $0414, $302c, $0754
	dc.w    $0000, $0000, $0000, $812b, $0001, $0100, $00ff, $ff00
	dc.w    $0080, $4000, $0080, $af01, $d91f, $1127, $0021, $2600
	dc.w    $f977, $edb0, $dde1, $fde1, $ed47, $ed4f, $d1e1, $f108
	dc.w    $d9c1, $d1e1, $f1f9, $f3ed, $5636, $e9e9, $8104, $8f01
	dc.w    $c000, $0000, $4000, $0010, $9fbf, $dfff

Continue:
	tst.w    $00C00004
*	move.w  #$2300,sr			; user mode
	lea     $ff0000,a0			; clear Genesis RAM
	moveq   #0,d0
clrram: move.l  #0,(a0)+
	subq.w  #4,d0
	bne     clrram
	
	jmp	_main


