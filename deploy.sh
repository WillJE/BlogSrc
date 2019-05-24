
#!/bin/bash
# 部署到 github pages 脚本
# 错误时终止脚本
set -e

# 删除打包文件夹
rm -rf public

# 打包。even 是主题
hugo -t even # if using a theme, replace with `hugo -t <YOURTHEME>`

# 进入打包文件夹
cd public

# 添加 readme
echo '## Blog

Hugo+github pages build blog.

> visit [here](<https://willje.github.io/>).'> README.md
# Add changes to git.
git init
git add -A

# Commit changes.
msg="building site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# 推送到 github pages
# WillJE.github.io 只能使用 master分支
# -f 强制推送
git push -f git@github.com:WillJE/WillJE.github.io.git master

echo deploy done
exit
