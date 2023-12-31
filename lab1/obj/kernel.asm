
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
    80200024:	23d000ef          	jal	ra,80200a60 <memset>

    cons_init();  // init the console
    80200028:	152000ef          	jal	ra,8020017a <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a4c58593          	addi	a1,a1,-1460 # 80200a78 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a6450513          	addi	a0,a0,-1436 # 80200a98 <etext+0x26>
    8020003c:	036000ef          	jal	ra,80200072 <cprintf>

    print_kerninfo();
    80200040:	066000ef          	jal	ra,802000a6 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	146000ef          	jal	ra,8020018a <idt_init>
    
    asm volatile("mret");
    80200048:	30200073          	mret
    asm volatile("ebreak");
    8020004c:	9002                	ebreak

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    8020004e:	0e8000ef          	jal	ra,80200136 <clock_init>

    intr_enable();  // enable irq interrupt
    80200052:	132000ef          	jal	ra,80200184 <intr_enable>
    
    while (1)
        ;
    80200056:	a001                	j	80200056 <kern_init+0x4a>

0000000080200058 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200058:	1141                	addi	sp,sp,-16
    8020005a:	e022                	sd	s0,0(sp)
    8020005c:	e406                	sd	ra,8(sp)
    8020005e:	842e                	mv	s0,a1
    cons_putc(c);
    80200060:	11c000ef          	jal	ra,8020017c <cons_putc>
    (*cnt)++;
    80200064:	401c                	lw	a5,0(s0)
}
    80200066:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200068:	2785                	addiw	a5,a5,1
    8020006a:	c01c                	sw	a5,0(s0)
}
    8020006c:	6402                	ld	s0,0(sp)
    8020006e:	0141                	addi	sp,sp,16
    80200070:	8082                	ret

0000000080200072 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200072:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200074:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	862a                	mv	a2,a0
    80200080:	004c                	addi	a1,sp,4
    80200082:	00000517          	auipc	a0,0x0
    80200086:	fd650513          	addi	a0,a0,-42 # 80200058 <cputch>
    8020008a:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200096:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200098:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009a:	5c0000ef          	jal	ra,8020065a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	9f850513          	addi	a0,a0,-1544 # 80200aa0 <etext+0x2e>
void print_kerninfo(void) {
    802000b0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b2:	fc1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5658593          	addi	a1,a1,-170 # 8020000c <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	a0250513          	addi	a0,a0,-1534 # 80200ac0 <etext+0x4e>
    802000c6:	fadff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	9a858593          	addi	a1,a1,-1624 # 80200a72 <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	a0e50513          	addi	a0,a0,-1522 # 80200ae0 <etext+0x6e>
    802000da:	f99ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f3258593          	addi	a1,a1,-206 # 80204010 <edata>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	a1a50513          	addi	a0,a0,-1510 # 80200b00 <etext+0x8e>
    802000ee:	f85ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f3658593          	addi	a1,a1,-202 # 80204028 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	a2650513          	addi	a0,a0,-1498 # 80200b20 <etext+0xae>
    80200102:	f71ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	32158593          	addi	a1,a1,801 # 80204427 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efe78793          	addi	a5,a5,-258 # 8020000c <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	43f7d593          	srai	a1,a5,0x3f
}
    8020011e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	a1850513          	addi	a0,a0,-1512 # 80200b40 <etext+0xce>
}
    80200130:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200132:	f41ff06f          	j	80200072 <cprintf>

0000000080200136 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200136:	1141                	addi	sp,sp,-16
    80200138:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020013a:	02000793          	li	a5,32
    8020013e:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200142:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200146:	67e1                	lui	a5,0x18
    80200148:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020014c:	953e                	add	a0,a0,a5
    8020014e:	0b5000ef          	jal	ra,80200a02 <sbi_set_timer>
}
    80200152:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200154:	00004797          	auipc	a5,0x4
    80200158:	ec07b623          	sd	zero,-308(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015c:	00001517          	auipc	a0,0x1
    80200160:	a1450513          	addi	a0,a0,-1516 # 80200b70 <etext+0xfe>
}
    80200164:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200166:	f0dff06f          	j	80200072 <cprintf>

000000008020016a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020016a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016e:	67e1                	lui	a5,0x18
    80200170:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200174:	953e                	add	a0,a0,a5
    80200176:	08d0006f          	j	80200a02 <sbi_set_timer>

000000008020017a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020017a:	8082                	ret

000000008020017c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017c:	0ff57513          	andi	a0,a0,255
    80200180:	0670006f          	j	802009e6 <sbi_console_putchar>

0000000080200184 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200184:	100167f3          	csrrsi	a5,sstatus,2
    80200188:	8082                	ret

000000008020018a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020018a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018e:	00000797          	auipc	a5,0x0
    80200192:	3aa78793          	addi	a5,a5,938 # 80200538 <__alltraps>
    80200196:	10579073          	csrw	stvec,a5
}
    8020019a:	8082                	ret

000000008020019c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019e:	1141                	addi	sp,sp,-16
    802001a0:	e022                	sd	s0,0(sp)
    802001a2:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	b5450513          	addi	a0,a0,-1196 # 80200cf8 <etext+0x286>
void print_regs(struct pushregs *gpr) {
    802001ac:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ae:	ec5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b2:	640c                	ld	a1,8(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	b5c50513          	addi	a0,a0,-1188 # 80200d10 <etext+0x29e>
    802001bc:	eb7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001c0:	680c                	ld	a1,16(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	b6650513          	addi	a0,a0,-1178 # 80200d28 <etext+0x2b6>
    802001ca:	ea9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ce:	6c0c                	ld	a1,24(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	b7050513          	addi	a0,a0,-1168 # 80200d40 <etext+0x2ce>
    802001d8:	e9bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001dc:	700c                	ld	a1,32(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	b7a50513          	addi	a0,a0,-1158 # 80200d58 <etext+0x2e6>
    802001e6:	e8dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001ea:	740c                	ld	a1,40(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	b8450513          	addi	a0,a0,-1148 # 80200d70 <etext+0x2fe>
    802001f4:	e7fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f8:	780c                	ld	a1,48(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	b8e50513          	addi	a0,a0,-1138 # 80200d88 <etext+0x316>
    80200202:	e71ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200206:	7c0c                	ld	a1,56(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	b9850513          	addi	a0,a0,-1128 # 80200da0 <etext+0x32e>
    80200210:	e63ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200214:	602c                	ld	a1,64(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	ba250513          	addi	a0,a0,-1118 # 80200db8 <etext+0x346>
    8020021e:	e55ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200222:	642c                	ld	a1,72(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	bac50513          	addi	a0,a0,-1108 # 80200dd0 <etext+0x35e>
    8020022c:	e47ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200230:	682c                	ld	a1,80(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	bb650513          	addi	a0,a0,-1098 # 80200de8 <etext+0x376>
    8020023a:	e39ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023e:	6c2c                	ld	a1,88(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	bc050513          	addi	a0,a0,-1088 # 80200e00 <etext+0x38e>
    80200248:	e2bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024c:	702c                	ld	a1,96(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	bca50513          	addi	a0,a0,-1078 # 80200e18 <etext+0x3a6>
    80200256:	e1dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020025a:	742c                	ld	a1,104(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	bd450513          	addi	a0,a0,-1068 # 80200e30 <etext+0x3be>
    80200264:	e0fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200268:	782c                	ld	a1,112(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	bde50513          	addi	a0,a0,-1058 # 80200e48 <etext+0x3d6>
    80200272:	e01ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200276:	7c2c                	ld	a1,120(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	be850513          	addi	a0,a0,-1048 # 80200e60 <etext+0x3ee>
    80200280:	df3ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200284:	604c                	ld	a1,128(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	bf250513          	addi	a0,a0,-1038 # 80200e78 <etext+0x406>
    8020028e:	de5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200292:	644c                	ld	a1,136(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	bfc50513          	addi	a0,a0,-1028 # 80200e90 <etext+0x41e>
    8020029c:	dd7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002a0:	684c                	ld	a1,144(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	c0650513          	addi	a0,a0,-1018 # 80200ea8 <etext+0x436>
    802002aa:	dc9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ae:	6c4c                	ld	a1,152(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	c1050513          	addi	a0,a0,-1008 # 80200ec0 <etext+0x44e>
    802002b8:	dbbff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002bc:	704c                	ld	a1,160(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	c1a50513          	addi	a0,a0,-998 # 80200ed8 <etext+0x466>
    802002c6:	dadff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ca:	744c                	ld	a1,168(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	c2450513          	addi	a0,a0,-988 # 80200ef0 <etext+0x47e>
    802002d4:	d9fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d8:	784c                	ld	a1,176(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	c2e50513          	addi	a0,a0,-978 # 80200f08 <etext+0x496>
    802002e2:	d91ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e6:	7c4c                	ld	a1,184(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	c3850513          	addi	a0,a0,-968 # 80200f20 <etext+0x4ae>
    802002f0:	d83ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f4:	606c                	ld	a1,192(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	c4250513          	addi	a0,a0,-958 # 80200f38 <etext+0x4c6>
    802002fe:	d75ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200302:	646c                	ld	a1,200(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	c4c50513          	addi	a0,a0,-948 # 80200f50 <etext+0x4de>
    8020030c:	d67ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200310:	686c                	ld	a1,208(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	c5650513          	addi	a0,a0,-938 # 80200f68 <etext+0x4f6>
    8020031a:	d59ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031e:	6c6c                	ld	a1,216(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	c6050513          	addi	a0,a0,-928 # 80200f80 <etext+0x50e>
    80200328:	d4bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032c:	706c                	ld	a1,224(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	c6a50513          	addi	a0,a0,-918 # 80200f98 <etext+0x526>
    80200336:	d3dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020033a:	746c                	ld	a1,232(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	c7450513          	addi	a0,a0,-908 # 80200fb0 <etext+0x53e>
    80200344:	d2fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200348:	786c                	ld	a1,240(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	c7e50513          	addi	a0,a0,-898 # 80200fc8 <etext+0x556>
    80200352:	d21ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	7c6c                	ld	a1,248(s0)
}
    80200358:	6402                	ld	s0,0(sp)
    8020035a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	c8450513          	addi	a0,a0,-892 # 80200fe0 <etext+0x56e>
}
    80200364:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200366:	d0dff06f          	j	80200072 <cprintf>

000000008020036a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020036a:	1141                	addi	sp,sp,-16
    8020036c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200370:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200372:	00001517          	auipc	a0,0x1
    80200376:	c8650513          	addi	a0,a0,-890 # 80200ff8 <etext+0x586>
void print_trapframe(struct trapframe *tf) {
    8020037a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037c:	cf7ff0ef          	jal	ra,80200072 <cprintf>
    print_regs(&tf->gpr);
    80200380:	8522                	mv	a0,s0
    80200382:	e1bff0ef          	jal	ra,8020019c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200386:	10043583          	ld	a1,256(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	c8650513          	addi	a0,a0,-890 # 80201010 <etext+0x59e>
    80200392:	ce1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200396:	10843583          	ld	a1,264(s0)
    8020039a:	00001517          	auipc	a0,0x1
    8020039e:	c8e50513          	addi	a0,a0,-882 # 80201028 <etext+0x5b6>
    802003a2:	cd1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a6:	11043583          	ld	a1,272(s0)
    802003aa:	00001517          	auipc	a0,0x1
    802003ae:	c9650513          	addi	a0,a0,-874 # 80201040 <etext+0x5ce>
    802003b2:	cc1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b6:	11843583          	ld	a1,280(s0)
}
    802003ba:	6402                	ld	s0,0(sp)
    802003bc:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003be:	00001517          	auipc	a0,0x1
    802003c2:	c9a50513          	addi	a0,a0,-870 # 80201058 <etext+0x5e6>
}
    802003c6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c8:	cabff06f          	j	80200072 <cprintf>

00000000802003cc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003cc:	11853783          	ld	a5,280(a0)
    802003d0:	577d                	li	a4,-1
    802003d2:	8305                	srli	a4,a4,0x1
    802003d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d6:	472d                	li	a4,11
    802003d8:	08f76063          	bltu	a4,a5,80200458 <interrupt_handler+0x8c>
    802003dc:	00000717          	auipc	a4,0x0
    802003e0:	7b070713          	addi	a4,a4,1968 # 80200b8c <etext+0x11a>
    802003e4:	078a                	slli	a5,a5,0x2
    802003e6:	97ba                	add	a5,a5,a4
    802003e8:	439c                	lw	a5,0(a5)
    802003ea:	97ba                	add	a5,a5,a4
    802003ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	8ba50513          	addi	a0,a0,-1862 # 80200ca8 <etext+0x236>
    802003f6:	c7dff06f          	j	80200072 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003fa:	00001517          	auipc	a0,0x1
    802003fe:	88e50513          	addi	a0,a0,-1906 # 80200c88 <etext+0x216>
    80200402:	c71ff06f          	j	80200072 <cprintf>
            cprintf("User software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	84250513          	addi	a0,a0,-1982 # 80200c48 <etext+0x1d6>
    8020040e:	c65ff06f          	j	80200072 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200412:	00001517          	auipc	a0,0x1
    80200416:	85650513          	addi	a0,a0,-1962 # 80200c68 <etext+0x1f6>
    8020041a:	c59ff06f          	j	80200072 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041e:	00001517          	auipc	a0,0x1
    80200422:	8ba50513          	addi	a0,a0,-1862 # 80200cd8 <etext+0x266>
    80200426:	c4dff06f          	j	80200072 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020042a:	1141                	addi	sp,sp,-16
    8020042c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    8020042e:	d3dff0ef          	jal	ra,8020016a <clock_set_next_event>
            ticks++;
    80200432:	00004717          	auipc	a4,0x4
    80200436:	bee70713          	addi	a4,a4,-1042 # 80204020 <ticks>
    8020043a:	631c                	ld	a5,0(a4)
    8020043c:	0785                	addi	a5,a5,1
    8020043e:	00004697          	auipc	a3,0x4
    80200442:	bef6b123          	sd	a5,-1054(a3) # 80204020 <ticks>
            if (ticks % TICK_NUM == 0){
    80200446:	631c                	ld	a5,0(a4)
    80200448:	06400713          	li	a4,100
    8020044c:	02e7f7b3          	remu	a5,a5,a4
    80200450:	c791                	beqz	a5,8020045c <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200452:	60a2                	ld	ra,8(sp)
    80200454:	0141                	addi	sp,sp,16
    80200456:	8082                	ret
            print_trapframe(tf);
    80200458:	f13ff06f          	j	8020036a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020045c:	06400593          	li	a1,100
    80200460:	00001517          	auipc	a0,0x1
    80200464:	86850513          	addi	a0,a0,-1944 # 80200cc8 <etext+0x256>
    80200468:	c0bff0ef          	jal	ra,80200072 <cprintf>
            	num++;
    8020046c:	00004717          	auipc	a4,0x4
    80200470:	ba470713          	addi	a4,a4,-1116 # 80204010 <edata>
    80200474:	631c                	ld	a5,0(a4)
    80200476:	0785                	addi	a5,a5,1
    80200478:	00004697          	auipc	a3,0x4
    8020047c:	b8f6bc23          	sd	a5,-1128(a3) # 80204010 <edata>
            	if (num % 10 ==0)
    80200480:	631c                	ld	a5,0(a4)
    80200482:	4729                	li	a4,10
    80200484:	02e7f7b3          	remu	a5,a5,a4
    80200488:	f7e9                	bnez	a5,80200452 <interrupt_handler+0x86>
}
    8020048a:	60a2                	ld	ra,8(sp)
    8020048c:	0141                	addi	sp,sp,16
            		sbi_shutdown();
    8020048e:	5900006f          	j	80200a1e <sbi_shutdown>

0000000080200492 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200492:	11853783          	ld	a5,280(a0)
    80200496:	472d                	li	a4,11
    80200498:	02f76863          	bltu	a4,a5,802004c8 <exception_handler+0x36>
    8020049c:	4705                	li	a4,1
    8020049e:	00f71733          	sll	a4,a4,a5
    802004a2:	6785                	lui	a5,0x1
    802004a4:	17cd                	addi	a5,a5,-13
    802004a6:	8ff9                	and	a5,a5,a4
    802004a8:	ef99                	bnez	a5,802004c6 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004aa:	1141                	addi	sp,sp,-16
    802004ac:	e022                	sd	s0,0(sp)
    802004ae:	e406                	sd	ra,8(sp)
    802004b0:	00877793          	andi	a5,a4,8
    802004b4:	842a                	mv	s0,a0
    802004b6:	e3b1                	bnez	a5,802004fa <exception_handler+0x68>
    802004b8:	8b11                	andi	a4,a4,4
    802004ba:	eb09                	bnez	a4,802004cc <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004bc:	6402                	ld	s0,0(sp)
    802004be:	60a2                	ld	ra,8(sp)
    802004c0:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c2:	ea9ff06f          	j	8020036a <print_trapframe>
    802004c6:	8082                	ret
    802004c8:	ea3ff06f          	j	8020036a <print_trapframe>
            cprintf("Exception type:Illegal instruction\n");
    802004cc:	00000517          	auipc	a0,0x0
    802004d0:	6f450513          	addi	a0,a0,1780 # 80200bc0 <etext+0x14e>
    802004d4:	b9fff0ef          	jal	ra,80200072 <cprintf>
            cprintf("Illegal instruction caught at 0x%x\n",tf->epc);
    802004d8:	10843583          	ld	a1,264(s0)
    802004dc:	00000517          	auipc	a0,0x0
    802004e0:	70c50513          	addi	a0,a0,1804 # 80200be8 <etext+0x176>
    802004e4:	b8fff0ef          	jal	ra,80200072 <cprintf>
            tf->epc+=4;
    802004e8:	10843783          	ld	a5,264(s0)
}
    802004ec:	60a2                	ld	ra,8(sp)
            tf->epc+=4;
    802004ee:	0791                	addi	a5,a5,4
    802004f0:	10f43423          	sd	a5,264(s0)
}
    802004f4:	6402                	ld	s0,0(sp)
    802004f6:	0141                	addi	sp,sp,16
    802004f8:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    802004fa:	00000517          	auipc	a0,0x0
    802004fe:	71650513          	addi	a0,a0,1814 # 80200c10 <etext+0x19e>
    80200502:	b71ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("ebreak caught at 0x%x\n",tf->epc);
    80200506:	10843583          	ld	a1,264(s0)
    8020050a:	00000517          	auipc	a0,0x0
    8020050e:	72650513          	addi	a0,a0,1830 # 80200c30 <etext+0x1be>
    80200512:	b61ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc+=2;
    80200516:	10843783          	ld	a5,264(s0)
}
    8020051a:	60a2                	ld	ra,8(sp)
            tf->epc+=2;
    8020051c:	0789                	addi	a5,a5,2
    8020051e:	10f43423          	sd	a5,264(s0)
}
    80200522:	6402                	ld	s0,0(sp)
    80200524:	0141                	addi	sp,sp,16
    80200526:	8082                	ret

0000000080200528 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200528:	11853783          	ld	a5,280(a0)
    8020052c:	0007c463          	bltz	a5,80200534 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200530:	f63ff06f          	j	80200492 <exception_handler>
        interrupt_handler(tf);
    80200534:	e99ff06f          	j	802003cc <interrupt_handler>

0000000080200538 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200538:	14011073          	csrw	sscratch,sp
    8020053c:	712d                	addi	sp,sp,-288
    8020053e:	e002                	sd	zero,0(sp)
    80200540:	e406                	sd	ra,8(sp)
    80200542:	ec0e                	sd	gp,24(sp)
    80200544:	f012                	sd	tp,32(sp)
    80200546:	f416                	sd	t0,40(sp)
    80200548:	f81a                	sd	t1,48(sp)
    8020054a:	fc1e                	sd	t2,56(sp)
    8020054c:	e0a2                	sd	s0,64(sp)
    8020054e:	e4a6                	sd	s1,72(sp)
    80200550:	e8aa                	sd	a0,80(sp)
    80200552:	ecae                	sd	a1,88(sp)
    80200554:	f0b2                	sd	a2,96(sp)
    80200556:	f4b6                	sd	a3,104(sp)
    80200558:	f8ba                	sd	a4,112(sp)
    8020055a:	fcbe                	sd	a5,120(sp)
    8020055c:	e142                	sd	a6,128(sp)
    8020055e:	e546                	sd	a7,136(sp)
    80200560:	e94a                	sd	s2,144(sp)
    80200562:	ed4e                	sd	s3,152(sp)
    80200564:	f152                	sd	s4,160(sp)
    80200566:	f556                	sd	s5,168(sp)
    80200568:	f95a                	sd	s6,176(sp)
    8020056a:	fd5e                	sd	s7,184(sp)
    8020056c:	e1e2                	sd	s8,192(sp)
    8020056e:	e5e6                	sd	s9,200(sp)
    80200570:	e9ea                	sd	s10,208(sp)
    80200572:	edee                	sd	s11,216(sp)
    80200574:	f1f2                	sd	t3,224(sp)
    80200576:	f5f6                	sd	t4,232(sp)
    80200578:	f9fa                	sd	t5,240(sp)
    8020057a:	fdfe                	sd	t6,248(sp)
    8020057c:	14001473          	csrrw	s0,sscratch,zero
    80200580:	100024f3          	csrr	s1,sstatus
    80200584:	14102973          	csrr	s2,sepc
    80200588:	143029f3          	csrr	s3,stval
    8020058c:	14202a73          	csrr	s4,scause
    80200590:	e822                	sd	s0,16(sp)
    80200592:	e226                	sd	s1,256(sp)
    80200594:	e64a                	sd	s2,264(sp)
    80200596:	ea4e                	sd	s3,272(sp)
    80200598:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020059a:	850a                	mv	a0,sp
    jal trap
    8020059c:	f8dff0ef          	jal	ra,80200528 <trap>

00000000802005a0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005a0:	6492                	ld	s1,256(sp)
    802005a2:	6932                	ld	s2,264(sp)
    802005a4:	10049073          	csrw	sstatus,s1
    802005a8:	14191073          	csrw	sepc,s2
    802005ac:	60a2                	ld	ra,8(sp)
    802005ae:	61e2                	ld	gp,24(sp)
    802005b0:	7202                	ld	tp,32(sp)
    802005b2:	72a2                	ld	t0,40(sp)
    802005b4:	7342                	ld	t1,48(sp)
    802005b6:	73e2                	ld	t2,56(sp)
    802005b8:	6406                	ld	s0,64(sp)
    802005ba:	64a6                	ld	s1,72(sp)
    802005bc:	6546                	ld	a0,80(sp)
    802005be:	65e6                	ld	a1,88(sp)
    802005c0:	7606                	ld	a2,96(sp)
    802005c2:	76a6                	ld	a3,104(sp)
    802005c4:	7746                	ld	a4,112(sp)
    802005c6:	77e6                	ld	a5,120(sp)
    802005c8:	680a                	ld	a6,128(sp)
    802005ca:	68aa                	ld	a7,136(sp)
    802005cc:	694a                	ld	s2,144(sp)
    802005ce:	69ea                	ld	s3,152(sp)
    802005d0:	7a0a                	ld	s4,160(sp)
    802005d2:	7aaa                	ld	s5,168(sp)
    802005d4:	7b4a                	ld	s6,176(sp)
    802005d6:	7bea                	ld	s7,184(sp)
    802005d8:	6c0e                	ld	s8,192(sp)
    802005da:	6cae                	ld	s9,200(sp)
    802005dc:	6d4e                	ld	s10,208(sp)
    802005de:	6dee                	ld	s11,216(sp)
    802005e0:	7e0e                	ld	t3,224(sp)
    802005e2:	7eae                	ld	t4,232(sp)
    802005e4:	7f4e                	ld	t5,240(sp)
    802005e6:	7fee                	ld	t6,248(sp)
    802005e8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005ea:	10200073          	sret

00000000802005ee <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005ee:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005f2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005f4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005f8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005fa:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005fe:	f022                	sd	s0,32(sp)
    80200600:	ec26                	sd	s1,24(sp)
    80200602:	e84a                	sd	s2,16(sp)
    80200604:	f406                	sd	ra,40(sp)
    80200606:	e44e                	sd	s3,8(sp)
    80200608:	84aa                	mv	s1,a0
    8020060a:	892e                	mv	s2,a1
    8020060c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200610:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200612:	03067e63          	bleu	a6,a2,8020064e <printnum+0x60>
    80200616:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200618:	00805763          	blez	s0,80200626 <printnum+0x38>
    8020061c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020061e:	85ca                	mv	a1,s2
    80200620:	854e                	mv	a0,s3
    80200622:	9482                	jalr	s1
        while (-- width > 0)
    80200624:	fc65                	bnez	s0,8020061c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200626:	1a02                	slli	s4,s4,0x20
    80200628:	020a5a13          	srli	s4,s4,0x20
    8020062c:	00001797          	auipc	a5,0x1
    80200630:	bd478793          	addi	a5,a5,-1068 # 80201200 <error_string+0x38>
    80200634:	9a3e                	add	s4,s4,a5
}
    80200636:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200638:	000a4503          	lbu	a0,0(s4)
}
    8020063c:	70a2                	ld	ra,40(sp)
    8020063e:	69a2                	ld	s3,8(sp)
    80200640:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200642:	85ca                	mv	a1,s2
    80200644:	8326                	mv	t1,s1
}
    80200646:	6942                	ld	s2,16(sp)
    80200648:	64e2                	ld	s1,24(sp)
    8020064a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020064c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020064e:	03065633          	divu	a2,a2,a6
    80200652:	8722                	mv	a4,s0
    80200654:	f9bff0ef          	jal	ra,802005ee <printnum>
    80200658:	b7f9                	j	80200626 <printnum+0x38>

000000008020065a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020065a:	7119                	addi	sp,sp,-128
    8020065c:	f4a6                	sd	s1,104(sp)
    8020065e:	f0ca                	sd	s2,96(sp)
    80200660:	e8d2                	sd	s4,80(sp)
    80200662:	e4d6                	sd	s5,72(sp)
    80200664:	e0da                	sd	s6,64(sp)
    80200666:	fc5e                	sd	s7,56(sp)
    80200668:	f862                	sd	s8,48(sp)
    8020066a:	f06a                	sd	s10,32(sp)
    8020066c:	fc86                	sd	ra,120(sp)
    8020066e:	f8a2                	sd	s0,112(sp)
    80200670:	ecce                	sd	s3,88(sp)
    80200672:	f466                	sd	s9,40(sp)
    80200674:	ec6e                	sd	s11,24(sp)
    80200676:	892a                	mv	s2,a0
    80200678:	84ae                	mv	s1,a1
    8020067a:	8d32                	mv	s10,a2
    8020067c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020067e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200680:	00001a17          	auipc	s4,0x1
    80200684:	9eca0a13          	addi	s4,s4,-1556 # 8020106c <etext+0x5fa>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200688:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020068c:	00001c17          	auipc	s8,0x1
    80200690:	b3cc0c13          	addi	s8,s8,-1220 # 802011c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200694:	000d4503          	lbu	a0,0(s10)
    80200698:	02500793          	li	a5,37
    8020069c:	001d0413          	addi	s0,s10,1
    802006a0:	00f50e63          	beq	a0,a5,802006bc <vprintfmt+0x62>
            if (ch == '\0') {
    802006a4:	c521                	beqz	a0,802006ec <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a6:	02500993          	li	s3,37
    802006aa:	a011                	j	802006ae <vprintfmt+0x54>
            if (ch == '\0') {
    802006ac:	c121                	beqz	a0,802006ec <vprintfmt+0x92>
            putch(ch, putdat);
    802006ae:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006b2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b4:	fff44503          	lbu	a0,-1(s0)
    802006b8:	ff351ae3          	bne	a0,s3,802006ac <vprintfmt+0x52>
    802006bc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006c0:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006c4:	4981                	li	s3,0
    802006c6:	4801                	li	a6,0
        width = precision = -1;
    802006c8:	5cfd                	li	s9,-1
    802006ca:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006cc:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006d0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006d2:	fdd6069b          	addiw	a3,a2,-35
    802006d6:	0ff6f693          	andi	a3,a3,255
    802006da:	00140d13          	addi	s10,s0,1
    802006de:	20d5e563          	bltu	a1,a3,802008e8 <vprintfmt+0x28e>
    802006e2:	068a                	slli	a3,a3,0x2
    802006e4:	96d2                	add	a3,a3,s4
    802006e6:	4294                	lw	a3,0(a3)
    802006e8:	96d2                	add	a3,a3,s4
    802006ea:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006ec:	70e6                	ld	ra,120(sp)
    802006ee:	7446                	ld	s0,112(sp)
    802006f0:	74a6                	ld	s1,104(sp)
    802006f2:	7906                	ld	s2,96(sp)
    802006f4:	69e6                	ld	s3,88(sp)
    802006f6:	6a46                	ld	s4,80(sp)
    802006f8:	6aa6                	ld	s5,72(sp)
    802006fa:	6b06                	ld	s6,64(sp)
    802006fc:	7be2                	ld	s7,56(sp)
    802006fe:	7c42                	ld	s8,48(sp)
    80200700:	7ca2                	ld	s9,40(sp)
    80200702:	7d02                	ld	s10,32(sp)
    80200704:	6de2                	ld	s11,24(sp)
    80200706:	6109                	addi	sp,sp,128
    80200708:	8082                	ret
    if (lflag >= 2) {
    8020070a:	4705                	li	a4,1
    8020070c:	008a8593          	addi	a1,s5,8
    80200710:	01074463          	blt	a4,a6,80200718 <vprintfmt+0xbe>
    else if (lflag) {
    80200714:	26080363          	beqz	a6,8020097a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200718:	000ab603          	ld	a2,0(s5)
    8020071c:	46c1                	li	a3,16
    8020071e:	8aae                	mv	s5,a1
    80200720:	a06d                	j	802007ca <vprintfmt+0x170>
            goto reswitch;
    80200722:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200726:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200728:	846a                	mv	s0,s10
            goto reswitch;
    8020072a:	b765                	j	802006d2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    8020072c:	000aa503          	lw	a0,0(s5)
    80200730:	85a6                	mv	a1,s1
    80200732:	0aa1                	addi	s5,s5,8
    80200734:	9902                	jalr	s2
            break;
    80200736:	bfb9                	j	80200694 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200738:	4705                	li	a4,1
    8020073a:	008a8993          	addi	s3,s5,8
    8020073e:	01074463          	blt	a4,a6,80200746 <vprintfmt+0xec>
    else if (lflag) {
    80200742:	22080463          	beqz	a6,8020096a <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200746:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020074a:	24044463          	bltz	s0,80200992 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020074e:	8622                	mv	a2,s0
    80200750:	8ace                	mv	s5,s3
    80200752:	46a9                	li	a3,10
    80200754:	a89d                	j	802007ca <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200756:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020075a:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020075c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020075e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200762:	8fb5                	xor	a5,a5,a3
    80200764:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200768:	1ad74363          	blt	a4,a3,8020090e <vprintfmt+0x2b4>
    8020076c:	00369793          	slli	a5,a3,0x3
    80200770:	97e2                	add	a5,a5,s8
    80200772:	639c                	ld	a5,0(a5)
    80200774:	18078d63          	beqz	a5,8020090e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200778:	86be                	mv	a3,a5
    8020077a:	00001617          	auipc	a2,0x1
    8020077e:	b3660613          	addi	a2,a2,-1226 # 802012b0 <error_string+0xe8>
    80200782:	85a6                	mv	a1,s1
    80200784:	854a                	mv	a0,s2
    80200786:	240000ef          	jal	ra,802009c6 <printfmt>
    8020078a:	b729                	j	80200694 <vprintfmt+0x3a>
            lflag ++;
    8020078c:	00144603          	lbu	a2,1(s0)
    80200790:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200792:	846a                	mv	s0,s10
            goto reswitch;
    80200794:	bf3d                	j	802006d2 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200796:	4705                	li	a4,1
    80200798:	008a8593          	addi	a1,s5,8
    8020079c:	01074463          	blt	a4,a6,802007a4 <vprintfmt+0x14a>
    else if (lflag) {
    802007a0:	1e080263          	beqz	a6,80200984 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007a4:	000ab603          	ld	a2,0(s5)
    802007a8:	46a1                	li	a3,8
    802007aa:	8aae                	mv	s5,a1
    802007ac:	a839                	j	802007ca <vprintfmt+0x170>
            putch('0', putdat);
    802007ae:	03000513          	li	a0,48
    802007b2:	85a6                	mv	a1,s1
    802007b4:	e03e                	sd	a5,0(sp)
    802007b6:	9902                	jalr	s2
            putch('x', putdat);
    802007b8:	85a6                	mv	a1,s1
    802007ba:	07800513          	li	a0,120
    802007be:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007c0:	0aa1                	addi	s5,s5,8
    802007c2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007c6:	6782                	ld	a5,0(sp)
    802007c8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007ca:	876e                	mv	a4,s11
    802007cc:	85a6                	mv	a1,s1
    802007ce:	854a                	mv	a0,s2
    802007d0:	e1fff0ef          	jal	ra,802005ee <printnum>
            break;
    802007d4:	b5c1                	j	80200694 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007d6:	000ab603          	ld	a2,0(s5)
    802007da:	0aa1                	addi	s5,s5,8
    802007dc:	1c060663          	beqz	a2,802009a8 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007e0:	00160413          	addi	s0,a2,1
    802007e4:	17b05c63          	blez	s11,8020095c <vprintfmt+0x302>
    802007e8:	02d00593          	li	a1,45
    802007ec:	14b79263          	bne	a5,a1,80200930 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007f0:	00064783          	lbu	a5,0(a2)
    802007f4:	0007851b          	sext.w	a0,a5
    802007f8:	c905                	beqz	a0,80200828 <vprintfmt+0x1ce>
    802007fa:	000cc563          	bltz	s9,80200804 <vprintfmt+0x1aa>
    802007fe:	3cfd                	addiw	s9,s9,-1
    80200800:	036c8263          	beq	s9,s6,80200824 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200804:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200806:	18098463          	beqz	s3,8020098e <vprintfmt+0x334>
    8020080a:	3781                	addiw	a5,a5,-32
    8020080c:	18fbf163          	bleu	a5,s7,8020098e <vprintfmt+0x334>
                    putch('?', putdat);
    80200810:	03f00513          	li	a0,63
    80200814:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200816:	0405                	addi	s0,s0,1
    80200818:	fff44783          	lbu	a5,-1(s0)
    8020081c:	3dfd                	addiw	s11,s11,-1
    8020081e:	0007851b          	sext.w	a0,a5
    80200822:	fd61                	bnez	a0,802007fa <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200824:	e7b058e3          	blez	s11,80200694 <vprintfmt+0x3a>
    80200828:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020082a:	85a6                	mv	a1,s1
    8020082c:	02000513          	li	a0,32
    80200830:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200832:	e60d81e3          	beqz	s11,80200694 <vprintfmt+0x3a>
    80200836:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200838:	85a6                	mv	a1,s1
    8020083a:	02000513          	li	a0,32
    8020083e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200840:	fe0d94e3          	bnez	s11,80200828 <vprintfmt+0x1ce>
    80200844:	bd81                	j	80200694 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200846:	4705                	li	a4,1
    80200848:	008a8593          	addi	a1,s5,8
    8020084c:	01074463          	blt	a4,a6,80200854 <vprintfmt+0x1fa>
    else if (lflag) {
    80200850:	12080063          	beqz	a6,80200970 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200854:	000ab603          	ld	a2,0(s5)
    80200858:	46a9                	li	a3,10
    8020085a:	8aae                	mv	s5,a1
    8020085c:	b7bd                	j	802007ca <vprintfmt+0x170>
    8020085e:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200862:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200866:	846a                	mv	s0,s10
    80200868:	b5ad                	j	802006d2 <vprintfmt+0x78>
            putch(ch, putdat);
    8020086a:	85a6                	mv	a1,s1
    8020086c:	02500513          	li	a0,37
    80200870:	9902                	jalr	s2
            break;
    80200872:	b50d                	j	80200694 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200874:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200878:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020087c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020087e:	846a                	mv	s0,s10
            if (width < 0)
    80200880:	e40dd9e3          	bgez	s11,802006d2 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200884:	8de6                	mv	s11,s9
    80200886:	5cfd                	li	s9,-1
    80200888:	b5a9                	j	802006d2 <vprintfmt+0x78>
            goto reswitch;
    8020088a:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020088e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    80200892:	846a                	mv	s0,s10
            goto reswitch;
    80200894:	bd3d                	j	802006d2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200896:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020089a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020089e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008a0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008a4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008a8:	fcd56ce3          	bltu	a0,a3,80200880 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008ac:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008ae:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008b2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008b6:	0196873b          	addw	a4,a3,s9
    802008ba:	0017171b          	slliw	a4,a4,0x1
    802008be:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008c2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008c6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008ca:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008ce:	fcd57fe3          	bleu	a3,a0,802008ac <vprintfmt+0x252>
    802008d2:	b77d                	j	80200880 <vprintfmt+0x226>
            if (width < 0)
    802008d4:	fffdc693          	not	a3,s11
    802008d8:	96fd                	srai	a3,a3,0x3f
    802008da:	00ddfdb3          	and	s11,s11,a3
    802008de:	00144603          	lbu	a2,1(s0)
    802008e2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008e4:	846a                	mv	s0,s10
    802008e6:	b3f5                	j	802006d2 <vprintfmt+0x78>
            putch('%', putdat);
    802008e8:	85a6                	mv	a1,s1
    802008ea:	02500513          	li	a0,37
    802008ee:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008f0:	fff44703          	lbu	a4,-1(s0)
    802008f4:	02500793          	li	a5,37
    802008f8:	8d22                	mv	s10,s0
    802008fa:	d8f70de3          	beq	a4,a5,80200694 <vprintfmt+0x3a>
    802008fe:	02500713          	li	a4,37
    80200902:	1d7d                	addi	s10,s10,-1
    80200904:	fffd4783          	lbu	a5,-1(s10)
    80200908:	fee79de3          	bne	a5,a4,80200902 <vprintfmt+0x2a8>
    8020090c:	b361                	j	80200694 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020090e:	00001617          	auipc	a2,0x1
    80200912:	99260613          	addi	a2,a2,-1646 # 802012a0 <error_string+0xd8>
    80200916:	85a6                	mv	a1,s1
    80200918:	854a                	mv	a0,s2
    8020091a:	0ac000ef          	jal	ra,802009c6 <printfmt>
    8020091e:	bb9d                	j	80200694 <vprintfmt+0x3a>
                p = "(null)";
    80200920:	00001617          	auipc	a2,0x1
    80200924:	97860613          	addi	a2,a2,-1672 # 80201298 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200928:	00001417          	auipc	s0,0x1
    8020092c:	97140413          	addi	s0,s0,-1679 # 80201299 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200930:	8532                	mv	a0,a2
    80200932:	85e6                	mv	a1,s9
    80200934:	e032                	sd	a2,0(sp)
    80200936:	e43e                	sd	a5,8(sp)
    80200938:	102000ef          	jal	ra,80200a3a <strnlen>
    8020093c:	40ad8dbb          	subw	s11,s11,a0
    80200940:	6602                	ld	a2,0(sp)
    80200942:	01b05d63          	blez	s11,8020095c <vprintfmt+0x302>
    80200946:	67a2                	ld	a5,8(sp)
    80200948:	2781                	sext.w	a5,a5
    8020094a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    8020094c:	6522                	ld	a0,8(sp)
    8020094e:	85a6                	mv	a1,s1
    80200950:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200952:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200954:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200956:	6602                	ld	a2,0(sp)
    80200958:	fe0d9ae3          	bnez	s11,8020094c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020095c:	00064783          	lbu	a5,0(a2)
    80200960:	0007851b          	sext.w	a0,a5
    80200964:	e8051be3          	bnez	a0,802007fa <vprintfmt+0x1a0>
    80200968:	b335                	j	80200694 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020096a:	000aa403          	lw	s0,0(s5)
    8020096e:	bbf1                	j	8020074a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200970:	000ae603          	lwu	a2,0(s5)
    80200974:	46a9                	li	a3,10
    80200976:	8aae                	mv	s5,a1
    80200978:	bd89                	j	802007ca <vprintfmt+0x170>
    8020097a:	000ae603          	lwu	a2,0(s5)
    8020097e:	46c1                	li	a3,16
    80200980:	8aae                	mv	s5,a1
    80200982:	b5a1                	j	802007ca <vprintfmt+0x170>
    80200984:	000ae603          	lwu	a2,0(s5)
    80200988:	46a1                	li	a3,8
    8020098a:	8aae                	mv	s5,a1
    8020098c:	bd3d                	j	802007ca <vprintfmt+0x170>
                    putch(ch, putdat);
    8020098e:	9902                	jalr	s2
    80200990:	b559                	j	80200816 <vprintfmt+0x1bc>
                putch('-', putdat);
    80200992:	85a6                	mv	a1,s1
    80200994:	02d00513          	li	a0,45
    80200998:	e03e                	sd	a5,0(sp)
    8020099a:	9902                	jalr	s2
                num = -(long long)num;
    8020099c:	8ace                	mv	s5,s3
    8020099e:	40800633          	neg	a2,s0
    802009a2:	46a9                	li	a3,10
    802009a4:	6782                	ld	a5,0(sp)
    802009a6:	b515                	j	802007ca <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009a8:	01b05663          	blez	s11,802009b4 <vprintfmt+0x35a>
    802009ac:	02d00693          	li	a3,45
    802009b0:	f6d798e3          	bne	a5,a3,80200920 <vprintfmt+0x2c6>
    802009b4:	00001417          	auipc	s0,0x1
    802009b8:	8e540413          	addi	s0,s0,-1819 # 80201299 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009bc:	02800513          	li	a0,40
    802009c0:	02800793          	li	a5,40
    802009c4:	bd1d                	j	802007fa <vprintfmt+0x1a0>

00000000802009c6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009c8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009cc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009ce:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d0:	ec06                	sd	ra,24(sp)
    802009d2:	f83a                	sd	a4,48(sp)
    802009d4:	fc3e                	sd	a5,56(sp)
    802009d6:	e0c2                	sd	a6,64(sp)
    802009d8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009da:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009dc:	c7fff0ef          	jal	ra,8020065a <vprintfmt>
}
    802009e0:	60e2                	ld	ra,24(sp)
    802009e2:	6161                	addi	sp,sp,80
    802009e4:	8082                	ret

00000000802009e6 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009e6:	00003797          	auipc	a5,0x3
    802009ea:	61a78793          	addi	a5,a5,1562 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009ee:	6398                	ld	a4,0(a5)
    802009f0:	4781                	li	a5,0
    802009f2:	88ba                	mv	a7,a4
    802009f4:	852a                	mv	a0,a0
    802009f6:	85be                	mv	a1,a5
    802009f8:	863e                	mv	a2,a5
    802009fa:	00000073          	ecall
    802009fe:	87aa                	mv	a5,a0
}
    80200a00:	8082                	ret

0000000080200a02 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a02:	00003797          	auipc	a5,0x3
    80200a06:	61678793          	addi	a5,a5,1558 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a0a:	6398                	ld	a4,0(a5)
    80200a0c:	4781                	li	a5,0
    80200a0e:	88ba                	mv	a7,a4
    80200a10:	852a                	mv	a0,a0
    80200a12:	85be                	mv	a1,a5
    80200a14:	863e                	mv	a2,a5
    80200a16:	00000073          	ecall
    80200a1a:	87aa                	mv	a5,a0
}
    80200a1c:	8082                	ret

0000000080200a1e <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a1e:	00003797          	auipc	a5,0x3
    80200a22:	5ea78793          	addi	a5,a5,1514 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a26:	6398                	ld	a4,0(a5)
    80200a28:	4781                	li	a5,0
    80200a2a:	88ba                	mv	a7,a4
    80200a2c:	853e                	mv	a0,a5
    80200a2e:	85be                	mv	a1,a5
    80200a30:	863e                	mv	a2,a5
    80200a32:	00000073          	ecall
    80200a36:	87aa                	mv	a5,a0
    80200a38:	8082                	ret

0000000080200a3a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a3a:	c185                	beqz	a1,80200a5a <strnlen+0x20>
    80200a3c:	00054783          	lbu	a5,0(a0)
    80200a40:	cf89                	beqz	a5,80200a5a <strnlen+0x20>
    size_t cnt = 0;
    80200a42:	4781                	li	a5,0
    80200a44:	a021                	j	80200a4c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a46:	00074703          	lbu	a4,0(a4)
    80200a4a:	c711                	beqz	a4,80200a56 <strnlen+0x1c>
        cnt ++;
    80200a4c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a4e:	00f50733          	add	a4,a0,a5
    80200a52:	fef59ae3          	bne	a1,a5,80200a46 <strnlen+0xc>
    }
    return cnt;
}
    80200a56:	853e                	mv	a0,a5
    80200a58:	8082                	ret
    size_t cnt = 0;
    80200a5a:	4781                	li	a5,0
}
    80200a5c:	853e                	mv	a0,a5
    80200a5e:	8082                	ret

0000000080200a60 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a60:	ca01                	beqz	a2,80200a70 <memset+0x10>
    80200a62:	962a                	add	a2,a2,a0
    char *p = s;
    80200a64:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a66:	0785                	addi	a5,a5,1
    80200a68:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a6c:	fec79de3          	bne	a5,a2,80200a66 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a70:	8082                	ret
