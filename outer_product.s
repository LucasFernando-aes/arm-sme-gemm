	.global _mm_32x32x8
	.align 4

//inputs
//x0 A ptr
//x1 B ptr
//x2 C ptr
//x3 M
//x4 N
//x5 K
//x6 ldc

//temps
//x8 svl.s
//x9 svl.s * k
//x10 A0 (initial pointer)
//x11 A1 (middle pointer)
//x12 B0 (initial pointer)
//x13 B1 (middle pointer)
//w14 iterator over tile slice
//x15 c1 (middle pointer)
_mm_32x32x8:
	smstart
	ptrue 	pn8.b
	ptrue 	p0.b
	ptrue 	p1.b

	cntw x8				//x8 = SLV.s
	mul x9, x8, x5			//x9 = SLV.s(16) * K

	mov x10, x0			//x10 = A -- first pointer of A
	add x11, x0, x9, lsl #2 	//x11 = A + SLV.s(16) * K * sizeof(float) -- second pointer of A
	mov x12, x1 			//x12 = B -- first pointer of B
	add x13, x1, x9, lsl #2 	//x11 = A + SLV.s(16) * K * sizeof(float) -- second pointer of B

	//LOAD STEP
kloop:
	ld1w 	{z0.s-z3.s}, pn8/z, [x10]
	ld1w 	{z16.s-z19.s}, pn8/z, [x12]
        fmopa 	za0.s, p0/m, p1/m,  z0.s, z16.s
        fmopa 	za0.s, p0/m, p1/m,  z1.s, z17.s
        fmopa 	za0.s, p0/m, p1/m,  z2.s, z18.s
        fmopa 	za0.s, p0/m, p1/m,  z3.s, z19.s
	add x10, x10, x8, lsl #4 
	add x12, x12, x8, lsl #4 

	ld1w 	{z8.s-z11.s}, pn8/z, [x11]
	ld1w 	{z24.s-z27.s}, pn8/z, [x13]
        fmopa 	za2.s, p0/m, p1/m,  z8.s, z16.s
        fmopa 	za2.s, p0/m, p1/m,  z9.s, z17.s
        fmopa 	za2.s, p0/m, p1/m,  z10.s, z18.s
        fmopa 	za2.s, p0/m, p1/m,  z11.s, z19.s
	add x11, x11, x8, lsl #4 
	add x13, x13, x8, lsl #4 

	ld1w 	{z4.s-z7.s}, pn8/z, [x10]
	ld1w 	{z20.s-z23.s}, pn8/z, [x12]
        fmopa 	za1.s, p0/m, p1/m,  z0.s, z24.s
        fmopa 	za1.s, p0/m, p1/m,  z1.s, z25.s
        fmopa 	za1.s, p0/m, p1/m,  z2.s, z26.s
        fmopa 	za1.s, p0/m, p1/m,  z3.s, z27.s
	add x10, x10, x8, lsl #4 
	add x12, x12, x8, lsl #4 

	ld1w 	{z12.s-z15.s}, pn8/z, [x11]
	ld1w 	{z28.s-z31.s}, pn8/z, [x13]
        fmopa 	za3.s, p0/m, p1/m,  z8.s, z24.s
        fmopa 	za3.s, p0/m, p1/m,  z9.s, z25.s
        fmopa 	za3.s, p0/m, p1/m,  z10.s, z26.s
        fmopa 	za3.s, p0/m, p1/m,  z11.s, z27.s
	add x11, x11, x8, lsl #4 
	add x13, x13, x8, lsl #4 

        fmopa 	za0.s, p0/m, p1/m,  z4.s, z20.s
        fmopa 	za0.s, p0/m, p1/m,  z5.s, z21.s
        fmopa 	za0.s, p0/m, p1/m,  z6.s, z22.s
        fmopa 	za0.s, p0/m, p1/m,  z7.s, z23.s

        fmopa 	za2.s, p0/m, p1/m,  z12.s, z20.s
        fmopa 	za2.s, p0/m, p1/m,  z13.s, z21.s
        fmopa 	za2.s, p0/m, p1/m,  z14.s, z22.s
        fmopa 	za2.s, p0/m, p1/m,  z15.s, z23.s

        fmopa 	za1.s, p0/m, p1/m,  z4.s, z28.s
        fmopa 	za1.s, p0/m, p1/m,  z5.s, z29.s
        fmopa 	za1.s, p0/m, p1/m,  z6.s, z30.s
        fmopa 	za1.s, p0/m, p1/m,  z7.s, z31.s

        fmopa 	za3.s, p0/m, p1/m,  z12.s, z28.s
        fmopa 	za3.s, p0/m, p1/m,  z13.s, z29.s
        fmopa 	za3.s, p0/m, p1/m,  z14.s, z30.s
        fmopa 	za3.s, p0/m, p1/m,  z15.s, z31.s

	sub x5, x5, 8
	cmp x5, #0
	bgt kloop

	//SAVE STEP
	mov x14, #0 			//mov register index
	mov x15, x8			//x9 = 16 elements (vl)
	mul x15, x15, x6		//x9 = x9 * LDC (X6)
	lsl x15, x15, #2		//x9 = x9 * LDC (X6)
	add x15, x15, x2		//x9 = x9 + C -- x9 = C + LDC * 16
save2x2:
	mova    {z0.b-z3.b}, za0h.b[w14, 0:3] 	//mov 4 registers of ZA0.B
	st1w    {z0.s-z1.s}, pn8, [x2]		//Store vectors of ZA0.s and ZA1.S on C
	st1w    {z2.s-z3.s}, pn8, [x15]		//Store vectors of ZA2.s and ZA3.S on C
	
	add w14, w14, #4			//update w12 
	add x2, x2, #128			//update x2 -- C + LDC*sizeof(float)
	add x15, x15, #128			//update x9 -- C + LDC * 16 + LDC

	cmp x14, #64
	blt save2x2

	smstop
	ret
