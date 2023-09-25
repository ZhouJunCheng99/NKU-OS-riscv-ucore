
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	1ad000ef          	jal	ra,802009d0 <memset>

    cons_init();  // init the console
    80200028:	14c000ef          	jal	ra,80200174 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	9bc58593          	addi	a1,a1,-1604 # 802009e8 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	9d450513          	addi	a0,a0,-1580 # 80200a08 <etext+0x26>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	140000ef          	jal	ra,80200184 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	132000ef          	jal	ra,8020017e <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	11c000ef          	jal	ra,80200176 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	536000ef          	jal	ra,802005ca <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	96e50513          	addi	a0,a0,-1682 # 80200a10 <etext+0x2e>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	97850513          	addi	a0,a0,-1672 # 80200a30 <etext+0x4e>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	91e58593          	addi	a1,a1,-1762 # 802009e2 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	98450513          	addi	a0,a0,-1660 # 80200a50 <etext+0x6e>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	99050513          	addi	a0,a0,-1648 # 80200a70 <etext+0x8e>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	99c50513          	addi	a0,a0,-1636 # 80200a90 <etext+0xae>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	98e50513          	addi	a0,a0,-1650 # 80200ab0 <etext+0xce>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	02b000ef          	jal	ra,80200972 <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b923          	sd	zero,-302(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	98a50513          	addi	a0,a0,-1654 # 80200ae0 <etext+0xfe>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200164:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	0030006f          	j	80200972 <sbi_set_timer>

0000000080200174 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200174:	8082                	ret

0000000080200176 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200176:	0ff57513          	andi	a0,a0,255
    8020017a:	7dc0006f          	j	80200956 <sbi_console_putchar>

000000008020017e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	32078793          	addi	a5,a5,800 # 802004a8 <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	a4250513          	addi	a0,a0,-1470 # 80200be0 <etext+0x1fe>
void print_regs(struct pushregs *gpr) {
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	a4a50513          	addi	a0,a0,-1462 # 80200bf8 <etext+0x216>
    802001b6:	eb7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	a5450513          	addi	a0,a0,-1452 # 80200c10 <etext+0x22e>
    802001c4:	ea9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	a5e50513          	addi	a0,a0,-1442 # 80200c28 <etext+0x246>
    802001d2:	e9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	a6850513          	addi	a0,a0,-1432 # 80200c40 <etext+0x25e>
    802001e0:	e8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	a7250513          	addi	a0,a0,-1422 # 80200c58 <etext+0x276>
    802001ee:	e7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	a7c50513          	addi	a0,a0,-1412 # 80200c70 <etext+0x28e>
    802001fc:	e71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	a8650513          	addi	a0,a0,-1402 # 80200c88 <etext+0x2a6>
    8020020a:	e63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	a9050513          	addi	a0,a0,-1392 # 80200ca0 <etext+0x2be>
    80200218:	e55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	a9a50513          	addi	a0,a0,-1382 # 80200cb8 <etext+0x2d6>
    80200226:	e47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	aa450513          	addi	a0,a0,-1372 # 80200cd0 <etext+0x2ee>
    80200234:	e39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	aae50513          	addi	a0,a0,-1362 # 80200ce8 <etext+0x306>
    80200242:	e2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	ab850513          	addi	a0,a0,-1352 # 80200d00 <etext+0x31e>
    80200250:	e1dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	ac250513          	addi	a0,a0,-1342 # 80200d18 <etext+0x336>
    8020025e:	e0fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	acc50513          	addi	a0,a0,-1332 # 80200d30 <etext+0x34e>
    8020026c:	e01ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	ad650513          	addi	a0,a0,-1322 # 80200d48 <etext+0x366>
    8020027a:	df3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	ae050513          	addi	a0,a0,-1312 # 80200d60 <etext+0x37e>
    80200288:	de5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	aea50513          	addi	a0,a0,-1302 # 80200d78 <etext+0x396>
    80200296:	dd7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	af450513          	addi	a0,a0,-1292 # 80200d90 <etext+0x3ae>
    802002a4:	dc9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	afe50513          	addi	a0,a0,-1282 # 80200da8 <etext+0x3c6>
    802002b2:	dbbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	b0850513          	addi	a0,a0,-1272 # 80200dc0 <etext+0x3de>
    802002c0:	dadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	b1250513          	addi	a0,a0,-1262 # 80200dd8 <etext+0x3f6>
    802002ce:	d9fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	b1c50513          	addi	a0,a0,-1252 # 80200df0 <etext+0x40e>
    802002dc:	d91ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	b2650513          	addi	a0,a0,-1242 # 80200e08 <etext+0x426>
    802002ea:	d83ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	b3050513          	addi	a0,a0,-1232 # 80200e20 <etext+0x43e>
    802002f8:	d75ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	b3a50513          	addi	a0,a0,-1222 # 80200e38 <etext+0x456>
    80200306:	d67ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	b4450513          	addi	a0,a0,-1212 # 80200e50 <etext+0x46e>
    80200314:	d59ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	b4e50513          	addi	a0,a0,-1202 # 80200e68 <etext+0x486>
    80200322:	d4bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	b5850513          	addi	a0,a0,-1192 # 80200e80 <etext+0x49e>
    80200330:	d3dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	b6250513          	addi	a0,a0,-1182 # 80200e98 <etext+0x4b6>
    8020033e:	d2fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	b6c50513          	addi	a0,a0,-1172 # 80200eb0 <etext+0x4ce>
    8020034c:	d21ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	b7250513          	addi	a0,a0,-1166 # 80200ec8 <etext+0x4e6>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	d0dff06f          	j	8020006c <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	b7450513          	addi	a0,a0,-1164 # 80200ee0 <etext+0x4fe>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cf7ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1bff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	b7450513          	addi	a0,a0,-1164 # 80200ef8 <etext+0x516>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	b7c50513          	addi	a0,a0,-1156 # 80200f10 <etext+0x52e>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	b8450513          	addi	a0,a0,-1148 # 80200f28 <etext+0x546>
    802003ac:	cc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	b8850513          	addi	a0,a0,-1144 # 80200f40 <etext+0x55e>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	cabff06f          	j	8020006c <cprintf>

00000000802003c6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c6:	11853783          	ld	a5,280(a0)
    802003ca:	577d                	li	a4,-1
    802003cc:	8305                	srli	a4,a4,0x1
    802003ce:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d0:	472d                	li	a4,11
    802003d2:	08f76963          	bltu	a4,a5,80200464 <interrupt_handler+0x9e>
    802003d6:	00000717          	auipc	a4,0x0
    802003da:	72670713          	addi	a4,a4,1830 # 80200afc <etext+0x11a>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e8:	00000517          	auipc	a0,0x0
    802003ec:	7a850513          	addi	a0,a0,1960 # 80200b90 <etext+0x1ae>
    802003f0:	c7dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f4:	00000517          	auipc	a0,0x0
    802003f8:	77c50513          	addi	a0,a0,1916 # 80200b70 <etext+0x18e>
    802003fc:	c71ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200400:	00000517          	auipc	a0,0x0
    80200404:	73050513          	addi	a0,a0,1840 # 80200b30 <etext+0x14e>
    80200408:	c65ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040c:	00000517          	auipc	a0,0x0
    80200410:	74450513          	addi	a0,a0,1860 # 80200b50 <etext+0x16e>
    80200414:	c59ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200418:	00000517          	auipc	a0,0x0
    8020041c:	7a850513          	addi	a0,a0,1960 # 80200bc0 <etext+0x1de>
    80200420:	c4dff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200424:	1141                	addi	sp,sp,-16
    80200426:	e022                	sd	s0,0(sp)
    80200428:	e406                	sd	ra,8(sp)
            clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
    8020042a:	d3bff0ef          	jal	ra,80200164 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
    8020042e:	00004797          	auipc	a5,0x4
    80200432:	bf278793          	addi	a5,a5,-1038 # 80204020 <ticks>
    80200436:	639c                	ld	a5,0(a5)
    80200438:	06400713          	li	a4,100
    8020043c:	00004417          	auipc	s0,0x4
    80200440:	bd440413          	addi	s0,s0,-1068 # 80204010 <edata>
    80200444:	0785                	addi	a5,a5,1
    80200446:	02e7f733          	remu	a4,a5,a4
    8020044a:	00004697          	auipc	a3,0x4
    8020044e:	bcf6bb23          	sd	a5,-1066(a3) # 80204020 <ticks>
    80200452:	cb19                	beqz	a4,80200468 <interrupt_handler+0xa2>
            if(num==10){
    80200454:	6018                	ld	a4,0(s0)
    80200456:	47a9                	li	a5,10
    80200458:	02f70763          	beq	a4,a5,80200486 <interrupt_handler+0xc0>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020045c:	60a2                	ld	ra,8(sp)
    8020045e:	6402                	ld	s0,0(sp)
    80200460:	0141                	addi	sp,sp,16
    80200462:	8082                	ret
            print_trapframe(tf);
    80200464:	f01ff06f          	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200468:	06400593          	li	a1,100
    8020046c:	00000517          	auipc	a0,0x0
    80200470:	74450513          	addi	a0,a0,1860 # 80200bb0 <etext+0x1ce>
    80200474:	bf9ff0ef          	jal	ra,8020006c <cprintf>
                num++;
    80200478:	601c                	ld	a5,0(s0)
    8020047a:	0785                	addi	a5,a5,1
    8020047c:	00004717          	auipc	a4,0x4
    80200480:	b8f73a23          	sd	a5,-1132(a4) # 80204010 <edata>
    80200484:	bfc1                	j	80200454 <interrupt_handler+0x8e>
}
    80200486:	6402                	ld	s0,0(sp)
    80200488:	60a2                	ld	ra,8(sp)
    8020048a:	0141                	addi	sp,sp,16
                sbi_shutdown();
    8020048c:	5020006f          	j	8020098e <sbi_shutdown>

0000000080200490 <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200490:	11853783          	ld	a5,280(a0)
    80200494:	0007c863          	bltz	a5,802004a4 <trap+0x14>
    switch (tf->cause) {
    80200498:	472d                	li	a4,11
    8020049a:	00f76363          	bltu	a4,a5,802004a0 <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    8020049e:	8082                	ret
            print_trapframe(tf);
    802004a0:	ec5ff06f          	j	80200364 <print_trapframe>
        interrupt_handler(tf);
    802004a4:	f23ff06f          	j	802003c6 <interrupt_handler>

00000000802004a8 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004a8:	14011073          	csrw	sscratch,sp
    802004ac:	712d                	addi	sp,sp,-288
    802004ae:	e002                	sd	zero,0(sp)
    802004b0:	e406                	sd	ra,8(sp)
    802004b2:	ec0e                	sd	gp,24(sp)
    802004b4:	f012                	sd	tp,32(sp)
    802004b6:	f416                	sd	t0,40(sp)
    802004b8:	f81a                	sd	t1,48(sp)
    802004ba:	fc1e                	sd	t2,56(sp)
    802004bc:	e0a2                	sd	s0,64(sp)
    802004be:	e4a6                	sd	s1,72(sp)
    802004c0:	e8aa                	sd	a0,80(sp)
    802004c2:	ecae                	sd	a1,88(sp)
    802004c4:	f0b2                	sd	a2,96(sp)
    802004c6:	f4b6                	sd	a3,104(sp)
    802004c8:	f8ba                	sd	a4,112(sp)
    802004ca:	fcbe                	sd	a5,120(sp)
    802004cc:	e142                	sd	a6,128(sp)
    802004ce:	e546                	sd	a7,136(sp)
    802004d0:	e94a                	sd	s2,144(sp)
    802004d2:	ed4e                	sd	s3,152(sp)
    802004d4:	f152                	sd	s4,160(sp)
    802004d6:	f556                	sd	s5,168(sp)
    802004d8:	f95a                	sd	s6,176(sp)
    802004da:	fd5e                	sd	s7,184(sp)
    802004dc:	e1e2                	sd	s8,192(sp)
    802004de:	e5e6                	sd	s9,200(sp)
    802004e0:	e9ea                	sd	s10,208(sp)
    802004e2:	edee                	sd	s11,216(sp)
    802004e4:	f1f2                	sd	t3,224(sp)
    802004e6:	f5f6                	sd	t4,232(sp)
    802004e8:	f9fa                	sd	t5,240(sp)
    802004ea:	fdfe                	sd	t6,248(sp)
    802004ec:	14001473          	csrrw	s0,sscratch,zero
    802004f0:	100024f3          	csrr	s1,sstatus
    802004f4:	14102973          	csrr	s2,sepc
    802004f8:	143029f3          	csrr	s3,stval
    802004fc:	14202a73          	csrr	s4,scause
    80200500:	e822                	sd	s0,16(sp)
    80200502:	e226                	sd	s1,256(sp)
    80200504:	e64a                	sd	s2,264(sp)
    80200506:	ea4e                	sd	s3,272(sp)
    80200508:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020050a:	850a                	mv	a0,sp
    jal trap
    8020050c:	f85ff0ef          	jal	ra,80200490 <trap>

0000000080200510 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200510:	6492                	ld	s1,256(sp)
    80200512:	6932                	ld	s2,264(sp)
    80200514:	10049073          	csrw	sstatus,s1
    80200518:	14191073          	csrw	sepc,s2
    8020051c:	60a2                	ld	ra,8(sp)
    8020051e:	61e2                	ld	gp,24(sp)
    80200520:	7202                	ld	tp,32(sp)
    80200522:	72a2                	ld	t0,40(sp)
    80200524:	7342                	ld	t1,48(sp)
    80200526:	73e2                	ld	t2,56(sp)
    80200528:	6406                	ld	s0,64(sp)
    8020052a:	64a6                	ld	s1,72(sp)
    8020052c:	6546                	ld	a0,80(sp)
    8020052e:	65e6                	ld	a1,88(sp)
    80200530:	7606                	ld	a2,96(sp)
    80200532:	76a6                	ld	a3,104(sp)
    80200534:	7746                	ld	a4,112(sp)
    80200536:	77e6                	ld	a5,120(sp)
    80200538:	680a                	ld	a6,128(sp)
    8020053a:	68aa                	ld	a7,136(sp)
    8020053c:	694a                	ld	s2,144(sp)
    8020053e:	69ea                	ld	s3,152(sp)
    80200540:	7a0a                	ld	s4,160(sp)
    80200542:	7aaa                	ld	s5,168(sp)
    80200544:	7b4a                	ld	s6,176(sp)
    80200546:	7bea                	ld	s7,184(sp)
    80200548:	6c0e                	ld	s8,192(sp)
    8020054a:	6cae                	ld	s9,200(sp)
    8020054c:	6d4e                	ld	s10,208(sp)
    8020054e:	6dee                	ld	s11,216(sp)
    80200550:	7e0e                	ld	t3,224(sp)
    80200552:	7eae                	ld	t4,232(sp)
    80200554:	7f4e                	ld	t5,240(sp)
    80200556:	7fee                	ld	t6,248(sp)
    80200558:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020055a:	10200073          	sret

000000008020055e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020055e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200562:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200564:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200568:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020056a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020056e:	f022                	sd	s0,32(sp)
    80200570:	ec26                	sd	s1,24(sp)
    80200572:	e84a                	sd	s2,16(sp)
    80200574:	f406                	sd	ra,40(sp)
    80200576:	e44e                	sd	s3,8(sp)
    80200578:	84aa                	mv	s1,a0
    8020057a:	892e                	mv	s2,a1
    8020057c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200580:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200582:	03067e63          	bleu	a6,a2,802005be <printnum+0x60>
    80200586:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200588:	00805763          	blez	s0,80200596 <printnum+0x38>
    8020058c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020058e:	85ca                	mv	a1,s2
    80200590:	854e                	mv	a0,s3
    80200592:	9482                	jalr	s1
        while (-- width > 0)
    80200594:	fc65                	bnez	s0,8020058c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200596:	1a02                	slli	s4,s4,0x20
    80200598:	020a5a13          	srli	s4,s4,0x20
    8020059c:	00001797          	auipc	a5,0x1
    802005a0:	b4c78793          	addi	a5,a5,-1204 # 802010e8 <error_string+0x38>
    802005a4:	9a3e                	add	s4,s4,a5
}
    802005a6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005a8:	000a4503          	lbu	a0,0(s4)
}
    802005ac:	70a2                	ld	ra,40(sp)
    802005ae:	69a2                	ld	s3,8(sp)
    802005b0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005b2:	85ca                	mv	a1,s2
    802005b4:	8326                	mv	t1,s1
}
    802005b6:	6942                	ld	s2,16(sp)
    802005b8:	64e2                	ld	s1,24(sp)
    802005ba:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005bc:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    802005be:	03065633          	divu	a2,a2,a6
    802005c2:	8722                	mv	a4,s0
    802005c4:	f9bff0ef          	jal	ra,8020055e <printnum>
    802005c8:	b7f9                	j	80200596 <printnum+0x38>

00000000802005ca <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005ca:	7119                	addi	sp,sp,-128
    802005cc:	f4a6                	sd	s1,104(sp)
    802005ce:	f0ca                	sd	s2,96(sp)
    802005d0:	e8d2                	sd	s4,80(sp)
    802005d2:	e4d6                	sd	s5,72(sp)
    802005d4:	e0da                	sd	s6,64(sp)
    802005d6:	fc5e                	sd	s7,56(sp)
    802005d8:	f862                	sd	s8,48(sp)
    802005da:	f06a                	sd	s10,32(sp)
    802005dc:	fc86                	sd	ra,120(sp)
    802005de:	f8a2                	sd	s0,112(sp)
    802005e0:	ecce                	sd	s3,88(sp)
    802005e2:	f466                	sd	s9,40(sp)
    802005e4:	ec6e                	sd	s11,24(sp)
    802005e6:	892a                	mv	s2,a0
    802005e8:	84ae                	mv	s1,a1
    802005ea:	8d32                	mv	s10,a2
    802005ec:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802005ee:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802005f0:	00001a17          	auipc	s4,0x1
    802005f4:	964a0a13          	addi	s4,s4,-1692 # 80200f54 <etext+0x572>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802005f8:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802005fc:	00001c17          	auipc	s8,0x1
    80200600:	ab4c0c13          	addi	s8,s8,-1356 # 802010b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200604:	000d4503          	lbu	a0,0(s10)
    80200608:	02500793          	li	a5,37
    8020060c:	001d0413          	addi	s0,s10,1
    80200610:	00f50e63          	beq	a0,a5,8020062c <vprintfmt+0x62>
            if (ch == '\0') {
    80200614:	c521                	beqz	a0,8020065c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200616:	02500993          	li	s3,37
    8020061a:	a011                	j	8020061e <vprintfmt+0x54>
            if (ch == '\0') {
    8020061c:	c121                	beqz	a0,8020065c <vprintfmt+0x92>
            putch(ch, putdat);
    8020061e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200620:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200622:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200624:	fff44503          	lbu	a0,-1(s0)
    80200628:	ff351ae3          	bne	a0,s3,8020061c <vprintfmt+0x52>
    8020062c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200630:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200634:	4981                	li	s3,0
    80200636:	4801                	li	a6,0
        width = precision = -1;
    80200638:	5cfd                	li	s9,-1
    8020063a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    8020063c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200640:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200642:	fdd6069b          	addiw	a3,a2,-35
    80200646:	0ff6f693          	andi	a3,a3,255
    8020064a:	00140d13          	addi	s10,s0,1
    8020064e:	20d5e563          	bltu	a1,a3,80200858 <vprintfmt+0x28e>
    80200652:	068a                	slli	a3,a3,0x2
    80200654:	96d2                	add	a3,a3,s4
    80200656:	4294                	lw	a3,0(a3)
    80200658:	96d2                	add	a3,a3,s4
    8020065a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020065c:	70e6                	ld	ra,120(sp)
    8020065e:	7446                	ld	s0,112(sp)
    80200660:	74a6                	ld	s1,104(sp)
    80200662:	7906                	ld	s2,96(sp)
    80200664:	69e6                	ld	s3,88(sp)
    80200666:	6a46                	ld	s4,80(sp)
    80200668:	6aa6                	ld	s5,72(sp)
    8020066a:	6b06                	ld	s6,64(sp)
    8020066c:	7be2                	ld	s7,56(sp)
    8020066e:	7c42                	ld	s8,48(sp)
    80200670:	7ca2                	ld	s9,40(sp)
    80200672:	7d02                	ld	s10,32(sp)
    80200674:	6de2                	ld	s11,24(sp)
    80200676:	6109                	addi	sp,sp,128
    80200678:	8082                	ret
    if (lflag >= 2) {
    8020067a:	4705                	li	a4,1
    8020067c:	008a8593          	addi	a1,s5,8
    80200680:	01074463          	blt	a4,a6,80200688 <vprintfmt+0xbe>
    else if (lflag) {
    80200684:	26080363          	beqz	a6,802008ea <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200688:	000ab603          	ld	a2,0(s5)
    8020068c:	46c1                	li	a3,16
    8020068e:	8aae                	mv	s5,a1
    80200690:	a06d                	j	8020073a <vprintfmt+0x170>
            goto reswitch;
    80200692:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200696:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200698:	846a                	mv	s0,s10
            goto reswitch;
    8020069a:	b765                	j	80200642 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    8020069c:	000aa503          	lw	a0,0(s5)
    802006a0:	85a6                	mv	a1,s1
    802006a2:	0aa1                	addi	s5,s5,8
    802006a4:	9902                	jalr	s2
            break;
    802006a6:	bfb9                	j	80200604 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006a8:	4705                	li	a4,1
    802006aa:	008a8993          	addi	s3,s5,8
    802006ae:	01074463          	blt	a4,a6,802006b6 <vprintfmt+0xec>
    else if (lflag) {
    802006b2:	22080463          	beqz	a6,802008da <vprintfmt+0x310>
        return va_arg(*ap, long);
    802006b6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    802006ba:	24044463          	bltz	s0,80200902 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    802006be:	8622                	mv	a2,s0
    802006c0:	8ace                	mv	s5,s3
    802006c2:	46a9                	li	a3,10
    802006c4:	a89d                	j	8020073a <vprintfmt+0x170>
            err = va_arg(ap, int);
    802006c6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006ca:	4719                	li	a4,6
            err = va_arg(ap, int);
    802006cc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    802006ce:	41f7d69b          	sraiw	a3,a5,0x1f
    802006d2:	8fb5                	xor	a5,a5,a3
    802006d4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006d8:	1ad74363          	blt	a4,a3,8020087e <vprintfmt+0x2b4>
    802006dc:	00369793          	slli	a5,a3,0x3
    802006e0:	97e2                	add	a5,a5,s8
    802006e2:	639c                	ld	a5,0(a5)
    802006e4:	18078d63          	beqz	a5,8020087e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    802006e8:	86be                	mv	a3,a5
    802006ea:	00001617          	auipc	a2,0x1
    802006ee:	aae60613          	addi	a2,a2,-1362 # 80201198 <error_string+0xe8>
    802006f2:	85a6                	mv	a1,s1
    802006f4:	854a                	mv	a0,s2
    802006f6:	240000ef          	jal	ra,80200936 <printfmt>
    802006fa:	b729                	j	80200604 <vprintfmt+0x3a>
            lflag ++;
    802006fc:	00144603          	lbu	a2,1(s0)
    80200700:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200702:	846a                	mv	s0,s10
            goto reswitch;
    80200704:	bf3d                	j	80200642 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200706:	4705                	li	a4,1
    80200708:	008a8593          	addi	a1,s5,8
    8020070c:	01074463          	blt	a4,a6,80200714 <vprintfmt+0x14a>
    else if (lflag) {
    80200710:	1e080263          	beqz	a6,802008f4 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200714:	000ab603          	ld	a2,0(s5)
    80200718:	46a1                	li	a3,8
    8020071a:	8aae                	mv	s5,a1
    8020071c:	a839                	j	8020073a <vprintfmt+0x170>
            putch('0', putdat);
    8020071e:	03000513          	li	a0,48
    80200722:	85a6                	mv	a1,s1
    80200724:	e03e                	sd	a5,0(sp)
    80200726:	9902                	jalr	s2
            putch('x', putdat);
    80200728:	85a6                	mv	a1,s1
    8020072a:	07800513          	li	a0,120
    8020072e:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200730:	0aa1                	addi	s5,s5,8
    80200732:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200736:	6782                	ld	a5,0(sp)
    80200738:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    8020073a:	876e                	mv	a4,s11
    8020073c:	85a6                	mv	a1,s1
    8020073e:	854a                	mv	a0,s2
    80200740:	e1fff0ef          	jal	ra,8020055e <printnum>
            break;
    80200744:	b5c1                	j	80200604 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200746:	000ab603          	ld	a2,0(s5)
    8020074a:	0aa1                	addi	s5,s5,8
    8020074c:	1c060663          	beqz	a2,80200918 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    80200750:	00160413          	addi	s0,a2,1
    80200754:	17b05c63          	blez	s11,802008cc <vprintfmt+0x302>
    80200758:	02d00593          	li	a1,45
    8020075c:	14b79263          	bne	a5,a1,802008a0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200760:	00064783          	lbu	a5,0(a2)
    80200764:	0007851b          	sext.w	a0,a5
    80200768:	c905                	beqz	a0,80200798 <vprintfmt+0x1ce>
    8020076a:	000cc563          	bltz	s9,80200774 <vprintfmt+0x1aa>
    8020076e:	3cfd                	addiw	s9,s9,-1
    80200770:	036c8263          	beq	s9,s6,80200794 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200774:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200776:	18098463          	beqz	s3,802008fe <vprintfmt+0x334>
    8020077a:	3781                	addiw	a5,a5,-32
    8020077c:	18fbf163          	bleu	a5,s7,802008fe <vprintfmt+0x334>
                    putch('?', putdat);
    80200780:	03f00513          	li	a0,63
    80200784:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200786:	0405                	addi	s0,s0,1
    80200788:	fff44783          	lbu	a5,-1(s0)
    8020078c:	3dfd                	addiw	s11,s11,-1
    8020078e:	0007851b          	sext.w	a0,a5
    80200792:	fd61                	bnez	a0,8020076a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200794:	e7b058e3          	blez	s11,80200604 <vprintfmt+0x3a>
    80200798:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020079a:	85a6                	mv	a1,s1
    8020079c:	02000513          	li	a0,32
    802007a0:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007a2:	e60d81e3          	beqz	s11,80200604 <vprintfmt+0x3a>
    802007a6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007a8:	85a6                	mv	a1,s1
    802007aa:	02000513          	li	a0,32
    802007ae:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007b0:	fe0d94e3          	bnez	s11,80200798 <vprintfmt+0x1ce>
    802007b4:	bd81                	j	80200604 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007b6:	4705                	li	a4,1
    802007b8:	008a8593          	addi	a1,s5,8
    802007bc:	01074463          	blt	a4,a6,802007c4 <vprintfmt+0x1fa>
    else if (lflag) {
    802007c0:	12080063          	beqz	a6,802008e0 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    802007c4:	000ab603          	ld	a2,0(s5)
    802007c8:	46a9                	li	a3,10
    802007ca:	8aae                	mv	s5,a1
    802007cc:	b7bd                	j	8020073a <vprintfmt+0x170>
    802007ce:	00144603          	lbu	a2,1(s0)
            padc = '-';
    802007d2:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    802007d6:	846a                	mv	s0,s10
    802007d8:	b5ad                	j	80200642 <vprintfmt+0x78>
            putch(ch, putdat);
    802007da:	85a6                	mv	a1,s1
    802007dc:	02500513          	li	a0,37
    802007e0:	9902                	jalr	s2
            break;
    802007e2:	b50d                	j	80200604 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    802007e4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802007e8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802007ec:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802007ee:	846a                	mv	s0,s10
            if (width < 0)
    802007f0:	e40dd9e3          	bgez	s11,80200642 <vprintfmt+0x78>
                width = precision, precision = -1;
    802007f4:	8de6                	mv	s11,s9
    802007f6:	5cfd                	li	s9,-1
    802007f8:	b5a9                	j	80200642 <vprintfmt+0x78>
            goto reswitch;
    802007fa:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802007fe:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    80200802:	846a                	mv	s0,s10
            goto reswitch;
    80200804:	bd3d                	j	80200642 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200806:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020080a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020080e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200810:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200814:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200818:	fcd56ce3          	bltu	a0,a3,802007f0 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    8020081c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020081e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200822:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200826:	0196873b          	addw	a4,a3,s9
    8020082a:	0017171b          	slliw	a4,a4,0x1
    8020082e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    80200832:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    80200836:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    8020083a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020083e:	fcd57fe3          	bleu	a3,a0,8020081c <vprintfmt+0x252>
    80200842:	b77d                	j	802007f0 <vprintfmt+0x226>
            if (width < 0)
    80200844:	fffdc693          	not	a3,s11
    80200848:	96fd                	srai	a3,a3,0x3f
    8020084a:	00ddfdb3          	and	s11,s11,a3
    8020084e:	00144603          	lbu	a2,1(s0)
    80200852:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    80200854:	846a                	mv	s0,s10
    80200856:	b3f5                	j	80200642 <vprintfmt+0x78>
            putch('%', putdat);
    80200858:	85a6                	mv	a1,s1
    8020085a:	02500513          	li	a0,37
    8020085e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200860:	fff44703          	lbu	a4,-1(s0)
    80200864:	02500793          	li	a5,37
    80200868:	8d22                	mv	s10,s0
    8020086a:	d8f70de3          	beq	a4,a5,80200604 <vprintfmt+0x3a>
    8020086e:	02500713          	li	a4,37
    80200872:	1d7d                	addi	s10,s10,-1
    80200874:	fffd4783          	lbu	a5,-1(s10)
    80200878:	fee79de3          	bne	a5,a4,80200872 <vprintfmt+0x2a8>
    8020087c:	b361                	j	80200604 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020087e:	00001617          	auipc	a2,0x1
    80200882:	90a60613          	addi	a2,a2,-1782 # 80201188 <error_string+0xd8>
    80200886:	85a6                	mv	a1,s1
    80200888:	854a                	mv	a0,s2
    8020088a:	0ac000ef          	jal	ra,80200936 <printfmt>
    8020088e:	bb9d                	j	80200604 <vprintfmt+0x3a>
                p = "(null)";
    80200890:	00001617          	auipc	a2,0x1
    80200894:	8f060613          	addi	a2,a2,-1808 # 80201180 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200898:	00001417          	auipc	s0,0x1
    8020089c:	8e940413          	addi	s0,s0,-1815 # 80201181 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008a0:	8532                	mv	a0,a2
    802008a2:	85e6                	mv	a1,s9
    802008a4:	e032                	sd	a2,0(sp)
    802008a6:	e43e                	sd	a5,8(sp)
    802008a8:	102000ef          	jal	ra,802009aa <strnlen>
    802008ac:	40ad8dbb          	subw	s11,s11,a0
    802008b0:	6602                	ld	a2,0(sp)
    802008b2:	01b05d63          	blez	s11,802008cc <vprintfmt+0x302>
    802008b6:	67a2                	ld	a5,8(sp)
    802008b8:	2781                	sext.w	a5,a5
    802008ba:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    802008bc:	6522                	ld	a0,8(sp)
    802008be:	85a6                	mv	a1,s1
    802008c0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008c2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008c4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008c6:	6602                	ld	a2,0(sp)
    802008c8:	fe0d9ae3          	bnez	s11,802008bc <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008cc:	00064783          	lbu	a5,0(a2)
    802008d0:	0007851b          	sext.w	a0,a5
    802008d4:	e8051be3          	bnez	a0,8020076a <vprintfmt+0x1a0>
    802008d8:	b335                	j	80200604 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    802008da:	000aa403          	lw	s0,0(s5)
    802008de:	bbf1                	j	802006ba <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    802008e0:	000ae603          	lwu	a2,0(s5)
    802008e4:	46a9                	li	a3,10
    802008e6:	8aae                	mv	s5,a1
    802008e8:	bd89                	j	8020073a <vprintfmt+0x170>
    802008ea:	000ae603          	lwu	a2,0(s5)
    802008ee:	46c1                	li	a3,16
    802008f0:	8aae                	mv	s5,a1
    802008f2:	b5a1                	j	8020073a <vprintfmt+0x170>
    802008f4:	000ae603          	lwu	a2,0(s5)
    802008f8:	46a1                	li	a3,8
    802008fa:	8aae                	mv	s5,a1
    802008fc:	bd3d                	j	8020073a <vprintfmt+0x170>
                    putch(ch, putdat);
    802008fe:	9902                	jalr	s2
    80200900:	b559                	j	80200786 <vprintfmt+0x1bc>
                putch('-', putdat);
    80200902:	85a6                	mv	a1,s1
    80200904:	02d00513          	li	a0,45
    80200908:	e03e                	sd	a5,0(sp)
    8020090a:	9902                	jalr	s2
                num = -(long long)num;
    8020090c:	8ace                	mv	s5,s3
    8020090e:	40800633          	neg	a2,s0
    80200912:	46a9                	li	a3,10
    80200914:	6782                	ld	a5,0(sp)
    80200916:	b515                	j	8020073a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200918:	01b05663          	blez	s11,80200924 <vprintfmt+0x35a>
    8020091c:	02d00693          	li	a3,45
    80200920:	f6d798e3          	bne	a5,a3,80200890 <vprintfmt+0x2c6>
    80200924:	00001417          	auipc	s0,0x1
    80200928:	85d40413          	addi	s0,s0,-1955 # 80201181 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020092c:	02800513          	li	a0,40
    80200930:	02800793          	li	a5,40
    80200934:	bd1d                	j	8020076a <vprintfmt+0x1a0>

0000000080200936 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200936:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200938:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020093c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020093e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200940:	ec06                	sd	ra,24(sp)
    80200942:	f83a                	sd	a4,48(sp)
    80200944:	fc3e                	sd	a5,56(sp)
    80200946:	e0c2                	sd	a6,64(sp)
    80200948:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    8020094a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020094c:	c7fff0ef          	jal	ra,802005ca <vprintfmt>
}
    80200950:	60e2                	ld	ra,24(sp)
    80200952:	6161                	addi	sp,sp,80
    80200954:	8082                	ret

0000000080200956 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200956:	00003797          	auipc	a5,0x3
    8020095a:	6aa78793          	addi	a5,a5,1706 # 80204000 <bootstacktop>
    __asm__ volatile (
    8020095e:	6398                	ld	a4,0(a5)
    80200960:	4781                	li	a5,0
    80200962:	88ba                	mv	a7,a4
    80200964:	852a                	mv	a0,a0
    80200966:	85be                	mv	a1,a5
    80200968:	863e                	mv	a2,a5
    8020096a:	00000073          	ecall
    8020096e:	87aa                	mv	a5,a0
}
    80200970:	8082                	ret

0000000080200972 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200972:	00003797          	auipc	a5,0x3
    80200976:	6a678793          	addi	a5,a5,1702 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    8020097a:	6398                	ld	a4,0(a5)
    8020097c:	4781                	li	a5,0
    8020097e:	88ba                	mv	a7,a4
    80200980:	852a                	mv	a0,a0
    80200982:	85be                	mv	a1,a5
    80200984:	863e                	mv	a2,a5
    80200986:	00000073          	ecall
    8020098a:	87aa                	mv	a5,a0
}
    8020098c:	8082                	ret

000000008020098e <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    8020098e:	00003797          	auipc	a5,0x3
    80200992:	67a78793          	addi	a5,a5,1658 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200996:	6398                	ld	a4,0(a5)
    80200998:	4781                	li	a5,0
    8020099a:	88ba                	mv	a7,a4
    8020099c:	853e                	mv	a0,a5
    8020099e:	85be                	mv	a1,a5
    802009a0:	863e                	mv	a2,a5
    802009a2:	00000073          	ecall
    802009a6:	87aa                	mv	a5,a0
    802009a8:	8082                	ret

00000000802009aa <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802009aa:	c185                	beqz	a1,802009ca <strnlen+0x20>
    802009ac:	00054783          	lbu	a5,0(a0)
    802009b0:	cf89                	beqz	a5,802009ca <strnlen+0x20>
    size_t cnt = 0;
    802009b2:	4781                	li	a5,0
    802009b4:	a021                	j	802009bc <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802009b6:	00074703          	lbu	a4,0(a4)
    802009ba:	c711                	beqz	a4,802009c6 <strnlen+0x1c>
        cnt ++;
    802009bc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009be:	00f50733          	add	a4,a0,a5
    802009c2:	fef59ae3          	bne	a1,a5,802009b6 <strnlen+0xc>
    }
    return cnt;
}
    802009c6:	853e                	mv	a0,a5
    802009c8:	8082                	ret
    size_t cnt = 0;
    802009ca:	4781                	li	a5,0
}
    802009cc:	853e                	mv	a0,a5
    802009ce:	8082                	ret

00000000802009d0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802009d0:	ca01                	beqz	a2,802009e0 <memset+0x10>
    802009d2:	962a                	add	a2,a2,a0
    char *p = s;
    802009d4:	87aa                	mv	a5,a0
        *p ++ = c;
    802009d6:	0785                	addi	a5,a5,1
    802009d8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802009dc:	fec79de3          	bne	a5,a2,802009d6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802009e0:	8082                	ret
