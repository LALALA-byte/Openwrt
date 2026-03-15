#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
git clone https://github.com/chenmozhijin/luci-app-socat.git package/luci-app-socat
# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate





# 3. 修改 Makefile (4M → 8M)
echo "=== 修改 Makefile ==="
sed -i '/TLWR703/ s/4Mlzma/8Mlzma/' target/linux/ar71xx/image/Makefile

# 4. 修改 mktplinkfw.c (4M → 8M)
echo "=== 修改 mktplinkfw.c ==="
sed -i '/TL-WR703Nv1/,/layout/{s/4Mlzma/8Mlzma/;}' tools/firmware-utils/src/mktplinkfw.c

# 5. 在 mktplinkfw.c 中添加 8M layout 定义
echo "=== 添加 8M layout 定义 ==="
sed -i '/static struct flash_layout layouts\[\] = {/a\
\	{\
\		.id		= "8Mlzma",\
\		.fw_max_len	= 0x7c0000,\
\		.kernel_la	= 0x80060000,\
\		.kernel_ep	= 0x80060000,\
\		.rootfs_ofs	= 0x100000,\
\	},' tools/firmware-utils/src/mktplinkfw.c

# 6. 修改 tiny.mk 中的 IMAGE_SIZE
echo "=== 修改 tiny.mk ==="
sed -i 's/IMAGE_SIZE := 4064k/IMAGE_SIZE := 8128k/g' target/linux/ar71xx/image/tiny.mk

# ==========================================

exit 0
