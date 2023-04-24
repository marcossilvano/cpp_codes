
out/a.elf:     file format elf32-m68k


Disassembly of section .text:

00000000 <_start>:
extern void (*__init_array_start[])() __attribute__((weak));
extern void (*__init_array_end[])() __attribute__((weak));
extern void (*__fini_array_start[])() __attribute__((weak));
extern void (*__fini_array_end[])() __attribute__((weak));

__attribute__((used)) __attribute__((section(".text.unlikely"))) void _start() {
       0:	       movem.l d2-d3/a2,-(sp)
	// initialize globals, ctors etc.
	unsigned long count;
	unsigned long i;

	count = __preinit_array_end - __preinit_array_start;
       4:	       move.l #16384,d3
       a:	       subi.l #16384,d3
      10:	       asr.l #2,d3
	for (i = 0; i < count; i++)
      12:	       move.l #16384,d0
      18:	       cmpi.l #16384,d0
      1e:	/----- beq.s 32 <_start+0x32>
      20:	|      lea 4000 <incbin_image_start>,a2
      26:	|      moveq #0,d2
		__preinit_array_start[i]();
      28:	|  /-> movea.l (a2)+,a0
      2a:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
      2c:	|  |   addq.l #1,d2
      2e:	|  |   cmp.l d3,d2
      30:	|  \-- bcs.s 28 <_start+0x28>

	count = __init_array_end - __init_array_start;
      32:	\----> move.l #16384,d3
      38:	       subi.l #16384,d3
      3e:	       asr.l #2,d3
	for (i = 0; i < count; i++)
      40:	       move.l #16384,d0
      46:	       cmpi.l #16384,d0
      4c:	/----- beq.s 60 <_start+0x60>
      4e:	|      lea 4000 <incbin_image_start>,a2
      54:	|      moveq #0,d2
		__init_array_start[i]();
      56:	|  /-> movea.l (a2)+,a0
      58:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
      5a:	|  |   addq.l #1,d2
      5c:	|  |   cmp.l d3,d2
      5e:	|  \-- bcs.s 56 <_start+0x56>

	main();
      60:	\----> jsr 8c <main>

	// call dtors
	count = __fini_array_end - __fini_array_start;
      66:	       move.l #16384,d2
      6c:	       subi.l #16384,d2
      72:	       asr.l #2,d2
	for (i = count; i > 0; i--)
      74:	/----- beq.s 86 <_start+0x86>
      76:	|      lea 4000 <incbin_image_start>,a2
		__fini_array_start[i - 1]();
      7c:	|  /-> subq.l #1,d2
      7e:	|  |   movea.l -(a2),a0
      80:	|  |   jsr (a0)
	for (i = count; i > 0; i--)
      82:	|  |   tst.l d2
      84:	|  \-- bne.s 7c <_start+0x7c>
}
      86:	\----> movem.l (sp)+,d2-d3/a2
      8a:	       rts

0000008c <main>:
static void Wait10() { WaitLine(0x10); }
static void Wait11() { WaitLine(0x11); }
static void Wait12() { WaitLine(0x12); }
static void Wait13() { WaitLine(0x13); }

int main() {
      8c:	                                                          link.w a5,#-52
      90:	                                                          movem.l d2-d7/a2-a4/a6,-(sp)

	SysBase = *((struct ExecBase**)4UL);
      94:	                                                          movea.l 4 <_start+0x4>,a6
      98:	                                                          move.l a6,12b9a <SysBase>
	custom = (struct Custom*)0xdff000;
      9e:	                                                          move.l #14675968,12ba4 <custom>

	// We will use the graphics library only to locate and restore the system copper list once we are through.
	GfxBase = (struct GfxBase *)OpenLibrary((CONST_STRPTR)"graphics.library",0);
      a8:	                                                          lea 32c4 <incbin_player_end+0xd4>,a1
      ae:	                                                          moveq #0,d0
      b0:	                                                          jsr -552(a6)
      b4:	                                                          move.l d0,12b96 <GfxBase>
	if (!GfxBase)
      ba:	      /-------------------------------------------------- beq.w c70 <main+0xbe4>
		Exit(0);

	// used for printing
	DOSBase = (struct DosLibrary*)OpenLibrary((CONST_STRPTR)"dos.library", 0);
      be:	      |                                                   movea.l 12b9a <SysBase>,a6
      c4:	      |                                                   lea 32d5 <incbin_player_end+0xe5>,a1
      ca:	      |                                                   moveq #0,d0
      cc:	      |                                                   jsr -552(a6)
      d0:	      |                                                   move.l d0,12b92 <DOSBase>
	if (!DOSBase)
      d6:	/-----|-------------------------------------------------- beq.w bf6 <main+0xb6a>
		Exit(0);

#ifdef __cplusplus
	KPrintF("Hello debugger from Amiga: %ld!\n", staticClass.i);
#else
	KPrintF("Hello debugger from Amiga!\n");
      da:	|  /--|-------------------------------------------------> pea 32e1 <incbin_player_end+0xf1>
      e0:	|  |  |                                                   lea fa6 <KPrintF>,a4
      e6:	|  |  |                                                   jsr (a4)
	KPrintF("Another hello from Amiga!\n");
      e8:	|  |  |                                                   pea 32fd <incbin_player_end+0x10d>
      ee:	|  |  |                                                   jsr (a4)
#endif
	Write(Output(), (APTR)"Hello console!\n", 15);
      f0:	|  |  |                                                   movea.l 12b92 <DOSBase>,a6
      f6:	|  |  |                                                   jsr -60(a6)
      fa:	|  |  |                                                   movea.l 12b92 <DOSBase>,a6
     100:	|  |  |                                                   move.l d0,d1
     102:	|  |  |                                                   move.l #13080,d2
     108:	|  |  |                                                   moveq #15,d3
     10a:	|  |  |                                                   jsr -48(a6)
	Delay(50);
     10e:	|  |  |                                                   movea.l 12b92 <DOSBase>,a6
     114:	|  |  |                                                   moveq #50,d1
     116:	|  |  |                                                   jsr -198(a6)

	warpmode(1);
     11a:	|  |  |                                                   pea 1 <_start+0x1>
     11e:	|  |  |                                                   jsr 1018 <warpmode>
		register volatile const void* _a0 ASM("a0") = module;
     124:	|  |  |                                                   lea 11704 <incbin_module_start>,a0
		register volatile const void* _a1 ASM("a1") = NULL;
     12a:	|  |  |                                                   suba.l a1,a1
		register volatile const void* _a2 ASM("a2") = NULL;
     12c:	|  |  |                                                   suba.l a2,a2
		register volatile const void* _a3 ASM("a3") = player;
     12e:	|  |  |                                                   lea 188a <incbin_player_start>,a3
		__asm volatile (
     134:	|  |  |                                                   movem.l d1-d7/a4-a6,-(sp)
     138:	|  |  |                                                   jsr (a3)
     13a:	|  |  |                                                   movem.l (sp)+,d1-d7/a4-a6
	// TODO: precalc stuff here
#ifdef MUSIC
	if(p61Init(module) != 0)
     13e:	|  |  |                                                   lea 12(sp),sp
     142:	|  |  |                                                   tst.l d0
     144:	|  |  |  /----------------------------------------------- bne.w b46 <main+0xaba>
		KPrintF("p61Init failed!\n");
#endif
	warpmode(0);
     148:	|  |  |  |  /-------------------------------------------> clr.l -(sp)
     14a:	|  |  |  |  |                                             jsr 1018 <warpmode>
	Forbid();
     150:	|  |  |  |  |                                             movea.l 12b9a <SysBase>,a6
     156:	|  |  |  |  |                                             jsr -132(a6)
	SystemADKCON=custom->adkconr;
     15a:	|  |  |  |  |                                             movea.l 12ba4 <custom>,a0
     160:	|  |  |  |  |                                             move.w 16(a0),d0
     164:	|  |  |  |  |                                             move.w d0,12b84 <SystemADKCON>
	SystemInts=custom->intenar;
     16a:	|  |  |  |  |                                             move.w 28(a0),d0
     16e:	|  |  |  |  |                                             move.w d0,12b88 <SystemInts>
	SystemDMA=custom->dmaconr;
     174:	|  |  |  |  |                                             move.w 2(a0),d0
     178:	|  |  |  |  |                                             move.w d0,12b86 <SystemDMA>
	ActiView=GfxBase->ActiView; //store current view
     17e:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     184:	|  |  |  |  |                                             move.l 34(a6),12b80 <ActiView>
	LoadView(0);
     18c:	|  |  |  |  |                                             suba.l a1,a1
     18e:	|  |  |  |  |                                             jsr -222(a6)
	WaitTOF();
     192:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     198:	|  |  |  |  |                                             jsr -270(a6)
	WaitTOF();
     19c:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     1a2:	|  |  |  |  |                                             jsr -270(a6)
	WaitVbl();
     1a6:	|  |  |  |  |                                             lea ef0 <WaitVbl>,a2
     1ac:	|  |  |  |  |                                             jsr (a2)
	WaitVbl();
     1ae:	|  |  |  |  |                                             jsr (a2)
	OwnBlitter();
     1b0:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     1b6:	|  |  |  |  |                                             jsr -456(a6)
	WaitBlit();	
     1ba:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     1c0:	|  |  |  |  |                                             jsr -228(a6)
	Disable();
     1c4:	|  |  |  |  |                                             movea.l 12b9a <SysBase>,a6
     1ca:	|  |  |  |  |                                             jsr -120(a6)
	custom->intena=0x7fff;//disable all interrupts
     1ce:	|  |  |  |  |                                             movea.l 12ba4 <custom>,a0
     1d4:	|  |  |  |  |                                             move.w #32767,154(a0)
	custom->intreq=0x7fff;//Clear any interrupts that were pending
     1da:	|  |  |  |  |                                             move.w #32767,156(a0)
	custom->dmacon=0x7fff;//Clear all DMA channels
     1e0:	|  |  |  |  |                                             move.w #32767,150(a0)
     1e6:	|  |  |  |  |                                             addq.l #4,sp
	for(int a=0;a<32;a++)
     1e8:	|  |  |  |  |                                             moveq #0,d1
		custom->color[a]=0;
     1ea:	|  |  |  |  |        /----------------------------------> move.l d1,d0
     1ec:	|  |  |  |  |        |                                    addi.l #192,d0
     1f2:	|  |  |  |  |        |                                    add.l d0,d0
     1f4:	|  |  |  |  |        |                                    move.w #0,(0,a0,d0.l)
	for(int a=0;a<32;a++)
     1fa:	|  |  |  |  |        |                                    addq.l #1,d1
     1fc:	|  |  |  |  |        |                                    moveq #32,d0
     1fe:	|  |  |  |  |        |                                    cmp.l d1,d0
     200:	|  |  |  |  |        +----------------------------------- bne.s 1ea <main+0x15e>
	WaitVbl();
     202:	|  |  |  |  |        |                                    jsr (a2)
	WaitVbl();
     204:	|  |  |  |  |        |                                    jsr (a2)
	UWORD getvbr[] = { 0x4e7a, 0x0801, 0x4e73 }; // MOVEC.L VBR,D0 RTE
     206:	|  |  |  |  |        |                                    move.w #20090,-50(a5)
     20c:	|  |  |  |  |        |                                    move.w #2049,-48(a5)
     212:	|  |  |  |  |        |                                    move.w #20083,-46(a5)
	if (SysBase->AttnFlags & AFF_68010) 
     218:	|  |  |  |  |        |                                    movea.l 12b9a <SysBase>,a6
     21e:	|  |  |  |  |        |                                    btst #0,297(a6)
     224:	|  |  |  |  |  /-----|----------------------------------- beq.w c9c <main+0xc10>
		vbr = (APTR)Supervisor((ULONG (*)())getvbr);
     228:	|  |  |  |  |  |     |                                    moveq #-50,d7
     22a:	|  |  |  |  |  |     |                                    add.l a5,d7
     22c:	|  |  |  |  |  |     |                                    exg d7,a5
     22e:	|  |  |  |  |  |     |                                    jsr -30(a6)
     232:	|  |  |  |  |  |     |                                    exg d7,a5
	VBR=GetVBR();
     234:	|  |  |  |  |  |     |                                    move.l d0,12b8e <VBR>
	return *(volatile APTR*)(((UBYTE*)VBR)+0x6c);
     23a:	|  |  |  |  |  |     |                                    movea.l 12b8e <VBR>,a0
     240:	|  |  |  |  |  |     |                                    move.l 108(a0),d0
	SystemIrq=GetInterruptHandler(); //store interrupt register
     244:	|  |  |  |  |  |     |                                    move.l d0,12b8a <SystemIrq>

	TakeSystem();
	WaitVbl();
     24a:	|  |  |  |  |  |     |                                    jsr (a2)

	char* test = (char*)AllocMem(2502, MEMF_ANY);
     24c:	|  |  |  |  |  |     |                                    movea.l 12b9a <SysBase>,a6
     252:	|  |  |  |  |  |     |                                    move.l #2502,d0
     258:	|  |  |  |  |  |     |                                    moveq #0,d1
     25a:	|  |  |  |  |  |     |                                    jsr -198(a6)
     25e:	|  |  |  |  |  |     |                                    move.l d0,d4
	memset(test, 0xcd, 2502);
     260:	|  |  |  |  |  |     |                                    pea 9c6 <main+0x93a>
     264:	|  |  |  |  |  |     |                                    pea cd <main+0x41>
     268:	|  |  |  |  |  |     |                                    move.l d0,-(sp)
     26a:	|  |  |  |  |  |     |                                    jsr 12ea <memset>
	memclr(test + 2, 2502 - 4);
     270:	|  |  |  |  |  |     |                                    movea.l d4,a0
     272:	|  |  |  |  |  |     |                                    addq.l #2,a0
	__asm volatile (
     274:	|  |  |  |  |  |     |                                    move.l #2498,d5
     27a:	|  |  |  |  |  |     |                                    cmpi.l #256,d5
     280:	|  |  |  |  |  |     |                             /----- blt.w 2de <main+0x252>
     284:	|  |  |  |  |  |     |                             |      adda.l d5,a0
     286:	|  |  |  |  |  |     |                             |      moveq #0,d0
     288:	|  |  |  |  |  |     |                             |      moveq #0,d1
     28a:	|  |  |  |  |  |     |                             |      moveq #0,d2
     28c:	|  |  |  |  |  |     |                             |      moveq #0,d3
     28e:	|  |  |  |  |  |     |                             |  /-> movem.l d0-d3,-(a0)
     292:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     296:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     29a:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     29e:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2a2:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2a6:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2aa:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2ae:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2b2:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2b6:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2ba:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2be:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2c2:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2c6:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2ca:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2ce:	|  |  |  |  |  |     |                             |  |   subi.l #256,d5
     2d4:	|  |  |  |  |  |     |                             |  |   cmpi.l #256,d5
     2da:	|  |  |  |  |  |     |                             |  \-- bge.w 28e <main+0x202>
     2de:	|  |  |  |  |  |     |                             >----> cmpi.w #64,d5
     2e2:	|  |  |  |  |  |     |                             |  /-- blt.w 2fe <main+0x272>
     2e6:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2ea:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2ee:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2f2:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2f6:	|  |  |  |  |  |     |                             |  |   subi.w #64,d5
     2fa:	|  |  |  |  |  |     |                             \--|-- bra.w 2de <main+0x252>
     2fe:	|  |  |  |  |  |     |                                \-> lsr.w #2,d5
     300:	|  |  |  |  |  |     |                                /-- bcc.w 306 <main+0x27a>
     304:	|  |  |  |  |  |     |                                |   clr.w -(a0)
     306:	|  |  |  |  |  |     |                                \-> moveq #16,d0
     308:	|  |  |  |  |  |     |                                    sub.w d5,d0
     30a:	|  |  |  |  |  |     |                                    add.w d0,d0
     30c:	|  |  |  |  |  |     |                                    jmp (310 <main+0x284>,pc,d0.w)
     310:	|  |  |  |  |  |     |                                    clr.l -(a0)
     312:	|  |  |  |  |  |     |                                    clr.l -(a0)
     314:	|  |  |  |  |  |     |                                    clr.l -(a0)
     316:	|  |  |  |  |  |     |                                    clr.l -(a0)
     318:	|  |  |  |  |  |     |                                    clr.l -(a0)
     31a:	|  |  |  |  |  |     |                                    clr.l -(a0)
     31c:	|  |  |  |  |  |     |                                    clr.l -(a0)
     31e:	|  |  |  |  |  |     |                                    clr.l -(a0)
     320:	|  |  |  |  |  |     |                                    clr.l -(a0)
     322:	|  |  |  |  |  |     |                                    clr.l -(a0)
     324:	|  |  |  |  |  |     |                                    clr.l -(a0)
     326:	|  |  |  |  |  |     |                                    clr.l -(a0)
     328:	|  |  |  |  |  |     |                                    clr.l -(a0)
     32a:	|  |  |  |  |  |     |                                    clr.l -(a0)
     32c:	|  |  |  |  |  |     |                                    clr.l -(a0)
     32e:	|  |  |  |  |  |     |                                    clr.l -(a0)
	FreeMem(test, 2502);
     330:	|  |  |  |  |  |     |                                    movea.l 12b9a <SysBase>,a6
     336:	|  |  |  |  |  |     |                                    movea.l d4,a1
     338:	|  |  |  |  |  |     |                                    move.l #2502,d0
     33e:	|  |  |  |  |  |     |                                    jsr -210(a6)

	USHORT* copper1 = (USHORT*)AllocMem(1024, MEMF_CHIP);
     342:	|  |  |  |  |  |     |                                    movea.l 12b9a <SysBase>,a6
     348:	|  |  |  |  |  |     |                                    move.l #1024,d0
     34e:	|  |  |  |  |  |     |                                    moveq #2,d1
     350:	|  |  |  |  |  |     |                                    jsr -198(a6)
     354:	|  |  |  |  |  |     |                                    movea.l d0,a3
	USHORT* copPtr = copper1;

	// register graphics resources with WinUAE for nicer gfx debugger experience
	debug_register_bitmap(image, "image.bpl", 320, 256, 5, debug_resource_bitmap_interleaved);
     356:	|  |  |  |  |  |     |                                    pea 1 <_start+0x1>
     35a:	|  |  |  |  |  |     |                                    pea 100 <main+0x74>
     35e:	|  |  |  |  |  |     |                                    pea 140 <main+0xb4>
     362:	|  |  |  |  |  |     |                                    pea 3339 <incbin_player_end+0x149>
     368:	|  |  |  |  |  |     |                                    pea 4000 <incbin_image_start>
     36e:	|  |  |  |  |  |     |                                    lea 1174 <debug_register_bitmap.constprop.0>,a4
     374:	|  |  |  |  |  |     |                                    jsr (a4)
	debug_register_bitmap(bob, "bob.bpl", 32, 96, 5, debug_resource_bitmap_interleaved | debug_resource_bitmap_masked);
     376:	|  |  |  |  |  |     |                                    lea 32(sp),sp
     37a:	|  |  |  |  |  |     |                                    pea 3 <_start+0x3>
     37e:	|  |  |  |  |  |     |                                    pea 60 <_start+0x60>
     382:	|  |  |  |  |  |     |                                    pea 20 <_start+0x20>
     386:	|  |  |  |  |  |     |                                    pea 3343 <incbin_player_end+0x153>
     38c:	|  |  |  |  |  |     |                                    pea 10802 <incbin_bob_start>
     392:	|  |  |  |  |  |     |                                    jsr (a4)
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}

void debug_register_palette(const void* addr, const char* name, short numEntries, unsigned short flags) {
	struct debug_resource resource = {
     394:	|  |  |  |  |  |     |                                    clr.l -42(a5)
     398:	|  |  |  |  |  |     |                                    clr.l -38(a5)
     39c:	|  |  |  |  |  |     |                                    clr.l -34(a5)
     3a0:	|  |  |  |  |  |     |                                    clr.l -30(a5)
     3a4:	|  |  |  |  |  |     |                                    clr.l -26(a5)
     3a8:	|  |  |  |  |  |     |                                    clr.l -22(a5)
     3ac:	|  |  |  |  |  |     |                                    clr.l -18(a5)
     3b0:	|  |  |  |  |  |     |                                    clr.l -14(a5)
     3b4:	|  |  |  |  |  |     |                                    clr.l -10(a5)
     3b8:	|  |  |  |  |  |     |                                    clr.l -6(a5)
     3bc:	|  |  |  |  |  |     |                                    clr.w -2(a5)
		.address = (unsigned int)addr,
     3c0:	|  |  |  |  |  |     |                                    move.l #6216,d3
	struct debug_resource resource = {
     3c6:	|  |  |  |  |  |     |                                    move.l d3,-50(a5)
     3ca:	|  |  |  |  |  |     |                                    moveq #64,d1
     3cc:	|  |  |  |  |  |     |                                    move.l d1,-46(a5)
     3d0:	|  |  |  |  |  |     |                                    move.w #1,-10(a5)
     3d6:	|  |  |  |  |  |     |                                    move.w #32,-6(a5)
     3dc:	|  |  |  |  |  |     |                                    lea 20(sp),sp
	while(*source && --num > 0)
     3e0:	|  |  |  |  |  |     |                                    moveq #105,d0
	struct debug_resource resource = {
     3e2:	|  |  |  |  |  |     |                                    lea -42(a5),a0
     3e6:	|  |  |  |  |  |     |                                    lea 32ba <incbin_player_end+0xca>,a1
	while(*source && --num > 0)
     3ec:	|  |  |  |  |  |     |                                    lea -11(a5),a4
		*destination++ = *source++;
     3f0:	|  |  |  |  |  |  /--|----------------------------------> addq.l #1,a1
     3f2:	|  |  |  |  |  |  |  |                                    move.b d0,(a0)+
	while(*source && --num > 0)
     3f4:	|  |  |  |  |  |  |  |                                    move.b (a1),d0
     3f6:	|  |  |  |  |  |  |  |                                /-- beq.s 3fc <main+0x370>
     3f8:	|  |  |  |  |  |  |  |                                |   cmpa.l a0,a4
     3fa:	|  |  |  |  |  |  +--|--------------------------------|-- bne.s 3f0 <main+0x364>
	*destination = '\0';
     3fc:	|  |  |  |  |  |  |  |                                \-> clr.b (a0)
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     3fe:	|  |  |  |  |  |  |  |                                    move.w f0ff60 <_end+0xefd3b8>,d0
     404:	|  |  |  |  |  |  |  |                                    cmpi.w #20153,d0
     408:	|  |  |  |  |  |  |  |     /----------------------------- beq.w 9da <main+0x94e>
     40c:	|  |  |  |  |  |  |  |     |                              cmpi.w #-24562,d0
     410:	|  |  |  |  |  |  |  |     +----------------------------- beq.w 9da <main+0x94e>
	debug_register_palette(colors, "image.pal", 32, 0);
	debug_register_copperlist(copper1, "copper1", 1024, 0);
     414:	|  |  |  |  |  |  |  |     |                              pea 400 <main+0x374>
     418:	|  |  |  |  |  |  |  |     |                              pea 334b <incbin_player_end+0x15b>
     41e:	|  |  |  |  |  |  |  |     |                              move.l a3,-(sp)
     420:	|  |  |  |  |  |  |  |     |                              lea 123a <debug_register_copperlist.constprop.0>,a4
     426:	|  |  |  |  |  |  |  |     |                              jsr (a4)
	debug_register_copperlist(copper2, "copper2", sizeof(copper2), 0);
     428:	|  |  |  |  |  |  |  |     |                              pea 80 <_start+0x80>
     42c:	|  |  |  |  |  |  |  |     |                              pea 3353 <incbin_player_end+0x163>
     432:	|  |  |  |  |  |  |  |     |                              pea 342e <copper2>
     438:	|  |  |  |  |  |  |  |     |                              jsr (a4)
	*copListEnd++ = offsetof(struct Custom, ddfstrt);
     43a:	|  |  |  |  |  |  |  |     |                              move.w #146,(a3)
	*copListEnd++ = fw;
     43e:	|  |  |  |  |  |  |  |     |                              move.w #56,2(a3)
	*copListEnd++ = offsetof(struct Custom, ddfstop);
     444:	|  |  |  |  |  |  |  |     |                              move.w #148,4(a3)
	*copListEnd++ = fw+(((width>>4)-1)<<3);
     44a:	|  |  |  |  |  |  |  |     |                              move.w #208,6(a3)
	*copListEnd++ = offsetof(struct Custom, diwstrt);
     450:	|  |  |  |  |  |  |  |     |                              move.w #142,8(a3)
	*copListEnd++ = x+(y<<8);
     456:	|  |  |  |  |  |  |  |     |                              move.w #11393,10(a3)
	*copListEnd++ = offsetof(struct Custom, diwstop);
     45c:	|  |  |  |  |  |  |  |     |                              move.w #144,12(a3)
	*copListEnd++ = (xstop-256)+((ystop-256)<<8);
     462:	|  |  |  |  |  |  |  |     |                              move.w #11457,14(a3)

	copPtr = screenScanDefault(copPtr);
	//enable bitplanes	
	*copPtr++ = offsetof(struct Custom, bplcon0);
     468:	|  |  |  |  |  |  |  |     |                              move.w #256,16(a3)
	*copPtr++ = (0<<10)/*dual pf*/|(1<<9)/*color*/|((5)<<12)/*num bitplanes*/;
     46e:	|  |  |  |  |  |  |  |     |                              move.w #20992,18(a3)
	*copPtr++ = offsetof(struct Custom, bplcon1);	//scrolling
     474:	|  |  |  |  |  |  |  |     |                              move.w #258,20(a3)
     47a:	|  |  |  |  |  |  |  |     |                              lea 22(a3),a0
     47e:	|  |  |  |  |  |  |  |     |                              move.l a0,12ba0 <scroll>
	scroll = copPtr;
	*copPtr++ = 0;
     484:	|  |  |  |  |  |  |  |     |                              clr.w 22(a3)
	*copPtr++ = offsetof(struct Custom, bplcon2);	//playfied priority
     488:	|  |  |  |  |  |  |  |     |                              move.w #260,24(a3)
	*copPtr++ = 1<<6;//0x24;			//Sprites have priority over playfields
     48e:	|  |  |  |  |  |  |  |     |                              move.w #64,26(a3)

	const USHORT lineSize=320/8;

	//set bitplane modulo
	*copPtr++=offsetof(struct Custom, bpl1mod); //odd planes   1,3,5
     494:	|  |  |  |  |  |  |  |     |                              move.w #264,28(a3)
	*copPtr++=4*lineSize;
     49a:	|  |  |  |  |  |  |  |     |                              move.w #160,30(a3)
	*copPtr++=offsetof(struct Custom, bpl2mod); //even  planes 2,4
     4a0:	|  |  |  |  |  |  |  |     |                              move.w #266,32(a3)
	*copPtr++=4*lineSize;
     4a6:	|  |  |  |  |  |  |  |     |                              move.w #160,34(a3)
		ULONG addr=(ULONG)planes[i];
     4ac:	|  |  |  |  |  |  |  |     |                              move.l #16384,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     4b2:	|  |  |  |  |  |  |  |     |                              move.w #224,36(a3)
		*copListEnd++=(UWORD)(addr>>16);
     4b8:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     4ba:	|  |  |  |  |  |  |  |     |                              clr.w d1
     4bc:	|  |  |  |  |  |  |  |     |                              swap d1
     4be:	|  |  |  |  |  |  |  |     |                              move.w d1,38(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     4c2:	|  |  |  |  |  |  |  |     |                              move.w #226,40(a3)
		*copListEnd++=(UWORD)addr;
     4c8:	|  |  |  |  |  |  |  |     |                              move.w d0,42(a3)
		ULONG addr=(ULONG)planes[i];
     4cc:	|  |  |  |  |  |  |  |     |                              move.l #16424,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     4d2:	|  |  |  |  |  |  |  |     |                              move.w #228,44(a3)
		*copListEnd++=(UWORD)(addr>>16);
     4d8:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     4da:	|  |  |  |  |  |  |  |     |                              clr.w d1
     4dc:	|  |  |  |  |  |  |  |     |                              swap d1
     4de:	|  |  |  |  |  |  |  |     |                              move.w d1,46(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     4e2:	|  |  |  |  |  |  |  |     |                              move.w #230,48(a3)
		*copListEnd++=(UWORD)addr;
     4e8:	|  |  |  |  |  |  |  |     |                              move.w d0,50(a3)
		ULONG addr=(ULONG)planes[i];
     4ec:	|  |  |  |  |  |  |  |     |                              move.l #16464,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     4f2:	|  |  |  |  |  |  |  |     |                              move.w #232,52(a3)
		*copListEnd++=(UWORD)(addr>>16);
     4f8:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     4fa:	|  |  |  |  |  |  |  |     |                              clr.w d1
     4fc:	|  |  |  |  |  |  |  |     |                              swap d1
     4fe:	|  |  |  |  |  |  |  |     |                              move.w d1,54(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     502:	|  |  |  |  |  |  |  |     |                              move.w #234,56(a3)
		*copListEnd++=(UWORD)addr;
     508:	|  |  |  |  |  |  |  |     |                              move.w d0,58(a3)
		ULONG addr=(ULONG)planes[i];
     50c:	|  |  |  |  |  |  |  |     |                              move.l #16504,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     512:	|  |  |  |  |  |  |  |     |                              move.w #236,60(a3)
		*copListEnd++=(UWORD)(addr>>16);
     518:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     51a:	|  |  |  |  |  |  |  |     |                              clr.w d1
     51c:	|  |  |  |  |  |  |  |     |                              swap d1
     51e:	|  |  |  |  |  |  |  |     |                              move.w d1,62(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     522:	|  |  |  |  |  |  |  |     |                              move.w #238,64(a3)
		*copListEnd++=(UWORD)addr;
     528:	|  |  |  |  |  |  |  |     |                              move.w d0,66(a3)
		ULONG addr=(ULONG)planes[i];
     52c:	|  |  |  |  |  |  |  |     |                              move.l #16544,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     532:	|  |  |  |  |  |  |  |     |                              move.w #240,68(a3)
		*copListEnd++=(UWORD)(addr>>16);
     538:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     53a:	|  |  |  |  |  |  |  |     |                              clr.w d1
     53c:	|  |  |  |  |  |  |  |     |                              swap d1
     53e:	|  |  |  |  |  |  |  |     |                              move.w d1,70(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     542:	|  |  |  |  |  |  |  |     |                              move.w #242,72(a3)
		*copListEnd++=(UWORD)addr;
     548:	|  |  |  |  |  |  |  |     |                              move.w d0,74(a3)
     54c:	|  |  |  |  |  |  |  |     |                              lea 76(a3),a1
     550:	|  |  |  |  |  |  |  |     |                              move.l #6280,d2
     556:	|  |  |  |  |  |  |  |     |                              lea 24(sp),sp
     55a:	|  |  |  |  |  |  |  |     |                              lea 1848 <incbin_colors_start>,a0
     560:	|  |  |  |  |  |  |  |     |                              move.w #382,d0
     564:	|  |  |  |  |  |  |  |     |                              sub.w d3,d0
		planes[a]=(UBYTE*)(image + lineSize * a);
	copPtr = copSetPlanes(0, copPtr, planes, 5);

	// set colors
	for(int a=0; a < 32; a++)
		copPtr = copSetColor(copPtr, a, ((USHORT*)colors)[a]);
     566:	|  |  |  |  |  |  |  |  /--|----------------------------> move.w (a0)+,d1
	*copListCurrent++=offsetof(struct Custom, color[index]);
     568:	|  |  |  |  |  |  |  |  |  |                              movea.w d0,a6
     56a:	|  |  |  |  |  |  |  |  |  |                              adda.w a0,a6
     56c:	|  |  |  |  |  |  |  |  |  |                              move.w a6,(a1)
	*copListCurrent++=color;
     56e:	|  |  |  |  |  |  |  |  |  |                              addq.l #4,a1
     570:	|  |  |  |  |  |  |  |  |  |                              move.w d1,-2(a1)
	for(int a=0; a < 32; a++)
     574:	|  |  |  |  |  |  |  |  |  |                              cmpa.l d2,a0
     576:	|  |  |  |  |  |  |  |  +--|----------------------------- bne.s 566 <main+0x4da>

	// jump to copper2
	*copPtr++ = offsetof(struct Custom, copjmp2);
     578:	|  |  |  |  |  |  |  |  |  |                              move.w #138,204(a3)
	*copPtr++ = 0x7fff;
     57e:	|  |  |  |  |  |  |  |  |  |                              move.w #32767,206(a3)

	custom->cop1lc = (ULONG)copper1;
     584:	|  |  |  |  |  |  |  |  |  |                              movea.l 12ba4 <custom>,a0
     58a:	|  |  |  |  |  |  |  |  |  |                              move.l a3,128(a0)
	custom->cop2lc = (ULONG)copper2;
     58e:	|  |  |  |  |  |  |  |  |  |                              move.l #13358,132(a0)
	custom->dmacon = DMAF_BLITTER;//disable blitter dma for copjmp bug
     596:	|  |  |  |  |  |  |  |  |  |                              move.w #64,150(a0)
	custom->copjmp1 = 0x7fff; //start coppper
     59c:	|  |  |  |  |  |  |  |  |  |                              move.w #32767,136(a0)
	custom->dmacon = DMAF_SETCLR | DMAF_MASTER | DMAF_RASTER | DMAF_COPPER | DMAF_BLITTER;
     5a2:	|  |  |  |  |  |  |  |  |  |                              move.w #-31808,150(a0)
	*(volatile APTR*)(((UBYTE*)VBR)+0x6c) = interrupt;
     5a8:	|  |  |  |  |  |  |  |  |  |                              movea.l 12b8e <VBR>,a1
     5ae:	|  |  |  |  |  |  |  |  |  |                              move.l #3680,108(a1)

	// DEMO
	SetInterruptHandler((APTR)interruptHandler);
	custom->intena = INTF_SETCLR | INTF_INTEN | INTF_VERTB;
     5b6:	|  |  |  |  |  |  |  |  |  |                              move.w #-16352,154(a0)
#ifdef MUSIC
	custom->intena = INTF_SETCLR | INTF_EXTER; // ThePlayer needs INTF_EXTER
     5bc:	|  |  |  |  |  |  |  |  |  |                              move.w #-24576,154(a0)
#endif

	custom->intreq=(1<<INTB_VERTB);//reset vbl req
     5c2:	|  |  |  |  |  |  |  |  |  |                              move.w #32,156(a0)
__attribute__((always_inline)) inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
     5c8:	|  |  |  |  |  |  |  |  |  |                              move.b bfe001 <_end+0xbeb459>,d0

	while(!MouseLeft()) {
     5ce:	|  |  |  |  |  |  |  |  |  |                              btst #6,d0
     5d2:	|  |  |  |  |  |  |  |  |  |  /-------------------------- beq.w 75c <main+0x6d0>
     5d6:	|  |  |  |  |  |  |  |  |  |  |                           lea 1668 <__umodsi3>,a4
     5dc:	|  |  |  |  |  |  |  |  |  |  |                           lea 337a <sinus40>,a3
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     5e2:	|  |  |  |  |  |  |  |  |  |  |  /----------------------> move.l dff004 <_end+0xdec45c>,d0
     5e8:	|  |  |  |  |  |  |  |  |  |  |  |                        move.l d0,-50(a5)
		if(((vpos >> 8) & 511) == line)
     5ec:	|  |  |  |  |  |  |  |  |  |  |  |                        move.l -50(a5),d0
     5f0:	|  |  |  |  |  |  |  |  |  |  |  |                        lsr.l #8,d0
     5f2:	|  |  |  |  |  |  |  |  |  |  |  |                        andi.l #511,d0
     5f8:	|  |  |  |  |  |  |  |  |  |  |  |                        moveq #16,d1
     5fa:	|  |  |  |  |  |  |  |  |  |  |  |                        cmp.l d0,d1
     5fc:	|  |  |  |  |  |  |  |  |  |  |  +----------------------- bne.s 5e2 <main+0x556>
		Wait10();
		int f = frameCounter & 255;
     5fe:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w 12b9e <frameCounter>,d7

		// clear
		WaitBlit();
     604:	|  |  |  |  |  |  |  |  |  |  |  |                        movea.l 12b96 <GfxBase>,a6
     60a:	|  |  |  |  |  |  |  |  |  |  |  |                        jsr -228(a6)
		custom->bltcon0 = A_TO_D | DEST;
     60e:	|  |  |  |  |  |  |  |  |  |  |  |                        movea.l 12ba4 <custom>,a0
     614:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #496,64(a0)
		custom->bltcon1 = 0;
     61a:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #0,66(a0)
		custom->bltadat = 0;
     620:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #0,116(a0)
		custom->bltdpt = (APTR)image + 320 / 8 * 200 * 5;
     626:	|  |  |  |  |  |  |  |  |  |  |  |                        move.l #56384,84(a0)
		custom->bltdmod = 0;
     62e:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #0,102(a0)
		custom->bltafwm = custom->bltalwm = 0xffff;
     634:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #-1,70(a0)
     63a:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #-1,68(a0)
		custom->bltsize = ((56 * 5) << HSIZEBITS) | (320/16);
     640:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #17940,88(a0)
     646:	|  |  |  |  |  |  |  |  |  |  |  |                        moveq #0,d6
     648:	|  |  |  |  |  |  |  |  |  |  |  |                        moveq #0,d5

		// blit
		for(short i = 0; i < 16; i++) {
			const short x = i * 16 + sinus32[(frameCounter + i) % sizeof(sinus32)] * 2;
     64a:	|  |  |  |  |  |  |  |  |  |  |  |                    /-> movea.w 12b9e <frameCounter>,a0
     650:	|  |  |  |  |  |  |  |  |  |  |  |                    |   pea 33 <_start+0x33>
     654:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.w a0,a6
     656:	|  |  |  |  |  |  |  |  |  |  |  |                    |   pea (0,a6,d5.l)
     65a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   jsr (a4)
     65c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #8,sp
     65e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lea 33ba <sinus32>,a0
     664:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #0,d3
     666:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.b (0,a0,d0.l),d3
     66a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d6,d3
     66c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.w d3,d3
			const short y = sinus40[((frameCounter + i) * 2) & 63] / 2;
     66e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.w 12b9e <frameCounter>,a0
     674:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.w a0,a6
     676:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lea (0,a6,d5.l),a0
     67a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   adda.l a0,a0
     67c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l a0,d0
     67e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #62,d1
     680:	|  |  |  |  |  |  |  |  |  |  |  |                    |   and.l d1,d0
     682:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.b (0,a3,d0.l),d2
     686:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsr.b #1,d2
			const APTR src = (APTR)bob + 32 / 8 * 10 * 16 * (i % 6);
     688:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d5,d0
     68a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #6,d1
     68c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   ext.l d0
     68e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   divs.w d1,d0
     690:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d0,d4
     692:	|  |  |  |  |  |  |  |  |  |  |  |                    |   swap d4
     694:	|  |  |  |  |  |  |  |  |  |  |  |                    |   muls.w #640,d4
     698:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addi.l #67586,d4

			WaitBlit();
     69e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.l 12b96 <GfxBase>,a6
     6a4:	|  |  |  |  |  |  |  |  |  |  |  |                    |   jsr -228(a6)
			custom->bltcon0 = 0xca | SRCA | SRCB | SRCC | DEST | ((x & 15) << ASHIFTSHIFT); // A = source, B = mask, C = background, D = destination
     6a8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #0,d0
     6aa:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d3,d0
     6ac:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #12,d1
     6ae:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsl.l d1,d0
     6b0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.l 12ba4 <custom>,a0
     6b6:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d0,d1
     6b8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   ori.w #4042,d1
     6bc:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d1,64(a0)
			custom->bltcon1 = ((x & 15) << BSHIFTSHIFT);
     6c0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d0,66(a0)
			custom->bltapt = src;
     6c4:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d4,80(a0)
			custom->bltamod = 32 / 8;
     6c8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #4,100(a0)
			custom->bltbpt = src + 32 / 8 * 1;
     6ce:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #4,d4
     6d0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d4,76(a0)
			custom->bltbmod = 32 / 8;
     6d4:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #4,98(a0)
			custom->bltcpt = custom->bltdpt = (APTR)image + 320 / 8 * 5 * (200 + y) + x / 8;
     6da:	|  |  |  |  |  |  |  |  |  |  |  |                    |   andi.l #255,d2
     6e0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addi.l #200,d2
     6e6:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d2,d0
     6e8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d2,d0
     6ea:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d2,d0
     6ec:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsl.l #3,d0
     6ee:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d2,d0
     6f0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsl.l #3,d0
     6f2:	|  |  |  |  |  |  |  |  |  |  |  |                    |   asr.w #3,d3
     6f4:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d3,d1
     6f6:	|  |  |  |  |  |  |  |  |  |  |  |                    |   ext.l d1
     6f8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.l d0,a6
     6fa:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lea (0,a6,d1.l),a1
     6fe:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l a1,d0
     700:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addi.l #16384,d0
     706:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d0,84(a0)
     70a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d0,72(a0)
			custom->bltcmod = custom->bltdmod = (320 - 32) / 8;
     70e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #36,102(a0)
     714:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #36,96(a0)
			custom->bltafwm = custom->bltalwm = 0xffff;
     71a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #-1,70(a0)
     720:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #-1,68(a0)
			custom->bltsize = ((16 * 5) << HSIZEBITS) | (32/16);
     726:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #5122,88(a0)
		for(short i = 0; i < 16; i++) {
     72c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #1,d5
     72e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #8,d6
     730:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #16,d3
     732:	|  |  |  |  |  |  |  |  |  |  |  |                    |   cmp.l d5,d3
     734:	|  |  |  |  |  |  |  |  |  |  |  |                    \-- bne.w 64a <main+0x5be>
     738:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w f0ff60 <_end+0xefd3b8>,d0
     73e:	|  |  |  |  |  |  |  |  |  |  |  |                        cmpi.w #20153,d0
     742:	|  |  |  |  |  |  |  |  |  |  |  |                    /-- beq.w 85a <main+0x7ce>
     746:	|  |  |  |  |  |  |  |  |  |  |  |                    |   cmpi.w #-24562,d0
     74a:	|  |  |  |  |  |  |  |  |  |  |  |                    +-- beq.w 85a <main+0x7ce>
__attribute__((always_inline)) inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
     74e:	|  |  |  |  |  |  |  |  |  |  |  |  /-----------------|-> move.b bfe001 <_end+0xbeb459>,d0
	while(!MouseLeft()) {
     754:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   btst #6,d0
     758:	|  |  |  |  |  |  |  |  |  |  |  +--|-----------------|-- bne.w 5e2 <main+0x556>
		register volatile const void* _a3 ASM("a3") = player;
     75c:	|  |  |  |  |  |  |  |  |  |  >--|--|-----------------|-> lea 188a <incbin_player_start>,a3
		register volatile const void* _a6 ASM("a6") = (void*)0xdff000;
     762:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l #14675968,a6
		__asm volatile (
     768:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movem.l d0-d1/a0-a1,-(sp)
     76c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr 8(a3)
     770:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movem.l (sp)+,d0-d1/a0-a1
	WaitVbl();
     774:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr (a2)
	WaitBlit();
     776:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     77c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -228(a6)
	custom->intena=0x7fff;//disable all interrupts
     780:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12ba4 <custom>,a0
     786:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,154(a0)
	custom->intreq=0x7fff;//Clear any interrupts that were pending
     78c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,156(a0)
	custom->dmacon=0x7fff;//Clear all DMA channels
     792:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,150(a0)
	*(volatile APTR*)(((UBYTE*)VBR)+0x6c) = interrupt;
     798:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b8e <VBR>,a1
     79e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.l 12b8a <SystemIrq>,108(a1)
	custom->cop1lc=(ULONG)GfxBase->copinit;
     7a6:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     7ac:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.l 38(a6),128(a0)
	custom->cop2lc=(ULONG)GfxBase->LOFlist;
     7b2:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.l 50(a6),132(a0)
	custom->copjmp1=0x7fff; //start coppper
     7b8:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,136(a0)
	custom->intena=SystemInts|0x8000;
     7be:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w 12b88 <SystemInts>,d0
     7c4:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   ori.w #-32768,d0
     7c8:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w d0,154(a0)
	custom->dmacon=SystemDMA|0x8000;
     7cc:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w 12b86 <SystemDMA>,d0
     7d2:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   ori.w #-32768,d0
     7d6:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w d0,150(a0)
	custom->adkcon=SystemADKCON|0x8000;
     7da:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w 12b84 <SystemADKCON>,d0
     7e0:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   ori.w #-32768,d0
     7e4:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w d0,158(a0)
	WaitBlit();	
     7e8:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -228(a6)
	DisownBlitter();
     7ec:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     7f2:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -462(a6)
	Enable();
     7f6:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     7fc:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -126(a6)
	LoadView(ActiView);
     800:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     806:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b80 <ActiView>,a1
     80c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -222(a6)
	WaitTOF();
     810:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     816:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -270(a6)
	WaitTOF();
     81a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     820:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -270(a6)
	Permit();
     824:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     82a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -138(a6)
#endif

	// END
	FreeSystem();

	CloseLibrary((struct Library*)DOSBase);
     82e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     834:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b92 <DOSBase>,a1
     83a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -414(a6)
	CloseLibrary((struct Library*)GfxBase);
     83e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     844:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a1
     84a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -414(a6)
}
     84e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   moveq #0,d0
     850:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movem.l -92(a5),d2-d7/a2-a4/a6
     856:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   unlk a5
     858:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   rts
		UaeLib(88, arg1, arg2, arg3, arg4);
     85a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 \-> clr.l -(sp)
     85c:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.l -(sp)
     85e:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.l -(sp)
     860:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.l -(sp)
     862:	|  |  |  |  |  |  |  |  |  |  |  |  |                     pea 58 <_start+0x58>
     866:	|  |  |  |  |  |  |  |  |  |  |  |  |                     movea.l #15794016,a6
     86c:	|  |  |  |  |  |  |  |  |  |  |  |  |                     jsr (a6)
		debug_filled_rect(f + 100, 200*2, f + 400, 220*2, 0x0000ff00); // 0x00RRGGBB
     86e:	|  |  |  |  |  |  |  |  |  |  |  |  |                     andi.w #255,d7
     872:	|  |  |  |  |  |  |  |  |  |  |  |  |                     move.w d7,d2
     874:	|  |  |  |  |  |  |  |  |  |  |  |  |                     addi.w #400,d2
	debug_cmd(barto_cmd_filled_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
     878:	|  |  |  |  |  |  |  |  |  |  |  |  |                     swap d2
     87a:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.w d2
     87c:	|  |  |  |  |  |  |  |  |  |  |  |  |                     ori.w #440,d2
     880:	|  |  |  |  |  |  |  |  |  |  |  |  |                     move.w d7,d0
     882:	|  |  |  |  |  |  |  |  |  |  |  |  |                     addi.w #100,d0
     886:	|  |  |  |  |  |  |  |  |  |  |  |  |                     swap d0
     888:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.w d0
     88a:	|  |  |  |  |  |  |  |  |  |  |  |  |                     ori.w #400,d0
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     88e:	|  |  |  |  |  |  |  |  |  |  |  |  |                     move.w (a6),d1
     890:	|  |  |  |  |  |  |  |  |  |  |  |  |                     lea 20(sp),sp
     894:	|  |  |  |  |  |  |  |  |  |  |  |  |                     cmpi.w #20153,d1
     898:	|  |  |  |  |  |  |  |  |  |  |  |  |              /----- bne.w 95e <main+0x8d2>
		UaeLib(88, arg1, arg2, arg3, arg4);
     89c:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.l #65280,-(sp)
     8a2:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.l d2,-(sp)
     8a4:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.l d0,-(sp)
     8a6:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      pea 2 <_start+0x2>
     8aa:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      pea 58 <_start+0x58>
     8ae:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      movea.l #15794016,a6
     8b4:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      jsr (a6)
		debug_rect(f + 90, 190*2, f + 400, 220*2, 0x000000ff); // 0x00RRGGBB
     8b6:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.w d7,d0
     8b8:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      addi.w #90,d0
	debug_cmd(barto_cmd_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
     8bc:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      swap d0
     8be:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      clr.w d0
     8c0:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      ori.w #380,d0
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     8c4:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.w (a6),d1
     8c6:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      lea 20(sp),sp
     8ca:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      cmpi.w #20153,d1
     8ce:	|  |  |  |  |  |  |  |  |  |  |  |  |        /-----|----- bne.w 99c <main+0x910>
		UaeLib(88, arg1, arg2, arg3, arg4);
     8d2:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  /--|----> pea ff <main+0x73>
     8d6:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      move.l d2,-(sp)
     8d8:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      move.l d0,-(sp)
     8da:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      pea 1 <_start+0x1>
     8de:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      pea 58 <_start+0x58>
     8e2:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      movea.l #15794016,a6
     8e8:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      jsr (a6)
		debug_text(f+ 130, 209*2, "This is a WinUAE debug overlay", 0x00ff00ff);
     8ea:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      addi.w #130,d7
	debug_cmd(barto_cmd_text, (((unsigned int)left) << 16) | ((unsigned int)top), (unsigned int)text, color);
     8ee:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      swap d7
     8f0:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      clr.w d7
     8f2:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      ori.w #418,d7
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     8f6:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      move.w (a6),d0
     8f8:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      lea 20(sp),sp
     8fc:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      cmpi.w #20153,d0
     900:	|  |  |  |  |  |  |  |  |  |  |  |  |  /-----|--|--|----- bne.s 934 <main+0x8a8>
		UaeLib(88, arg1, arg2, arg3, arg4);
     902:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  /--|--|--|----> move.l #16711935,-(sp)
     908:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      pea 335b <incbin_player_end+0x16b>
     90e:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      move.l d7,-(sp)
     910:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      pea 3 <_start+0x3>
     914:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      pea 58 <_start+0x58>
     918:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      jsr f0ff60 <_end+0xefd3b8>
}
     91e:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      lea 20(sp),sp
__attribute__((always_inline)) inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
     922:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  /-> move.b bfe001 <_end+0xbeb459>,d0
	while(!MouseLeft()) {
     928:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |   btst #6,d0
     92c:	|  |  |  |  |  |  |  |  |  |  |  \--|--|--|--|--|--|--|-- bne.w 5e2 <main+0x556>
     930:	|  |  |  |  |  |  |  |  |  |  \-----|--|--|--|--|--|--|-- bra.w 75c <main+0x6d0>
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     934:	|  |  |  |  |  |  |  |  |  |        |  >--|--|--|--|--|-> cmpi.w #-24562,d0
     938:	|  |  |  |  |  |  |  |  |  |        +--|--|--|--|--|--|-- bne.w 74e <main+0x6c2>
		UaeLib(88, arg1, arg2, arg3, arg4);
     93c:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   move.l #16711935,-(sp)
     942:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   pea 335b <incbin_player_end+0x16b>
     948:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   move.l d7,-(sp)
     94a:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   pea 3 <_start+0x3>
     94e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   pea 58 <_start+0x58>
     952:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   jsr f0ff60 <_end+0xefd3b8>
}
     958:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   lea 20(sp),sp
     95c:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  \-- bra.s 922 <main+0x896>
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     95e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  \----> cmpi.w #-24562,d1
     962:	|  |  |  |  |  |  |  |  |  |        +--|--|--|--|-------- bne.w 74e <main+0x6c2>
		UaeLib(88, arg1, arg2, arg3, arg4);
     966:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.l #65280,-(sp)
     96c:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.l d2,-(sp)
     96e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.l d0,-(sp)
     970:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         pea 2 <_start+0x2>
     974:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         pea 58 <_start+0x58>
     978:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         movea.l #15794016,a6
     97e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         jsr (a6)
		debug_rect(f + 90, 190*2, f + 400, 220*2, 0x000000ff); // 0x00RRGGBB
     980:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.w d7,d0
     982:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         addi.w #90,d0
	debug_cmd(barto_cmd_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
     986:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         swap d0
     988:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         clr.w d0
     98a:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         ori.w #380,d0
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     98e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.w (a6),d1
     990:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         lea 20(sp),sp
     994:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         cmpi.w #20153,d1
     998:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  \-------- beq.w 8d2 <main+0x846>
     99c:	|  |  |  |  |  |  |  |  |  |        |  |  |  \----------> cmpi.w #-24562,d1
     9a0:	|  |  |  |  |  |  |  |  |  |        \--|--|-------------- bne.w 74e <main+0x6c2>
		UaeLib(88, arg1, arg2, arg3, arg4);
     9a4:	|  |  |  |  |  |  |  |  |  |           |  |               pea ff <main+0x73>
     9a8:	|  |  |  |  |  |  |  |  |  |           |  |               move.l d2,-(sp)
     9aa:	|  |  |  |  |  |  |  |  |  |           |  |               move.l d0,-(sp)
     9ac:	|  |  |  |  |  |  |  |  |  |           |  |               pea 1 <_start+0x1>
     9b0:	|  |  |  |  |  |  |  |  |  |           |  |               pea 58 <_start+0x58>
     9b4:	|  |  |  |  |  |  |  |  |  |           |  |               movea.l #15794016,a6
     9ba:	|  |  |  |  |  |  |  |  |  |           |  |               jsr (a6)
		debug_text(f+ 130, 209*2, "This is a WinUAE debug overlay", 0x00ff00ff);
     9bc:	|  |  |  |  |  |  |  |  |  |           |  |               addi.w #130,d7
	debug_cmd(barto_cmd_text, (((unsigned int)left) << 16) | ((unsigned int)top), (unsigned int)text, color);
     9c0:	|  |  |  |  |  |  |  |  |  |           |  |               swap d7
     9c2:	|  |  |  |  |  |  |  |  |  |           |  |               clr.w d7
     9c4:	|  |  |  |  |  |  |  |  |  |           |  |               ori.w #418,d7
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     9c8:	|  |  |  |  |  |  |  |  |  |           |  |               move.w (a6),d0
     9ca:	|  |  |  |  |  |  |  |  |  |           |  |               lea 20(sp),sp
     9ce:	|  |  |  |  |  |  |  |  |  |           |  |               cmpi.w #20153,d0
     9d2:	|  |  |  |  |  |  |  |  |  |           |  \-------------- beq.w 902 <main+0x876>
     9d6:	|  |  |  |  |  |  |  |  |  |           \----------------- bra.w 934 <main+0x8a8>
     9da:	|  |  |  |  |  |  |  |  |  \----------------------------> clr.l -(sp)
     9dc:	|  |  |  |  |  |  |  |  |                                 clr.l -(sp)
     9de:	|  |  |  |  |  |  |  |  |                                 pea -50(a5)
     9e2:	|  |  |  |  |  |  |  |  |                                 pea 4 <_start+0x4>
     9e6:	|  |  |  |  |  |  |  |  |                                 jsr ed0 <debug_cmd.part.0>
     9ec:	|  |  |  |  |  |  |  |  |                                 lea 16(sp),sp
	debug_register_copperlist(copper1, "copper1", 1024, 0);
     9f0:	|  |  |  |  |  |  |  |  |                                 pea 400 <main+0x374>
     9f4:	|  |  |  |  |  |  |  |  |                                 pea 334b <incbin_player_end+0x15b>
     9fa:	|  |  |  |  |  |  |  |  |                                 move.l a3,-(sp)
     9fc:	|  |  |  |  |  |  |  |  |                                 lea 123a <debug_register_copperlist.constprop.0>,a4
     a02:	|  |  |  |  |  |  |  |  |                                 jsr (a4)
	debug_register_copperlist(copper2, "copper2", sizeof(copper2), 0);
     a04:	|  |  |  |  |  |  |  |  |                                 pea 80 <_start+0x80>
     a08:	|  |  |  |  |  |  |  |  |                                 pea 3353 <incbin_player_end+0x163>
     a0e:	|  |  |  |  |  |  |  |  |                                 pea 342e <copper2>
     a14:	|  |  |  |  |  |  |  |  |                                 jsr (a4)
	*copListEnd++ = offsetof(struct Custom, ddfstrt);
     a16:	|  |  |  |  |  |  |  |  |                                 move.w #146,(a3)
	*copListEnd++ = fw;
     a1a:	|  |  |  |  |  |  |  |  |                                 move.w #56,2(a3)
	*copListEnd++ = offsetof(struct Custom, ddfstop);
     a20:	|  |  |  |  |  |  |  |  |                                 move.w #148,4(a3)
	*copListEnd++ = fw+(((width>>4)-1)<<3);
     a26:	|  |  |  |  |  |  |  |  |                                 move.w #208,6(a3)
	*copListEnd++ = offsetof(struct Custom, diwstrt);
     a2c:	|  |  |  |  |  |  |  |  |                                 move.w #142,8(a3)
	*copListEnd++ = x+(y<<8);
     a32:	|  |  |  |  |  |  |  |  |                                 move.w #11393,10(a3)
	*copListEnd++ = offsetof(struct Custom, diwstop);
     a38:	|  |  |  |  |  |  |  |  |                                 move.w #144,12(a3)
	*copListEnd++ = (xstop-256)+((ystop-256)<<8);
     a3e:	|  |  |  |  |  |  |  |  |                                 move.w #11457,14(a3)
	*copPtr++ = offsetof(struct Custom, bplcon0);
     a44:	|  |  |  |  |  |  |  |  |                                 move.w #256,16(a3)
	*copPtr++ = (0<<10)/*dual pf*/|(1<<9)/*color*/|((5)<<12)/*num bitplanes*/;
     a4a:	|  |  |  |  |  |  |  |  |                                 move.w #20992,18(a3)
	*copPtr++ = offsetof(struct Custom, bplcon1);	//scrolling
     a50:	|  |  |  |  |  |  |  |  |                                 move.w #258,20(a3)
     a56:	|  |  |  |  |  |  |  |  |                                 lea 22(a3),a0
     a5a:	|  |  |  |  |  |  |  |  |                                 move.l a0,12ba0 <scroll>
	*copPtr++ = 0;
     a60:	|  |  |  |  |  |  |  |  |                                 clr.w 22(a3)
	*copPtr++ = offsetof(struct Custom, bplcon2);	//playfied priority
     a64:	|  |  |  |  |  |  |  |  |                                 move.w #260,24(a3)
	*copPtr++ = 1<<6;//0x24;			//Sprites have priority over playfields
     a6a:	|  |  |  |  |  |  |  |  |                                 move.w #64,26(a3)
	*copPtr++=offsetof(struct Custom, bpl1mod); //odd planes   1,3,5
     a70:	|  |  |  |  |  |  |  |  |                                 move.w #264,28(a3)
	*copPtr++=4*lineSize;
     a76:	|  |  |  |  |  |  |  |  |                                 move.w #160,30(a3)
	*copPtr++=offsetof(struct Custom, bpl2mod); //even  planes 2,4
     a7c:	|  |  |  |  |  |  |  |  |                                 move.w #266,32(a3)
	*copPtr++=4*lineSize;
     a82:	|  |  |  |  |  |  |  |  |                                 move.w #160,34(a3)
		ULONG addr=(ULONG)planes[i];
     a88:	|  |  |  |  |  |  |  |  |                                 move.l #16384,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     a8e:	|  |  |  |  |  |  |  |  |                                 move.w #224,36(a3)
		*copListEnd++=(UWORD)(addr>>16);
     a94:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     a96:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     a98:	|  |  |  |  |  |  |  |  |                                 swap d1
     a9a:	|  |  |  |  |  |  |  |  |                                 move.w d1,38(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     a9e:	|  |  |  |  |  |  |  |  |                                 move.w #226,40(a3)
		*copListEnd++=(UWORD)addr;
     aa4:	|  |  |  |  |  |  |  |  |                                 move.w d0,42(a3)
		ULONG addr=(ULONG)planes[i];
     aa8:	|  |  |  |  |  |  |  |  |                                 move.l #16424,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     aae:	|  |  |  |  |  |  |  |  |                                 move.w #228,44(a3)
		*copListEnd++=(UWORD)(addr>>16);
     ab4:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     ab6:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     ab8:	|  |  |  |  |  |  |  |  |                                 swap d1
     aba:	|  |  |  |  |  |  |  |  |                                 move.w d1,46(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     abe:	|  |  |  |  |  |  |  |  |                                 move.w #230,48(a3)
		*copListEnd++=(UWORD)addr;
     ac4:	|  |  |  |  |  |  |  |  |                                 move.w d0,50(a3)
		ULONG addr=(ULONG)planes[i];
     ac8:	|  |  |  |  |  |  |  |  |                                 move.l #16464,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     ace:	|  |  |  |  |  |  |  |  |                                 move.w #232,52(a3)
		*copListEnd++=(UWORD)(addr>>16);
     ad4:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     ad6:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     ad8:	|  |  |  |  |  |  |  |  |                                 swap d1
     ada:	|  |  |  |  |  |  |  |  |                                 move.w d1,54(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     ade:	|  |  |  |  |  |  |  |  |                                 move.w #234,56(a3)
		*copListEnd++=(UWORD)addr;
     ae4:	|  |  |  |  |  |  |  |  |                                 move.w d0,58(a3)
		ULONG addr=(ULONG)planes[i];
     ae8:	|  |  |  |  |  |  |  |  |                                 move.l #16504,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     aee:	|  |  |  |  |  |  |  |  |                                 move.w #236,60(a3)
		*copListEnd++=(UWORD)(addr>>16);
     af4:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     af6:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     af8:	|  |  |  |  |  |  |  |  |                                 swap d1
     afa:	|  |  |  |  |  |  |  |  |                                 move.w d1,62(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     afe:	|  |  |  |  |  |  |  |  |                                 move.w #238,64(a3)
		*copListEnd++=(UWORD)addr;
     b04:	|  |  |  |  |  |  |  |  |                                 move.w d0,66(a3)
		ULONG addr=(ULONG)planes[i];
     b08:	|  |  |  |  |  |  |  |  |                                 move.l #16544,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     b0e:	|  |  |  |  |  |  |  |  |                                 move.w #240,68(a3)
		*copListEnd++=(UWORD)(addr>>16);
     b14:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     b16:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     b18:	|  |  |  |  |  |  |  |  |                                 swap d1
     b1a:	|  |  |  |  |  |  |  |  |                                 move.w d1,70(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     b1e:	|  |  |  |  |  |  |  |  |                                 move.w #242,72(a3)
		*copListEnd++=(UWORD)addr;
     b24:	|  |  |  |  |  |  |  |  |                                 move.w d0,74(a3)
     b28:	|  |  |  |  |  |  |  |  |                                 lea 76(a3),a1
     b2c:	|  |  |  |  |  |  |  |  |                                 move.l #6280,d2
     b32:	|  |  |  |  |  |  |  |  |                                 lea 24(sp),sp
     b36:	|  |  |  |  |  |  |  |  |                                 lea 1848 <incbin_colors_start>,a0
     b3c:	|  |  |  |  |  |  |  |  |                                 move.w #382,d0
     b40:	|  |  |  |  |  |  |  |  |                                 sub.w d3,d0
     b42:	|  |  |  |  |  |  |  |  \-------------------------------- bra.w 566 <main+0x4da>
		KPrintF("p61Init failed!\n");
     b46:	|  |  |  >--|--|--|--|----------------------------------> pea 3328 <incbin_player_end+0x138>
     b4c:	|  |  |  |  |  |  |  |                                    jsr (a4)
     b4e:	|  |  |  |  |  |  |  |                                    addq.l #4,sp
	warpmode(0);
     b50:	|  |  |  |  |  |  |  |                                    clr.l -(sp)
     b52:	|  |  |  |  |  |  |  |                                    jsr 1018 <warpmode>
	Forbid();
     b58:	|  |  |  |  |  |  |  |                                    movea.l 12b9a <SysBase>,a6
     b5e:	|  |  |  |  |  |  |  |                                    jsr -132(a6)
	SystemADKCON=custom->adkconr;
     b62:	|  |  |  |  |  |  |  |                                    movea.l 12ba4 <custom>,a0
     b68:	|  |  |  |  |  |  |  |                                    move.w 16(a0),d0
     b6c:	|  |  |  |  |  |  |  |                                    move.w d0,12b84 <SystemADKCON>
	SystemInts=custom->intenar;
     b72:	|  |  |  |  |  |  |  |                                    move.w 28(a0),d0
     b76:	|  |  |  |  |  |  |  |                                    move.w d0,12b88 <SystemInts>
	SystemDMA=custom->dmaconr;
     b7c:	|  |  |  |  |  |  |  |                                    move.w 2(a0),d0
     b80:	|  |  |  |  |  |  |  |                                    move.w d0,12b86 <SystemDMA>
	ActiView=GfxBase->ActiView; //store current view
     b86:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     b8c:	|  |  |  |  |  |  |  |                                    move.l 34(a6),12b80 <ActiView>
	LoadView(0);
     b94:	|  |  |  |  |  |  |  |                                    suba.l a1,a1
     b96:	|  |  |  |  |  |  |  |                                    jsr -222(a6)
	WaitTOF();
     b9a:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     ba0:	|  |  |  |  |  |  |  |                                    jsr -270(a6)
	WaitTOF();
     ba4:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     baa:	|  |  |  |  |  |  |  |                                    jsr -270(a6)
	WaitVbl();
     bae:	|  |  |  |  |  |  |  |                                    lea ef0 <WaitVbl>,a2
     bb4:	|  |  |  |  |  |  |  |                                    jsr (a2)
	WaitVbl();
     bb6:	|  |  |  |  |  |  |  |                                    jsr (a2)
	OwnBlitter();
     bb8:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     bbe:	|  |  |  |  |  |  |  |                                    jsr -456(a6)
	WaitBlit();	
     bc2:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     bc8:	|  |  |  |  |  |  |  |                                    jsr -228(a6)
	Disable();
     bcc:	|  |  |  |  |  |  |  |                                    movea.l 12b9a <SysBase>,a6
     bd2:	|  |  |  |  |  |  |  |                                    jsr -120(a6)
	custom->intena=0x7fff;//disable all interrupts
     bd6:	|  |  |  |  |  |  |  |                                    movea.l 12ba4 <custom>,a0
     bdc:	|  |  |  |  |  |  |  |                                    move.w #32767,154(a0)
	custom->intreq=0x7fff;//Clear any interrupts that were pending
     be2:	|  |  |  |  |  |  |  |                                    move.w #32767,156(a0)
	custom->dmacon=0x7fff;//Clear all DMA channels
     be8:	|  |  |  |  |  |  |  |                                    move.w #32767,150(a0)
     bee:	|  |  |  |  |  |  |  |                                    addq.l #4,sp
	for(int a=0;a<32;a++)
     bf0:	|  |  |  |  |  |  |  |                                    moveq #0,d1
     bf2:	|  |  |  |  |  |  |  \----------------------------------- bra.w 1ea <main+0x15e>
		Exit(0);
     bf6:	>--|--|--|--|--|--|-------------------------------------> suba.l a6,a6
     bf8:	|  |  |  |  |  |  |                                       moveq #0,d1
     bfa:	|  |  |  |  |  |  |                                       jsr -144(a6)
	KPrintF("Hello debugger from Amiga!\n");
     bfe:	|  |  |  |  |  |  |                                       pea 32e1 <incbin_player_end+0xf1>
     c04:	|  |  |  |  |  |  |                                       lea fa6 <KPrintF>,a4
     c0a:	|  |  |  |  |  |  |                                       jsr (a4)
	KPrintF("Another hello from Amiga!\n");
     c0c:	|  |  |  |  |  |  |                                       pea 32fd <incbin_player_end+0x10d>
     c12:	|  |  |  |  |  |  |                                       jsr (a4)
	Write(Output(), (APTR)"Hello console!\n", 15);
     c14:	|  |  |  |  |  |  |                                       movea.l 12b92 <DOSBase>,a6
     c1a:	|  |  |  |  |  |  |                                       jsr -60(a6)
     c1e:	|  |  |  |  |  |  |                                       movea.l 12b92 <DOSBase>,a6
     c24:	|  |  |  |  |  |  |                                       move.l d0,d1
     c26:	|  |  |  |  |  |  |                                       move.l #13080,d2
     c2c:	|  |  |  |  |  |  |                                       moveq #15,d3
     c2e:	|  |  |  |  |  |  |                                       jsr -48(a6)
	Delay(50);
     c32:	|  |  |  |  |  |  |                                       movea.l 12b92 <DOSBase>,a6
     c38:	|  |  |  |  |  |  |                                       moveq #50,d1
     c3a:	|  |  |  |  |  |  |                                       jsr -198(a6)
	warpmode(1);
     c3e:	|  |  |  |  |  |  |                                       pea 1 <_start+0x1>
     c42:	|  |  |  |  |  |  |                                       jsr 1018 <warpmode>
		register volatile const void* _a0 ASM("a0") = module;
     c48:	|  |  |  |  |  |  |                                       lea 11704 <incbin_module_start>,a0
		register volatile const void* _a1 ASM("a1") = NULL;
     c4e:	|  |  |  |  |  |  |                                       suba.l a1,a1
		register volatile const void* _a2 ASM("a2") = NULL;
     c50:	|  |  |  |  |  |  |                                       suba.l a2,a2
		register volatile const void* _a3 ASM("a3") = player;
     c52:	|  |  |  |  |  |  |                                       lea 188a <incbin_player_start>,a3
		__asm volatile (
     c58:	|  |  |  |  |  |  |                                       movem.l d1-d7/a4-a6,-(sp)
     c5c:	|  |  |  |  |  |  |                                       jsr (a3)
     c5e:	|  |  |  |  |  |  |                                       movem.l (sp)+,d1-d7/a4-a6
	if(p61Init(module) != 0)
     c62:	|  |  |  |  |  |  |                                       lea 12(sp),sp
     c66:	|  |  |  |  |  |  |                                       tst.l d0
     c68:	|  |  |  |  \--|--|-------------------------------------- beq.w 148 <main+0xbc>
     c6c:	|  |  |  \-----|--|-------------------------------------- bra.w b46 <main+0xaba>
		Exit(0);
     c70:	|  |  \--------|--|-------------------------------------> movea.l 12b92 <DOSBase>,a6
     c76:	|  |           |  |                                       moveq #0,d1
     c78:	|  |           |  |                                       jsr -144(a6)
	DOSBase = (struct DosLibrary*)OpenLibrary((CONST_STRPTR)"dos.library", 0);
     c7c:	|  |           |  |                                       movea.l 12b9a <SysBase>,a6
     c82:	|  |           |  |                                       lea 32d5 <incbin_player_end+0xe5>,a1
     c88:	|  |           |  |                                       moveq #0,d0
     c8a:	|  |           |  |                                       jsr -552(a6)
     c8e:	|  |           |  |                                       move.l d0,12b92 <DOSBase>
	if (!DOSBase)
     c94:	|  \-----------|--|-------------------------------------- bne.w da <main+0x4e>
     c98:	\--------------|--|-------------------------------------- bra.w bf6 <main+0xb6a>
	APTR vbr = 0;
     c9c:	               \--|-------------------------------------> moveq #0,d0
	VBR=GetVBR();
     c9e:	                  |                                       move.l d0,12b8e <VBR>
	return *(volatile APTR*)(((UBYTE*)VBR)+0x6c);
     ca4:	                  |                                       movea.l 12b8e <VBR>,a0
     caa:	                  |                                       move.l 108(a0),d0
	SystemIrq=GetInterruptHandler(); //store interrupt register
     cae:	                  |                                       move.l d0,12b8a <SystemIrq>
	WaitVbl();
     cb4:	                  |                                       jsr (a2)
	char* test = (char*)AllocMem(2502, MEMF_ANY);
     cb6:	                  |                                       movea.l 12b9a <SysBase>,a6
     cbc:	                  |                                       move.l #2502,d0
     cc2:	                  |                                       moveq #0,d1
     cc4:	                  |                                       jsr -198(a6)
     cc8:	                  |                                       move.l d0,d4
	memset(test, 0xcd, 2502);
     cca:	                  |                                       pea 9c6 <main+0x93a>
     cce:	                  |                                       pea cd <main+0x41>
     cd2:	                  |                                       move.l d0,-(sp)
     cd4:	                  |                                       jsr 12ea <memset>
	memclr(test + 2, 2502 - 4);
     cda:	                  |                                       movea.l d4,a0
     cdc:	                  |                                       addq.l #2,a0
	__asm volatile (
     cde:	                  |                                       move.l #2498,d5
     ce4:	                  |                                       cmpi.l #256,d5
     cea:	                  |                                /----- blt.w d48 <main+0xcbc>
     cee:	                  |                                |      adda.l d5,a0
     cf0:	                  |                                |      moveq #0,d0
     cf2:	                  |                                |      moveq #0,d1
     cf4:	                  |                                |      moveq #0,d2
     cf6:	                  |                                |      moveq #0,d3
     cf8:	                  |                                |  /-> movem.l d0-d3,-(a0)
     cfc:	                  |                                |  |   movem.l d0-d3,-(a0)
     d00:	                  |                                |  |   movem.l d0-d3,-(a0)
     d04:	                  |                                |  |   movem.l d0-d3,-(a0)
     d08:	                  |                                |  |   movem.l d0-d3,-(a0)
     d0c:	                  |                                |  |   movem.l d0-d3,-(a0)
     d10:	                  |                                |  |   movem.l d0-d3,-(a0)
     d14:	                  |                                |  |   movem.l d0-d3,-(a0)
     d18:	                  |                                |  |   movem.l d0-d3,-(a0)
     d1c:	                  |                                |  |   movem.l d0-d3,-(a0)
     d20:	                  |                                |  |   movem.l d0-d3,-(a0)
     d24:	                  |                                |  |   movem.l d0-d3,-(a0)
     d28:	                  |                                |  |   movem.l d0-d3,-(a0)
     d2c:	                  |                                |  |   movem.l d0-d3,-(a0)
     d30:	                  |                                |  |   movem.l d0-d3,-(a0)
     d34:	                  |                                |  |   movem.l d0-d3,-(a0)
     d38:	                  |                                |  |   subi.l #256,d5
     d3e:	                  |                                |  |   cmpi.l #256,d5
     d44:	                  |                                |  \-- bge.w cf8 <main+0xc6c>
     d48:	                  |                                >----> cmpi.w #64,d5
     d4c:	                  |                                |  /-- blt.w d68 <main+0xcdc>
     d50:	                  |                                |  |   movem.l d0-d3,-(a0)
     d54:	                  |                                |  |   movem.l d0-d3,-(a0)
     d58:	                  |                                |  |   movem.l d0-d3,-(a0)
     d5c:	                  |                                |  |   movem.l d0-d3,-(a0)
     d60:	                  |                                |  |   subi.w #64,d5
     d64:	                  |                                \--|-- bra.w d48 <main+0xcbc>
     d68:	                  |                                   \-> lsr.w #2,d5
     d6a:	                  |                                   /-- bcc.w d70 <main+0xce4>
     d6e:	                  |                                   |   clr.w -(a0)
     d70:	                  |                                   \-> moveq #16,d0
     d72:	                  |                                       sub.w d5,d0
     d74:	                  |                                       add.w d0,d0
     d76:	                  |                                       jmp (d7a <main+0xcee>,pc,d0.w)
     d7a:	                  |                                       clr.l -(a0)
     d7c:	                  |                                       clr.l -(a0)
     d7e:	                  |                                       clr.l -(a0)
     d80:	                  |                                       clr.l -(a0)
     d82:	                  |                                       clr.l -(a0)
     d84:	                  |                                       clr.l -(a0)
     d86:	                  |                                       clr.l -(a0)
     d88:	                  |                                       clr.l -(a0)
     d8a:	                  |                                       clr.l -(a0)
     d8c:	                  |                                       clr.l -(a0)
     d8e:	                  |                                       clr.l -(a0)
     d90:	                  |                                       clr.l -(a0)
     d92:	                  |                                       clr.l -(a0)
     d94:	                  |                                       clr.l -(a0)
     d96:	                  |                                       clr.l -(a0)
     d98:	                  |                                       clr.l -(a0)
	FreeMem(test, 2502);
     d9a:	                  |                                       movea.l 12b9a <SysBase>,a6
     da0:	                  |                                       movea.l d4,a1
     da2:	                  |                                       move.l #2502,d0
     da8:	                  |                                       jsr -210(a6)
	USHORT* copper1 = (USHORT*)AllocMem(1024, MEMF_CHIP);
     dac:	                  |                                       movea.l 12b9a <SysBase>,a6
     db2:	                  |                                       move.l #1024,d0
     db8:	                  |                                       moveq #2,d1
     dba:	                  |                                       jsr -198(a6)
     dbe:	                  |                                       movea.l d0,a3
	debug_register_bitmap(image, "image.bpl", 320, 256, 5, debug_resource_bitmap_interleaved);
     dc0:	                  |                                       pea 1 <_start+0x1>
     dc4:	                  |                                       pea 100 <main+0x74>
     dc8:	                  |                                       pea 140 <main+0xb4>
     dcc:	                  |                                       pea 3339 <incbin_player_end+0x149>
     dd2:	                  |                                       pea 4000 <incbin_image_start>
     dd8:	                  |                                       lea 1174 <debug_register_bitmap.constprop.0>,a4
     dde:	                  |                                       jsr (a4)
	debug_register_bitmap(bob, "bob.bpl", 32, 96, 5, debug_resource_bitmap_interleaved | debug_resource_bitmap_masked);
     de0:	                  |                                       lea 32(sp),sp
     de4:	                  |                                       pea 3 <_start+0x3>
     de8:	                  |                                       pea 60 <_start+0x60>
     dec:	                  |                                       pea 20 <_start+0x20>
     df0:	                  |                                       pea 3343 <incbin_player_end+0x153>
     df6:	                  |                                       pea 10802 <incbin_bob_start>
     dfc:	                  |                                       jsr (a4)
	struct debug_resource resource = {
     dfe:	                  |                                       clr.l -42(a5)
     e02:	                  |                                       clr.l -38(a5)
     e06:	                  |                                       clr.l -34(a5)
     e0a:	                  |                                       clr.l -30(a5)
     e0e:	                  |                                       clr.l -26(a5)
     e12:	                  |                                       clr.l -22(a5)
     e16:	                  |                                       clr.l -18(a5)
     e1a:	                  |                                       clr.l -14(a5)
     e1e:	                  |                                       clr.l -10(a5)
     e22:	                  |                                       clr.l -6(a5)
     e26:	                  |                                       clr.w -2(a5)
		.address = (unsigned int)addr,
     e2a:	                  |                                       move.l #6216,d3
	struct debug_resource resource = {
     e30:	                  |                                       move.l d3,-50(a5)
     e34:	                  |                                       moveq #64,d1
     e36:	                  |                                       move.l d1,-46(a5)
     e3a:	                  |                                       move.w #1,-10(a5)
     e40:	                  |                                       move.w #32,-6(a5)
     e46:	                  |                                       lea 20(sp),sp
	while(*source && --num > 0)
     e4a:	                  |                                       moveq #105,d0
	struct debug_resource resource = {
     e4c:	                  |                                       lea -42(a5),a0
     e50:	                  |                                       lea 32ba <incbin_player_end+0xca>,a1
	while(*source && --num > 0)
     e56:	                  |                                       lea -11(a5),a4
     e5a:	                  \-------------------------------------- bra.w 3f0 <main+0x364>
     e5e:	                                                          nop

00000e60 <interruptHandler>:
static __attribute__((interrupt)) void interruptHandler() {
     e60:	    movem.l d0-d1/a0-a1/a3/a6,-(sp)
	custom->intreq=(1<<INTB_VERTB); custom->intreq=(1<<INTB_VERTB); //reset vbl req. twice for a4000 bug.
     e64:	    movea.l 12ba4 <custom>,a0
     e6a:	    move.w #32,156(a0)
     e70:	    move.w #32,156(a0)
	if(scroll) {
     e76:	    movea.l 12ba0 <scroll>,a0
     e7c:	    cmpa.w #0,a0
     e80:	/-- beq.s ea4 <interruptHandler+0x44>
		int sin = sinus15[frameCounter & 63];
     e82:	|   move.w 12b9e <frameCounter>,d0
     e88:	|   moveq #63,d1
     e8a:	|   and.l d1,d0
     e8c:	|   lea 33ed <sinus15>,a1
     e92:	|   move.b (0,a1,d0.l),d0
     e96:	|   moveq #0,d1
     e98:	|   move.b d0,d1
		*scroll = sin | (sin << 4);
     e9a:	|   lsl.l #4,d1
     e9c:	|   andi.w #255,d0
     ea0:	|   or.w d1,d0
     ea2:	|   move.w d0,(a0)
		register volatile const void* _a3 ASM("a3") = player;
     ea4:	\-> lea 188a <incbin_player_start>,a3
		register volatile const void* _a6 ASM("a6") = (void*)0xdff000;
     eaa:	    movea.l #14675968,a6
		__asm volatile (
     eb0:	    movem.l d0-a2/a4-a5,-(sp)
     eb4:	    jsr 4(a3)
     eb8:	    movem.l (sp)+,d0-a2/a4-a5
	frameCounter++;
     ebc:	    move.w 12b9e <frameCounter>,d0
     ec2:	    addq.w #1,d0
     ec4:	    move.w d0,12b9e <frameCounter>
}
     eca:	    movem.l (sp)+,d0-d1/a0-a1/a3/a6
     ece:	    rte

00000ed0 <debug_cmd.part.0>:
		UaeLib(88, arg1, arg2, arg3, arg4);
     ed0:	move.l 16(sp),-(sp)
     ed4:	move.l 16(sp),-(sp)
     ed8:	move.l 16(sp),-(sp)
     edc:	move.l 16(sp),-(sp)
     ee0:	pea 58 <_start+0x58>
     ee4:	jsr f0ff60 <_end+0xefd3b8>
}
     eea:	lea 20(sp),sp
     eee:	rts

00000ef0 <WaitVbl>:
void WaitVbl() {
     ef0:	             subq.l #8,sp
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     ef2:	             move.w f0ff60 <_end+0xefd3b8>,d0
     ef8:	             cmpi.w #20153,d0
     efc:	      /----- beq.s f70 <WaitVbl+0x80>
     efe:	      |      cmpi.w #-24562,d0
     f02:	      +----- beq.s f70 <WaitVbl+0x80>
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     f04:	/-----|----> move.l dff004 <_end+0xdec45c>,d0
     f0a:	|     |      move.l d0,(sp)
		vpos&=0x1ff00;
     f0c:	|     |      move.l (sp),d0
     f0e:	|     |      andi.l #130816,d0
     f14:	|     |      move.l d0,(sp)
		if (vpos!=(311<<8))
     f16:	|     |      move.l (sp),d0
     f18:	|     |      cmpi.l #79616,d0
     f1e:	+-----|----- beq.s f04 <WaitVbl+0x14>
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     f20:	|  /--|----> move.l dff004 <_end+0xdec45c>,d0
     f26:	|  |  |      move.l d0,4(sp)
		vpos&=0x1ff00;
     f2a:	|  |  |      move.l 4(sp),d0
     f2e:	|  |  |      andi.l #130816,d0
     f34:	|  |  |      move.l d0,4(sp)
		if (vpos==(311<<8))
     f38:	|  |  |      move.l 4(sp),d0
     f3c:	|  |  |      cmpi.l #79616,d0
     f42:	|  +--|----- bne.s f20 <WaitVbl+0x30>
     f44:	|  |  |      move.w f0ff60 <_end+0xefd3b8>,d0
     f4a:	|  |  |      cmpi.w #20153,d0
     f4e:	|  |  |  /-- beq.s f5a <WaitVbl+0x6a>
     f50:	|  |  |  |   cmpi.w #-24562,d0
     f54:	|  |  |  +-- beq.s f5a <WaitVbl+0x6a>
}
     f56:	|  |  |  |   addq.l #8,sp
     f58:	|  |  |  |   rts
     f5a:	|  |  |  \-> clr.l -(sp)
     f5c:	|  |  |      clr.l -(sp)
     f5e:	|  |  |      clr.l -(sp)
     f60:	|  |  |      pea 5 <_start+0x5>
     f64:	|  |  |      jsr ed0 <debug_cmd.part.0>(pc)
}
     f68:	|  |  |      lea 16(sp),sp
     f6c:	|  |  |      addq.l #8,sp
     f6e:	|  |  |      rts
     f70:	|  |  \----> clr.l -(sp)
     f72:	|  |         clr.l -(sp)
     f74:	|  |         pea 1 <_start+0x1>
     f78:	|  |         pea 5 <_start+0x5>
     f7c:	|  |         jsr ed0 <debug_cmd.part.0>(pc)
}
     f80:	|  |         lea 16(sp),sp
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     f84:	|  |         move.l dff004 <_end+0xdec45c>,d0
     f8a:	|  |         move.l d0,(sp)
		vpos&=0x1ff00;
     f8c:	|  |         move.l (sp),d0
     f8e:	|  |         andi.l #130816,d0
     f94:	|  |         move.l d0,(sp)
		if (vpos!=(311<<8))
     f96:	|  |         move.l (sp),d0
     f98:	|  |         cmpi.l #79616,d0
     f9e:	\--|-------- beq.w f04 <WaitVbl+0x14>
     fa2:	   \-------- bra.w f20 <WaitVbl+0x30>

00000fa6 <KPrintF>:
void KPrintF(const char* fmt, ...) {
     fa6:	    lea -128(sp),sp
     faa:	    movem.l a2-a3/a6,-(sp)
	if(*((UWORD *)UaeDbgLog) == 0x4eb9 || *((UWORD *)UaeDbgLog) == 0xa00e) {
     fae:	    move.w f0ff60 <_end+0xefd3b8>,d0
     fb4:	    cmpi.w #20153,d0
     fb8:	/-- beq.s fe4 <KPrintF+0x3e>
     fba:	|   cmpi.w #-24562,d0
     fbe:	+-- beq.s fe4 <KPrintF+0x3e>
		RawDoFmt((CONST_STRPTR)fmt, vl, KPutCharX, 0);
     fc0:	|   movea.l 12b9a <SysBase>,a6
     fc6:	|   movea.l 144(sp),a0
     fca:	|   lea 148(sp),a1
     fce:	|   lea 1692 <KPutCharX>,a2
     fd4:	|   suba.l a3,a3
     fd6:	|   jsr -522(a6)
}
     fda:	|   movem.l (sp)+,a2-a3/a6
     fde:	|   lea 128(sp),sp
     fe2:	|   rts
		RawDoFmt((CONST_STRPTR)fmt, vl, PutChar, temp);
     fe4:	\-> movea.l 12b9a <SysBase>,a6
     fea:	    movea.l 144(sp),a0
     fee:	    lea 148(sp),a1
     ff2:	    lea 16a0 <PutChar>,a2
     ff8:	    lea 12(sp),a3
     ffc:	    jsr -522(a6)
		UaeDbgLog(86, temp);
    1000:	    move.l a3,-(sp)
    1002:	    pea 56 <_start+0x56>
    1006:	    jsr f0ff60 <_end+0xefd3b8>
	if(*((UWORD *)UaeDbgLog) == 0x4eb9 || *((UWORD *)UaeDbgLog) == 0xa00e) {
    100c:	    addq.l #8,sp
}
    100e:	    movem.l (sp)+,a2-a3/a6
    1012:	    lea 128(sp),sp
    1016:	    rts

00001018 <warpmode>:
void warpmode(int on) { // bool
    1018:	       subq.l #4,sp
    101a:	       move.l a2,-(sp)
    101c:	       move.l d2,-(sp)
	if(*((UWORD *)UaeConf) == 0x4eb9 || *((UWORD *)UaeConf) == 0xa00e) {
    101e:	       move.w f0ff60 <_end+0xefd3b8>,d0
    1024:	       cmpi.w #20153,d0
    1028:	   /-- beq.s 1038 <warpmode+0x20>
    102a:	   |   cmpi.w #-24562,d0
    102e:	   +-- beq.s 1038 <warpmode+0x20>
}
    1030:	   |   move.l (sp)+,d2
    1032:	   |   movea.l (sp)+,a2
    1034:	   |   addq.l #4,sp
    1036:	   |   rts
		UaeConf(82, -1, on ? "cpu_speed max" : "cpu_speed real", 0, &outbuf, 1);
    1038:	   \-> tst.l 16(sp)
    103c:	/----- beq.w 10dc <warpmode+0xc4>
    1040:	|      pea 1 <_start+0x1>
    1044:	|      moveq #15,d2
    1046:	|      add.l sp,d2
    1048:	|      move.l d2,-(sp)
    104a:	|      clr.l -(sp)
    104c:	|      pea 325f <incbin_player_end+0x6f>
    1052:	|      pea ffffffff <_end+0xfffed457>
    1056:	|      pea 52 <_start+0x52>
    105a:	|      movea.l #15794016,a2
    1060:	|      jsr (a2)
		UaeConf(82, -1, on ? "cpu_cycle_exact false" : "cpu_cycle_exact true", 0, &outbuf, 1);
    1062:	|      pea 1 <_start+0x1>
    1066:	|      move.l d2,-(sp)
    1068:	|      clr.l -(sp)
    106a:	|      pea 326d <incbin_player_end+0x7d>
    1070:	|      pea ffffffff <_end+0xfffed457>
    1074:	|      pea 52 <_start+0x52>
    1078:	|      jsr (a2)
		UaeConf(82, -1, on ? "cpu_memory_cycle_exact false" : "cpu_memory_cycle_exact true", 0, &outbuf, 1);
    107a:	|      lea 48(sp),sp
    107e:	|      pea 1 <_start+0x1>
    1082:	|      move.l d2,-(sp)
    1084:	|      clr.l -(sp)
    1086:	|      pea 3283 <incbin_player_end+0x93>
    108c:	|      pea ffffffff <_end+0xfffed457>
    1090:	|      pea 52 <_start+0x52>
    1094:	|      jsr (a2)
		UaeConf(82, -1, on ? "blitter_cycle_exact false" : "blitter_cycle_exact true", 0, &outbuf, 1);
    1096:	|      pea 1 <_start+0x1>
    109a:	|      move.l d2,-(sp)
    109c:	|      clr.l -(sp)
    109e:	|      pea 32a0 <incbin_player_end+0xb0>
    10a4:	|      pea ffffffff <_end+0xfffed457>
    10a8:	|      pea 52 <_start+0x52>
    10ac:	|      jsr (a2)
    10ae:	|      lea 48(sp),sp
		UaeConf(82, -1, on ? "warp true" : "warp false", 0, &outbuf, 1);
    10b2:	|      move.l #12785,d0
    10b8:	|      pea 1 <_start+0x1>
    10bc:	|      move.l d2,-(sp)
    10be:	|      clr.l -(sp)
    10c0:	|      move.l d0,-(sp)
    10c2:	|      pea ffffffff <_end+0xfffed457>
    10c6:	|      pea 52 <_start+0x52>
    10ca:	|      jsr f0ff60 <_end+0xefd3b8>
}
    10d0:	|      lea 24(sp),sp
    10d4:	|  /-> move.l (sp)+,d2
    10d6:	|  |   movea.l (sp)+,a2
    10d8:	|  |   addq.l #4,sp
    10da:	|  |   rts
		UaeConf(82, -1, on ? "cpu_speed max" : "cpu_speed real", 0, &outbuf, 1);
    10dc:	\--|-> pea 1 <_start+0x1>
    10e0:	   |   moveq #15,d2
    10e2:	   |   add.l sp,d2
    10e4:	   |   move.l d2,-(sp)
    10e6:	   |   clr.l -(sp)
    10e8:	   |   pea 3206 <incbin_player_end+0x16>
    10ee:	   |   pea ffffffff <_end+0xfffed457>
    10f2:	   |   pea 52 <_start+0x52>
    10f6:	   |   movea.l #15794016,a2
    10fc:	   |   jsr (a2)
		UaeConf(82, -1, on ? "cpu_cycle_exact false" : "cpu_cycle_exact true", 0, &outbuf, 1);
    10fe:	   |   pea 1 <_start+0x1>
    1102:	   |   move.l d2,-(sp)
    1104:	   |   clr.l -(sp)
    1106:	   |   pea 3215 <incbin_player_end+0x25>
    110c:	   |   pea ffffffff <_end+0xfffed457>
    1110:	   |   pea 52 <_start+0x52>
    1114:	   |   jsr (a2)
		UaeConf(82, -1, on ? "cpu_memory_cycle_exact false" : "cpu_memory_cycle_exact true", 0, &outbuf, 1);
    1116:	   |   lea 48(sp),sp
    111a:	   |   pea 1 <_start+0x1>
    111e:	   |   move.l d2,-(sp)
    1120:	   |   clr.l -(sp)
    1122:	   |   pea 322a <incbin_player_end+0x3a>
    1128:	   |   pea ffffffff <_end+0xfffed457>
    112c:	   |   pea 52 <_start+0x52>
    1130:	   |   jsr (a2)
		UaeConf(82, -1, on ? "blitter_cycle_exact false" : "blitter_cycle_exact true", 0, &outbuf, 1);
    1132:	   |   pea 1 <_start+0x1>
    1136:	   |   move.l d2,-(sp)
    1138:	   |   clr.l -(sp)
    113a:	   |   pea 3246 <incbin_player_end+0x56>
    1140:	   |   pea ffffffff <_end+0xfffed457>
    1144:	   |   pea 52 <_start+0x52>
    1148:	   |   jsr (a2)
    114a:	   |   lea 48(sp),sp
		UaeConf(82, -1, on ? "warp true" : "warp false", 0, &outbuf, 1);
    114e:	   |   move.l #12795,d0
    1154:	   |   pea 1 <_start+0x1>
    1158:	   |   move.l d2,-(sp)
    115a:	   |   clr.l -(sp)
    115c:	   |   move.l d0,-(sp)
    115e:	   |   pea ffffffff <_end+0xfffed457>
    1162:	   |   pea 52 <_start+0x52>
    1166:	   |   jsr f0ff60 <_end+0xefd3b8>
}
    116c:	   |   lea 24(sp),sp
    1170:	   \-- bra.w 10d4 <warpmode+0xbc>

00001174 <debug_register_bitmap.constprop.0>:
void debug_register_bitmap(const void* addr, const char* name, short width, short height, short numPlanes, unsigned short flags) {
    1174:	       link.w a5,#-52
    1178:	       movem.l d2-d4/a2,-(sp)
    117c:	       movea.l 12(a5),a1
    1180:	       move.l 16(a5),d4
    1184:	       move.l 20(a5),d3
    1188:	       move.l 24(a5),d2
	struct debug_resource resource = {
    118c:	       clr.l -42(a5)
    1190:	       clr.l -38(a5)
    1194:	       clr.l -34(a5)
    1198:	       clr.l -30(a5)
    119c:	       clr.l -26(a5)
    11a0:	       clr.l -22(a5)
    11a4:	       clr.l -18(a5)
    11a8:	       clr.l -14(a5)
    11ac:	       clr.w -10(a5)
    11b0:	       move.l 8(a5),-50(a5)
		.size = width / 8 * height * numPlanes,
    11b6:	       move.w d4,d0
    11b8:	       asr.w #3,d0
    11ba:	       muls.w d3,d0
    11bc:	       move.l d0,d1
    11be:	       add.l d0,d1
    11c0:	       add.l d1,d1
    11c2:	       add.l d1,d0
	struct debug_resource resource = {
    11c4:	       move.l d0,-46(a5)
    11c8:	       move.w d2,-8(a5)
    11cc:	       move.w d4,-6(a5)
    11d0:	       move.w d3,-4(a5)
    11d4:	       move.w #5,-2(a5)
	if (flags & debug_resource_bitmap_masked)
    11da:	       btst #1,d2
    11de:	   /-- beq.s 11e6 <debug_register_bitmap.constprop.0+0x72>
		resource.size *= 2;
    11e0:	   |   add.l d0,d0
    11e2:	   |   move.l d0,-46(a5)
	while(*source && --num > 0)
    11e6:	   \-> move.b (a1),d0
    11e8:	       lea -42(a5),a0
    11ec:	/----- beq.s 11fe <debug_register_bitmap.constprop.0+0x8a>
    11ee:	|      lea -11(a5),a2
		*destination++ = *source++;
    11f2:	|  /-> addq.l #1,a1
    11f4:	|  |   move.b d0,(a0)+
	while(*source && --num > 0)
    11f6:	|  |   move.b (a1),d0
    11f8:	+--|-- beq.s 11fe <debug_register_bitmap.constprop.0+0x8a>
    11fa:	|  |   cmpa.l a0,a2
    11fc:	|  \-- bne.s 11f2 <debug_register_bitmap.constprop.0+0x7e>
	*destination = '\0';
    11fe:	\----> clr.b (a0)
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
    1200:	       move.w f0ff60 <_end+0xefd3b8>,d0
    1206:	       cmpi.w #20153,d0
    120a:	   /-- beq.s 121c <debug_register_bitmap.constprop.0+0xa8>
    120c:	   |   cmpi.w #-24562,d0
    1210:	   +-- beq.s 121c <debug_register_bitmap.constprop.0+0xa8>
}
    1212:	   |   movem.l -68(a5),d2-d4/a2
    1218:	   |   unlk a5
    121a:	   |   rts
    121c:	   \-> clr.l -(sp)
    121e:	       clr.l -(sp)
    1220:	       pea -50(a5)
    1224:	       pea 4 <_start+0x4>
    1228:	       jsr ed0 <debug_cmd.part.0>(pc)
    122c:	       lea 16(sp),sp
    1230:	       movem.l -68(a5),d2-d4/a2
    1236:	       unlk a5
    1238:	       rts

0000123a <debug_register_copperlist.constprop.0>:
	};
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}

void debug_register_copperlist(const void* addr, const char* name, unsigned int size, unsigned short flags) {
    123a:	       link.w a5,#-52
    123e:	       move.l a2,-(sp)
    1240:	       movea.l 12(a5),a1
	struct debug_resource resource = {
    1244:	       clr.l -42(a5)
    1248:	       clr.l -38(a5)
    124c:	       clr.l -34(a5)
    1250:	       clr.l -30(a5)
    1254:	       clr.l -26(a5)
    1258:	       clr.l -22(a5)
    125c:	       clr.l -18(a5)
    1260:	       clr.l -14(a5)
    1264:	       clr.l -10(a5)
    1268:	       clr.l -6(a5)
    126c:	       clr.w -2(a5)
    1270:	       move.l 8(a5),-50(a5)
    1276:	       move.l 16(a5),-46(a5)
    127c:	       move.w #2,-10(a5)
	while(*source && --num > 0)
    1282:	       move.b (a1),d0
    1284:	       lea -42(a5),a0
    1288:	/----- beq.s 129a <debug_register_copperlist.constprop.0+0x60>
    128a:	|      lea -11(a5),a2
		*destination++ = *source++;
    128e:	|  /-> addq.l #1,a1
    1290:	|  |   move.b d0,(a0)+
	while(*source && --num > 0)
    1292:	|  |   move.b (a1),d0
    1294:	+--|-- beq.s 129a <debug_register_copperlist.constprop.0+0x60>
    1296:	|  |   cmpa.l a0,a2
    1298:	|  \-- bne.s 128e <debug_register_copperlist.constprop.0+0x54>
	*destination = '\0';
    129a:	\----> clr.b (a0)
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
    129c:	       move.w f0ff60 <_end+0xefd3b8>,d0
    12a2:	       cmpi.w #20153,d0
    12a6:	   /-- beq.s 12b6 <debug_register_copperlist.constprop.0+0x7c>
    12a8:	   |   cmpi.w #-24562,d0
    12ac:	   +-- beq.s 12b6 <debug_register_copperlist.constprop.0+0x7c>
		.type = debug_resource_type_copperlist,
		.flags = flags,
	};
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}
    12ae:	   |   movea.l -56(a5),a2
    12b2:	   |   unlk a5
    12b4:	   |   rts
    12b6:	   \-> clr.l -(sp)
    12b8:	       clr.l -(sp)
    12ba:	       pea -50(a5)
    12be:	       pea 4 <_start+0x4>
    12c2:	       jsr ed0 <debug_cmd.part.0>(pc)
    12c6:	       lea 16(sp),sp
    12ca:	       movea.l -56(a5),a2
    12ce:	       unlk a5
    12d0:	       rts

000012d2 <strlen>:
	while(*s++)
    12d2:	   /-> movea.l 4(sp),a0
    12d6:	   |   tst.b (a0)+
    12d8:	/--|-- beq.s 12e6 <strlen+0x14>
    12da:	|  |   move.l a0,-(sp)
    12dc:	|  \-- jsr 12d2 <strlen>(pc)
    12e0:	|      addq.l #4,sp
    12e2:	|      addq.l #1,d0
}
    12e4:	|      rts
	unsigned long t=0;
    12e6:	\----> moveq #0,d0
}
    12e8:	       rts

000012ea <memset>:
void* memset(void *dest, int val, unsigned long len) {
    12ea:	                      movem.l d2-d7/a2,-(sp)
    12ee:	                      move.l 32(sp),d0
    12f2:	                      move.l 36(sp),d4
    12f6:	                      movea.l 40(sp),a0
	while(len-- > 0)
    12fa:	                      lea -1(a0),a1
    12fe:	                      cmpa.w #0,a0
    1302:	               /----- beq.w 13b8 <memset+0xce>
		*ptr++ = val;
    1306:	               |      move.b d4,d7
    1308:	               |      move.l d0,d2
    130a:	               |      neg.l d2
    130c:	               |      moveq #3,d1
    130e:	               |      and.l d2,d1
    1310:	               |      moveq #5,d3
    1312:	               |      cmp.l a1,d3
    1314:	/--------------|----- bcc.w 1454 <memset+0x16a>
    1318:	|              |      tst.l d1
    131a:	|        /-----|----- beq.w 13f2 <memset+0x108>
    131e:	|        |     |      movea.l d0,a1
    1320:	|        |     |      move.b d4,(a1)
	while(len-- > 0)
    1322:	|        |     |      btst #1,d2
    1326:	|        |     |  /-- beq.w 13be <memset+0xd4>
		*ptr++ = val;
    132a:	|        |     |  |   move.b d4,1(a1)
	while(len-- > 0)
    132e:	|        |     |  |   move.l d0,d2
    1330:	|        |     |  |   subq.l #1,d2
    1332:	|        |     |  |   moveq #3,d3
    1334:	|        |     |  |   and.l d3,d2
    1336:	|  /-----|-----|--|-- bne.w 1420 <memset+0x136>
		*ptr++ = val;
    133a:	|  |     |     |  |   lea 3(a1),a2
    133e:	|  |     |     |  |   move.b d4,2(a1)
	while(len-- > 0)
    1342:	|  |     |     |  |   lea -4(a0),a1
    1346:	|  |     |     |  |   move.l a0,d3
    1348:	|  |     |     |  |   sub.l d1,d3
    134a:	|  |     |     |  |   moveq #0,d5
    134c:	|  |     |     |  |   move.b d4,d5
    134e:	|  |     |     |  |   move.l d5,d6
    1350:	|  |     |     |  |   swap d6
    1352:	|  |     |     |  |   clr.w d6
    1354:	|  |     |     |  |   move.l d4,d2
    1356:	|  |     |     |  |   lsl.w #8,d2
    1358:	|  |     |     |  |   swap d2
    135a:	|  |     |     |  |   clr.w d2
    135c:	|  |     |     |  |   lsl.l #8,d5
    135e:	|  |     |     |  |   or.l d6,d2
    1360:	|  |     |     |  |   or.l d5,d2
    1362:	|  |     |     |  |   move.b d7,d2
    1364:	|  |     |     |  |   movea.l d0,a0
    1366:	|  |     |     |  |   adda.l d1,a0
    1368:	|  |     |     |  |   moveq #-4,d1
    136a:	|  |     |     |  |   and.l d3,d1
    136c:	|  |     |     |  |   add.l a0,d1
		*ptr++ = val;
    136e:	|  |  /--|-----|--|-> move.l d2,(a0)+
	while(len-- > 0)
    1370:	|  |  |  |     |  |   cmp.l a0,d1
    1372:	|  |  +--|-----|--|-- bne.s 136e <memset+0x84>
    1374:	|  |  |  |     |  |   moveq #3,d1
    1376:	|  |  |  |     |  |   and.l d3,d1
    1378:	|  |  |  |     +--|-- beq.s 13b8 <memset+0xce>
    137a:	|  |  |  |     |  |   moveq #-4,d1
    137c:	|  |  |  |     |  |   and.l d1,d3
    137e:	|  |  |  |     |  |   lea (0,a2,d3.l),a0
    1382:	|  |  |  |     |  |   suba.l d3,a1
		*ptr++ = val;
    1384:	|  |  |  |  /--|--|-> move.b d4,(a0)
	while(len-- > 0)
    1386:	|  |  |  |  |  |  |   cmpa.w #0,a1
    138a:	|  |  |  |  |  +--|-- beq.s 13b8 <memset+0xce>
		*ptr++ = val;
    138c:	|  |  |  |  |  |  |   move.b d4,1(a0)
	while(len-- > 0)
    1390:	|  |  |  |  |  |  |   moveq #1,d3
    1392:	|  |  |  |  |  |  |   cmp.l a1,d3
    1394:	|  |  |  |  |  +--|-- beq.s 13b8 <memset+0xce>
		*ptr++ = val;
    1396:	|  |  |  |  |  |  |   move.b d4,2(a0)
	while(len-- > 0)
    139a:	|  |  |  |  |  |  |   moveq #2,d1
    139c:	|  |  |  |  |  |  |   cmp.l a1,d1
    139e:	|  |  |  |  |  +--|-- beq.s 13b8 <memset+0xce>
		*ptr++ = val;
    13a0:	|  |  |  |  |  |  |   move.b d4,3(a0)
	while(len-- > 0)
    13a4:	|  |  |  |  |  |  |   moveq #3,d3
    13a6:	|  |  |  |  |  |  |   cmp.l a1,d3
    13a8:	|  |  |  |  |  +--|-- beq.s 13b8 <memset+0xce>
		*ptr++ = val;
    13aa:	|  |  |  |  |  |  |   move.b d4,4(a0)
	while(len-- > 0)
    13ae:	|  |  |  |  |  |  |   moveq #4,d1
    13b0:	|  |  |  |  |  |  |   cmp.l a1,d1
    13b2:	|  |  |  |  |  +--|-- beq.s 13b8 <memset+0xce>
		*ptr++ = val;
    13b4:	|  |  |  |  |  |  |   move.b d4,5(a0)
}
    13b8:	|  |  |  |  |  \--|-> movem.l (sp)+,d2-d7/a2
    13bc:	|  |  |  |  |     |   rts
		*ptr++ = val;
    13be:	|  |  |  |  |     \-> lea 1(a1),a2
	while(len-- > 0)
    13c2:	|  |  |  |  |         lea -2(a0),a1
    13c6:	|  |  |  |  |         move.l a0,d3
    13c8:	|  |  |  |  |         sub.l d1,d3
    13ca:	|  |  |  |  |         moveq #0,d5
    13cc:	|  |  |  |  |         move.b d4,d5
    13ce:	|  |  |  |  |         move.l d5,d6
    13d0:	|  |  |  |  |         swap d6
    13d2:	|  |  |  |  |         clr.w d6
    13d4:	|  |  |  |  |         move.l d4,d2
    13d6:	|  |  |  |  |         lsl.w #8,d2
    13d8:	|  |  |  |  |         swap d2
    13da:	|  |  |  |  |         clr.w d2
    13dc:	|  |  |  |  |         lsl.l #8,d5
    13de:	|  |  |  |  |         or.l d6,d2
    13e0:	|  |  |  |  |         or.l d5,d2
    13e2:	|  |  |  |  |         move.b d7,d2
    13e4:	|  |  |  |  |         movea.l d0,a0
    13e6:	|  |  |  |  |         adda.l d1,a0
    13e8:	|  |  |  |  |         moveq #-4,d1
    13ea:	|  |  |  |  |         and.l d3,d1
    13ec:	|  |  |  |  |         add.l a0,d1
    13ee:	|  |  +--|--|-------- bra.w 136e <memset+0x84>
	unsigned char *ptr = (unsigned char *)dest;
    13f2:	|  |  |  \--|-------> movea.l d0,a2
    13f4:	|  |  |     |         move.l a0,d3
    13f6:	|  |  |     |         sub.l d1,d3
    13f8:	|  |  |     |         moveq #0,d5
    13fa:	|  |  |     |         move.b d4,d5
    13fc:	|  |  |     |         move.l d5,d6
    13fe:	|  |  |     |         swap d6
    1400:	|  |  |     |         clr.w d6
    1402:	|  |  |     |         move.l d4,d2
    1404:	|  |  |     |         lsl.w #8,d2
    1406:	|  |  |     |         swap d2
    1408:	|  |  |     |         clr.w d2
    140a:	|  |  |     |         lsl.l #8,d5
    140c:	|  |  |     |         or.l d6,d2
    140e:	|  |  |     |         or.l d5,d2
    1410:	|  |  |     |         move.b d7,d2
    1412:	|  |  |     |         movea.l d0,a0
    1414:	|  |  |     |         adda.l d1,a0
    1416:	|  |  |     |         moveq #-4,d1
    1418:	|  |  |     |         and.l d3,d1
    141a:	|  |  |     |         add.l a0,d1
    141c:	|  |  +-----|-------- bra.w 136e <memset+0x84>
		*ptr++ = val;
    1420:	|  \--|-----|-------> lea 2(a1),a2
	while(len-- > 0)
    1424:	|     |     |         lea -3(a0),a1
    1428:	|     |     |         move.l a0,d3
    142a:	|     |     |         sub.l d1,d3
    142c:	|     |     |         moveq #0,d5
    142e:	|     |     |         move.b d4,d5
    1430:	|     |     |         move.l d5,d6
    1432:	|     |     |         swap d6
    1434:	|     |     |         clr.w d6
    1436:	|     |     |         move.l d4,d2
    1438:	|     |     |         lsl.w #8,d2
    143a:	|     |     |         swap d2
    143c:	|     |     |         clr.w d2
    143e:	|     |     |         lsl.l #8,d5
    1440:	|     |     |         or.l d6,d2
    1442:	|     |     |         or.l d5,d2
    1444:	|     |     |         move.b d7,d2
    1446:	|     |     |         movea.l d0,a0
    1448:	|     |     |         adda.l d1,a0
    144a:	|     |     |         moveq #-4,d1
    144c:	|     |     |         and.l d3,d1
    144e:	|     |     |         add.l a0,d1
    1450:	|     \-----|-------- bra.w 136e <memset+0x84>
	unsigned char *ptr = (unsigned char *)dest;
    1454:	\-----------|-------> movea.l d0,a0
    1456:	            \-------- bra.w 1384 <memset+0x9a>

0000145a <memcpy>:
void* memcpy(void *dest, const void *src, unsigned long len) {
    145a:	             movem.l d2-d5,-(sp)
    145e:	             move.l 20(sp),d0
    1462:	             move.l 24(sp),d1
    1466:	             move.l 28(sp),d2
	while(len--)
    146a:	             move.l d2,d4
    146c:	             subq.l #1,d4
    146e:	             tst.l d2
    1470:	/----------- beq.s 14ca <memcpy+0x70>
    1472:	|            moveq #6,d3
    1474:	|            cmp.l d4,d3
    1476:	|  /-------- bcc.s 14d0 <memcpy+0x76>
    1478:	|  |         move.l d0,d3
    147a:	|  |         or.l d1,d3
    147c:	|  |         moveq #3,d5
    147e:	|  |         and.l d5,d3
    1480:	|  |         movea.l d1,a0
    1482:	|  |         addq.l #1,a0
    1484:	|  |  /----- bne.s 14d4 <memcpy+0x7a>
    1486:	|  |  |      movea.l d0,a1
    1488:	|  |  |      suba.l a0,a1
    148a:	|  |  |      moveq #2,d3
    148c:	|  |  |      cmp.l a1,d3
    148e:	|  |  +----- bcc.s 14d4 <memcpy+0x7a>
    1490:	|  |  |      movea.l d1,a0
    1492:	|  |  |      movea.l d0,a1
    1494:	|  |  |      moveq #-4,d3
    1496:	|  |  |      and.l d2,d3
    1498:	|  |  |      add.l d1,d3
		*d++ = *s++;
    149a:	|  |  |  /-> move.l (a0)+,(a1)+
	while(len--)
    149c:	|  |  |  |   cmp.l a0,d3
    149e:	|  |  |  \-- bne.s 149a <memcpy+0x40>
    14a0:	|  |  |      moveq #-4,d3
    14a2:	|  |  |      and.l d2,d3
    14a4:	|  |  |      movea.l d0,a0
    14a6:	|  |  |      adda.l d3,a0
    14a8:	|  |  |      add.l d3,d1
    14aa:	|  |  |      sub.l d3,d4
    14ac:	|  |  |      moveq #3,d5
    14ae:	|  |  |      and.l d5,d2
    14b0:	+--|--|----- beq.s 14ca <memcpy+0x70>
		*d++ = *s++;
    14b2:	|  |  |      movea.l d1,a1
    14b4:	|  |  |      move.b (a1),(a0)
	while(len--)
    14b6:	|  |  |      tst.l d4
    14b8:	+--|--|----- beq.s 14ca <memcpy+0x70>
		*d++ = *s++;
    14ba:	|  |  |      move.b 1(a1),1(a0)
	while(len--)
    14c0:	|  |  |      subq.l #1,d4
    14c2:	+--|--|----- beq.s 14ca <memcpy+0x70>
		*d++ = *s++;
    14c4:	|  |  |      move.b 2(a1),2(a0)
}
    14ca:	>--|--|----> movem.l (sp)+,d2-d5
    14ce:	|  |  |      rts
    14d0:	|  \--|----> movea.l d1,a0
    14d2:	|     |      addq.l #1,a0
    14d4:	|     \----> movea.l d0,a1
    14d6:	|            add.l d2,d1
		*d++ = *s++;
    14d8:	|        /-> move.b -1(a0),(a1)+
	while(len--)
    14dc:	|        |   cmpa.l d1,a0
    14de:	\--------|-- beq.s 14ca <memcpy+0x70>
    14e0:	         |   addq.l #1,a0
    14e2:	         \-- bra.s 14d8 <memcpy+0x7e>

000014e4 <memmove>:
void* memmove(void *dest, const void *src, unsigned long len) {
    14e4:	             movem.l d2-d4/a2,-(sp)
    14e8:	             move.l 20(sp),d0
    14ec:	             move.l 24(sp),d1
    14f0:	             move.l 28(sp),d2
		while (len--)
    14f4:	             movea.l d2,a1
    14f6:	             subq.l #1,a1
	if (d < s) {
    14f8:	             cmp.l d0,d1
    14fa:	      /----- bls.s 1562 <memmove+0x7e>
		while (len--)
    14fc:	      |      tst.l d2
    14fe:	/-----|----- beq.s 155c <memmove+0x78>
    1500:	|     |      moveq #6,d3
    1502:	|     |      movea.l d1,a0
    1504:	|     |      addq.l #1,a0
    1506:	|     |      cmp.l a1,d3
    1508:	|  /--|----- bcc.s 1586 <memmove+0xa2>
    150a:	|  |  |      move.l d0,d3
    150c:	|  |  |      sub.l a0,d3
    150e:	|  |  |      moveq #2,d4
    1510:	|  |  |      cmp.l d3,d4
    1512:	|  +--|----- bcc.s 1586 <memmove+0xa2>
    1514:	|  |  |      move.l d0,d3
    1516:	|  |  |      or.l d1,d3
    1518:	|  |  |      moveq #3,d4
    151a:	|  |  |      and.l d4,d3
    151c:	|  +--|----- bne.s 1586 <memmove+0xa2>
    151e:	|  |  |      movea.l d1,a0
    1520:	|  |  |      movea.l d0,a2
    1522:	|  |  |      moveq #-4,d3
    1524:	|  |  |      and.l d2,d3
    1526:	|  |  |      add.l d1,d3
			*d++ = *s++;
    1528:	|  |  |  /-> move.l (a0)+,(a2)+
		while (len--)
    152a:	|  |  |  |   cmp.l a0,d3
    152c:	|  |  |  \-- bne.s 1528 <memmove+0x44>
    152e:	|  |  |      moveq #-4,d3
    1530:	|  |  |      and.l d2,d3
    1532:	|  |  |      movea.l d0,a2
    1534:	|  |  |      adda.l d3,a2
    1536:	|  |  |      movea.l d1,a0
    1538:	|  |  |      adda.l d3,a0
    153a:	|  |  |      suba.l d3,a1
    153c:	|  |  |      moveq #3,d1
    153e:	|  |  |      and.l d1,d2
    1540:	+--|--|----- beq.s 155c <memmove+0x78>
			*d++ = *s++;
    1542:	|  |  |      move.b (a0),(a2)
		while (len--)
    1544:	|  |  |      cmpa.w #0,a1
    1548:	+--|--|----- beq.s 155c <memmove+0x78>
			*d++ = *s++;
    154a:	|  |  |      move.b 1(a0),1(a2)
		while (len--)
    1550:	|  |  |      moveq #1,d3
    1552:	|  |  |      cmp.l a1,d3
    1554:	+--|--|----- beq.s 155c <memmove+0x78>
			*d++ = *s++;
    1556:	|  |  |      move.b 2(a0),2(a2)
}
    155c:	>--|--|----> movem.l (sp)+,d2-d4/a2
    1560:	|  |  |      rts
		const char *lasts = s + (len - 1);
    1562:	|  |  \----> lea (0,a1,d1.l),a0
		char *lastd = d + (len - 1);
    1566:	|  |         adda.l d0,a1
		while (len--)
    1568:	|  |         tst.l d2
    156a:	+--|-------- beq.s 155c <memmove+0x78>
    156c:	|  |         move.l a0,d1
    156e:	|  |         sub.l d2,d1
			*lastd-- = *lasts--;
    1570:	|  |     /-> move.b (a0),(a1)
		while (len--)
    1572:	|  |     |   subq.l #1,a0
    1574:	|  |     |   subq.l #1,a1
    1576:	|  |     |   cmp.l a0,d1
    1578:	+--|-----|-- beq.s 155c <memmove+0x78>
			*lastd-- = *lasts--;
    157a:	|  |     |   move.b (a0),(a1)
		while (len--)
    157c:	|  |     |   subq.l #1,a0
    157e:	|  |     |   subq.l #1,a1
    1580:	|  |     |   cmp.l a0,d1
    1582:	|  |     \-- bne.s 1570 <memmove+0x8c>
    1584:	+--|-------- bra.s 155c <memmove+0x78>
    1586:	|  \-------> movea.l d0,a1
    1588:	|            add.l d2,d1
			*d++ = *s++;
    158a:	|        /-> move.b -1(a0),(a1)+
		while (len--)
    158e:	|        |   cmpa.l d1,a0
    1590:	\--------|-- beq.s 155c <memmove+0x78>
    1592:	         |   addq.l #1,a0
    1594:	         \-- bra.s 158a <memmove+0xa6>
    1596:	             nop

00001598 <__mulsi3>:
	.text
	.type __mulsi3, function
	.globl	__mulsi3
__mulsi3:
	.cfi_startproc
	movew	sp@(4), d0	/* x0 -> d0 */
    1598:	move.w 4(sp),d0
	muluw	sp@(10), d0	/* x0*y1 */
    159c:	mulu.w 10(sp),d0
	movew	sp@(6), d1	/* x1 -> d1 */
    15a0:	move.w 6(sp),d1
	muluw	sp@(8), d1	/* x1*y0 */
    15a4:	mulu.w 8(sp),d1
	addw	d1, d0
    15a8:	add.w d1,d0
	swap	d0
    15aa:	swap d0
	clrw	d0
    15ac:	clr.w d0
	movew	sp@(6), d1	/* x1 -> d1 */
    15ae:	move.w 6(sp),d1
	muluw	sp@(10), d1	/* x1*y1 */
    15b2:	mulu.w 10(sp),d1
	addl	d1, d0
    15b6:	add.l d1,d0
	rts
    15b8:	rts

000015ba <__udivsi3>:
	.text
	.type __udivsi3, function
	.globl	__udivsi3
__udivsi3:
	.cfi_startproc
	movel	d2, sp@-
    15ba:	       move.l d2,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	sp@(12), d1	/* d1 = divisor */
    15bc:	       move.l 12(sp),d1
	movel	sp@(8), d0	/* d0 = dividend */
    15c0:	       move.l 8(sp),d0

	cmpl	#0x10000, d1 /* divisor >= 2 ^ 16 ?   */
    15c4:	       cmpi.l #65536,d1
	jcc	3f		/* then try next algorithm */
    15ca:	   /-- bcc.s 15e2 <__udivsi3+0x28>
	movel	d0, d2
    15cc:	   |   move.l d0,d2
	clrw	d2
    15ce:	   |   clr.w d2
	swap	d2
    15d0:	   |   swap d2
	divu	d1, d2          /* high quotient in lower word */
    15d2:	   |   divu.w d1,d2
	movew	d2, d0		/* save high quotient */
    15d4:	   |   move.w d2,d0
	swap	d0
    15d6:	   |   swap d0
	movew	sp@(10), d2	/* get low dividend + high rest */
    15d8:	   |   move.w 10(sp),d2
	divu	d1, d2		/* low quotient */
    15dc:	   |   divu.w d1,d2
	movew	d2, d0
    15de:	   |   move.w d2,d0
	jra	6f
    15e0:	/--|-- bra.s 1612 <__udivsi3+0x58>

3:	movel	d1, d2		/* use d2 as divisor backup */
    15e2:	|  \-> move.l d1,d2
4:	lsrl	#1, d1	/* shift divisor */
    15e4:	|  /-> lsr.l #1,d1
	lsrl	#1, d0	/* shift dividend */
    15e6:	|  |   lsr.l #1,d0
	cmpl	#0x10000, d1 /* still divisor >= 2 ^ 16 ?  */
    15e8:	|  |   cmpi.l #65536,d1
	jcc	4b
    15ee:	|  \-- bcc.s 15e4 <__udivsi3+0x2a>
	divu	d1, d0		/* now we have 16-bit divisor */
    15f0:	|      divu.w d1,d0
	andl	#0xffff, d0 /* mask out divisor, ignore remainder */
    15f2:	|      andi.l #65535,d0

/* Multiply the 16-bit tentative quotient with the 32-bit divisor.  Because of
   the operand ranges, this might give a 33-bit product.  If this product is
   greater than the dividend, the tentative quotient was too large. */
	movel	d2, d1
    15f8:	|      move.l d2,d1
	mulu	d0, d1		/* low part, 32 bits */
    15fa:	|      mulu.w d0,d1
	swap	d2
    15fc:	|      swap d2
	mulu	d0, d2		/* high part, at most 17 bits */
    15fe:	|      mulu.w d0,d2
	swap	d2		/* align high part with low part */
    1600:	|      swap d2
	tstw	d2		/* high part 17 bits? */
    1602:	|      tst.w d2
	jne	5f		/* if 17 bits, quotient was too large */
    1604:	|  /-- bne.s 1610 <__udivsi3+0x56>
	addl	d2, d1		/* add parts */
    1606:	|  |   add.l d2,d1
	jcs	5f		/* if sum is 33 bits, quotient was too large */
    1608:	|  +-- bcs.s 1610 <__udivsi3+0x56>
	cmpl	sp@(8), d1	/* compare the sum with the dividend */
    160a:	|  |   cmp.l 8(sp),d1
	jls	6f		/* if sum > dividend, quotient was too large */
    160e:	+--|-- bls.s 1612 <__udivsi3+0x58>
5:	subql	#1, d0	/* adjust quotient */
    1610:	|  \-> subq.l #1,d0

6:	movel	sp@+, d2
    1612:	\----> move.l (sp)+,d2
	.cfi_adjust_cfa_offset -4
	rts
    1614:	       rts

00001616 <__divsi3>:
	.text
	.type __divsi3, function
	.globl	__divsi3
 __divsi3:
 	.cfi_startproc
	movel	d2, sp@-
    1616:	    move.l d2,-(sp)
	.cfi_adjust_cfa_offset 4

	moveq	#1, d2	/* sign of result stored in d2 (=1 or =-1) */
    1618:	    moveq #1,d2
	movel	sp@(12), d1	/* d1 = divisor */
    161a:	    move.l 12(sp),d1
	jpl	1f
    161e:	/-- bpl.s 1624 <__divsi3+0xe>
	negl	d1
    1620:	|   neg.l d1
	negb	d2		/* change sign because divisor <0  */
    1622:	|   neg.b d2
1:	movel	sp@(8), d0	/* d0 = dividend */
    1624:	\-> move.l 8(sp),d0
	jpl	2f
    1628:	/-- bpl.s 162e <__divsi3+0x18>
	negl	d0
    162a:	|   neg.l d0
	negb	d2
    162c:	|   neg.b d2

2:	movel	d1, sp@-
    162e:	\-> move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    1630:	    move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__udivsi3	/* divide abs(dividend) by abs(divisor) */
    1632:	    bsr.s 15ba <__udivsi3>
	addql	#8, sp
    1634:	    addq.l #8,sp
	.cfi_adjust_cfa_offset -8

	tstb	d2
    1636:	    tst.b d2
	jpl	3f
    1638:	/-- bpl.s 163c <__divsi3+0x26>
	negl	d0
    163a:	|   neg.l d0

3:	movel	sp@+, d2
    163c:	\-> move.l (sp)+,d2
	.cfi_adjust_cfa_offset -4
	rts
    163e:	    rts

00001640 <__modsi3>:
	.text
	.type __modsi3, function
	.globl	__modsi3
__modsi3:
	.cfi_startproc
	movel	sp@(8), d1	/* d1 = divisor */
    1640:	move.l 8(sp),d1
	movel	sp@(4), d0	/* d0 = dividend */
    1644:	move.l 4(sp),d0
	movel	d1, sp@-
    1648:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    164a:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__divsi3
    164c:	bsr.s 1616 <__divsi3>
	addql	#8, sp
    164e:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(8), d1	/* d1 = divisor */
    1650:	move.l 8(sp),d1
	movel	d1, sp@-
    1654:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    1656:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__mulsi3	/* d0 = (a/b)*b */
    1658:	bsr.w 1598 <__mulsi3>
	addql	#8, sp
    165c:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(4), d1	/* d1 = dividend */
    165e:	move.l 4(sp),d1
	subl	d0, d1		/* d1 = a - (a/b)*b */
    1662:	sub.l d0,d1
	movel	d1, d0
    1664:	move.l d1,d0
	rts
    1666:	rts

00001668 <__umodsi3>:
	.text
	.type __umodsi3, function
	.globl	__umodsi3
__umodsi3:
	.cfi_startproc
	movel	sp@(8), d1	/* d1 = divisor */
    1668:	move.l 8(sp),d1
	movel	sp@(4), d0	/* d0 = dividend */
    166c:	move.l 4(sp),d0
	movel	d1, sp@-
    1670:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    1672:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__udivsi3
    1674:	bsr.w 15ba <__udivsi3>
	addql	#8, sp
    1678:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(8), d1	/* d1 = divisor */
    167a:	move.l 8(sp),d1
	movel	d1, sp@-
    167e:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    1680:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__mulsi3	/* d0 = (a/b)*b */
    1682:	bsr.w 1598 <__mulsi3>
	addql	#8, sp
    1686:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(4), d1	/* d1 = dividend */
    1688:	move.l 4(sp),d1
	subl	d0, d1		/* d1 = a - (a/b)*b */
    168c:	sub.l d0,d1
	movel	d1, d0
    168e:	move.l d1,d0
	rts
    1690:	rts

00001692 <KPutCharX>:
	.type KPutCharX, function
	.globl	KPutCharX

KPutCharX:
	.cfi_startproc
    move.l  a6, -(sp)
    1692:	move.l a6,-(sp)
	.cfi_adjust_cfa_offset 4
    move.l  4.w, a6
    1694:	movea.l 4 <_start+0x4>,a6
    jsr     -0x204(a6)
    1698:	jsr -516(a6)
    move.l (sp)+, a6
    169c:	movea.l (sp)+,a6
	.cfi_adjust_cfa_offset -4
    rts
    169e:	rts

000016a0 <PutChar>:
	.type PutChar, function
	.globl	PutChar

PutChar:
	.cfi_startproc
	move.b d0, (a3)+
    16a0:	move.b d0,(a3)+
	rts
    16a2:	rts

000016a4 <_doynaxdepack_asm>:

	|Entry point. Wind up the decruncher
	.type _doynaxdepack_asm,function
	.globl _doynaxdepack_asm
_doynaxdepack_asm:
	movea.l	(a0)+,a2				|Unaligned literal buffer at the end of
    16a4:	                         movea.l (a0)+,a2
	adda.l	a0,a2					|the stream
    16a6:	                         adda.l a0,a2
	move.l	a2,a3
    16a8:	                         movea.l a2,a3
	move.l	(a0)+,d0				|Seed the shift register
    16aa:	                         move.l (a0)+,d0
	moveq	#0x38,d4				|Masks for match offset extraction
    16ac:	                         moveq #56,d4
	moveq	#8,d5
    16ae:	                         moveq #8,d5
	bra.s	.Lliteral
    16b0:	   /-------------------- bra.s 171a <_doynaxdepack_asm+0x76>

	|******** Copy a literal sequence ********

.Llcopy:							|Copy two bytes at a time, with the
	move.b	(a0)+,(a1)+				|deferral of the length LSB helping
    16b2:	/--|-------------------> move.b (a0)+,(a1)+
	move.b	(a0)+,(a1)+				|slightly in the unrolling
    16b4:	|  |                     move.b (a0)+,(a1)+
	dbf		d1,.Llcopy
    16b6:	+--|-------------------- dbf d1,16b2 <_doynaxdepack_asm+0xe>

	lsl.l	#2,d0					|Copy odd bytes separately in order
    16ba:	|  |                     lsl.l #2,d0
	bcc.s	.Lmatch					|to keep the source aligned
    16bc:	|  |     /-------------- bcc.s 16c0 <_doynaxdepack_asm+0x1c>
.Llsingle:
	move.b	(a2)+,(a1)+
    16be:	|  |  /--|-------------> move.b (a2)+,(a1)+

	|******** Process a match ********

	|Start by refilling the bit-buffer
.Lmatch:
	DOY_REFILL1 mprefix
    16c0:	|  |  |  >-------------> tst.w d0
    16c2:	|  |  |  |           /-- bne.s 16cc <_doynaxdepack_asm+0x28>
	cmp.l	a0,a3					|Take the opportunity to test for the
    16c4:	|  |  |  |           |   cmpa.l a0,a3
	bls.s	.Lreturn				|end of the stream while refilling
    16c6:	|  |  |  |           |   bls.s 173e <doy_table+0x6>
.Lmrefill:
	DOY_REFILL2
    16c8:	|  |  |  |           |   move.w (a0)+,d0
    16ca:	|  |  |  |           |   swap d0

.Lmprefix:
	|Fetch the first three bits identifying the match length, and look up
	|the corresponding table entry
	rol.l	#3+3,d0
    16cc:	|  |  |  |           \-> rol.l #6,d0
	move.w	d0,d1
    16ce:	|  |  |  |               move.w d0,d1
	and.w	d4,d1
    16d0:	|  |  |  |               and.w d4,d1
	eor.w	d1,d0
    16d2:	|  |  |  |               eor.w d1,d0
	movem.w	doy_table(pc,d1.w),d2/d3/a4
    16d4:	|  |  |  |               movem.w (1738 <doy_table>,pc,d1.w),d2-d3/a4

	|Extract the offset bits and compute the relative source address from it
	rol.l	d2,d0					|Reduced by 3 to account for 8x offset
    16da:	|  |  |  |               rol.l d2,d0
	and.w	d0,d3					|scaling
    16dc:	|  |  |  |               and.w d0,d3
	eor.w	d3,d0
    16de:	|  |  |  |               eor.w d3,d0
	suba.w	d3,a4
    16e0:	|  |  |  |               suba.w d3,a4
	adda.l	a1,a4
    16e2:	|  |  |  |               adda.l a1,a4

	|Decode the match length
	DOY_REFILL
    16e4:	|  |  |  |               tst.w d0
    16e6:	|  |  |  |           /-- bne.s 16ec <_doynaxdepack_asm+0x48>
    16e8:	|  |  |  |           |   move.w (a0)+,d0
    16ea:	|  |  |  |           |   swap d0
	and.w	d5,d1					|Check the initial length bit from the
    16ec:	|  |  |  |           \-> and.w d5,d1
	beq.s	.Lmcopy					|type triple
    16ee:	|  |  |  |  /----------- beq.s 1706 <_doynaxdepack_asm+0x62>

	moveq	#1,d1					|This loops peeks at the next flag
    16f0:	|  |  |  |  |            moveq #1,d1
	tst.l	d0						|through the sign bit bit while keeping
    16f2:	|  |  |  |  |            tst.l d0
	bpl.s	.Lmendlen2				|the LSB in carry
    16f4:	|  |  |  |  |  /-------- bpl.s 1702 <_doynaxdepack_asm+0x5e>
	lsl.l	#2,d0
    16f6:	|  |  |  |  |  |         lsl.l #2,d0
	bpl.s	.Lmendlen1
    16f8:	|  |  |  |  |  |  /----- bpl.s 1700 <_doynaxdepack_asm+0x5c>
.Lmgetlen:
	addx.b	d1,d1
    16fa:	|  |  |  |  |  |  |  /-> addx.b d1,d1
	lsl.l	#2,d0
    16fc:	|  |  |  |  |  |  |  |   lsl.l #2,d0
	bmi.s	.Lmgetlen
    16fe:	|  |  |  |  |  |  |  \-- bmi.s 16fa <_doynaxdepack_asm+0x56>
.Lmendlen1:
	addx.b	d1,d1
    1700:	|  |  |  |  |  |  \----> addx.b d1,d1
.Lmendlen2:
	|Copy the match data a word at a time. Note that the minimum length is
	|two bytes
	lsl.l	#2,d0					|The trailing length payload bit is
    1702:	|  |  |  |  |  \-------> lsl.l #2,d0
	bcc.s	.Lmhalf					|stored out-of-order
    1704:	|  |  |  |  |        /-- bcc.s 1708 <_doynaxdepack_asm+0x64>
.Lmcopy:
	move.b	(a4)+,(a1)+
    1706:	|  |  |  |  >--------|-> move.b (a4)+,(a1)+
.Lmhalf:
	move.b	(a4)+,(a1)+
    1708:	|  |  |  |  |        \-> move.b (a4)+,(a1)+
	dbf		d1,.Lmcopy
    170a:	|  |  |  |  \----------- dbf d1,1706 <_doynaxdepack_asm+0x62>

	|Fetch a bit flag to see whether what follows is a literal run or
	|another match
	add.l	d0,d0
    170e:	|  |  |  |               add.l d0,d0
	bcc.s	.Lmatch
    1710:	|  |  |  \-------------- bcc.s 16c0 <_doynaxdepack_asm+0x1c>


	|******** Process a run of literal bytes ********

	DOY_REFILL						|Replenish the shift-register
    1712:	|  |  |                  tst.w d0
    1714:	|  +--|----------------- bne.s 171a <_doynaxdepack_asm+0x76>
    1716:	|  |  |                  move.w (a0)+,d0
    1718:	|  |  |                  swap d0
.Lliteral:
	|Extract delta-coded run length in the same swizzled format as the
	|matches above
	moveq	#0,d1
    171a:	|  \--|----------------> moveq #0,d1
	add.l	d0,d0
    171c:	|     |                  add.l d0,d0
	bcc.s	.Llsingle				|Single out the one-byte case
    171e:	|     \----------------- bcc.s 16be <_doynaxdepack_asm+0x1a>
	bpl.s	.Llendlen
    1720:	|                 /----- bpl.s 1728 <_doynaxdepack_asm+0x84>
.Llgetlen:
	addx.b	d1,d1
    1722:	|                 |  /-> addx.b d1,d1
	lsl.l	#2,d0
    1724:	|                 |  |   lsl.l #2,d0
	bmi.s	.Llgetlen
    1726:	|                 |  \-- bmi.s 1722 <_doynaxdepack_asm+0x7e>
.Llendlen:
	addx.b	d1,d1
    1728:	|                 \----> addx.b d1,d1
	|or greater, in which case the sixteen guaranteed bits in the buffer
	|may have run out.
	|In the latter case simply give up and stuff the payload bits back onto
	|the stream before fetching a literal 16-bit run length instead
.Llcopy_near:
	dbvs	d1,.Llcopy
    172a:	\--------------------/-X dbv.s d1,16b2 <_doynaxdepack_asm+0xe>

	add.l	d0,d0
    172e:	                     |   add.l d0,d0
	eor.w	d1,d0		
    1730:	                     |   eor.w d1,d0
	ror.l	#7+1,d0					|Note that the constant MSB acts as a
    1732:	                     |   ror.l #8,d0
	move.w	(a0)+,d1				|substitute for the unfetched stop bit
    1734:	                     |   move.w (a0)+,d1
	bra.s	.Llcopy_near
    1736:	                     \-- bra.s 172a <_doynaxdepack_asm+0x86>

00001738 <doy_table>:
    1738:	......Nu........
doy_table:
	DOY_OFFSET 3,1					|Short A
.Lreturn:
	rts
	DOY_OFFSET 4,1					|Long A
	dc.w	0						|(Empty hole)
    1748:	...?............
	DOY_OFFSET 6,1+8				|Short B
	dc.w	0						|(Empty hole)
	DOY_OFFSET 7,1+16				|Long B
	dc.w	0						|(Empty hole)
    1758:	.............o..
	DOY_OFFSET 8,1+8+64				|Short C
	dc.w	0						|(Empty hole)
	DOY_OFFSET 10,1+16+128			|Long C
	dc.w	0						|(Empty hole)
    1768:	.............o

Disassembly of section CODE:

00001776 <_doynaxdepack_vasm>:
		swap.w	d0						;encoder is in on the scheme
		endm

		;Entry point. Wind up the decruncher
_doynaxdepack_vasm:
		movea.l	(a0)+,a2				;Unaligned literal buffer at the end of
    1776:	movea.l (a0)+,a2
		adda.l	a0,a2					;the stream
    1778:	adda.l a0,a2
		move.l	a2,a3
    177a:	movea.l a2,a3
		move.l	(a0)+,d0				;Seed the shift register
    177c:	move.l (a0)+,d0
		moveq	#@70,d4					;Masks for match offset extraction
    177e:	moveq #56,d4
		moveq	#@10,d5
    1780:	moveq #8,d5
		bra.s	doy_literal
    1782:	bra.s 17ec <doy_full_000006>

00001784 <doy_lcopy>:


		;******** Copy a literal sequence ********

doy_lcopy:								;Copy two bytes at a time, with the
		move.b	(a0)+,(a1)+				;deferral of the length LSB helping
    1784:	/-> move.b (a0)+,(a1)+
		move.b	(a0)+,(a1)+				;slightly in the unrolling
    1786:	|   move.b (a0)+,(a1)+
		dbf		d1,doy_lcopy
    1788:	\-- dbf d1,1784 <doy_lcopy>

		lsl.l	#2,d0					;Copy odd bytes separately in order
    178c:	    lsl.l #2,d0
		bcc.s	doy_match				;to keep the source aligned
    178e:	    bcc.s 1792 <doy_match>

00001790 <doy_lsingle>:
doy_lsingle:
		move.b	(a2)+,(a1)+
    1790:	move.b (a2)+,(a1)+

00001792 <doy_match>:
		tst.w	d0
    1792:	tst.w d0
		bne.s	\1
    1794:	bne.s 179e <doy_mprefix>
		;******** Process a match ********

		;Start by refilling the bit-buffer
doy_match:
		DOY_REFILL1 doy_mprefix
		cmp.l	a0,a3					;Take the opportunity to test for the
    1796:	cmpa.l a0,a3
		bls.s	doy_return				;end of the stream while refilling
    1798:	bls.s 1810 <doy_return>

0000179a <doy_mrefill>:
		move.w	(a0)+,d0				;old, but that's fine as long as the
    179a:	move.w (a0)+,d0
		swap.w	d0						;encoder is in on the scheme
    179c:	swap d0

0000179e <doy_mprefix>:
		DOY_REFILL2

doy_mprefix:
		;Fetch the first three bits identifying the match length, and look up
		;the corresponding table entry
		rol.l	#3+3,d0
    179e:	rol.l #6,d0
		move.w	d0,d1
    17a0:	move.w d0,d1
		and.w	d4,d1
    17a2:	and.w d4,d1
		eor.w	d1,d0
    17a4:	eor.w d1,d0
		movem.w	doy_table(pc,d1.w),d2/d3/a4
    17a6:	movem.w (180a <doy_table>,pc,d1.w),d2-d3/a4

		;Extract the offset bits and compute the relative source address from it
		rol.l	d2,d0					;Reduced by 3 to account for 8x offset
    17ac:	rol.l d2,d0
		and.w	d0,d3					;scaling
    17ae:	and.w d0,d3
		eor.w	d3,d0
    17b0:	eor.w d3,d0
		suba.w	d3,a4
    17b2:	suba.w d3,a4
		adda.l	a1,a4
    17b4:	adda.l a1,a4
		tst.w	d0
    17b6:	tst.w d0
		bne.s	\1
    17b8:	bne.s 17be <doy_full_000003>
		move.w	(a0)+,d0				;old, but that's fine as long as the
    17ba:	move.w (a0)+,d0
		swap.w	d0						;encoder is in on the scheme
    17bc:	swap d0

000017be <doy_full_000003>:

		;Decode the match length
		DOY_REFILL
		and.w	d5,d1					;Check the initial length bit from the
    17be:	and.w d5,d1
		beq.s	doy_mcopy				;type triple
    17c0:	beq.s 17d8 <doy_mcopy>

		moveq	#1,d1					;This loops peeks at the next flag
    17c2:	moveq #1,d1
		tst.l	d0						;through the sign bit bit while keeping
    17c4:	tst.l d0
		bpl.s	doy_mendlen2			;the LSB in carry
    17c6:	bpl.s 17d4 <doy_mendlen2>
		lsl.l	#2,d0
    17c8:	lsl.l #2,d0
		bpl.s	doy_mendlen1
    17ca:	bpl.s 17d2 <doy_mendlen1>

000017cc <doy_mgetlen>:
doy_mgetlen:
		addx.b	d1,d1
    17cc:	/-> addx.b d1,d1
		lsl.l	#2,d0
    17ce:	|   lsl.l #2,d0
		bmi.s	doy_mgetlen
    17d0:	\-- bmi.s 17cc <doy_mgetlen>

000017d2 <doy_mendlen1>:
doy_mendlen1:
		addx.b	d1,d1
    17d2:	addx.b d1,d1

000017d4 <doy_mendlen2>:
doy_mendlen2:

		;Copy the match data a word at a time. Note that the minimum length is
		;two bytes
		lsl.l	#2,d0					;The trailing length payload bit is
    17d4:	lsl.l #2,d0
		bcc.s	doy_mhalf				;stored out-of-order
    17d6:	bcc.s 17da <doy_mhalf>

000017d8 <doy_mcopy>:
doy_mcopy:
		move.b	(a4)+,(a1)+
    17d8:	move.b (a4)+,(a1)+

000017da <doy_mhalf>:
doy_mhalf:
		move.b	(a4)+,(a1)+
    17da:	move.b (a4)+,(a1)+
		dbf		d1,doy_mcopy
    17dc:	dbf d1,17d8 <doy_mcopy>

		;Fetch a bit flag to see whether what follows is a literal run or
		;another match
		add.l	d0,d0
    17e0:	add.l d0,d0
		bcc.s	doy_match
    17e2:	bcc.s 1792 <doy_match>
		tst.w	d0
    17e4:	tst.w d0
		bne.s	\1
    17e6:	bne.s 17ec <doy_full_000006>
		move.w	(a0)+,d0				;old, but that's fine as long as the
    17e8:	move.w (a0)+,d0
		swap.w	d0						;encoder is in on the scheme
    17ea:	swap d0

000017ec <doy_full_000006>:

		DOY_REFILL						;Replenish the shift-register
doy_literal:
		;Extract delta-coded run length in the same swizzled format as the
		;matches above
		moveq	#0,d1
    17ec:	moveq #0,d1
		add.l	d0,d0
    17ee:	add.l d0,d0
		bcc.s	doy_lsingle				;Single out the one-byte case
    17f0:	bcc.s 1790 <doy_lsingle>
		bpl.s	doy_lendlen
    17f2:	bpl.s 17fa <doy_lendlen>

000017f4 <doy_lgetlen>:
doy_lgetlen:
		addx.b	d1,d1
    17f4:	/-> addx.b d1,d1
		lsl.l	#2,d0
    17f6:	|   lsl.l #2,d0
		bmi.s	doy_lgetlen
    17f8:	\-- bmi.s 17f4 <doy_lgetlen>

000017fa <doy_lendlen>:
doy_lendlen:
		addx.b	d1,d1
    17fa:	addx.b d1,d1

000017fc <doy_lcopy_near>:
		;or greater, in which case the sixteen guaranteed bits in the buffer
		;may have run out.
		;In the latter case simply give up and stuff the payload bits back onto
		;the stream before fetching a literal 16-bit run length instead
doy_lcopy_near:
		dbvs	d1,doy_lcopy
    17fc:	/-> dbv.s d1,1784 <doy_lcopy>

		add.l	d0,d0
    1800:	|   add.l d0,d0
		eor.w	d1,d0		
    1802:	|   eor.w d1,d0
		ror.l	#7+1,d0					;Note that the constant MSB acts as a
    1804:	|   ror.l #8,d0
		move.w	(a0)+,d1				;substitute for the unfetched stop bit
    1806:	|   move.w (a0)+,d1
		bra.s	doy_lcopy_near
    1808:	\-- bra.s 17fc <doy_lcopy_near>

0000180a <doy_table>:
    180a:	ori.b #7,d0
    180e:	.short 0xffff

00001810 <doy_return>:
		endm

doy_table:
		DOY_OFFSET 3,1					;Short A
doy_return:
		rts
    1810:	rts
    1812:	ori.b #15,d1
    1816:	.short 0xffff
    1818:	ori.b #3,d0
    181c:	.short 0x003f
    181e:	.short 0xfff7
    1820:	ori.b #4,d0
    1824:	.short 0x007f
    1826:	.short 0xffef
    1828:	ori.b #5,d0
    182c:	.short 0x00ff
    182e:	.short 0xffb7
    1830:	ori.b #7,d0
    1834:	.short 0x03ff
    1836:	.short 0xff6f
    1838:	ori.b #7,d0
    183c:	.short 0x03ff
    183e:	.short 0xfeb7
    1840:	ori.b #10,d0
    1844:	.short 0x1fff
    1846:	.short 0xfb6f
