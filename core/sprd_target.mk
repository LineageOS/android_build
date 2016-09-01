# Target-specific configuration

ifeq ($(BOARD_USES_SPRD_HARDWARE),true)

sprd_flags := -DSPRD_HARDWARE

TARGET_GLOBAL_CFLAGS += $(sprd_flags)
TARGET_GLOBAL_CPPFLAGS += $(sprd_flags)
CLANG_TARGET_GLOBAL_CFLAGS += $(sprd_flags)
CLANG_TARGET_GLOBAL_CPPFLAGS += $(sprd_flags)

endif
