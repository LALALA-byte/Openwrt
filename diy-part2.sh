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




# ==========================================
# OpenWrt 自定义配置 - TL-WR703N 8MB 闪存
# ==========================================

# 注意：源码目录是当前目录，不需要 cd openwrt
# 从日志看：/home/runner/work/Openwrt/Openwrt/diy-part2.sh: line 26: cd: openwrt: No such file or directory

# ==========================================
# 2. 修改 tiny-tp-link.mk（关键！不是 tiny.mk）
# ==========================================
echo "=== 修改 tiny-tp-link.mk ==="

# 修改 IMAGE_SIZE 为 8128k（8MB 闪存可用空间）
sed -i 's/IMAGE_SIZE := 16000k/IMAGE_SIZE := 8128k/g' target/linux/ar71xx/image/tiny-tp-link.mk
sed -i 's/IMAGE_SIZE := 4064k/IMAGE_SIZE := 8128k/g' target/linux/ar71xx/image/tiny-tp-link.mk

# 确认修改
grep "IMAGE_SIZE" target/linux/ar71xx/image/tiny-tp-link.mk | head -5

# ==========================================
# 3. 修改 Makefile（4M → 8M）
# ==========================================
echo "=== 修改 Makefile ==="
sed -i 's/4Mlzma/8Mlzma/g' target/linux/ar71xx/image/Makefile

# ==========================================
# 4. 修改 mktplinkfw.c（关键！）
# ==========================================
echo "=== 修改 mktplinkfw.c ==="

# 4.1 将 4Mlzma 改为 8Mlzma
sed -i 's/4Mlzma/8Mlzma/g' tools/firmware-utils/src/mktplinkfw.c

# 4.2 修正 8Mlzma 的 fw_max_len（从 0x3c0000 改为 0x7c0000）
sed -i '/\.id.*=.*"8Mlzma"/,/\.rootfs_ofs/{s/\.fw_max_len.*=.*0x3c0000/.fw_max_len\t= 0x7c0000/}' tools/firmware-utils/src/mktplinkfw.c

# 4.3 如果 8Mlzma layout 不存在，添加它
if ! grep -q '\.id.*=.*"8Mlzma"' tools/firmware-utils/src/mktplinkfw.c; then
    echo "添加 8Mlzma layout 定义..."
    sed -i '/static struct flash_layout layouts\[\] = {/a\
\	{\
\		.id\t\t= "8Mlzma",\
\		.fw_max_len\t= 0x7c0000,\
\		.kernel_la\t= 0x80060000,\
\		.kernel_ep\t= 0x80060000,\
\		.rootfs_ofs\t= 0x100000,\
\	},' tools/firmware-utils/src/mktplinkfw.c
fi

# 确认修改
grep -A5 '"8Mlzma"' tools/firmware-utils/src/mktplinkfw.c | head -10

# ==========================================
# 5. 修改 common-tp-link.mk（确保使用 8Mlzma）
# ==========================================
echo "=== 修改 common-tp-link.mk ==="
sed -i 's/TPLINK_FLASHLAYOUT := 4Mlzma/TPLINK_FLASHLAYOUT := 8Mlzma/g' target/linux/ar71xx/image/common-tp-link.mk
grep "TPLINK_FLASHLAYOUT" target/linux/ar71xx/image/common-tp-link.mk

# ==========================================

exit 0

exit 0
