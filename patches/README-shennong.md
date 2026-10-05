# shennong A17 解密补丁说明 (移植自 Pixel8Pro A17 PBRP)

来源: https://github.com/Lauk1z/Pixel8Pro-Android17-PBRP-Recovery
(`PATCH_ORDER.md`, `BUILD_INFO.env` 引用的 `leegarchat/twrp_device_google_pixels@b8f8407` RC5 链)

## 能直接复用的通用补丁 (已放入 `patches/`, 按原编号顺序打)

**twrp-14 适配说明**: 0001/0002 已按 twrp-14 的 `partitionmanager.cpp` 重写;
0005 目标改为 `hardware/interfaces/weaver/aidl` (AOSP 真实路径);
0006 已删除 (twrp-14 的 vold 无 weaver 链接点, houji 同方案已验证可解);
0007/0008/0010/0011 合并为 `0007-recovery-twrp14-crypto-links-metadata.patch` (twrp-14 上下文版)。

| 补丁 | 目标源码 | 作用, 为何 shennong 也需要 |
|---|---|---|
| 0001+0002 | `bootable/recovery` | 解密期间保持 `/vendor` 挂载 (`TW_KEEP_VENDOR_MOUNTED_FOR_CRYPTO`), AIDL HAL 不掉线; BoardConfig 已加该 flag |
| 0003 | `system/security/keystore2` | recovery 下跳过 shared-secret 协商 (recovery 无 auth 上下文) |
| 0004 | `system/security/keystore2` | 缺 StrongBox 时直接返回不可用, 避免卡死 (shennong 有 NXP strongbox, 留作兼容) |
| 0005-0008 | `hardware/interfaces/security`, `system/vold`, `bootable/recovery` | Weaver AIDL `recovery_available` + 链接 `weaver-V2-ndk` (SM8650 用 AIDL Weaver V2, 必需) |
| 0009 | `system/security/keystore2` | **A17 关键**: 接受 `>=300` 的新版 KeyMint (A17 可能是 v4, 旧代码只认 300 会拒) |
| 0010 | `bootable/recovery` | **metadata 解密关键**: fork 短命子进程调 `fscrypt_mount_metadata_encrypted` + 30s 超时, 避免 vold 全局 fstab 状态污染长命 recovery 进程 |
| 0011 | `bootable/recovery` | 子进程用 `_exit` 代替 `exit`, 不跑析构 |
| 0012 | `system/vold` | **FBE 关键**: recovery 自己建缺失的 `fscrypt` session keyring (init 的 mount_all 路径在 recovery 被 bypass) |
| `source-overlays/system/vold/Weaver1.*` | `system/vold` | AIDL 优先 + HIDL 兜底的双栈 Weaver, 覆盖 QCOM NXP Weaver 各种版本 |

打补丁方法 (从各目标源码根目录):
```bash
git apply --check patches/0001-*.patch && git apply patches/0001-*.patch
# ... 按 0001→0012 顺序
cp source-overlays/system/vold/Weaver1.* system/vold/
```

## 不能照抄的 Pixel 专用部分 (已剔除, shennong 用自己的 QCOM 等价物)

* `device-overlay/recovery/root/init.recovery.zuma.rc` 里的 `trusty-ipc-dev0 / recovery_storageproxyd / rust.trusty KeyMint / gsc0 Titan-M2 Weaver` — 那是 Tensor G3 链.
  shennong (SM8650/QSEE) 继续用本树 `recovery/root/` 下现有的 `qseecomd / keymint-service-qti / gatekeeper-service-qti / weaver-service.nxp / secure_element` 那套 rc, 不要覆盖.
* `device-overlay/.../vintf/manifest*.xml` 里 `IGatekeeper/default + IWeaver/default` 的 Pixel 写法 — shennong 从原厂 `vendor/etc/vintf` 提取 QTI/NXP 的 manifest 即可.
* `system.prop` 里 `ro.board.platform=zuma / ro.build.version.release=17` 等 Pixel 属性 — shennong 保持 `pineapple` 平台属性.

## shennong 还要自己做的

1. `./extract-files.sh adb` 从 A17 原厂拉 QCOM blobs (`proprietary-files.txt` 清单), `prebuilt/kernel` 必须换 A17 内核 (否则 inlinecrypt/wrappedkey 不支持).
2. 按 `RUNTIME_VALIDATION.md` 思路实机验证: `/metadata` 可挂载 → `/dev/block/dm-*` (metadata mapper) 出现 → 用户0 DE 初始化 → PIN CE 解锁 → `/data/user/0 /sdcard` 可读.
