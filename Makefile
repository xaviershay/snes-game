all: main.smc

main.smc: main.obj temp
	wlalink -vr temp main.smc

main.obj: gen/colors.asm
	wla-65816 -o main.asm main.obj

gen/colors.asm: pre/colors.rb
	ruby pre/colors.rb > gen/colors.asm

temp:
	echo "[objects]\nmain.obj" > temp

clean:
	rm temp
	rm *.obj
	rm gen/*
