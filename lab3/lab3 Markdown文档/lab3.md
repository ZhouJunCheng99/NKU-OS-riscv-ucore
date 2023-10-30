#### 练习1：理解基于FIFO的页面替换算法（思考题）
> 描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
> - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

#### 练习2：深入理解不同分页模式的工作原理（思考题）
>get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
> - get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
> - 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

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