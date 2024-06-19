SHELL := /bin/bash

################################## Buildroot ###################################

.PHONY: default
default: all

OS := $(shell uname -s)
ifneq ($(OS),Darwin)

all menuconfig defconfig: $(O)/.config

## Making sure defconfig is already run
$(O)/.config: 
	$(MAKE) raspberrypizero2w_defconfig

BR2_EXTERNAL := $(CURDIR)
BR2_DEFCONFIG := $(CURDIR)/configs/raspberrypizero2w_defconfig
O := $(CURDIR)/build
include $(BR2_DEFCONFIG)
export

endif

.PHONY: %
ifeq ($(OS),Darwin)
%:
	mkdir -p build/images
	docker run --init --rm -it --privileged \
		-v .:/home/user/br-rpizero2 \
		-v ./build/images:/home/user/images \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--platform linux/amd64 br-rpizero2 \
		sudo -H -u user bash -c "cd /home/user/br-rpizero2 && sudo mount -o loop build.img build && sudo chown user:users build && mkdir -p build/images && sudo mount --bind /home/user/images build/images && make $*"
else
## Pass targets to buildroot
%:
	env - PATH=$(PATH) USER=$(USER) HOME=$(HOME) TERM=$(TERM) \
		$(MAKE) BR2_EXTERNAL=$(BR2_EXTERNAL) BR2_DEFCONFIG=$(BR2_DEFCONFIG) O=$(O) -C buildroot $*
endif

#################################### Linux ####################################

export LINUX_DIR = $(strip $(O)/build/linux-$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION))

## Generate reference defconfig with missing options set to default as a base for comparison using diffconfig
$(LINUX_DIR)/.$(BR2_LINUX_KERNEL_DEFCONFIG)_defconfig:
	$(MAKE) -C $(LINUX_DIR) KCONFIG_CONFIG=$@ ARCH=arm $(BR2_LINUX_KERNEL_DEFCONFIG)_defconfig

## Generate diff with reference config
linux-diffconfig: $(LINUX_DIR)/.$(BR2_LINUX_KERNEL_DEFCONFIG)_defconfig linux-extract
	$(LINUX_DIR)/scripts/diffconfig -m $< $(LINUX_DIR)/.config > $(BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES)

############################# Docker #############################

.PHONY: docker-build
docker-build:
	docker build -t br-rpizero2 .

build.img:
	truncate -s 20G build.img
	docker run --init --rm -it \
		-v .:/home/user/br-rpizero2 \
		--platform linux/amd64 br-rpizero2 \
		sudo -H -u user bash -c "cd /home/user/br-rpizero2 && mkfs.ext4 build.img"

.PHONY: docker-bash
docker-bash: build.img
	xhost+
	mkdir -p build/images
	docker run --init --rm -it --privileged \
		-e DISPLAY=host.docker.internal:0 \
		-v .:/home/user/br-rpizero2 \
		-v ./build/images:/home/user/images \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--platform linux/amd64 br-rpizero2 \
		sudo -H -u user bash -c "cd /home/user/br-rpizero2 && sudo mount -o loop build.img build && sudo chown user:users build && mkdir -p build/images && sudo mount --bind /home/user/images build/images && bash"

flash-%: build/images/sdcard.img
	@if df | grep '/Volumes/' | grep $*; then \
		(diskutil umount /dev/$*s1 || true) && \
		dd if=$< of=/dev/$* bs=4k status=progress && \
		sync; \
	else echo "Invalid device"; \
	fi