#!/bin/sh

hugo

cp -rf public/* ../WillJE.github.io/docs/

cd ../WillJE.github.io/

git add * && git commit -m 'new article' && git push

cd ../WillJE/