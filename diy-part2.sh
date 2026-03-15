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





cd openwrt

# ==========================================
# 1. 修改 .config 配置
# ==========================================
cat >> .config << EOF
CONFIG_TARGET_ar71xx=y
CONFIG_TARGET_ar71xx_tiny=y
CONFIG_TARGET_ar71xx_tiny_DEVICE_tl-wr703n-v1=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_ROOTFS_INITRAMFS=y
CONFIG_TARGET_IMAGES_GZIP=y
CONFIG_TARGET_SQUASHFS_BLOCK_SIZE=1024
EOF

make defconfig

# ==========================================
# 2. 调试：查找相关文件
# ==========================================
echo "=== 查找 Makefile ==="
find target/linux/ar71xx/image -name "Makefile" -o -name "*.mk" | head -20

echo "=== 查找 mktplinkfw.c ==="
find tools -name "mktplinkfw.c"

echo "=== 查找 tiny.mk ==="
find target/linux/ar71xx/image -name "tiny.mk"

# ==========================================
# 3. 修改 Makefile
# ==========================================
echo "=== 修改前 Makefile 内容 ==="
grep -n "TLWR703\|wr703n\|WR703" target/linux/ar71xx/image/Makefile 2>/dev/null || \
grep -rn "TLWR703\|wr703n\|WR703" target/linux/ar71xx/image/ 2>/dev/null | head -10

echo "=== 执行 Makefile 修改 ==="
sed -i 's/4Mlzma/8Mlzma/g' target/linux/ar71xx/image/Makefile 2>/dev/null
sed -i 's/4Mlzma/8Mlzma/g' target/linux/ar71xx/image/tiny.mk 2>/dev/null

echo "=== 修改后 Makefile 内容 ==="
grep -n "TLWR703\|wr703n\|WR703\|8Mlzma" target/linux/ar71xx/image/Makefile 2>/dev/null || \
grep -rn "TLWR703\|wr703n\|WR703\|8Mlzma" target/linux/ar71xx/image/ 2>/dev/null | head -10

# ==========================================
# 4. 修改 mktplinkfw.c
# ==========================================
echo "=== 修改前 mktplinkfw.c 内容 ==="
grep -A5 "TL-WR703Nv1\|4Mlzma" tools/firmware-utils/src/mktplinkfw.c 2>/dev/null | head -20

echo "=== 执行 mktplinkfw.c 修改 ==="
sed -i 's/4Mlzma/8Mlzma/g' tools/firmware-utils/src/mktplinkfw.c 2>/dev/null

# 添加 8M layout 定义（关键！）
cat >> /tmp/8m_layout.txt << 'EOF'
	{
		.id		= "8Mlzma",
		.fw_max_len	= 0x7c0000,
		.kernel_la	= 0x80060000,
		.kernel_ep	= 0x80060000,
		.rootfs_ofs	= 0x100000,
	},
EOF

# 在 layouts 数组开头添加 8M 定义
sed -i '/static struct flash_layout layouts\[\] = {/r /tmp/8m_layout.txt' tools/firmware-utils/src/mktplinkfw.c 2>/dev/null

echo "=== 修改后 mktplinkfw.c 内容 ==="
grep -A10 "8Mlzma\|TL-WR703Nv1" tools/firmware-utils/src/mktplinkfw.c 2>/dev/null | head -30

# ==========================================
# 5. 修改 IMAGE_SIZE
# ==========================================
echo "=== 修改 tiny.mk IMAGE_SIZE ==="
sed -i 's/IMAGE_SIZE := 4064k/IMAGE_SIZE := 8128k/g' target/linux/ar71xx/image/tiny.mk 2>/dev/null
grep "IMAGE_SIZE" target/linux/ar71xx/image/tiny.mk 2>/dev/null | head -5

# ==========================================

exit 0
