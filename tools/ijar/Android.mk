ifeq ($(HOST_OS_IS_WSL), true)
LOCAL_C_FLAGS += -DHOST_OS_IS_WSL
endif