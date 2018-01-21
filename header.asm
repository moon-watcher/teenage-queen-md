*;-------------------------------------------------------
*;
*;       Sega startup code for the Sozobon C compiler
*;       Written by Paul W. Lee
*;       Modified from Charles Coty's code
*;
*;-------------------------------------------------------
Stack		dc.l $0
JumpAddress	dc.l	MD_Startup_Code
		dc.l	Interrupt;		Bus error
		dc.l	Interrupt;		Address error
		dc.l	Interrupt;		Illegal instruction
		dc.l	Interrupt;		Division by zero
		dc.l	Interrupt;		CHK exception
		dc.l	Interrupt;		TRAPV exception
		dc.l	Interrupt;		Privilage violation	
		dc.l	Interrupt;		TRACE exception
		dc.l	Interrupt;		Line-A emulator
		dc.l	Interrupt;		Line-F emulator
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Spurious exception
		dc.l	Interrupt;		IRQ Level 1
		dc.l	Interrupt;		IRQ Level 2
		dc.l	Interrupt;		IRQ Level 3	
		dc.l	HBL;			IRQ Level 4 (VDP Horizontal Interrupt)
		dc.l	Interrupt;		IRQ Level 5 
		dc.l	VBL;			IRQ Level 6 (VDP Vertical Interrupt)
		dc.l	Interrupt;		IRQ Level 7
		dc.l	Interrupt;		TRAP #00 Exception	
		dc.l	Interrupt;		TRAP #01 Exception
		dc.l	Interrupt;		TRAP #02 Exception
		dc.l	Interrupt;		TRAP #03 Exception
		dc.l	Interrupt;		TRAP #04 Exception
		dc.l	Interrupt;		TRAP #05 Exception	
		dc.l	Interrupt;		TRAP #06 Exception
		dc.l	Interrupt;		TRAP #07 Exception
		dc.l	Interrupt;		TRAP #08 Exception
		dc.l	Interrupt;		TRAP #09 Exception
		dc.l	Interrupt;		TRAP #10 Exception
		dc.l	Interrupt;		TRAP #11 Exception
		dc.l	Interrupt;		TRAP #12 Exception
		dc.l	Interrupt;		TRAP #13 Exception
		dc.l	Interrupt;		TRAP #14 Exception
		dc.l	Interrupt;		TRAP #15 Exception
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)
		dc.l	Interrupt;		Reserved (NOT USED)

		dc.b 'SEGA MEGA DRIVE '
		dc.b '(C)SEGA 2007.JAN'
		
		if !DEMO
		dc.b 'TEENAGE QUEEN MD                                '
		dc.b 'TEENAGE QUEEN MD                                '
		else
		dc.b 'TEENAGE QUEEN MD THE DEMO                       '
		dc.b 'TEENAGE QUEEN MD THE DEMO                       '
		endc
		dc.b 'GM 00000000-00'

CheckSum:	dc.w $a5fb
		dc.b 'J               '
RomStartAdr:	dc.l MD_Startup_Code	; adresse démarrage rom
RomEndAdr:	dc.l $60000		; 384 ko
RamStartAdr:	dc.l $FF0000
RamEndAdr:	dc.l $FFFFFF
		dc.b '            '     ; SRam data
		dc.b '            '     ; Modem data
		dc.b '                    ' ; Memo
		dc.b '                    '
		dc.b 'JUE             ' ; Countries codes

