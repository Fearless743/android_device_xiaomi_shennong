# minimal-manifest-twrp 自带 release 配置为空, 这里声明一个空的 trunk_staging,
# 让 A14 的三段式 lunch (omni_shennong-trunk_staging-eng) 能通过 release 校验.
# recovery-only 构建不需要 aconfig flag, 空文件即可.
$(call declare-release-config, trunk_staging, device/xiaomi/shennong/release/trunk_staging.scl)
