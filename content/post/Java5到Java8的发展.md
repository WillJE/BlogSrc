#  Java 5��Java8 �ķ�չ

## JDK 5

### **�Զ�װ�������**

JDK1.5 Ϊÿһ�������������Ͷ�����һ����װ�ࡣʹ java �еĻ�����������Ҳ���Լ��Ķ���

```java
int -->Integer
double --> Double
long --> Long
char --> Character
float --> Float
boolean --> Boolean
short --> Short
byte -- > Byte
```

- �Զ�װ��������������ת����Ϊ�������磺`int --> Integer`
- �Զ������������ת����Ϊ�����������ͣ����磺`Integer --> int`

���� JDK1.5 ֮ǰ�����ܲ��ܴ�Ż����������͵����⣬����Ҳ�ܹ������

### **ö��**

ö���� JDK1.5 �Ƴ���һ���Ƚ���Ҫ�����ԡ���ؼ���Ϊ `enum`
���磺�������ͨ�Ƶ�ö��

```java
public enum MyEnum{    
    RED,GREEN,YELLOW
}
```

### **��̬����**

- �ŵ㣺ʹ�þ�̬�������ʹ������������о�̬�����;�̬�����ڵ�ǰ��ֱ�ӿɼ���ʹ����Щ��̬��Ա�����ٸ������ǵ�������
- ȱ�㣺����ʹ�ûή�ʹ���Ŀɶ���

### **�ɱ����**

�� JDK1.5 ��ǰ��������ҪΪһ���������ݶ��������ͬ�Ĳ���ʱ��
���������ַ������

1. ֱ�Ӵ���һ�������ȥ
2. �ж��ٸ������ʹ��ݶ��ٸ�������

���磺

```java
public void printColor(String red,String green,String yellow){ 
}
```

����

```java
public void printColor(String[] colors){}
```

������д����������Ȼ�ܹ�ʵ��������Ҫ��Ч�������ǣ������ǲ����е��鷳�أ�
���ߣ��������������ȷ����������ô���أ�Java JDK1.5 Ϊ�����ṩ�Ŀɱ�������ܹ������Ľ���������.

���磺

```java
public void printColor(String... colors){}
```

���������������ͬ����ô����ʹ�� `����+������` �������һ���������Ƶ���ʽ��
�����ĺô����ǣ�ֻҪ����������ͬ�����۴��ݼ���������û������
ע�⣺�ɱ���������ǲ����б�����һ������ԶԶ���ͻ����������Ͷ����ã�

### **����**

```java
//������ָ���������ͣ�������������ڴ������ݵ�ʱ��������String���͵����ݣ�����������ᱨ��List<String> strs = new ArrayList<String>();
```

�����͡� ��ζ�ű�д�Ĵ�����Ա���ͬ���͵Ķ��������á�

�ɼ����͵������Ϊ�˱�д�����Ը��õĴ��롣

���͵ı����ǲ��������ͣ�Ҳ����˵���������������ͱ�ָ��Ϊһ��������

���糣���ļ����� `LinkedList`����ʵ�ֵĽӿ������и�����Ĳ��� `<>`���������ĳ�Ա������ Link Ҳ����һ�� `<>`��������ŵľ������Ͳ�������ʹ���������У�����һ�� LinkedList ʱ���Դ��벻ͬ�����ͣ����� `new LinkedList`���������ĳ�Ա��ŵ�����Ҳ�� `String`��

### **For-Each ѭ��**

������������������ǿ���ͨ�� for-each �������������Ӽ�������

```java
for(String s : strs){      
    System.out.println(s); 
}
```

> ע�⣺ʹ�� for-each ��������ʱ��Ҫ�����ļ��ϱ���ʵ���� Iterator �ӿ�

### **�̲߳�����**

�̲߳������� Java1.5 ����Ĺ��ڶ��̴߳���ĸ߼����ܣ����ڰ���`java.util.concurrent` ����

1. �̻߳��⹤���ࣺ`Lock`��`ReadWriteLock`
2. �߳�ͨ�ţ�`Condition`
3. �̳߳أ�`ExecutorService`
4. ͬ�����У�`ArrayBlockingQueue`
5. ͬ�����ϣ�`ConcurrentHashMap`��`CopyOnWriteArrayList`
6. �߳�ͬ�����ߣ�`Semaphore`

## JDK 6

### **Desktop ��� SystemTray ��**

ǰ�߿���������ϵͳĬ����������ָ���� URL����ϵͳĬ���ʼ��ͻ��˸�ָ�������䷢�ʼ�����Ĭ��Ӧ�ó���򿪻�༭�ļ� (���磬�ü��±����� txt Ϊ��׺�����ļ�)����ϵͳĬ�ϵĴ�ӡ����ӡ�ĵ������߿���������ϵͳ����������һ�����̳���

### **ʹ�� Compiler API**

�������ǿ����� JDK1.6 �� Compiler API(JSR 199) ȥ��̬���� Java Դ�ļ���Compiler API ��Ϸ��书�ܾͿ���ʵ�ֶ�̬�Ĳ��� Java ���벢����ִ����Щ���룬�е㶯̬���Ե�������

������Զ���ĳЩ��Ҫ�õ���̬�����Ӧ�ó����൱���ã����� JSP Web Server���������ֶ��޸� JSP ���ǲ�ϣ����Ҫ���� Web Server �ſ��Կ���Ч���ģ���ʱ�����ǾͿ����� Compiler API ��ʵ�ֶ�̬���� JSP �ļ���

��Ȼ�����ڵ� JSP Web Server Ҳ��֧�� JSP �Ȳ���ģ����ڵ� JSP Web Server ͨ���������ڼ�ͨ�� Runtime.exec �� ProcessBuilder ������ javac ��������룬���ַ�ʽ��Ҫ���ǲ�����һ������ȥ�����빤�����������Ŷ�������ʹ�����������ض��Ĳ���ϵͳ��

Compiler API ͨ��һ�����õı�׼�� API �ṩ�˸��ӷḻ�ķ�ʽȥ����̬���룬�����ǿ�ƽ̨�ġ�

### **������ Http Server API**

JDK1.6 �ṩ��һ���򵥵� Http Server API���ݴ����ǿ��Թ����Լ���Ƕ��ʽ Http Server����֧�� Http �� Https Э�飬�ṩ�� HTTP1.1 �Ĳ���ʵ�֣�û�б�ʵ�ֵ��ǲ��ֿ���ͨ����չ���е� Http Server API ��ʵ�֣�����Ա�����Լ�ʵ�� HttpHandler �ӿڣ�HttpServer ����� `HttpHandler` ʵ����Ļص�����������ͻ���������������ǰ�һ�� Http �����������Ӧ��Ϊһ����������װ�� `HttpExchange` �࣬`HttpServer` ���� `HttpExchange` ���� `HttpHandler` ʵ����Ļص�������

### **�� Console ��������̨����**

JDK1.6 ���ṩ�� `java.io.Console` ��ר�������ʻ����ַ��Ŀ���̨�豸��
��ĳ������Ҫ�� Windows �µ� cmd ���� Linux �µ� Terminal �������Ϳ����� `Console` ����͡�
�����ǲ������ܵõ����õ� Console��һ�� JVM �Ƿ��п��õ� Console �����ڵײ�ƽ̨�� JVM ��α����á�
��� JVM ���ڽ���ʽ������ (���� Windows �� cmd) �������ģ������������û���ض�������ĵط�����ô�Ϳ��Եõ�һ�����õ� Console ʵ����

### **�Խű����Ե�֧��**

�磺ruby��groovy��javascript��

## JDK 7

### **���ֱ������»��ߵ�֧��**

JDK1.7 ��������ֵ���͵ı���������»��ߡ�

���磺

```java
int num = 1234_5678_9; 
float num2 = 222_33F; 
long num3 = 123_000_111L;
```

ע�⣬�м����ط��ǲ�����ӵģ�

1. ���ֵĿ�ͷ�ͽ�β
2. С����ǰ��
3. F ���� L ǰ

**switch �� String ��֧��**

```java
String status = "orderState";     
switch (status) {   
    case "ordercancel":   
        System.out.println("����ȡ��");   
        break;   
    case "orderSuccess":   
        System.out.println("Ԥ���ɹ�");   
        break;   
    default:   
        System.out.println("״̬δ֪");   
}
```

### **try-with-resource**

- `try-with-resources` ��һ��������һ��������Դ�� try �����������Դ��ָ����������֮����Ҫ�ر����Ķ���
- `try-with-resources` ȷ��ÿһ����Դ�ڴ�����ɺ󶼻ᱻ�رա�

����ʹ�� try-with-resources ����Դ�У� �κ�ʵ���� `java.lang.AutoCloseable` �ӿ� `java.io.Closeable` �ӿڵĶ���

���磺

```java
public static String readFirstLineFromFile(String path) throws IOException {   

    try (BufferedReader br = new BufferedReader(new FileReader(path))) {   
        return br.readLine();   
    }   
}
```

�� java 7 �Լ��Ժ�İ汾�`BufferedReader` ʵ���� `java.lang.AutoCloseable` �ӿڡ�
���� `BufferedReader` ������ `try-with-resources` ��������� `try` ������������쳣�Ľ�����
�������Զ��Ĺص������� java7 ��ǰ������Ҫʹ�� `finally` �����ص��������

**��������쳣���øĽ�������ͼ���������׳��쳣**

```java
public static void first(){   
    try {   
        BufferedReader reader = new BufferedReader(new FileReader(""));   
        Connection con = null;   
        Statement stmt = con.createStatement();   
    } catch (IOException | SQLException e) {   
        //�������쳣��e����final���͵�   
        e.printStackTrace();   
    }   
}
```

�ŵ㣺��һ�� `catch` �������쳣�����ö�� `catch` ÿ������һ���쳣���ɵ��ֽ���Ҫ��С����Ч��

### **��������ʱ�����ƶ�**

ֻҪ���������Դ����������ƶϳ����Ͳ�������Ϳ�����һ�Կ��ŵļ����� `<>` �����淺�Ͳ�����
�������˽�±���Ϊ���� (diamond)�� �� Java SE 7 ֮ǰ�����������Ͷ���ʱҪ����

```java
List<String> list = new ArrayList<String>();
```

���� Java SE7 �Ժ����������

```java
List<String> list = new ArrayList<>();
```

��Ϊ���������Դ�ǰ�� (List) �ƶϳ��ƶϳ����Ͳ��������Ժ���� `ArrayList` ֮����Բ���д���Ͳ����ˣ�ֻ��һ�Կ��ŵļ����ž��С�
��Ȼ�������������� `<>`��������о���ġ�
Java SE7 ֻ֧�����޵������ƶϣ�ֻ�й������Ĳ������������������б������������ˣ���ſ���ʹ�������ƶϣ������С�

```java
List<String> list = new ArrayList<>();
list.add("A"); 
//������� 
list.addAll(new ArrayList<>()); 
// ������� 
List<? extends String> list2 = new ArrayList<>(); 
list.addAll(list2);
```

## JDK 8

### **Lambda ���ʽ�ͺ���ʽ�ӿ�**

Lambda ���ʽ��Ҳ��Ϊ�հ����� Java 8 �������������ڴ������Ըı䡣���������ǽ��������ɲ������ݸ�ĳ�����������߰Ѵ��뱾�������ݴ�������ʽ�����߷ǳ���Ϥ��Щ����ܶ� JVM ƽ̨�ϵ����ԣ�Groovy��Scala �ȣ��ӵ���֮�վ�֧�� Lambda ���ʽ������ Java ������û��ѡ��ֻ��ʹ�������ڲ������ Lambda ���ʽ��

Lambda ����ƺķ��˺ܶ�ʱ��ͺܴ�����������������ҵ�һ�����е�ʵ�ַ���������ʵ�ּ������յ����Խṹ����򵥵� Lambda ���ʽ���ɶ��ŷָ��Ĳ����б�-> ���ź�������ɡ�

Lambda ���������Ϊ�������еĹ����� Lambda ���ʽ���ü��ݣ������˺ܶ෽�������ǲ����˺����ӿ������������ӿ�ָ����ֻ��һ�������Ľӿڣ������Ľӿڿ�����ʽת��Ϊ Lambda ���ʽ��java.lang.Runnable ��java.util.concurrent.Callable �Ǻ���ʽ�ӿڵ�������ӡ���ʵ���У�����ʽ�ӿڷǳ�������ֻҪĳ���������ڸýӿ������һ����������ýӿھͲ����Ǻ���ʽ�ӿڽ������±���ʧ�ܡ�Ϊ�˿˷����ִ������Ĵ����ԣ�����ʽ˵��ĳ���ӿ��Ǻ���ʽ�ӿڣ�Java 8 �ṩ��һ�������ע�� @FunctionalInterface��Java ���е�������ؽӿڶ��Ѿ��������ע���ˣ���

### **�ӿڵ�Ĭ�Ϸ����;�̬����**

Java 8 ʹ�������¸�����չ�˽ӿڵĺ��壺Ĭ�Ϸ����;�̬������Ĭ�Ϸ���ʹ�ýӿ��е����� traits������Ҫʵ�ֵ�Ŀ�겻һ����Ĭ�Ϸ���ʹ�ÿ����߿����� ���ƻ������Ƽ����Ե�ǰ���£����ִ�ӿ�������µķ���������ǿ����Щʵ���˸ýӿڵ���Ҳͬʱʵ������¼ӵķ�����

Ĭ�Ϸ����ͳ��󷽷�֮����������ڳ��󷽷���Ҫʵ�֣���Ĭ�Ϸ�������Ҫ���ӿ��ṩ��Ĭ�Ϸ����ᱻ�ӿڵ�ʵ����̳л��߸�д��

���� JVM �ϵ�Ĭ�Ϸ�����ʵ�����ֽ�������ṩ��֧�֣����Ч�ʷǳ��ߡ�Ĭ�Ϸ��������ڲ��������м̳���ϵ�Ļ����ϸĽ��ӿڡ��������ڹٷ����е�Ӧ���ǣ��� java.util.Collection �ӿ�����·������� stream()��parallelStream()��forEach() �� removeIf() �ȵȡ�

����Ĭ�Ϸ�������ô��ô�������ʵ�ʿ�����Ӧ�ý���ʹ�ã��ڸ��ӵļ̳���ϵ�У�Ĭ�Ϸ���������������ͱ������������˽����ϸ�ڣ����Բο��ٷ��ĵ���

### **���õ������ƶ�**

Java 8 �������������ƶϷ����кܴ���������ںܶೡ���±����������Ƶ���ĳ���������������ͣ��Ӷ�ʹ�ô����Ϊ��ࡣ

���� `Value.defaultValue()` �������ɱ������Ƶ��ó�������Ҫ��ʽָ������ Java 7 ����δ�����б�����󣬳���ʹ�� `Value.defaultValue()`��

### **Optional**

Java Ӧ��������� bug ���ǿ�ָ���쳣���� Java 8 ֮ǰ��Google Guava ������ `Optionals` ������� `NullPointerException`���Ӷ�����Դ�뱻���� `null` �����Ⱦ���Ա㿪����д����������Ĵ��롣Java 8 Ҳ�� Optional �����˹ٷ��⡣
`Optional` ������һ�����״�� T ���͵�ֵ���� null�����ṩ��һЩ���õĽӿ���������ʽ�� null ��飬���Բο� Java 8 �ٷ��ĵ��˽����ϸ�ڡ�

��� Optional ʵ������һ���ǿ�ֵ���� `isPresent()` �������� true�����򷵻� false��`orElseGet()` ������Optional ʵ������ null������Խ���һ�� lambda ���ʽ���ɵ�Ĭ��ֵ��map() �������Խ����е� `Optional` ʵ����ֵת�����µ�ֵ��orElse() ������ orElseGet() �������ƣ������ڳ��� null ��ʱ�򷵻ش����Ĭ��ֵ��

### **Stream**

������ Stream API��java.util.stream�������ɻ����ĺ���ʽ��������� Java ���С�����ĿǰΪֹ����һ�ζ� Java ������ƣ��Ա㿪�����ܹ�д��������Ч�����Ӽ��ͽ��յĴ��롣

Task ����һ����������α���Ӷȣ��ĸ�����⻹������״̬��OPEN ���� CLOSED�����ڼ�����һ�� task ���ϣ����ȿ�һ�����⣺����� task ������һ���ж��ٸ� OPEN ״̬�ĵ㣿

�� Java 8 ֮ǰ��Ҫ���������⣬����Ҫʹ�� foreach ѭ������ task ���ϣ������� Java 8 �п������� steams ���������һϵ��Ԫ�ص��б�����֧��˳��Ͳ��д���

```java
final Collection<Task> tasks = Arrays.asList(
        new Task(Status.OPEN, 5),
        new Task(Status.OPEN, 13),
        new Task(Status.CLOSED, 8)
);

// ʹ��sum()�������� OPEN ����
final long totalPointsOfOpenTasks = tasks
        .stream()
        .filter(task -> task.getStatus() == Status.OPEN)
        .mapToInt(Task::getPoints)
        .sum();

System.out.println("Total points: " + totalPointsOfOpenTasks);
```

���ȣ�tasks ���ϱ�ת���� steam ��ʾ����Σ��� steam �ϵ� filter ��������˵����� CLOSED �� task��������mapToInt ��������ÿ�� task ʵ����`Task::getPoints`������ task ��ת���� Integer ���ϣ����ͨ�� sum ���������ܺͣ��ó����Ľ����

### **�µ�����ʱ�� API**

Java 8 �������µ� Date-Time API(JSR 310) ���Ľ�ʱ�䡢���ڵĴ���ʱ������ڵĹ���һֱ������ Java ������ʹ������⡣java.util.Date �ͺ����� java.util.Calendar һֱû�н��������⣨��������߸�����ã������Ϊ������Щԭ�򣬵����˵������� Joda-Time��������� Java ��ʱ����� API��

Java 8 ���µ�ʱ������ڹ��� API ���� Joda-Time Ӱ�죬�������˺ܶ� Joda-Time �ľ�����

��һ���µ� java.time �����������й������ڡ�ʱ�䡢ʱ����Instant�����������Ƶ��Ǿ�ȷ�����룩��duration������ʱ�䣩��ʱ�Ӳ������ࡣ����Ƶ� API ���濼������Щ��Ĳ����ԣ��� java.util.Calendar ��ȡ�Ľ�ѵ�������ĳ��ʵ����Ҫ�޸ģ��򷵻�һ���µĶ���

�ڶ�����ע�� LocalDate �� LocalTime �ࡣLocalDate �������� ISO-8601 ����ϵͳ�е����ڲ��֣�LocalTime ���������������ϵͳ�е�ʱ�䲿�֡���������Ķ��󶼿���ʹ�� Clock ���󹹽��õ���

������LocalDateTime ������� LocalDate �� LocalTime ����Ϣ�����ǲ����� ISO-8601 ����ϵͳ�е�ʱ����Ϣ��������һЩ���� LocalDate �� LocalTime �����ӣ�

�������Ҫ�ض�ʱ���� data/time ��Ϣ�������ʹ�� ZoneDateTime���������� ISO-8601 ����ϵͳ�����ں�ʱ�䣬������ʱ����Ϣ��

### **Nashorn JavaScript ����**

Java 8 �ṩ���µ� Nashorn JavaScript ���棬ʹ�����ǿ����� JVM �Ͽ��������� JS Ӧ�á�
Nashorn JavaScript ������ javax.script.ScriptEngine ����һ��ʵ�ְ汾������ Script ������ѭ��ͬ�Ĺ������� Java �� JavaScript ����ʹ�á�

### **Base64**

�� Base64 �����֧���Ѿ������뵽 Java 8 �ٷ����У���������Ҫʹ�õ�������Ϳ��Խ��� Base64 ���롣

>��ӭת�أ�ת����ע�������� 
�����������ͣ�flywill.com
��ӭ��ע����΢�źţ�JavaС��V
�����Լ���ѧϰ & ѧϰ���� & ����
��Ҫ����������Ҳ���Լ�΢�źű�ע��Ⱥ��EscUpDn