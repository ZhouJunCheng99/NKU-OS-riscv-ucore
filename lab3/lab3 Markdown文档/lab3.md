#### 练习1：理解基于FIFO的页面替换算法（思考题）
> 描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
> - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数
#### 处理流程
下面在处理流程中遇到的函数/宏。

当缺页异常发生时，进入trap.c中的exception_handler()，随后进入vmm.c的do_default(struct mm_struct *mm, uint_t error_code, uintptr_t addr)函数,该函数是页面置换机制的核心。通过该函数进入页表项建立、页swap_out以及新页的swap_in；

在do_default函数中，首先将调用find_vma(mm, addr)，找到对应的vma段，得到他的读写属性；之后拼接页表项内容，需要将通过get_pte(pde_t *pgdir, uintptr_t la, bool create)，得到pte的地址，从而将拼接的结果写入地址内。

+ find_vma函数:找到地址addr对应的vma段
```C
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
    struct vma_struct *vma = NULL;
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
                    vma = le2vma(le, list_link);
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = NULL;
                }
        }
        if (vma != NULL) {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}
```
+ get_pte()函数:寻找、没有时创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。
```C
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep_store != NULL) {
        *ptep_store = ptep;
    }
    if (ptep != NULL && *ptep & PTE_V) {
        return pte2page(*ptep);
    }
    return NULL;
}
```
当get_pte发现该页表项是！0 说明有数据写入过，此时准备从磁盘换入。

在实现页面换入换出之前，FIFO交换算法打包成了一个交换管理器swap_manager_fifo。首先在swap的初始化函数中，把默认使用的交换管理器设定为swap_manager_fifo。其它的是一些基础的和测试例有关的信息的初始化。

+ swap_init函数：
```C
int
swap_init(void)
{
     swapfs_init();

     if (!(7 <= max_swap_offset &&
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     int r = sm->init();
     
     if (r == 0)
     {
          swap_init_ok = 1;
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
```
随后，进行换入操作。

swap_in函数:实现页的换入，将页面从磁盘加载到内存，使用复制的方式完成。
```C
int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
     struct Page *result = alloc_page();
     assert(result!=NULL);

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
     *ptr_result=result;
     return 0;
}
```
在swap_in函数中，调用alloc_page尝试获得空闲页，
而我们的实验实现的是一种消极的换出策略，在调用alloc_pages 获取空闲页时，发现无法从物理内存页的分配器中获得页，就调用swap_out函数完成页的换出。

其中alloc_pages函数:内存页面分配函数,若发现物理内存中无空闲页，就进入到swap_out函数。
```C
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
```
swap_out函数：实现页的换出
```C
int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
     {
          uintptr_t v;
          struct Page *page;
          int r = sm->swap_out_victim(mm, &page, in_tick);
          if (r != 0) {
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
                  break;
          }          
          v=page->pra_vaddr; 
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
          assert((*ptep & PTE_V) != 0);

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
                    cprintf("SWAP: failed to save\n");
                    sm->map_swappable(mm, v, page, 0);
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
}
```
获得空闲页后，swap_in函数继续调用get_pte()函数获取页表项。

然后，函数调用swapfs_read函数从磁盘交换区中读取页表项(*ptep)表示的页面，并将数据存储到之前分配的页面result中。

我们回到do_pgfault函数，在执行完swap_in函数后，会调用page_insert函数

+ page_insert函数:建立虚拟地址与物理页的映射
```C
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    tlb_invalidate(pgdir, la);
    return 0;
}
```
随后，调用swap_map_swappable函数,标记这个页面将来是可以再换出的。
+ swap_map_swappable函数
```C
int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
     return sm->map_swappable(mm, addr, page, swap_in);
}
```
最后，我们来看一看swap_manager中 组合页面置换需要的一些函数接口。
+ _fifo_init_mm函数：初始化 pra_list_head，让 mm->sm_priv 指向 pra_list_head 的地址。使得我们可以从内存控制结构 mm_struct 访问 FIFO PRA。
```C
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
```
+ _fifo_map_swappable函数：记录该页面访问过且可替换。
```C
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    list_add(head, entry);
    return 0;
}
```
+ _fifo_swap_out_victim函数:选择出将要换出的页，即最早被访问的页
```C
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}
```
+ _fifo_check_swap：检查具体交换了哪个页面，并输出
```C
static int
_fifo_check_swap(void) {
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==7);
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==8);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==9);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==10);
    cprintf("write Virt Page a in fifo_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==11);
    return 0;
}
```
#### 练习2：深入理解不同分页模式的工作原理（思考题）
>get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
> - get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
> - 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

(1)结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

sv32、sv39、sv48的异同：

1、sv32 是 RISC-V 的 32 位架构，采用两级页表结构。虚拟地址为32位，第一级页表项占用10位，第二级页表项占用10位，PTE占用12位。一级页表包含指向二级页表的指针，而二级页表包含页表项。sv32 的页表项大小是 4 字节。

2、sv39 是 RISC-V 的 64 位架构，采用三级页表结构。虚拟地址分别为39位，每级页表项占用9位，PTE占用12位。一级页表包含指向二级页表的指针，二级页表包含指向三级页表的指针，而三级页表包含页表项。sv39 的页表项大小是 8 字节。

3、sv48 也是 RISC-V 的 64 位架构，采用四级页表结构。虚拟地址分别为48位，每级页表项占用9位，PTE占用12位。类似于 sv39，它包含更多的页表级别，每个级别都包含指向下一级页表的指针，最后一级包含页表项。sv48 的页表项大小也是 8 字节。

4、三种架构的相同之处在于：都包含权限位，且都是根据逐级根据页目录索引，索引方式相同，最后指向由os分配的一个物理地址。

观察代码可知，这两段代码都是用于获取虚拟地址对应的页表项（Page Table Entry, PTE），其中第一段代码用于获取第一级页表项（PDE1），第二段代码用于获取第二级页表项（PDE0）。

尽管sv32、sv39、sv48在页表级别和页表项大小上有所不同，但是不同的页表格式下都需要进行类似的页表操作，包括获取页表项指针、检查有效位和创建页表项等，只是相似代码重复次数会有所不同，因此代码具有相似性。

(2)目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

我们认为没有必要把两个功能拆开。将查找和分配合并在一个函数中，只需判断一次便可实现页表项的获取（或查找获取或分配获取，避免代码的重复，提高了代码的可维护性和可读性，逻辑紧凑。
另外，代码中并无其他地方需要使用页表项的分配故无需封装为单独的函数。
#### 练习3：给未被映射的地址映射上物理页（需要编程）
>补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
> - 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
> - 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
>- 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

#### 练习4：补充完成Clock页替换算法（需要编程）
>通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
> - 比较Clock页替换算法和FIFO算法的不同。

Clock页替换算法需要初始化页面链表，标记页面的访问情况，以及选择要置换的页面来管理虚拟内存的页面置换。在初始化时，创建一个空链表 pra_list_head，将当前指针 curr_ptr 指向链表头，然后将 mm 的私有成员指针指向 pra_list_head，用于后续的页面置换操作。在页面标记为可置换时，将页面插入链表尾部，标记页面为已访问。在选择置换页面时，遍历页面链表，查找最早未被访问的页面，将其作为换出页面，并更新页面的访问状态。

```C
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: YOUR CODE*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     
     //pra_list_head.next = pra_list_head.prev = NULL;
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
     cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     
     return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问

    //pra_list_head.next = page;
    //list_add_before(curr_ptr, entry); wrong
    list_add_before(mm->sm_priv,entry);
    
    page->visited = 1;

    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: YOUR CODE*/ 
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问

        if (curr_ptr == head)
        {
            //curr_ptr = curr_ptr->next;
            curr_ptr = list_next(curr_ptr);
        }

        struct Page *page = le2page(curr_ptr, pra_page_link);
        if (page->visited == 1) {
            page->visited = 0;
            //curr_ptr = curr_ptr->next;
            curr_ptr = list_next(curr_ptr);
        }
        else{
            *ptr_page = page;
            cprintf("curr_ptr %p\n",curr_ptr);
            list_del(curr_ptr);           
            break;
        }

    }
    return 0;
}
```
运行成功，截图如下：
![Clock页替换算法运行截图](<屏幕截图 2023-10-30 091255.png>)


>Clock页替换算法和FIFO算法的不同之处在于Clock算法在FIFO算法的基础多了一个visted位的判断，所以需要遍历链表寻找最早未被访问的页面替换。Clock算法更复杂，能够更好地减少缺页中断，而FIFO算法则更简单但可能性能较低。具体来说：

>FIFO（First-In, First-Out）算法：FIFO算法选择要置换的页面时，总是选择最早进入内存的页面，即最先进入内存的页面会被最早置换出去。这是一个非常简单的算法，但它不考虑页面的使用情况，可能会导致性能下降。
>
>Clock页替换算法：也称为最近未使用（LRU）近似算法，选择要置换的页面时，考虑页面是否被引用过。它使用一个类似时钟的数据结构，定期扫描所有页面，并根据页面是否被引用来确定页面的位置。如果页面被引用，它会被移到时钟中的下一个位置，否则，它有可能被置换出去。为了简化硬件设计，我们使用一个visited位来进行判断是否访问。

>FIFO算法非常简单，因为它只需要一个队列来维护页面的进入顺序。然而，它可能会导致"Belady现象"，即增加页面数可能导致更多的缺页中断。Clock算法相对较复杂，因为它需要多一个位进行判断，以跟踪页面的引用情况。但它通常比FIFO算法更好地反映了程序的页面使用模式，减少了缺页中断的数量。



#### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）
>如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？
