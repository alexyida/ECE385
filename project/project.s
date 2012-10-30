.equ ADDR_JP2PORT, 0x10000070
.equ ADDR_JP2PORT_DIR, 0x00000000

.equ ADDR_7SEG1, 0x10000020
.equ ADDR_7SEG2, 0x10000030

.equ NUMBER0, 0x3F
.equ NUMBER1, 0x06
.equ NUMBER2, 0x5B
.equ NUMBER3, 0x4F
.equ NUMBER4, 0x66
.equ NUMBER5, 0x6D
.equ NUMBER6, 0x7D
.equ NUMBER7, 0x07
.equ NUMBER8, 0x7F
.equ NUMBER9, 0x6F
.equ NUMBERA, 0x77
.equ NUMBERB, 0x7C
.equ NUMBERC, 0x39
.equ NUMBERD, 0x5E
.equ NUMBERE, 0x79
.equ NUMBERF, 0x71

.global _start

_start:
	movia  r8, ADDR_JP2PORT

	movia  r9, 0x00000000        /* set direction to all output */
	stwio  r9, 4(r8)
 
loop:
	ldwio 	r3,(r8)   /* Read value from pins */
	
	andi r3, r3, 0x0000000f

	cmpeqi r4, r3, 0x0
	bne	   r4, r0, SEG0
	cmpeqi r4, r3, 0x1
	bne	   r4, r0, SEG1
	cmpeqi r4, r3, 0x2
	bne	   r4, r0, SEG2
	cmpeqi r4, r3, 0x3
	bne	   r4, r0, SEG3
	cmpeqi r4, r3, 0x4
	bne	   r4, r0, SEG4
	cmpeqi r4, r3, 0x5
	bne	   r4, r0, SEG5
	cmpeqi r4, r3, 0x6
	bne	   r4, r0, SEG6
	cmpeqi r4, r3, 0x7
	bne	   r4, r0, SEG7
	cmpeqi r4, r3, 0x8
	bne	   r4, r0, SEG8
	cmpeqi r4, r3, 0x9
	bne	   r4, r0, SEG9
	cmpeqi r4, r3, 0xa
	bne	   r4, r0, SEGa
	cmpeqi r4, r3, 0xb
	bne	   r4, r0, SEGb
	cmpeqi r4, r3, 0xb
	bne	   r4, r0, SEGc
	cmpeqi r4, r3, 0xd
	bne	   r4, r0, SEGd
	cmpeqi r4, r3, 0xe
	bne	   r4, r0, SEGe
	cmpeqi r4, r3, 0xf
	bne	   r4, r0, SEGf
	
SEG0:
	movia r1,NUMBER0
	br seg_done
SEG1:
	movia r1,NUMBER1
	br seg_done
SEG2:
	movia r1,NUMBER2
	br seg_done
SEG3:
	movia r1,NUMBER3
	br seg_done
SEG4:
	movia r1,NUMBER4
	br seg_done
SEG5:
	movia r1,NUMBER5
	br seg_done
SEG6:
	movia r1,NUMBER6
	br seg_done
SEG7:
	movia r1,NUMBER7
	br seg_done
SEG8:
	movia r1,NUMBER8
	br seg_done
SEG9:
	movia r1,NUMBER9
	br seg_done
SEGa:
	movia r1,NUMBERA
	br seg_done
SEGb:
	movia r1,NUMBERB
	br seg_done
SEGc:
	movia r1,NUMBERC
	br seg_done
SEGd:
	movia r1,NUMBERD
	br seg_done
SEGe:
	movia r1,NUMBERE
	br seg_done
SEGf:
	movia r1,NUMBERF
	br seg_done
	
seg_done:
	movia r2,ADDR_7SEG1
	stwio r1,0(r2)        /* Write to 7-seg display */
	movia r2,ADDR_7SEG2
	stwio r0,0(r2):
	br loop
