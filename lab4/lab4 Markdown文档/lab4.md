

### 练习2：为新创建的内核线程分配资源（需要编码）
设计实现过程在实验指导书书中已经详细给出了，大致就是：调用alloc_proc，首先获取用户信息块，然后setup_kstack为进程分配一个内核栈。接着，将原进程的内存管理信息复制到新进程，并将原进程的上下文复制到新进程。随后，将新进程添加到进程列表中，唤醒新进程，并最终返回新进程号。
```C
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;

    if((proc = alloc_proc())==NULL){ //分配并初始化进程控制块
        goto fork_out;
    }
    proc->parent = current; //将子进程的父节点设置为当前进程
    if((setup_kstack(proc)!=0)){ //分配并初始化内核栈
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) { //根据clone_flags决定是复制还是共享内存管理系统
        goto bad_fork_cleanup_kstack;
    }

    copy_thread(proc, stack, tf); //设置进程的中断帧和上下文

    proc->pid = get_pid();

    hash_proc(proc);
    list_add(&proc_list, &(proc->list_link)); //把设置好的进程加入链表
    nr_process ++; //全局线程的数目+1

    wakeup_proc(proc); //将新建的进程设为就绪态
    ret = proc->pid; //将返回值设为线程id

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

#### 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

ucore可以做到每个新fork的线程唯一，从关键代码我们可以看出，如果```if (proc->pid == last_pid)```，之后会```++last_pid```，说明一旦循环时出现线程号相等的情况就会立刻自增，不会构造出重复的pid。
```C
static int
get_pid(void) {
    ...
    repeat:
    //PID 的确定过程中会检查所有进程的 PID，确保唯一
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {  //确保新进程的pid不会与last_pid相等
                if (++ last_pid >= next_safe) { //自增
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```
### 练习三：编写proc_run函数（需要编码）
proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

+ 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
+ 禁用中断。你可以使用/kern/sync/sync.h中定义好的宏local_intr_save(x)和local_intr_restore(x)来实现关、开中断。
+ 切换当前进程为要运行的进程。
+ 切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
+ 实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
+ 允许中断。

请回答如下问题：
+ 在本实验的执行过程中，创建且运行了几个内核线程？

完成代码编写后，编译并运行代码：make qemu

如果可以得到如 附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。

编写的proc_run函数：
```C
void proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);//禁用中断
        current = proc;//切换当前进程为要运行的进程
        lcr3(next->cr3);//切换新进程的页表，以便使用新进程的地址空间。
        switch_to(&(prev->context), &(next->context));//实现上下文切换，切换到新进程
        local_intr_restore(intr_flag);//允许中断
    }
}
```
实现思路：

+ 首先判断要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
+ 使用 local_intr_save 函数保存当前的中断状态，并将中断禁用。这是为了在进行进程切换的过程中防止被中断打断。
+ 将全局变量 current 设置为传入的进程 proc，表示当前正在运行的进程切换为指定的进程。
+ 使用 lcr3 函数切换页表，以便开始使用新进程的地址空间。next->cr3 存储了新进程的页目录表的物理地址。
+ 使用 switch_to 函数进行上下文切换。这里传递了两个参数，分别是当前进程的上下文 prev->context 和要切换到的新进程的上下文 next->context。上下文切换的目的是保存当前进程的寄存器状态，并将新进程的寄存器状态恢复，从而实现进程的切换。
+ 最后，使用 local_intr_restore 函数允许中断，将之前保存的中断状态恢复，使系统能够响应中断。

在本实验的执行过程中，创建且运行了几个内核线程？

答：两个。
+ idleproc：第0个内核进程，完成新内核线程的创建以及内核中各个子系统的初始化，之后立即调度执行其他进程。 
+ initproc：在调度后使用的内核线程，本实验仅让它输出一个Hello World，证明我们的内核进程实现的没有问题。

### 实验结果

make qemu
![!\[Alt text\](<屏幕截图 2023-11-19 160706.png>)](<屏幕截图 2023-11-19 160616.png>)


make grade
![Alt text](image-1.png)
