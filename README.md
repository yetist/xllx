# xllx

xllx is XunLei LiXian api.

xllx 计划用C语言实现的迅雷离线API，目前只完成了迅雷云播功能。此API需要迅雷会员帐户才能使用。

## 已完成功能：

### 迅雷云点播

- 迅雷云点播

## 计划开发功能：

- 迅雷离线API

## 安装：

	./autogen.sh
	./configure --prefix=/usr
	sudo make install

## 测试：

	cd tests
	./tests <迅雷用户名> <迅雷密码> urls.txt

返回urls.txt文件中提供的url对应的播放地址。
