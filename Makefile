.PHONY:	all

ROOT_DIRNAME:=$(shell basename $(CURDIR))

c:
	flutter clean
i:
	flutter pub get
t:
	flutter test
bios:
	flutter build ios
band:
	flutter build appbundle

brb:
	flutter packages pub run build_runner build
brbc:
	flutter packages pub run build_runner build --delete-conflicting-outputs
brw:
	flutter packages pub run build_runner watch

