OUT=env

.PHONY: all

all: $(OUT)/ctfproxy.env

$(OUT)/ctfproxy.env: $(OUT)/0.env $(OUT)/1.env $(OUT)/2.env $(OUT)/3.env $(OUT)/4.env $(OUT)/5.env $(OUT)/6.env $(OUT)/7.env $(OUT)/8.env

$(OUT)/ctfproxy.env:
	echo SECRET=`cat /dev/urandom | LC_CTYPE=C tr -dc "a-z0-9!@#$%^&*(-_=+)" | head -c 50` > $(OUT)/ctfproxy.env
	cat $(OUT)/0.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/1.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/2.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/3.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/4.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/5.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/6.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/7.env >> $(OUT)/ctfproxy.env
	cat $(OUT)/8.env >> $(OUT)/ctfproxy.env

$(OUT)/0.env:
	echo LEVEL0_PW=`base64 /dev/urandom | head -c 10` > $(OUT)/0.env

$(OUT)/1.env:
	echo LEVEL1_PW=`base64 /dev/urandom | head -c 10` > $(OUT)/1.env

$(OUT)/2.env:
	echo LEVEL2_PW=`base64 /dev/urandom | head -c 10` > $(OUT)/2.env

$(OUT)/3.env:
	echo LEVEL3_PW=`base64 /dev/urandom | head -c 10` > $(OUT)/3.env

$(OUT)/4.env:
	echo LEVEL4_PW=`base64 /dev/urandom | head -c 10` > $(OUT)/4.env

$(OUT)/5.env:
	echo LEVEL5_PW=`base64 /dev/urandom | head -c 10` > $(OUT)/5.env

$(OUT)/6.env:
	echo LEVEL6_PW=`cat /dev/urandom | LC_CTYPE=C tr -dc "A-Z0-9\"'" | fold -w 16 | grep "'" | grep "\"" | head -n 1 | tr -d '\n'` > $(OUT)/6.env

$(OUT)/7.env:
	echo LEVEL7_PW=`base64 /dev/urandom | head -c 10` > $(OUT)/7.env

$(OUT)/8.env:
	echo LEVEL8_PW=`cat /dev/urandom | LC_CTYPE=C tr -dc "0-9" | head -c 12` > $(OUT)/8.env

clean:
	rm $(OUT)/*.env

$(shell   mkdir -p $(OUT))
