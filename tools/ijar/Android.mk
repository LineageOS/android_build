ifeq ($(HOST_OS_IS_WSL), true)
LOCAL_CFLAGS := -DHOST_OS_IS_WSL
endif