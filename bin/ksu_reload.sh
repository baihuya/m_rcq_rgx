# 强制 KernelSU
if [ "$KSU" != "true" ]; then
  abort "本模块**仅限 KernelSU**临时root（越狱模式）使用！\n请勿在 Magisk / APatch 等环境下安装。"
fi

ui_print "→ KernelSU v$KSU_VER ($KSU_VER_CODE) 检测通过"


KSU_DIR="/data/adb/ksu"

# === ksud 启动阶段 ===
echo "=== 执行启动阶段 ==="
"$KSU_DIR/bin/ksud" post-fs-data 2>&1

# 修复: 删除 KSU 自己创建的 magisk 兼容符号链接
# 否则 Manager 的 hasMagisk() 会通过 root shell 的 which magisk 找到它
# 导致误报 "因与magisk有冲突 所有模块不可用"
if [ -L "$KSU_DIR/bin/magisk" ]; then
    rm -f "$KSU_DIR/bin/magisk"
    echo "已移除 magisk 兼容链接 (防止误检测)"
fi

"$KSU_DIR/bin/ksud" services 2>&1
"$KSU_DIR/bin/ksud" boot-completed 2>&1
echo "启动阶段完成"
echo ""

# === 触发 KernelSU 识别 ===
echo "=== 触发 KernelSU 识别 ==="

APK_PATH=$(pm path me.weishu.kernelsu 2>/dev/null | head -1 | cut -d: -f2)
[ -z "$APK_PATH" ] && APK_PATH=$(pm path com.sukisu.ultra 2>/dev/null | head -1 | cut -d: -f2)
[ -z "$APK_PATH" ] && APK_PATH=$(pm path com.resukisu.resukisu 2>/dev/null | head -1 | cut -d: -f2)

if [ -z "$APK_PATH" ]; then
  echo "未识别到KSU! 非原始包名"
  echo "请自行将当前KSU的安装包命名为'Ksu.apk'并放置到/data/local/tmp目录下，并在切换KSU前记得删除或修改"
  echo "覆盖安装中"
  pm install -r /data/local/tmp/Ksu.apk
else
  echo "已识别到KSU，正在自动覆盖安装，卡住手动重新安装KSU触发重载"
  echo "APK路径: $APK_PATH"
  echo "复制到临时目录"
  cp "$APK_PATH" /data/adb/modules/m_rcq/_mgr_tmp.apk
  echo "覆盖安装中"
  pm install -r /data/adb/modules/m_rcq/_mgr_tmp.apk
  rm -f /data/adb/modules/m_rcq/_mgr_tmp.apk
  echo "正在清除临时文件"
fi

   echo "[OK]  模块重载完成"