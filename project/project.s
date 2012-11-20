.equ ADDR_JP2PORT, 		0x10000070
.equ ADDR_JP2PORT_DIR, 	0x00000000
.equ ADDR_JP2PORT_EDGE, 0x1000007C
.equ ADDR_JP2PORT_IE, 	0x10000078

.equ ADDR_7SEG1, 		0x10000020
.equ ADDR_7SEG2, 		0x10000030

.equ ADDR_PS2, 			0x10000100

.equ ADDR_JP1, 			0x10000060   /*Address GPIO JP1*/

.equ ADDR_TIMER, 		0x10002000
.equ STOP_PERIOD,		300000
.equ START_PERIOD,		150000

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

.equ STARTKEY, 0xE0
.equ UPKEY, 0x75
.equ DOWNKEY, 0x72
.equ FINISHKEY, 0xF0

.equ IRQ_PS2, 	0b10000000
.equ IRQ_JP2, 	0x00001000
.equ IRQ_TIMER, 0x1

.text
.global _start

_start:
	movia 	r8, ADDR_JP2PORT_IE
	movia 	r9, 0x00000010
	stwio	r9, 0(r8)
	
	movia 	r5, ADDR_PS2		# PS/2 port address
	movia  	r8, ADDR_JP2PORT
	
	movia	r13, 0b1000010000001
	wrctl	ctl3, r13
	
	movi 	r13,1
	stwio	r13, 4(r5)
	
	wrctl 	ctl0,r13   /* Enable global Interrupts on Nios2 */
	
	movia  	r9, 0xffffffe0        /* set direction */
	stwio 	r9, 4(r8)
	
    movia	r16, ADDR_JP1         /* load address GPIO JP1 into r16*/
    movia	r9, 0x07f557ff       /* set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs */
    stwio	r9, 4(r16)

	movia	r9, 0b11111111111111111111111111111111         /* all motors disabled (bit0=1) */
	stwio	r9, 0(r16)
	
	mov		r20, r0		# stop state
	mov		r22, r0
 
loop:
	br loop

.section .exceptions, "ax"

ISRHANDLER1:
	subi	sp, sp, 4
	stw		ra, 0(sp)
	rdctl	et, ctl4
	andi	r15, et, IRQ_PS2
	beq		r15, r0, ISRHANDLER2
	call 	PS2HANDLER
	br 		EXITISR
	
ISRHANDLER2:
	andi	r15, et, IRQ_JP2
	beq		r15, r0, ISRHANDLER3
	call	IRSENSORHANDLER
	br		EXITISR
	
ISRHANDLER3:
	andi	r15, et, IRQ_TIMER
	beq		r15, r0, EXITISR
	call	TIMERHANDLER
	br		EXITISR

PS2HANDLER:
	ldwio	r6, 0(r5)
	andi	r7, r6, 0xFFFF0000
	srli	r7, r7, 16
	beq		r7, r0, EXITISR 		
	
readps2:
	andi	r6, r6, 0xFF
	mov     r10, r11
	mov     r11, r12
	mov	    r12, r6


	
	
READKEY:

    cmpeqi  r3, r10, STARTKEY
	bne     r3, r0, MACTH1
	br		ps2return

MACTH1:	
    cmpeqi  r3, r11, UPKEY
	beq     r3, r0, MATCH2
	movia   r1,NUMBER1
	movia   r2,ADDR_7SEG2
	stwio   r1,0(r2)        /* Write to 7-seg display */

	bne		r20, r0, finishmatch
	
	/* set up the timer */
	movia	r17, ADDR_TIMER
	movui	r18, %lo(STOP_PERIOD)
	stwio	r18, 8(r17)
	movui	r18, %hi(STOP_PERIOD)
	stwio	r18, 12(r17)
	
	movui 	r18, 5				# 0b101: start, not continue, interrupt enabled
	stwio 	r18, 4(r17) 		# Start the timer
	
	mov		r19, r0			# stop state
	movi	r20, 1			# motion on
	movia	r21, 0b11111111111111111111111111111110		# motion direction
	
	br 		finishmatch
	
MATCH2:
    cmpeqi  r3, r11, FINISHKEY
	beq     r3, r0, MATCH3
	cmpeqi  r3, r12, UPKEY
	beq     r3, r0, MATCH4
	movia   r1,NUMBER0
	movia   r2,ADDR_7SEG2
	stwio   r1,0(r2)        /* Write to 7-seg display */
	mov     r10, r0
	mov     r11, r0
	mov     r12, r0

	mov		r20, r0
	
    br		ps2return
	
MATCH3:
    cmpeqi  r3, r11, DOWNKEY
	beq     r3, r0, ps2return
	movia   r1,NUMBER2
	movia   r2,ADDR_7SEG2
	stwio   r1,0(r2)        /* Write to 7-seg display */
	
	bne		r20, r0, finishmatch
	
	/* set up the timer */
	movia	r17, ADDR_TIMER
	movui	r18, %lo(STOP_PERIOD)
	stwio	r18, 8(r17)
	movui	r18, %hi(STOP_PERIOD)
	stwio	r18, 12(r17)
	
	movui 	r18, 5			# 0b101: start, not continue, interrupt enabled
	stwio 	r18, 4(r17) 		# Start the timer
	
	mov		r19, r0			# stop state
	movi	r20, 1			# motion on
	movia	r21, 0b11111111111111111111111111111100		# motion direction

	br		finishmatch
	
MATCH4:
    cmpeqi  r3, r12, DOWNKEY
	beq     r3, r0, ps2return
	movia   r1,NUMBER0
	movia   r2,ADDR_7SEG2
	stwio   r1,0(r2)        /* Write to 7-seg display */
    mov     r10, r0
	mov     r11, r0
	mov     r12, r0
	
	mov		r20, r0
	
	br		ps2return
	
finishmatch:
	mov     r10, r0
	mov     r11, r0
ps2return:
	ret
	
IRSENSORHANDLER:
	ldwio 	r3, 0(r8)   /* Read value from pins */
	andi 	r3, r3, 0x0000000f

	movi	r4, 8
	bge		r3, r4, danger
	mov		r22, r0
	br		safe
	
danger:
	movi	r22, 1

safe:
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
	cmpeqi r4, r3, 0xc
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
	stwio r1, 0(r2)        /* Write to 7-seg display */

	movia r10, ADDR_JP2PORT_EDGE
	stwio r0, 0(r10) /* De-assert interrupt - write to edgecapture regs*/
	ret
	
TIMERHANDLER:
	bne		r22, r0, motorstop
	beq		r20, r0, motionoff

	beq		r19, r0, motorstart
	
motorstop:
	stwio 	r0, 0(r17)	# reset timer

	movui	r18, %lo(STOP_PERIOD)
	stwio	r18, 8(r17)
	movui	r18, %hi(STOP_PERIOD)
	stwio	r18, 12(r17)
	
	movui 	r18, 5			# 0b101: start, not continue, interrupt enabled
	stwio 	r18, 4(r17) 		# Start the timer
	
	mov		r19, r0			# stop state
	
	movia	r23, 0b11111111111111111111111111111111        /* disable motor */
	stwio	r23, 0(r16)      /* Write to JP1 */
	
	ret
	
motorstart:
	stwio 	r0, 0(r17)	# reset timer

	movui	r18, %lo(START_PERIOD)
	stwio	r18, 8(r17)
	movui	r18, %hi(START_PERIOD)
	stwio	r18, 12(r17)
	
	movui 	r18, 5			# 0b101: start, not continue, interrupt enabled
	stwio 	r18, 4(r17) 		# Start the timer
	
	movi	r19, 1			# start state
	
	stwio	r21, 0(r16)      /* Write to JP1 to start the car */	
	
	ret
	
motionoff:
	stwio 	r0, 0(r17)	# reset timer
	
	movia	r23, 0b11111111111111111111111111111111       /* disable motor */
	stwio	r23, 0(r16)      /* Write to JP1 to start the car */
	
	ret
	
EXITISR:
	ldw 	ra, 0(sp)
	addi	sp, sp, 4
	subi	ea, ea, 4
	eret
