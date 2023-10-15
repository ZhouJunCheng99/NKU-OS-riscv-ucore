# lab2

## 练习1：理解first-fit 连续物理内存分配算法（思考题）

first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合kern/mm/default_pmm.c中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages，default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

+ 你的first fit算法是否有进一步的改进空间？

First Fit（最先匹配）是一种常见的内存分配算法。其基本原理是：存储管理器沿着段链表进行搜索，直到找到一个够大的空闲区，除非空闲区大小和要分配的空间大小正好一样，否则将该空闲区分为两部分，一部分供进程使用，另一部分形成新的空闲区。首次适配算法是一种速度很快的算法，因为它尽可能少地搜索链表结点。缺点是会导致内存碎片化，即剩余的小块无法满足大块的请求。以及如果较大的空闲块位于链表或数组的末尾，那么查找合适的空闲块可能需要较长的时间。

### default_init函数分析
代码如下：
```c
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```
+ `list_init(&free_list)`：这行代码调用list_init的函数，参数为指向free_list的指针。意在将free_list空闲链表初始化成一个空链表。

+ `nr_free = 0`：将空闲页数量置为0(因为还没开始计算空闲页的数量，所以是0)。
#### 综上，可以实现将空闲内存块列表初始化为空链表，并将空闲内存块的数量设置为0，达到初始化管理器结构的作用。
### default_init_memmap函数分析
代码如下：
```c
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```
+ 
