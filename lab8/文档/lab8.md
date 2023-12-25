## 练习1: 完成读文件操作的实现（需要编码）
> 首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c中 的sfs_io_nolock()函数，实现读文件中数据的代码。

函数主要是从文件的磁盘块中读取数据到内存，或者将内存中的数据写入到文件的磁盘块中，再对读写的起始和结束位置进行了合法性检查，避免非法访问。同时通过一系列的函数指针（sfs_buf_op和sfs_block_op）选择读写缓冲区或磁盘块的操作。

```C
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;
    assert(din->type != SFS_TYPE_DIR);
    // 确定读取的结束位置
    off_t endpos = offset + *alenp, blkoff;
    *alenp = 0;
	// calculate the Rd/Wr end position
    // 避免非法访问
    if (offset < 0 || offset >= SFS_MAX_FILE_SIZE || offset > endpos) {
        return -E_INVAL;
    }
    if (offset == endpos) {
        return 0;
    }
    if (endpos > SFS_MAX_FILE_SIZE) {
        endpos = SFS_MAX_FILE_SIZE;
    }
    if (!write) {
        if (offset >= din->size) {
            return 0;
        }
        if (endpos > din->size) {
            endpos = din->size;
        }
    }

    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
    if (write) {
        sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;
    }
    else {
        sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;
    }

    int ret = 0;
    size_t size, alen = 0;
    uint32_t ino;
    uint32_t blkno = offset / SFS_BLKSIZE;          // The NO. of Rd/Wr begin block
    uint32_t nblks = endpos / SFS_BLKSIZE - blkno;  // The size of Rd/Wr blocks

  //LAB8:EXERCISE1 YOUR CODE HINT: call sfs_bmap_load_nolock, sfs_rbuf, sfs_rblock,etc. read different kind of blocks in file
	/*
	 * (1) If offset isn't aligned with the first block, Rd/Wr some content from offset to the end of the first block
	 *       NOTICE: useful function: sfs_bmap_load_nolock, sfs_buf_op
	 *               Rd/Wr size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset)
	 * (2) Rd/Wr aligned blocks 
	 *       NOTICE: useful function: sfs_bmap_load_nolock, sfs_block_op
     * (3) If end position isn't aligned with the last block, Rd/Wr some content from begin to the (endpos % SFS_BLKSIZE) of the last block
	 *       NOTICE: useful function: sfs_bmap_load_nolock, sfs_buf_op	
	*/
    // nblks：表示要操作的块的数量。
    // SFS_BLKSIZE：表示一个块的大小。
    // blkoff：表示在块内的偏移量。
    // endpos：表示操作的结束位置。
    // offset：表示操作的开始位置。
    // 非对齐的第一块
    if ((blkoff = offset % SFS_BLKSIZE) != 0|| endpos / SFS_BLKSIZE == offset / SFS_BLKSIZE)  {
        // 找到第一块中要读的大小
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
         // 将数据块对应到磁盘上的数据块的编号给ino
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) 
        {
            goto out;
        }

        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) 
        {
            goto out;
        }
        alen += size;
        if (nblks == 0)
        {
            goto out;
        }
        buf += size;
        blkno++;
        nblks--;
    }

    // 循环读取对齐的中间块
    size = SFS_BLKSIZE;
    while (nblks != 0) { 
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }

        // 完整块
        if ((ret = sfs_block_op(sfs, buf, ino, 1)) != 0) { 
            goto out;
        }
        alen += size, buf += size, blkno++, nblks--;
    }

    // 末尾没对齐，同上
    if ((size = endpos % SFS_BLKSIZE) != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {   
            goto out;
        }
        alen += size;
    }
    

out:
    *alenp = alen;
    if (offset + alen > sin->din->size) {
        sin->din->size = offset + alen;
        sin->dirty = 1;
    }
    return ret;
}
```
主要步骤：

- 根据偏移量计算读写结束位置（endpos）。
- 针对不同情况进行一系列合法性检查和处理。
- 根据读写类型（read/write）选择相应的操作函数指针。
- 通过循环和函数调用完成对不同块的读写操作,主要分成三部分，如果开始的偏移量不是块大小的整数倍，函数读取或写入第一个块的一部分，函数读取或写入一系列完整的块，如果结束位置不是块大小的整数倍，函数读取或写入最后一个块的一部分。


## 实验结果
![](1.png)

![](2.png)


## 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案
如果要在ucore里加入UNIX的管道（Pipe）机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个（或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

管道可以看作是由内核管理的一个缓冲区，一端连接进程A的输出，另一端连接进程B的输入。进程A会向管道中放入信息，而进程B会取出被放入管道的信息。当管道中没有信息，进程B会等待，直到进程A 放入信息。当管道被放满信息的时候，进程A会等待，直到进程B取出信息。当两个进程都结束的时候， 管道也自动消失。管道基于fork机制建立，从而让两个进程可以连接到同一个PIPE上。

基于此，我们可以模仿UNIX,设计一个PIPE机制：

+ 数据结构：可以在在磁盘上保留一定的区域用来作为PIPE机制的缓冲区，或者创建一个文件为PIPE机制服务
+ 初始化：对系统文件初始化时将PIPE也初始化并创建相应的inode 在内存中为PIPE留一块区域，以便高效完成缓存
+ 当两个进程要建立管道时，那么可以在这两个进程的进程控制块上新增变量来记录进程的这种属性，包括管道的文件描述符，方便读写。
+ 当其中一个进程要对数据进行写操作时，通过进程控制块的信息，可以将其先对临时文件PIPE进行修改。但当写满时，写操作被阻塞直到有足够的空间。
+ 当一个进行需要对数据进行读操作时，可以通过进程控制块的信息完成对临时文件PIPE的读取。但当PIPE文件为空，读操作阻塞直到有可用数据。
+ 管道的写/读都使用系统调用write()/read()
+ 由于管道是共享的，因此可能需要使用信号量或互斥锁等机制来保证多个进程之间的同步。例如，当一个进程向管道中写入数据时，应该确保在另一个进程读取数据之前，该数据不会被覆盖或修改。
