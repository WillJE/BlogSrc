read -p  "please input commit comments:" msg
git add -A && git commit -m "$msg" && git pull && git push && git status
echo "Finish!"
read