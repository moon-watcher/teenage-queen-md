*******************************************************************************
* FILE:		debug.asm	
* DESCRIPTION:	fonctions de debug dans l'ému
*******************************************************************************

*******************************************************************************
* MACRO		BRK
* DESCRIPTION:	Force un breakpoint dans MDStudio/kmod
* PARAMETERS:	none
*******************************************************************************
BRK	macro
	if	DEBUG
	VDP_SetRegister $1d,$0
	endc
	endm
