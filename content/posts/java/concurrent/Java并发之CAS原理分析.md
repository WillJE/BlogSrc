# Java并发之CAS原理分析

CAS（Compare-and-Swap），即比较并替换，是一种实现并发算法时常用到的技术，Java并发包中的很多类都使用了CAS技术。

## 什么是CAS
1. CAS(compare and swap) 比较并替换，比较和替换是线程并发算法时用到的一种技术
2. CAS是原子操作，保证并发安全，而不是保证并发同步
3. CAS是CPU的一个指令
4. CAS是非阻塞的、轻量级的乐观锁
## 为什么说CAS是乐观锁
乐观锁，严格来说并不是锁，通过原子性来保证数据的同步，比如说数据库的乐观锁，通过版本控制来实现等，所以CAS不会保证线程同步。乐观的认为在数据更新期间没有其他线程影响
## CAS原理
CAS(compare and swap) 比较并替换，就是将内存值更新为需要的值，但是有个条件，内存值必须与期望值相同。举个例子，期望值 E、内存值M、更新值U，当E == M的时候将M更新为U。
## CAS应用
由于CAS是CPU指令，我们只能通过JNI与操作系统交互，关于CAS的方法都在sun.misc包下Unsafe的类里
java.util.concurrent.atomic包下的原子类等通过CAS来实现原子操作。

## CAS举例-计数器
```java
public class CasLock {
    private static final CountDownLatch latch = new CountDownLatch(5);
    private static AtomicInteger i = new AtomicInteger(0);
    private static int p = 0;

    public static void main(String[] args) throws InterruptedException {
        long time = System.currentTimeMillis();
        ExecutorService pool = Executors.newFixedThreadPool(5);
        for(int j = 0; j < 5; j++) {
            pool.execute(new Runnable() {
                public void run() {
                    for(int k = 0; k < 10000; k++) {
                        p++;                //不是原子操作
                        i.getAndIncrement();//调用原子类加1
                    }
                    latch.countDown();
                }
            });
        }
        latch.await();//保证所有子线程执行完成
        System.out.println(System.currentTimeMillis() - time);
        System.out.println("p=" + p);
        System.out.println("i=" + i);
        pool.shutdown();
    }
}
```
输出结果
```shell
"C:\Program Files\Java\jdk1.8.0_91\bin\java" ...
8
p=43204//结果不正确
i=50000

Process finished with exit code 0
```

根据结果我们发现，由于多线程异步进行p++操作，导致结果不正确。

为什么p++的记过不正确呢？比如两个线程读到p的值为1，然后做加1操作，这时候p的值是2，而不是3 而变量i的结果却

是对的，这就要归功于CAS,下面我们具体看一下原子类。

### CAS指令和具体源代码
原子类例如AtomicInteger里的方法都很简单，大家看一看都能懂，我们具体看下getAndIncrement方法。下面贴出代码：
```java
//该方法功能是Interger类型加1
public final int getAndIncrement() {
		//主要看这个getAndAddInt方法
        return unsafe.getAndAddInt(this, valueOffset, 1);
    }

//var1 是this指针
//var2 是地址偏移量
//var4 是自增的数值，是自增1还是自增N
public final int getAndAddInt(Object var1, long var2, int var4) {
        int var5;
        do {
	        //获取内存值，这是内存值已经是旧的，假设我们称作期望值E
            var5 = this.getIntVolatile(var1, var2);
            //compareAndSwapInt方法是重点，
            //var5是期望值，var5 + var4是要更新的值
            //这个操作就是调用CAS的JNI,每个线程将自己内存里的内存值M
            //与var5期望值E作比较，如果相同将内存值M更新为var5 + var4,否则做自旋操作
        } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

        return var5;
    }
```
解释一下getAndAddInt方法的流程

假设有以下情景：
1. A、B两个线程
2. jvm主内存的值1，A、B工作内存的值为1（工作内存会拷贝一份主内存的值）
3. 当前期望值为1，做加1操作
4. 此时var5 = 1, var4 = 1,
    - A线程将var5与工作内存值M比较，比较var5是否等于1
    - 如果相同则将工作内存值修改为var5+var4 既修改为2并同步到主内存，此时this指针里，示例变量value的值就是2，结束循环
    - 如果不相同则其B线程修改了主内存的值，说明B线程已经先于A线程做了加1操作，A线程没有更新成功需要继续循环，注意此时var5更新为新的内存值，假设当前的内存值是2，那么此时var5 = 2， var5 + var4 = 3,重复上述步骤直到成功

下面是compareAndSwapInt本地方法的源码，可以看到使用cmpxchg指令实现CAS，在效率上有不错的表现。

```c
UNSAFE_ENTRY(jboolean, Unsafe_CompareAndSwapInt(JNIEnv *env, jobject unsafe, jobject obj, jlong offset, jint e, jint x))
  UnsafeWrapper("Unsafe_CompareAndSwapInt");
  oop p = JNIHandles::resolve(obj);
  jint* addr = (jint *) index_oop_from_field_offset_long(p, offset);
  return (jint)(Atomic::cmpxchg(x, addr, e)) == e;
UNSAFE_END
```

## CAS优缺点

### 优点

非阻塞的轻量级的乐观锁，通过CPU指令实现，在资源竞争不激烈的情况下性能高，相比synchronized重量锁，synchronized会进行比较复杂的加锁，解锁和唤醒操作。

### 缺点

**ABA问题**
线程C、D,线程D将A修改为B后又修改为A,此时C线程以为A没有改变过，java的原子类AtomicStampedReference，通过控制变量值的版本来保证CAS的正确性。

自旋时间过长，消耗CPU资源
如果资源竞争激烈，多线程自旋长时间消耗资源。

## CAS总结
CAS不仅是乐观锁，是种思想，我们也可以在日常项目中通过类似CAS的操作保证数据安全，但并不是所有场合都适合，曾看过帖子说，能用synchronized就不要用CAS，除非遇到性能瓶颈，因为CAS会让代码可读性变差，这句话看大家怎么理解了。