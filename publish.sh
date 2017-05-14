rm -rf ./_book
gitbook build
cp -rf ./_book/* ./
gitbook pdf ./ ./ebook/RxJS5基本原理.pdf
gitbook mobi ./ ./ebook/RxJS5基本原理.mobi
gitbook epub ./ ./ebook/RxJS5基本原理.epub
git add .
git commit -m 'regenerated book'
git push origin master
