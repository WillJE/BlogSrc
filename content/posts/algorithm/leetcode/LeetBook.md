https://leetcode-cn.com/leetbook/read/tencent/xxst6e/

## 数组与字符串

### [1. 两数之和](https://leetcode-cn.com/problems/two-sum)

给定一个整数数组 nums 和一个整数目标值 target，请你在该数组中找出 和为目标值 target  的那 两个 整数，并返回它们的数组下标。

你可以假设每种输入只会对应一个答案。但是，数组中同一个元素在答案里不能重复出现。

你可以按任意顺序返回答案。

```go
func twoSum(nums []int, target int) []int {
    hashTable := map[int]int{}
    for i, x := range nums {
        if p, ok := hashTable[target-x]; ok {
            return []int{p, i}
        }
        hashTable[x] = i
    }
    return nil
}
```

### [4. 寻找两个正序数组的中位数](https://leetcode-cn.com/problems/median-of-two-sorted-arrays)

### [5. 最长回文子串](https://leetcode-cn.com/problems/longest-palindromic-substring)

给你一个字符串 `s`，找到 `s` 中最长的回文子串。

动态规划：

```java
public class Solution {

    public String longestPalindrome(String s) {
        int len = s.length();
        if (len < 2) {
            return s;
        }

        int maxLen = 1;
        int begin = 0;
        // dp[i][j] 表示 s[i..j] 是否是回文串
        boolean[][] dp = new boolean[len][len];
        // 初始化：所有长度为 1 的子串都是回文串
        for (int i = 0; i < len; i++) {
            dp[i][i] = true;
        }

        char[] charArray = s.toCharArray();
        // 递推开始
        // 先枚举子串长度
        for (int L = 2; L <= len; L++) {
            // 枚举左边界，左边界的上限设置可以宽松一些
            for (int i = 0; i < len; i++) {
                // 由 L 和 i 可以确定右边界，即 j - i + 1 = L 得
                int j = L + i - 1;
                // 如果右边界越界，就可以退出当前循环
                if (j >= len) {
                    break;
                }

                if (charArray[i] != charArray[j]) {
                    dp[i][j] = false;
                } else {
                    if (j - i < 3) {
                        dp[i][j] = true;
                    } else {
                        dp[i][j] = dp[i + 1][j - 1];
                    }
                }

                // 只要 dp[i][L] == true 成立，就表示子串 s[i..L] 是回文，此时记录回文长度和起始位置
                if (dp[i][j] && j - i + 1 > maxLen) {
                    maxLen = j - i + 1;
                    begin = i;
                }
            }
        }
        return s.substring(begin, begin + maxLen);
    }
}
```

### [409. 最长回文串](https://leetcode-cn.com/problems/longest-palindrome)


给定一个包含大写字母和小写字母的字符串，找到通过这些字母构造成的最长的回文串。

在构造过程中，请注意区分大小写。比如 `"Aa"` 不能当做一个回文字符串。

- 哈希表统计字符个数
- res = 尽可能多的偶数个字符 + 1，如果有奇数个字符的就加1

```java
public int longestPalindrome(String s) {
    Map<Character, Integer> map = new HashMap<>();
    for (char c : s.toCharArray()) {
        map.put(c, map.getOrDefault(c, 0) + 1);
    }
    int len = 0;
    boolean hasOne = false;
    for (int v : map.values()) {
        int y = v % 2;
        len += (v - y);
        if (!hasOne && y == 1) {
            hasOne = true;
            len ++;
        }
    }
    return len;
}
```

### [15. 三数之和](https://leetcode-cn.com/problems/3sum)

给你一个包含 n 个整数的数组 nums，判断 nums 中是否存在三个元素 a，b，c ，使得 a + b + c = 0 ？请你找出所有和为 0 且不重复的三元组。

注意：答案中不可以包含重复的三元组。



1. 特判，对于数组长度 n，如果数组为 null或者数组长度小于 3，返回 [][]。
2. 对数组进行排序。
3. 遍历排序后数组：
   1. 若 nums[i]>0nums[i]>0：因为已经排序好，所以后面不可能有三个数加和等于 0，直接返回结果。
   2. 对于重复元素：跳过，避免出现重复解
   3. 令左指针 L=i+1，右指针 R=n-1，当 L<R 时，执行循环：
      1. 当 nums[i]+nums[L]+nums[R]==0，执行循环，判断左界和右界是否和下一位置重复，去除重复解。并同时将 L,R 移到下一位置，寻找新的解
      2. 若和大于 0，说明 nums[R] 太大，R 左移
      3. 若和小于 0，说明 nums[L] 太小，L 右移

```java
    public List<List<Integer>> threeSum(int[] nums) {
        List<List<Integer>> lists = new ArrayList<>();
        //排序
        Arrays.sort(nums);
        //双指针
        int len = nums.length;
        for(int i = 0;i < len;++i) {
            if(nums[i] > 0) return lists;

            if(i > 0 && nums[i] == nums[i-1]) continue;

            int curr = nums[i];
            int L = i+1, R = len-1;
            while (L < R) {
                int tmp = curr + nums[L] + nums[R];
                if(tmp == 0) {
                    List<Integer> list = new ArrayList<>();
                    list.add(curr);
                    list.add(nums[L]);
                    list.add(nums[R]);
                    lists.add(list);
                    while(L < R && nums[L+1] == nums[L]) ++L;
                    while (L < R && nums[R-1] == nums[R]) --R;
                    ++L;
                    --R;
                } else if(tmp < 0) {
                    ++L;
                } else {
                    --R;
                }
            }
        }
        return lists;
    }
```

### [16. 最接近的三数之和](https://leetcode-cn.com/problems/3sum-closest)

给定一个包括 n 个整数的数组 nums 和 一个目标值 target。找出 nums 中的三个整数，使得它们的和与 target 最接近。返回这三个数的和。假定每组输入只存在唯一答案。

```java
class Solution {
    public int threeSumClosest(int[] nums, int target) {
        Arrays.sort(nums);
        int ans = nums[0] + nums[1] + nums[2];
        for(int i=0;i<nums.length;i++) {
            int start = i+1, end = nums.length - 1;
            while(start < end) {
                int sum = nums[start] + nums[end] + nums[i];
                if(Math.abs(target - sum) < Math.abs(target - ans))
                    ans = sum;
                if(sum > target)
                    end--;
                else if(sum < target)
                    start++;
                else
                    return ans;
            }
        }
        return ans;
    }
}
```

### [11. 盛最多水的容器](https://leetcode-cn.com/problems/container-with-most-water/) 

给你 n 个非负整数 a1，a2，...，an，每个数代表坐标中的一个点 (i, ai) 。在坐标内画 n 条垂直线，垂直线 i 的两个端点分别为 (i, ai) 和 (i, 0) 。找出其中的两条线，使得它们与 x 轴共同构成的容器可以容纳最多的水。

```java
public class Solution {
    public int maxArea(int[] height) {
        int l = 0, r = height.length - 1;
        int ans = 0;
        while (l < r) {
            int area = Math.min(height[l], height[r]) * (r - l);
            ans = Math.max(ans, area);
            if (height[l] <= height[r]) {
                ++l;
            }
            else {
                --r;
            }
        }
        return ans;
    }
}
```



### [20. 有效的括号](https://leetcode-cn.com/problems/valid-parentheses)

给定一个只包括 '('，')'，'{'，'}'，'['，']' 的字符串 s ，判断字符串是否有效。

有效字符串需满足：

左括号必须用相同类型的右括号闭合。
左括号必须以正确的顺序闭合。

```java
public boolean isValid(String s) {
    if(s.isEmpty())
        return true;
    Stack<Character> stack=new Stack<Character>();
    for(char c:s.toCharArray()){
        if(c=='(')
            stack.push(')');
        else if(c=='{')
            stack.push('}');
        else if(c=='[')
            stack.push(']');
        else if(stack.empty()||c!=stack.pop())
            return false;
    }
    if(stack.empty())
        return true;
    return false;
}
```



### [26. 删除有序数组中的重复项](https://leetcode-cn.com/problems/remove-duplicates-from-sorted-array)

给你一个有序数组 nums ，请你 **原地** 删除重复出现的元素，使每个元素 只出现一次 ，返回删除后数组的新长度。

不要使用额外的数组空间，你必须在 原地 修改输入数组 并在使用 O(1) 额外空间的条件下完成。

双指针

```java
class Solution {
    public int removeDuplicates(int[] nums) {
        int n = nums.length;
        if (n == 0) {
            return 0;
        }
        int fast = 1, slow = 1;
        while (fast < n) {
            if (nums[fast] != nums[fast - 1]) {
                nums[slow] = nums[fast];
                ++slow;
            }
            ++fast;
        }
        return slow;
    }
}
```

### [43. 字符串相乘](https://leetcode-cn.com/problems/multiply-strings)

给定两个以字符串形式表示的非负整数 `num1` 和 `num2`，返回 `num1` 和 `num2` 的乘积，它们的乘积也表示为字符串形式。

先分开相乘，再相加，就是 [415. 字符串相加](https://leetcode-cn.com/problems/add-strings/)。

```java
class Solution {
    /**
    * 计算形式
    *    num1
    *  x num2
    *  ------
    *  result
    */
    public String multiply(String num1, String num2) {
        if (num1.equals("0") || num2.equals("0")) {
            return "0";
        }
        // 保存计算结果
        String res = "0";
        
        // num2 逐位与 num1 相乘
        for (int i = num2.length() - 1; i >= 0; i--) {
            int carry = 0;
            // 保存 num2 第i位数字与 num1 相乘的结果
            StringBuilder temp = new StringBuilder();
            // 补 0 
            for (int j = 0; j < num2.length() - 1 - i; j++) {
                temp.append(0);
            }
            int n2 = num2.charAt(i) - '0';
            
            // num2 的第 i 位数字 n2 与 num1 相乘
            for (int j = num1.length() - 1; j >= 0 || carry != 0; j--) {
                int n1 = j < 0 ? 0 : num1.charAt(j) - '0';
                int product = (n1 * n2 + carry) % 10;
                temp.append(product);
                carry = (n1 * n2 + carry) / 10;
            }
            // 将当前结果与新计算的结果求和作为新的结果
            res = addStrings(res, temp.reverse().toString());
        }
        return res;
    }

    /**
     * 对两个字符串数字进行相加，返回字符串形式的和
     */
    public String addStrings(String num1, String num2) {
        StringBuilder builder = new StringBuilder();
        int carry = 0;
        for (int i = num1.length() - 1, j = num2.length() - 1;
             i >= 0 || j >= 0 || carry != 0;
             i--, j--) {
            int x = i < 0 ? 0 : num1.charAt(i) - '0';
            int y = j < 0 ? 0 : num2.charAt(j) - '0';
            int sum = (x + y + carry) % 10;
            builder.append(sum);
            carry = (x + y + carry) / 10;
        }
        return builder.reverse().toString();
    }
}
```

###  [415. 字符串相加](https://leetcode-cn.com/problems/add-strings/)

```java
class Solution {
    public String addStrings(String num1, String num2) {
        int i = num1.length() - 1, j = num2.length() - 1, add = 0;
        StringBuffer ans = new StringBuffer();
        while (i >= 0 || j >= 0 || add != 0) {
            int x = i >= 0 ? num1.charAt(i) - '0' : 0;
            int y = j >= 0 ? num2.charAt(j) - '0' : 0;
            int result = x + y + add;
            ans.append(result % 10);
            add = result / 10;
            i--;
            j--;
        }
        // 计算完以后的答案需要翻转过来
        ans.reverse();
        return ans.toString();
    }
}
```

### [344. 反转字符串](https://leetcode-cn.com/problems/reverse-string)

```java
class Solution {
    public void reverseString(char[] s) {
        int n = s.length;
        for (int left = 0, right = n - 1; left < right; ++left, --right) {
            char tmp = s[left];
            s[left] = s[right];
            s[right] = tmp;
        }
    }
}
```

go
```go
func reverseString(s []byte) {
    for left, right := 0, len(s)-1; left < right; left++ {
        s[left], s[right] = s[right], s[left]
        right--
    }
}
```

### [541. 反转字符串 II](https://leetcode-cn.com/problems/reverse-string-ii)

给定一个字符串 `s` 和一个整数 `k`，从字符串开头算起，每 `2k` 个字符反转前 `k` 个字符。

- 如果剩余字符少于 `k` 个，则将剩余字符全部反转。
- 如果剩余字符小于 `2k` 但大于或等于 `k` 个，则反转前 `k` 个字符，其余字符保持原样。

```
输入：s = "abcdefg", k = 2
输出："bacdfeg"
```

```java
class Solution {
    public String reverseStr(String s, int k) {
        char[] a = s.toCharArray();
        for (int start = 0; start < a.length; start += 2 * k) {
            int i = start, j = Math.min(start + k - 1, a.length - 1);
            while (i < j) {
                char tmp = a[i];
                a[i++] = a[j];
                a[j--] = tmp;
            }
        }
        return new String(a);
    }
}
```

``j = Math.min(start + k - 1, a.length - 1)``解释一下：

特别的，是因为start从0开始，然后每次都以2k为基准增加，也就是说start都是字符串需要反转的开始位置的下标，比如start = 0， start = 2 * k，start = 4 * k这些位置开始都是字符串将要反转的开始位置，既然找到了反转开始肯定要要找到每次的反转结尾，因为判断结尾有两种情况，第一就是能反转k个，这个的前提是从start开始其后面的字符串长度足够长的时候，第二种情况就是能反转的小于k个了，也就是说字符串剩下的部分小于k了，就是从start开始只能取到s.length() - 1这么长了，由此可得指定字符串反转结尾的指针j = Math.min(start + k - 1, s.length() - 1);

### [557. 反转字符串中的单词 III](https://leetcode-cn.com/problems/reverse-words-in-a-string-iii)

```java
    public String reverseWords(String s) {
        StringBuffer ret = new StringBuffer();
        int length = s.length();
        int i = 0;
        while (i < length) {
            int start = i;
            while (i < length && s.charAt(i) != ' ') {
                i++;
            }
            for (int p = start; p < i; p++) {
                ret.append(s.charAt(start + i - 1 - p));
            }
            while (i < length && s.charAt(i) == ' ') {
                i++;
                ret.append(' ');
            }
        }
        return ret.toString();
    }
```

### [238. 除自身以外数组的乘积](https://leetcode-cn.com/problems/product-of-array-except-self)

给你一个长度为 n 的整数数组 nums，其中 n > 1，返回输出数组 output ，其中 output[i] 等于 nums 中除 nums[i] 之外其余各元素的乘积。

示例:

```
输入: [1,2,3,4]
输出: [24,12,8,6]
```

```java
class Solution {
    public int[] productExceptSelf(int[] nums) {
        int length = nums.length;

        // L 和 R 分别表示左右两侧的乘积列表
        int[] L = new int[length];
        int[] R = new int[length];

        int[] answer = new int[length];

        // L[i] 为索引 i 左侧所有元素的乘积
        // 对于索引为 '0' 的元素，因为左侧没有元素，所以 L[0] = 1
        L[0] = 1;
        for (int i = 1; i < length; i++) {
            L[i] = nums[i - 1] * L[i - 1];
        }

        // R[i] 为索引 i 右侧所有元素的乘积
        // 对于索引为 'length-1' 的元素，因为右侧没有元素，所以 R[length-1] = 1
        R[length - 1] = 1;
        for (int i = length - 2; i >= 0; i--) {
            R[i] = nums[i + 1] * R[i + 1];
        }

        // 对于索引 i，除 nums[i] 之外其余各元素的乘积就是左侧所有元素的乘积乘以右侧所有元素的乘积
        for (int i = 0; i < length; i++) {
            answer[i] = L[i] * R[i];
        }

        return answer;
    }
}
```

### [217. 存在重复元素](https://leetcode-cn.com/problems/contains-duplicate)

给定一个整数数组，判断是否存在重复元素。

如果存在一值在数组中出现至少两次，函数返回 `true` 。如果数组中每个元素都不相同，则返回 `false` 。

```java
class Solution {
    public boolean containsDuplicate(int[] nums) {
        Set<Integer> set = new HashSet<Integer>();
        for (int x : nums) {
            if (!set.add(x)) {
                return true;
            }
        }
        return false;
    }
}
```

### [219. 存在重复元素 II](https://leetcode-cn.com/problems/contains-duplicate-ii)

给定一个整数数组和一个整数 k，判断数组中是否存在两个不同的索引 i 和 j，使得 nums [i] = nums [j]，并且 i 和 j 的差的 绝对值 至多为 k。

**示例 1:**

```
输入: nums = [1,2,3,1], k = 3
输出: true
```

```java
public boolean containsNearbyDuplicate(int[] nums, int k) {
    Set<Integer> set = new HashSet<>();
    for (int i = 0; i < nums.length; ++i) {
        if (set.contains(nums[i])) return true;
        set.add(nums[i]);
        if (set.size() > k) {
            set.remove(nums[i - k]);
        }
    }
    return false;
}
```

**思路**

这个类似维护了一个K大小的滑动窗口，然后在这个窗口里搜索是否存在跟当前元素相等的元素；
- 标签：哈希
- 维护一个哈希表，里面始终最多包含 k 个元素，当出现重复值时则说明在 k 距离内存在重复元素
- 每次遍历一个元素则将其加入哈希表中，如果哈希表的大小大于 k，则移除最前面的数字
- 时间复杂度：O(n)，n 为数组长度

### [220. 存在重复元素 III](https://leetcode-cn.com/problems/contains-duplicate-iii)

给你一个整数数组 nums 和两个整数 k 和 t 。请你判断是否存在 两个不同下标 i 和 j，使得 abs(nums[i] - nums[j]) <= t ，同时又满足 abs(i - j) <= k 。

如果存在则返回 true，不存在返回 false。

示例 1：

```
输入：nums = [1,2,3,1], k = 3, t = 0
输出：true
```

### [54. 螺旋矩阵](https://leetcode-cn.com/problems/spiral-matrix)

给你一个 `m` 行 `n` 列的矩阵 `matrix` ，请按照 **顺时针螺旋顺序** ，返回矩阵中的所有元素。

```
输入：matrix = [[1,2,3],[4,5,6],[7,8,9]]
输出：[1,2,3,6,9,8,7,4,5]
```

```java
public  List<Integer> spiralOrder(int[][] matrix) {
        int m=matrix.length; //纵向长度
        int n=matrix[0].length;//横向长度
        List<Integer> order = new ArrayList<Integer>();
        //边界
        int left =0;
        int right=n-1;
        int top=0;
        int bottom=m-1;
        //方向
        int cur_d=0;    //0右  1下  2左  3上
        int [][] dirs = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};  //移动方向对应的数据加减
        //目前位置下标
        int x=0,y=0;  //x为纵 y为横
        //arr数组存放标记
        int i=0;

        while(order.size()!=m*n){
            order.add(matrix[x][y]);
            i++;
            if(cur_d==0 && y==right){  //到达右边界
                cur_d++;
                top++;
            }else if(cur_d==1 && x==bottom){   //到达下边界
                cur_d++;
                right--;
            }else if(cur_d==2 && y==left){  //到达左边界
                cur_d++;
                bottom--;
            }else if(cur_d==3 && x==top){   //到达上边界
                cur_d++;
                left++;
            }
            cur_d %=4;
            x+=dirs[cur_d][0];
            y+=dirs[cur_d][1];
        }
        return  order;
    }
```

### [59. 螺旋矩阵 II](https://leetcode-cn.com/problems/spiral-matrix-ii)

给你一个正整数 `n` ，生成一个包含 `1` 到 `n2` 所有元素，且元素按顺时针顺序螺旋排列的 `n x n` 正方形矩阵 `matrix` 。

这个相当于[54. 螺旋矩阵](https://leetcode-cn.com/problems/spiral-matrix)的逆过程。

```java
class Solution {
    public int[][] generateMatrix(int n) {
        int l = 0, r = n - 1, t = 0, b = n - 1;
        int[][] mat = new int[n][n];
        int num = 1, tar = n * n;
        while(num <= tar){
            for(int i = l; i <= r; i++) mat[t][i] = num++; // left to right.
            t++;
            for(int i = t; i <= b; i++) mat[i][r] = num++; // top to bottom.
            r--;
            for(int i = r; i >= l; i--) mat[b][i] = num++; // right to left.
            b--;
            for(int i = b; i >= t; i--) mat[i][l] = num++; // bottom to top.
            l++;
        }
        return mat;
    }
}

作者：jyd
链接：https://leetcode-cn.com/problems/spiral-matrix-ii/solution/spiral-matrix-ii-mo-ni-fa-she-ding-bian-jie-qing-x/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### [885. 螺旋矩阵 III](https://leetcode-cn.com/problems/spiral-matrix-iii)

### [88. 合并两个有序数组](https://leetcode-cn.com/problems/merge-sorted-array)

给你两个有序整数数组 nums1 和 nums2，请你将 nums2 合并到 nums1 中，使 nums1 成为一个有序数组。

初始化 nums1 和 nums2 的元素数量分别为 m 和 n 。你可以假设 nums1 的空间大小等于 m + n，这样它就有足够的空间保存来自 nums2 的元素。

最简单的方法，将nums2放入nums1的尾部，然后对整个数组进行排序；

```java
public void merge(int[] nums1, int m, int[] nums2, int n) {
    for (int i = 0; i != n; ++i) {
        nums1[m + i] = nums2[i];
    }
    Arrays.sort(nums1);
}
```

逆向双指针

```java
public void merge(int[] nums1, int m, int[] nums2, int n) {
    int p1 = m - 1, p2 = n - 1;
    int tail = m + n - 1;
    int cur;
    while (p1 >= 0 || p2 >= 0) {
        if (p1 == -1) {
            cur = nums2[p2--];
        } else if (p2 == -1) {
            cur = nums1[p1--];
        } else if (nums1[p1] > nums2[p2]) {
            cur = nums1[p1--];
        } else {
            cur = nums2[p2--];
        }
        nums1[tail--] = cur;
    }
}
```

### [977. 有序数组的平方](https://leetcode-cn.com/problems/squares-of-a-sorted-array)

给你一个按 非递减顺序 排序的整数数组 nums，返回 每个数字的平方 组成的新数组，要求也按 非递减顺序 排序。

```
示例 1：

输入：nums = [-4,-1,0,3,10]
输出：[0,1,9,16,100]
解释：平方后，数组变为 [16,1,0,9,100]
排序后，数组变为 [0,1,9,16,100]
```

简单的通过平方后直接排序

```java
public int[] sortedSquares(int[] nums) {
    int[] ans = new int[nums.length];
    for (int i = 0; i < nums.length; ++i) {
        ans[i] = nums[i] * nums[i];
    }
    Arrays.sort(ans);
    return ans;
}
```

但是这里没有利用到该数组有序的条件，可以用双指针

```java
public int[] sortedSquares(int[] A) {
    int idx = A.length - 1;
    int[] res = new int[idx + 1];
    int start = 0,end = idx;
    while(start <= end) {
        int l = A[start] * A[start];
        int r = A[end] * A[end];
        if(l < r) {
            res[idx--] = r;
            end--;
        } else {
            res[idx--] = l;
            start++;
        }
    }
    return res;
}
```

### [面试题 16.16. 部分排序](https://leetcode-cn.com/problems/sub-sort-lcci)

给定一个整数数组，编写一个函数，找出索引m和n，只要将索引区间[m,n]的元素排好序，整个数组就是有序的。注意：n-m尽量最小，也就是说，找出符合条件的最短序列。函数返回值为[m,n]，若不存在这样的m和n（例如整个数组是有序的），请返回[-1,-1]。

```java
public int[] subSort(int[] array) {
    if(array == null || array.length == 0) return new int[]{-1, -1};
    int last = -1, first = -1;
    int max = Integer.MIN_VALUE;
    int min = Integer.MAX_VALUE;
    int len = array.length;
    for(int i = 0; i < len; i++){
        if(array[i] < max){
            last = i;
        }else{
            max = Math.max(max, array[i]);
        }

        if(array[len - 1 - i] > min){
            first = len - 1 - i;
        }else{
            min = Math.min(min, array[len - 1 - i]);
        }
    }
    return new int[] {first, last};
}
```

## 链表突击

### [206. 反转链表](https://leetcode-cn.com/problems/reverse-linked-list)

dummy->1->2->3换成3->2->1->dummy

```java
public ListNode reverseList(ListNode head) {
    ListNode prev = null;
    ListNode cur = head;
    while(cur != null){
        ListNode temp = cur.next;
        cur.next = prev;
        prev = cur;
        cur = temp;
    }
    return prev;
}
```

### [92. 反转链表 II](https://leetcode-cn.com/problems/reverse-linked-list-ii)

给你单链表的头指针 head 和两个整数 left 和 right ，其中 left <= right 。请你反转从位置 left 到位置 right 的链表节点，返回 反转后的链表 。

```java
public ListNode reverseBetween(ListNode head, int m, int n) {
    // 定义一个dummyHead, 方便处理
    ListNode dummyHead = new ListNode(0);
    dummyHead.next = head;

    // 初始化指针
    ListNode g = dummyHead;
    ListNode p = dummyHead.next;

    // 将指针移到相应的位置
    for(int step = 0; step < m - 1; step++) {
        g = g.next; p = p.next;
    }

    // 头插法插入节点
    for (int i = 0; i < n - m; i++) {
        ListNode removed = p.next;
        p.next = p.next.next;

        removed.next = g.next;
        g.next = removed;
    }

    return dummyHead.next;
}

作者：mu-yi-cheng-zhou-2
链接：https://leetcode-cn.com/problems/reverse-linked-list-ii/solution/java-shuang-zhi-zhen-tou-cha-fa-by-mu-yi-cheng-zho/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### [2. 两数相加](https://leetcode-cn.com/problems/add-two-numbers)

给你两个 非空 的链表，表示两个非负的整数。它们每位数字都是按照 逆序 的方式存储的，并且每个节点只能存储 一位 数字。

请你将两个数相加，并以相同形式返回一个表示和的链表。

你可以假设除了数字 0 之外，这两个数都不会以 0 开头。

```java
public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    ListNode pre = new ListNode(0);
    ListNode cur = pre;
    int carry = 0;
    while(l1 != null || l2 != null) {
        int x = l1 == null ? 0 : l1.val;
        int y = l2 == null ? 0 : l2.val;
        int sum = x + y + carry;

        carry = sum / 10;//进位
        sum = sum % 10;
        cur.next = new ListNode(sum);

        cur = cur.next;
        if(l1 != null)
            l1 = l1.next;
        if(l2 != null)
            l2 = l2.next;
    }
    if(carry == 1) {
        cur.next = new ListNode(carry);
    }
    return pre.next;
}
```

### [21. 合并两个有序链表](https://leetcode-cn.com/problems/merge-two-sorted-lists)

```java
public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
    ListNode resultNode = new ListNode(0);
    ListNode preNode = resultNode;
    while(l1!=null && l2!=null){
        if(l1.val <= l2.val){
            resultNode.next = l1;
            l1 = l1.next;
        }else{
            resultNode.next = l2;
            l2 = l2.next;
        }
        resultNode = resultNode.next;
    }
    resultNode.next = l1 == null ? l2: l1;
    return preNode.next;
}
```

递归写法

```java
private ListNode merge2Lists(ListNode l1, ListNode l2) {
    if (l1 == null) {
        return l2;
    }
    if (l2 == null) {
        return l1;
    }
    if (l1.val < l2.val) {
        l1.next = merge2Lists(l1.next, l2);
        return l1;
    }
    l2.next = merge2Lists(l1, l2.next);
    return l2;
}

```

### [23. 合并K个升序链表](https://leetcode-cn.com/problems/merge-k-sorted-lists)

给你一个链表数组，每个链表都已经按升序排列。

请你将所有链表合并到一个升序链表中，返回合并后的链表。

迭代法，这里用到了上面[21. 合并两个有序链表](https://leetcode-cn.com/problems/merge-two-sorted-lists)的``merge2Lists``方法。

```java
public ListNode mergeKLists(ListNode[] lists) {
    if (lists.length == 0) {
        return null;
    }
    int k = lists.length;
    while (k > 1) {
        int idx = 0;
        for (int i = 0; i < k; i += 2) {
            if (i == k - 1) {
                lists[idx++] = lists[i];
            } else {
                lists[idx++] = merge2Lists(lists[i], lists[i + 1]);
            }
        }
        k = idx;
    }
    return lists[0];
}

public ListNode merge2Lists(ListNode l1, ListNode l2) {
    if (l1 == null) {
        return l2;
    }
    if (l2 == null) {
        return l1;
    }
    if (l1.val < l2.val) {
        l1.next = merge2Lists(l1.next, l2);
        return l1;
    }
    l2.next = merge2Lists(l1, l2.next);
    return l2;
}
```

### [61. 旋转链表](https://leetcode-cn.com/problems/rotate-list)

给你一个链表的头节点 `head` ，旋转链表，将链表每个节点向右移动 `k` 个位置。

```
输入：head = [1,2,3,4,5], k = 2
输出：[4,5,1,2,3]
```

```java
public ListNode rotateRight(ListNode head, int k) {
    //链表长度为0，直接返回
    if(head == null){
        return head;
    }
    ListNode tmp1 = head;
    //得到链表的长度
    int len = 1;
    while(tmp1.next != null){
        len++;
        tmp1 = tmp1.next;
    }
    //如果K是len的整数倍，那么循环右移就相当于没有移动
    int mod = k % len;
    if(mod == 0){
        return head;
    }
    //如果K不是len的整数倍，那么循环右移（len-余数)位
    //先把单向链表弄成环，然后数（len-余数）位以后再断开
    tmp1.next = head;
    //数数，断开
    int cnt = 0;
    ListNode newHead = new ListNode();
    ListNode tmp2 = head;
    while(tmp2 != null){
        cnt++;
        if(cnt == len-mod){
            newHead = tmp2.next;
            tmp2.next = null;
            break;
        }
        tmp2 = tmp2.next;
    }
    return newHead;
}
```

### [141. 环形链表](https://leetcode-cn.com/problems/linked-list-cycle)

给定一个链表，判断链表中是否有环。

```java
public boolean hasCycle(ListNode head) {
    ListNode fast=head;
    ListNode slow=head;//定义快慢引用
    while(fast!=null&&fast.next!=null){
        //fast!=null要写在前面，这样由于短路与的特性，当前面为真时后面的条件就不执行了，就不会空指针异常了
        fast=fast.next.next;
        slow=slow.next;
        if(fast==slow){
            return true;
        }
    }
    return false;
}

```

### [142. 环形链表 II](https://leetcode-cn.com/problems/linked-list-cycle-ii)

给定一个链表，返回链表开始入环的第一个节点。 如果链表无环，则返回 `null`。

1. fast 走的步数是slow步数的 2 倍，即 f = 2s；（解析： fast 每轮走 2 步）
2. fast 比 slow多走了 n 个环的长度，即 f = s + nb；（ 解析： 双指针都走过 a 步，然后在环内绕圈直到重合，重合时 fast 比 slow 多走 环的长度整数倍 ）；
3. 以上两式相减得：f = 2nb，s = nb，即fast和slow 指针分别走了 2n，n个 环的周长 （注意： n 是未知数，不同链表的情况不同）。

然后重点是：

1. 走a+nb步一定是在环入口（a是指未入环之前不包括入环节点的长度，b指环内的长度）
2. 第一次相遇时慢指针已经走了nb步

```java
public class Solution {
    public ListNode detectCycle(ListNode head) {
        ListNode fast = head, slow = head;
        while (true) {//先判断有没有环
            if (fast == null || fast.next == null) return null;
            fast = fast.next.next;
            slow = slow.next;
            if (fast == slow) break;
        }
        fast = head;
        while (slow != fast) {
            slow = slow.next;
            fast = fast.next;
        }
        return fast;
    }
}
```

### [160. 相交链表](https://leetcode-cn.com/problems/intersection-of-two-linked-lists)

给你两个单链表的头节点 `headA` 和 `headB` ，请你找出并返回两个单链表相交的起始节点。如果两个链表没有交点，返回 `null` 。

简单解法

```java
public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
    //创建集合set
    Set<ListNode> set = new HashSet<>();
    //先把链表A的结点全部存放到集合set中
    while (headA != null) {
        set.add(headA);
        headA = headA.next;
    }

    //然后访问链表B的结点，判断集合中是否包含链表B的结点，如果包含就直接返回
    while (headB != null) {
        if (set.contains(headB))
            return headB;
        headB = headB.next;
    }
    //如果集合set不包含链表B的任何一个结点，说明他们没有交点，直接返回null
    return null;
}
```

双指针

「链表 headA」的节点数量为 a ，「链表 headB」的节点数量为 b ，「两链表的公共尾部」的节点数量为 c ，则有：

- 头节点 headA 到 node 前，共有 a - c个节点；
- 头节点 headB 到 node 前，共有 b - c个节点；

指针 `A` 先遍历完链表 `headA` ，再开始遍历链表 `headB` ，当走到 `node` 时，共走步数为：a + (b-c)

指针 `B` 先遍历完链表 `headB` ，再开始遍历链表 `headA` ，当走到 `node` 时，共走步数为：b + (a-c)

如下式所示，此时指针 `A` , `B` 重合，并有两种情况：a+(b−c)=b+(a−c)

- 若两链表 有 公共尾部 (即 c > 0 ) ：指针 A , B 同时指向「第一个公共节点」node 。
- 若两链表 无 公共尾部 (即 c = 0) ：指针 A , B 同时指向 null 。

```java
public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
    ListNode A = headA, B = headB;
    while (A != B) {
        A = A != null ? A.next : headB;
        B = B != null ? B.next : headA;
    }
    return A;
}
```

### [237. 删除链表中的节点](https://leetcode-cn.com/problems/delete-node-in-a-linked-list)

请编写一个函数，使其可以删除某个链表中给定的（非末尾）节点。传入函数的唯一参数为 **要被删除的节点** 。

```java
public void deleteNode(ListNode node) {
    node.val = node.next.val;
    node.next = node.next.next;
}
```

### [19. 删除链表的倒数第 N 个结点](https://leetcode-cn.com/problems/remove-nth-node-from-end-of-list)

给你一个链表，删除链表的倒数第 `n` 个结点，并且返回链表的头结点。

**进阶：**你能尝试使用一趟扫描实现吗？

简单思路，先得到链表的长度，然后从后往前，定位到要删除的节点

```java
public ListNode removeNthFromEnd(ListNode head, int n) {
    ListNode dummy = new ListNode(0, head);
    int length = getLength(head);
    ListNode cur = dummy;
    for (int i = 1; i < length - n + 1; ++i) {
        cur = cur.next;
    }
    cur.next = cur.next.next;
    ListNode ans = dummy.next;
    return ans;
}

public int getLength(ListNode head) {
    int length = 0;
    while (head != null) {
        ++length;
        head = head.next;
    }
    return length;
}
```

双指针

双指针的经典应用，如果要删除倒数第n个节点，让fast移动n步，然后让fast和slow同时移动，直到fast指向链表末尾。删掉slow所指向的节点就可以了。

```java
public ListNode removeNthFromEnd(ListNode head, int n) {
    ListNode dummy = new ListNode(0,head);//哑节点，即头指针的前一个结点
    ListNode quick = head;//快指针
    ListNode slow = dummy;//慢指针初始为哑结点，为了确保快指针为空时慢指针不是待删除节点，而是下一个为待删除结点、方便操作

    //将快指针移动n次，这样快慢指针隔n个节点
    for(int i=0;i<n;i++){
        quick = quick.next;
    }

    while(quick != null){
        quick = quick.next;
        slow =slow.next;
    }
    //slow下一个节点为待删除节点
    slow.next = slow.next.next;
    return dummy.next;
}
```

### [剑指 Offer 22. 链表中倒数第k个节点](https://leetcode-cn.com/problems/lian-biao-zhong-dao-shu-di-kge-jie-dian-lcof/)

### [876. 链表的中间结点](https://leetcode-cn.com/problems/middle-of-the-linked-list/)

## 排序与搜索

### [148. 排序链表](https://leetcode-cn.com/problems/sort-list)

给你链表的头结点 `head` ，请将其按 **升序** 排列并返回 **排序后的链表** 。

优先队列

```java
public static ListNode sortList(ListNode head) {
    ListNode cur = head;
    ListNode dummy = new ListNode(0);
    ListNode res = dummy;
    PriorityQueue<Integer> list = new PriorityQueue<>();
    while (cur!=null){
        list.add(cur.val);
        cur = cur.next;
    }
    while (list.size()!=0){
        res.next = new ListNode(list.poll());
        res = res.next;
    }
    return dummy.next;
}
```

归并排序

利用归并的思想，递归地将当前链表分为两段，然后 merge。

分两段的方法是使用快慢指针，fast 一次走两步，slow 一次走一步。因为 fast 指针走的遍历的节点数是 slow 指针遍节点数的两倍，所以当 fast 指针遍历到链表末尾时，此时 slow 指针所在位置就是链表的中间位置，这样就将当前链表分成了两段。

merge 时，把两段头部节点值比较，定义一个 p 指针指向较小的节点，且记录第一个节点，然后两段链表从头一步一步向后走，p 也一直向后走，总是指向较小节点，直至其中一个头为 NULL，继续处理剩下的元素，最后返回记录的头即可

```java
public ListNode sortList(ListNode head) {

    if (head == null) return null;
    return mergeSort(head);
}

private ListNode mergeSort(ListNode head) {

    if (head == null || head.next == null) return head;

    //利用快慢指针来找到链表的中点
    ListNode fast = head;
    ListNode slow = head;
    while (fast != null && fast.next != null && fast.next.next != null) {

        fast = fast.next.next;
        slow = slow.next;
    }

    ListNode right = mergeSort(slow.next);
    slow.next = null;
    ListNode left = mergeSort(head);

    return merge(left, right);
}

private ListNode merge(ListNode left, ListNode right) {

    ListNode dummyHead = new ListNode(0);
    ListNode p = dummyHead;

    while (left != null && right != null) {

        if (left.val <= right.val) {

            p.next = left;
            left = left.next;
        } else {

            p.next = right;
            right = right.next;
        }
        p = p.next;
    }

    if (left != null) p.next = left;
    if (right != null) p.next = right;

    return dummyHead.next;
}
```

### [215. 数组中的第K个最大元素](https://leetcode-cn.com/problems/kth-largest-element-in-an-array)

给定整数数组 nums 和整数 k，请返回数组中第 k 个最大的元素。

请注意，你需要找的是数组排序后的第 k 个最大的元素，而不是第 k 个不同的元素。

```
示例 1:

输入: [3,2,1,5,6,4] 和 k = 2
输出: 5
```

暴力解法

序排序以后，**目标元素的索引是 `len - k`**。

```java
public int findKthLargest(int[] nums, int k) {
    int len = nums.length;
    Arrays.sort(nums);
    return nums[len - k];
}
```

优先队列

思路1：把 len 个元素都放入一个最小堆中，然后再 pop() 出 len - k 个元素，此时最小堆只剩下 k 个元素，堆顶元素就是数组中的第 k 个最大元素。

```java
public int findKthLargest(int[] nums, int k) {
        int len = nums.length;
        // 使用一个含有 len 个元素的最小堆，默认是最小堆，可以不写 lambda 表达式：(a, b) -> a - b
        PriorityQueue<Integer> minHeap = new PriorityQueue<>(len, (a, b) -> a - b);
        for (int i = 0; i < len; i++) {
            minHeap.add(nums[i]);
        }
        for (int i = 0; i < len - k; i++) {
            minHeap.poll();
        }
        return minHeap.peek();
    }

```

思路2：把 len 个元素都放入一个最大堆中，然后再 pop() 出 k - 1 个元素，因为前 k - 1 大的元素都被弹出了，此时最大堆的堆顶元素就是数组中的第 k 个最大元素。

```java
 public int findKthLargest(int[] nums, int k) {
        int len = nums.length;
        // 使用一个含有 len 个元素的最大堆，lambda 表达式应写成：(a, b) -> b - a
        PriorityQueue<Integer> maxHeap = new PriorityQueue<>(len, (a, b) -> b - a);
        for (int i = 0; i < len; i++) {
            maxHeap.add(nums[i]);
        }
        for (int i = 0; i < k - 1; i++) {
            maxHeap.poll();
        }
        return maxHeap.peek();
    }
```

### [230. 二叉搜索树中第K小的元素](https://leetcode-cn.com/problems/kth-smallest-element-in-a-bst)

给定一个二叉搜索树的根节点 `root` ，和一个整数 `k` ，请你设计一个算法查找其中第 `k` 个最小元素（从 1 开始计数）。

利用二叉搜索树（BST）的性质，中序遍历是升序序列；

通过构造 BST 的中序遍历序列，则第 `k-1` 个元素就是第 `k` 小的元素。

```java
public ArrayList<Integer> inorder(TreeNode root, ArrayList<Integer> arr) {
    if (root == null) return arr;
    inorder(root.left, arr);
    arr.add(root.val);
    inorder(root.right, arr);
    return arr;
}

public int kthSmallest(TreeNode root, int k) {
    ArrayList<Integer> nums = inorder(root, new ArrayList<Integer>());
    return nums.get(k - 1);
}
```

### [104. 二叉树的最大深度](https://leetcode-cn.com/problems/maximum-depth-of-binary-tree)

```java
public int maxDepth(TreeNode root) {
    if (root == null) {
        return 0;
    } else {
        int leftHeight = maxDepth(root.left);
        int rightHeight = maxDepth(root.right);
        return Math.max(leftHeight, rightHeight) + 1;
    }
}
```

### [124. 二叉树中的最大路径和](https://leetcode-cn.com/problems/binary-tree-maximum-path-sum)

路径被定义为一条从树中任意节点出发，沿父节点-子节点连接，达到任意节点的序列。同一个节点在一条路径序列中 至多出现一次 。该路径 至少包含一个 节点，且不一定经过根节点。

路径和 是路径中各节点值的总和。

给你一个二叉树的根节点 root ，返回其 最大路径和 。

### [235. 二叉搜索树的最近公共祖先](https://leetcode-cn.com/problems/lowest-common-ancestor-of-a-binary-search-tree)

- 开启 while 循环，当 root 为 null 时就结束循环（root 就是一个指针）。
  - 如果 p.val、q.val 都小于 root.val，它们都在 root 的左子树，root=root.left，遍历到 root 的左子节点。
  - 如果 p.val、q.val 都大于 root.val，它们都在 root 的右子树，root=root.right，遍历到 root 的右子节点。
  - 其他情况，当前的 root 就是最近公共祖先，结束遍历， break。
- 返回 root，即，break 时的 root 节点就是最近公共祖先。

```java
public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
    TreeNode ancestor = root;
    while(true){
        if(p.val < ancestor.val && q.val < ancestor.val){
            ancestor = ancestor.left;
        }else if(p.val > ancestor.val && q.val > ancestor.val){
            ancestor = ancestor.right;
        }else{
            break;
        }
    }
    return ancestor;
}
```

go

```go
func lowestCommonAncestor(root, p, q *TreeNode) *TreeNode {
	for root != nil {
		if p.Val < root.Val && q.Val < root.Val {
			root = root.Left
		} else if p.Val > root.Val && q.Val > root.Val {
			root = root.Right
		} else {
			break
		}
	}
	return root
}
```

### [236. 二叉树的最近公共祖先](https://leetcode-cn.com/problems/lowest-common-ancestor-of-a-binary-tree)

```java
public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
    if(root == null || root == p || root == q) return root;
    TreeNode left = lowestCommonAncestor(root.left, p, q);
    TreeNode right = lowestCommonAncestor(root.right, p, q);
    if(left == null) return right;
    if(right == null) return left;
    return root;
}
```

## 回溯算法

### [22. 括号生成](https://leetcode-cn.com/problems/generate-parentheses)

数字 n 代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且 有效的 括号组合。

```
示例 1：
输入：n = 3
输出：["((()))","(()())","(())()","()(())","()()()"]
```

[优秀题解，很好理解](https://leetcode-cn.com/problems/generate-parentheses/solution/sui-ran-bu-shi-zui-xiu-de-dan-zhi-shao-n-0yt3/)

```java
public List<String> generateParenthesis(int n) {
    List<String> res = new ArrayList<>();
    // 特判
    if (n == 0) {
        return res;
    }

    // 执行深度优先遍历，搜索可能的结果
    dfs("", n, n, res);
    return res;
}

/**
     * @param curStr 当前递归得到的结果
     * @param left   左括号还有几个可以使用
     * @param right  右括号还有几个可以使用
     * @param res    结果集
     */
private void dfs(String curStr, int left, int right, List<String> res) {
    // 因为每一次尝试，都使用新的字符串变量，所以无需回溯
    // 在递归终止的时候，直接把它添加到结果集即可，注意与「力扣」第 46 题、第 39 题区分
    if (left == 0 && right == 0) {
        res.add(curStr);
        return;
    }

    // 剪枝（如图，左括号可以使用的个数严格大于右括号可以使用的个数，才剪枝，注意这个细节）
    if (left > right) {
        return;
    }

    if (left > 0) {
        dfs(curStr + "(", left - 1, right, res);
    }

    if (right > 0) {
        dfs(curStr + ")", left, right - 1, res);
    }
}
```

### [78. 子集](https://leetcode-cn.com/problems/subsets)


给你一个整数数组 `nums` ，数组中的元素 **互不相同** 。返回该数组所有可能的子集（幂集）。

解集 **不能** 包含重复的子集。你可以按 **任意顺序** 返回解集。

**示例 1：**

```
输入：nums = [1,2,3]
输出：[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]
```

```java
public List<List<Integer>> subsets(int[] nums) {
    List<List<Integer>> res = new ArrayList<>();
    dfs(res,nums,0,new ArrayList<>());
    return res;
}

private void dfs(List<List<Integer>> res, int[] nums, int length, List<Integer> sub) {
    res.add(new ArrayList<>(sub));
    int len = nums.length;

    if (length == len){
        return;
    }
    for (int i = length; i < len; i++){
        sub.add(nums[i]);
        dfs(res,nums,i+1,sub);
        sub.remove(sub.size() - 1);
    }
}
```

### [90. 子集 II](https://leetcode-cn.com/problems/subsets-ii)

给你一个整数数组 nums ，其中可能包含重复元素，请你返回该数组所有可能的子集（幂集）。

解集 不能 包含重复的子集。返回的解集中，子集可以按 任意顺序 排列。

**示例 1：**

```
输入：nums = [1,2,2]
输出：[[],[1],[1,2],[1,2,2],[2],[2,2]]
```

相对于78题来讲就是增加一步，现排序，然后判断``nums[i]``是否等于``nums[i-1]``，如果相等就不添加到``path``中。

```java
public List<List<Integer>> subsetsWithDup(int[] nums) {
    List<List<Integer>> res = new ArrayList<>();
    Arrays.sort(nums);
    backTrace(res,nums, 0, new ArrayList<>());
    return res;
}

public void backTrace(List<List<Integer>> res,int[] nums, int index, List<Integer> tmp){
    res.add(new ArrayList<>(tmp));
    for(int i = index; i < nums.length; ++i){
        //剔除重复元素
        if(i != index && nums[i] == nums[i - 1]){
            continue;
        }
        tmp.add(nums[i]);
        backTrace(res,nums, i + 1, tmp);
        tmp.remove(tmp.size() - 1);
    }
}
```

### [46. 全排列](https://leetcode-cn.com/problems/permutations/)

给定一个不含重复数字的数组 `nums` ，返回其 **所有可能的全排列** 。你可以 **按任意顺序** 返回答案。

**示例 1：**

```
输入：nums = [1,2,3]
输出：[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
```

```java
public List<List<Integer>> permute(int[] nums) {
    int len = nums.length;
    // 使用一个动态数组保存所有可能的全排列
    List<List<Integer>> res = new ArrayList<>();
    if (len == 0) {
        return res;
    }

    boolean[] used = new boolean[len];
    Deque<Integer> path = new ArrayDeque<>(len);

    dfs(nums, len, 0, path, used, res);
    return res;
}

private void dfs(int[] nums, int len, int depth,
                 Deque<Integer> path, boolean[] used,
                 List<List<Integer>> res) {
    if (depth == len) {
        res.add(new ArrayList<>(path));
        return;
    }

    for (int i = 0; i < len; i++) {
        if (!used[i]) {
            path.addLast(nums[i]);
            used[i] = true;

            System.out.println("  递归之前 => " + path);
            dfs(nums, len, depth + 1, path, used, res);

            used[i] = false;
            path.removeLast();
            System.out.println("递归之后 => " + path);
        }
    }
}
```

### [47. 全排列 II](https://leetcode-cn.com/problems/permutations-ii/)



### [39. 组合总和](https://leetcode-cn.com/problems/combination-sum)

给定一个无重复元素的正整数数组 candidates 和一个正整数 target ，找出 candidates 中所有可以使数字和为目标数 target 的唯一组合。

candidates 中的数字可以无限制重复被选取。如果至少一个所选数字数量不同，则两种组合是唯一的。 

对于给定的输入，保证和为 target 的唯一组合数少于 150 个。

**示例 1：**

```
输入: candidates = [2,3,6,7], target = 7
输出: [[7],[2,2,3]]
```

推荐阅读：[weiwei哥的题解](https://leetcode-cn.com/problems/combination-sum/solution/hui-su-suan-fa-jian-zhi-python-dai-ma-java-dai-m-2/)

```java
public List<List<Integer>> combinationSum(int[] candidates, int target) {
    int len = candidates.length;
    List<List<Integer>> res = new ArrayList<>();
    if (len == 0) {
        return res;
    }

    Deque<Integer> path = new ArrayDeque<>();
    dfs(candidates, 0, len, target, path, res);
    return res;
}

/**
     * @param candidates 候选数组
     * @param begin      搜索起点
     * @param len        冗余变量，是 candidates 里的属性，可以不传
     * @param target     每减去一个元素，目标值变小
     * @param path       从根结点到叶子结点的路径，是一个栈
     * @param res        结果集列表
     */
private void dfs(int[] candidates, int begin, int len, int target, Deque<Integer> path, List<List<Integer>> res) {
    // target 为负数和 0 的时候不再产生新的孩子结点
    if (target < 0) {
        return;
    }
    if (target == 0) {
        res.add(new ArrayList<>(path));
        return;
    }

    // 重点理解这里从 begin 开始搜索的语意
    for (int i = begin; i < len; i++) {
        path.addLast(candidates[i]);

        // 注意：由于每一个元素可以重复使用，下一轮搜索的起点依然是 i，这里非常容易弄错
        dfs(candidates, i, len, target - candidates[i], path, res);

        // 状态重置
        path.removeLast();
    }
}
```

### [40. 组合总和 II](https://leetcode-cn.com/problems/combination-sum-ii)

## 滑动窗口

滑动窗口算法思想是非常重要的一种思想，可以用来解决数组，字符串的子元素问题。它可以将嵌套循环的问题，转换为单层循环问题，降低时间复杂度，提高效率。

滑动窗口的思想非常简单，它将子数组（子字符串）理解成一个滑动的窗口，然后将这个窗口在数组上滑动，在窗口滑动的过程中，左边会出一个元素，右边会进一个元素，然后只需要计算当前窗口内的元素值即可。

可用滑动窗口思想解决的问题，一般有如下特点：

1. 窗口内元素是连续的。就是说，抽象出来的这个可滑动的窗口，在原数组或字符串上是连续的。
2. 窗口只能由左向右滑动，不能逆过来滑动。就是说，窗口的左右边界，只能从左到右增加，不能减少，即使局部也不可以。
3. 滑动窗口的重要性质是：窗口的左边界和右边界永远只能向右移动，而不能向左移动。这是为了保证滑动窗口的时间复杂度是 O(n)。如果左右边界向左移动的话，这叫做“回溯”，算法的时间复杂度就可能不止 O(n)。


### 算法思路

1. 使用双指针中的左右指针技巧，初始化 left = right = 0，把索引闭区间 [left, right] 称为一个「窗口」。
2. 先不断地增加 right 指针扩大窗口 [left, right]，直到窗口符合要求
3. 停止增加 right，转而不断增加 left 指针缩小窗口 [left, right]，直到窗口中的字符串不再符合要求。同时，每次增加 left，我们都要更新一轮结果。
4. 重复第 2 和第 3 步，直到 right 到达尽头。

> 第 2 步相当于在寻找一个「可行解」，然后第 3 步在优化这个「可行解」，最终找到最优解。 左右指针轮流前进，窗口大小增增减减，窗口不断向右滑动。

**代码模板**

```
left,right := 0,0 // 左右指针

// 窗口右边界滑动
for right < length {
  window.add(s[right])      // 右元素进窗
  right++                   // 右指针增加

  // 窗口满足条件
  for valid(window) && left<right {
    ...                      // 满足条件后的操作
    window.remove(arr[left]) // 左元素出窗
    left++                   // 左指针移动，直到窗口不满足条件
  }
}
```

注意:

- 滑动窗口适用的题目一般具有单调性
- 滑动窗口、双指针、单调队列和单调栈经常配合使用

滑动窗口的思路很简单，但在leetcode上关于滑动窗口的题目一般都是mid甚至hard的题目。其难点在于，如何抽象窗口内元素的操作，验证窗口是否符合要求的过程。
即上面步骤2，步骤3的两个过程。

说的有点生涩。来两个例子说明一下。

### 连续子数组的最大和

> 给定一个整数数组，计算长度为n的连续子数组的最大和。
>
> 比如，给定arr=[1,2,3,4]，n=2，则其连续子数组的最大和为7。其长度为2的连续子数组为[1,2],[2,3],[3,4]，和最大就是3+4=7。

所有问题都可以用穷举法解决，比如这个。我们可以穷举出所有长度为n的子数组，然后计算每个子数组的和，再求最大值。穷举法能实现，但是效率非常低。因为在穷举的过程中会嵌套循环。

滑动窗口的思想就是，把这个要求和的子数组当成一个窗口，然后在数组上滑动。

我们维护一个长度为2的窗口，然后依次滑动这个窗口直至结束。在滑动时，出一个左边元素，进一个右边元素，计算这个窗口内的元素和，然后和最大和比较。滑动结束，也就求出了最大和是多少。

```go
func maxSubSum(nums []int, n int) int {
  if n <= 0 {
    return 0
  }
  if n >= len(nums) {
    n = len(nums)
  }
  // sum 标记窗口内元素和
  // maxSum标记sum的最大值
  sum, maxSum := 0, 0
  // 初始化窗口
  for i := 0; i < n; i++ {
    sum += nums[i]
  }
  maxSum = sum
  // 滑动窗口
  for i := n; i < len(nums); i++ {
    // 左出右进
    sum = sum - nums[i-n] + nums[i]
    if sum > maxSum {
      maxSum = sum
    }
  }
  return maxSum
}
```

### [剑指 Offer 57 - II. 和为s的连续正数序列](https://leetcode-cn.com/problems/he-wei-sde-lian-xu-zheng-shu-xu-lie-lcof/)

输入一个正整数 target ，输出所有和为 target 的连续正整数序列（至少含有两个数）。

序列内的数字由小到大排列，不同序列按照首个数字从小到大排列。

 ```
 示例 1：
 
 输入：target = 9
 输出：[[2,3,4],[4,5]]
 ```

滑动窗口加双指针

```java
public int[][] findContinuousSequence(int target) {
    int i = 1; // 滑动窗口的左边界
    int j = 1; // 滑动窗口的右边界
    int sum = 0; // 滑动窗口中数字的和
    List<int[]> res = new ArrayList<>();

    while (i <= target / 2) {
        if (sum < target) {
            // 右边界向右移动
            sum += j;
            j++;
        } else if (sum > target) {
            // 左边界向右移动
            sum -= i;
            i++;
        } else {
            // 记录结果
            int[] arr = new int[j-i];
            for (int k = i; k < j; k++) {
                arr[k-i] = k;
            }
            res.add(arr);
            // 左边界向右移动
            sum -= i;
            i++;
        }
    }
    return res.toArray(new int[res.size()][]);
}
```

## 动态规划

### [70. 爬楼梯](https://leetcode-cn.com/problems/climbing-stairs/)

```java
public int climbStairs(int n) {
    if (n <= 2){
        return n;
    }
    int[] dp = new int[n + 1];
    dp[1] = 1;
    dp[2] = 2;
    for(int i = 3; i <= n; i++){
        dp[i] = dp[i-1] + dp[i-2];
    }
    return dp[n];
}
```

### [53. 最大子序和](https://leetcode-cn.com/problems/maximum-subarray/description/) 

给定一个整数数组 `nums` ，找到一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。

**示例:**

```
输入: [-2,1,-3,4,-1,2,1,-5,4],
输出: 6
解释: 连续子数组 [4,-1,2,1] 的和最大，为 6。
```

```java
// 给定一个整数数组 nums ，找到一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。

/**
     * 定义状态：
     * dp[i] ： 表示以 nums[i] 结尾的连续子数组的最大和
     * <p>
     * 状态转移方程：
     * dp[i] = max{num[i],dp[i-1] + num[i]}
     *
     * @param nums
     * @return
     */
public int maxSubArray(int[] nums) {
    int len = nums.length;
    if (len == 0) {
        return 0;
    }
    int[] dp = new int[len];
    dp[0] = nums[0];
    for (int i = 1; i < len; i++) {
        dp[i] = Math.max(nums[i], dp[i - 1] + nums[i]);
    }
    // 最后这一步，是求一个全局的最优值
    int res = dp[0];
    for (int i = 1; i < len; i++) {
        res = Math.max(res,dp[i]);
    }

```

也可以不用动态规划

```java
/**
     * 和 Solution 一样，空间复杂度更小
     * 时间复杂度：O(n)
     * 空间复杂度：O(1)
     *
     * @param nums
     * @return
     */
public int maxSubArray(int[] nums) {
    int len = nums.length;
    if (len == 0) {
        return 0;
    }
    int segmentSum = nums[0];
    int res = nums[0];
    for (int i = 1; i < len; i++) {
        segmentSum = Math.max(nums[i], segmentSum + nums[i]);
        res = Math.max(res, segmentSum);
    }
    return res;
}

public static void main(String[] args) {
    int[] nums = {-2, 1, -3, 4, -1, 2, 1, -5, 4};
    Solution2 solution = new Solution2();
    int maxSubArray = solution.maxSubArray(nums);
    System.out.println(maxSubArray);
}
```

### [121. 买卖股票的最佳时机](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock)

给定一个数组 prices ，它的第 i 个元素 prices[i] 表示一支给定股票第 i 天的价格。

你只能选择 某一天 买入这只股票，并选择在 未来的某一个不同的日子 卖出该股票。设计一个算法来计算你所能获取的最大利润。

返回你可以从这笔交易中获取的最大利润。如果你不能获取任何利润，返回 0 。

**示例 1：**

```
输入：prices = [7,6,4,3,1]
输出：0
解释：在这种情况下, 没有交易完成, 所以最大利润为 0。
```
简单方法，一次遍历
```java
public int maxProfit(int[] prices){
    int min = Integer.MAX_VALUE;
    int max = 0;
    for (int i = 0; i < prices.length; i++){
        max = Math.max(max,prices[i] - min);
        min = Math.min(nums[i],min);
    }
    return max;
}
```

一维数组动态规划

dp[i] 表示前 i 天的最大利润，因为我们始终要使利润最大化，则：

``dp[i] = max(dp[i-1], prices[i]-minprice)``

```java
public int maxProfit(int[] prices) {
    int[] dp = new int[prices.length];
    dp[0]=0;
    int minprice=prices[0];//minprice代表历史最低价格，
    // 所以i从1开始历史最低价格肯定是prices[0]
    for (int i = 1; i < prices.length; i++) {
        dp[i]=Math.max(dp[i-1],prices[i]-minprice);
        minprice=Math.min(minprice,prices[i]);

    }
    return dp[prices.length-1];
}
```

### [122. 买卖股票的最佳时机 II](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock-ii)

给定一个数组 prices ，其中 prices[i] 是一支给定股票第 i 天的价格。

设计一个算法来计算你所能获取的最大利润。你可以尽可能地完成更多的交易（多次买卖一支股票）。

```
示例 1:

输入: prices = [7,1,5,3,6,4]
输出: 7
解释: 在第 2 天（股票价格 = 1）的时候买入，在第 3 天（股票价格 = 5）的时候卖出, 这笔交易所能获得利润 = 5-1 = 4 。
     随后，在第 4 天（股票价格 = 3）的时候买入，在第 5 天（股票价格 = 6）的时候卖出, 这笔交易所能获得利润 = 6-3 = 3 。
```

简单方法，一次遍历

```java
public int maxProfit(int[] prices) {
    int maxProfit = 0;
    for(int i = 1; i < prices.length; i++){
        int temp = prices[i] - prices[i - 1];
        if(temp > 0){
            maxProfit += temp;
        }
    }
    return maxProfit;
}
```

### [剑指 Offer 57. 和为s的两个数字](https://leetcode-cn.com/problems/he-wei-sde-liang-ge-shu-zi-lcof/)

输入一个递增排序的数组和一个数字s，在数组中查找两个数，使得它们的和正好是s。如果有多对数字的和等于s，则输出任意一对即可。

```
示例 1：

输入：nums = [2,7,11,15], target = 9
输出：[2,7] 或者 [7,2]
```

```java
public int[] twoSum(int[] nums, int target) {
    int i = 0, j = nums.length - 1;
    while(i < j) {
        int s = nums[i] + nums[j];
        if(s < target) i++;
        else if(s > target) j--;
        else return new int[] { nums[i], nums[j] };
    }
    return new int[0];
}
```

### [62. 不同路径](https://leetcode-cn.com/problems/unique-paths/)

一个机器人位于一个 m x n 网格的左上角 （起始点在下图中标记为 “Start” ）。

机器人每次只能向下或者向右移动一步。机器人试图达到网格的右下角（在下图中标记为 “Finish” ）。

问总共有多少条不同的路径？

推荐题解：https://leetcode-cn.com/problems/unique-paths/solution/dai-ma-sui-xiang-lu-dong-gui-wu-bu-qu-xi-1vkb/

```java
public static int uniquePaths(int m, int n) {
    int[][] dp = new int[m][n];
    //初始化
    for (int i = 0; i < m; i++) {
        dp[i][0] = 1;
    }
    for (int i = 0; i < n; i++) {
        dp[0][i] = 1;
    }

    for (int i = 1; i < m; i++) {
        for (int j = 1; j < n; j++) {
            dp[i][j] = dp[i-1][j]+dp[i][j-1];
        }
    }
    return dp[m-1][n-1];
}
```

## 设计

### [146. LRU 缓存机制](https://leetcode-cn.com/problems/lru-cache)

哈希表+双向链表；

LRU 缓存机制可以通过哈希表辅以双向链表实现，我们用一个哈希表和一个双向链表维护所有在缓存中的键值对。

- 双向链表按照被使用的顺序存储了这些键值对，靠近头部的键值对是最近使用的，而靠近尾部的键值对是最久未使用的。

- 哈希表即为普通的哈希映射（HashMap），通过缓存数据的键映射到其在双向链表中的位置。

这样以来，我们首先使用哈希表进行定位，找出缓存项在双向链表中的位置，随后将其移动到双向链表的头部，即可在 O(1) 的时间内完成 get 或者 put 操作。

### [155. 最小栈](https://leetcode-cn.com/problems/min-stack)

设计一个支持 push ，pop ，top 操作，并能在常数时间内检索到最小元素的栈。

- push(x) —— 将元素 x 推入栈中。
- pop() —— 删除栈顶的元素。
- top() —— 获取栈顶元素。
- getMin() —— 检索栈中的最小元素。

可以用辅助栈，类似两个栈实现队列那种，那样比较麻烦。可以用自定义链表，每个节点存储当前值，当前最小值，和它前面的节点

```java
/**
 * 通过自定义链表实现，每个节点存储当前值，当前最小值，和它前面的节点
 * */
class MinStack {
    private Node head;
    
    public void push(int x) {
        if(head == null) 
            head = new Node(x, x);
        else 
            head = new Node(x, Math.min(x, head.min), head);
    }

    public void pop() {
        head = head.next;
    }

    public int top() {
        return head.val;
    }

    public int getMin() {
        return head.min;
    }
    
    private class Node {
        int val;
        int min;
        Node next;
        
        private Node(int val, int min) {
            this(val, min, null);
        }
        
        private Node(int val, int min, Node next) {
            this.val = val;
            this.min = min;
            this.next = next;
        }
    }
}
```



## 参考

https://liweiwei1419.github.io/leetcode-solution/

