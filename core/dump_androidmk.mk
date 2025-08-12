ifeq ($(LOCAL_RECORDED_MODULE_TYPE_IS),)
$(warning LOCAL_RECORDED_MODULE_TYPE_IS is empty for module $(LOCAL_MODULE))
endif

_out := $(LOCAL_PATH)/Android_mk_dump

ifeq ($(filter $(LOCAL_PATH),$(ALL_DUMP_ANDROIDMK_LOCAL_PATH)),)
$(shell echo 'LOCAL_PATH := $$(call my-dir)' > $(_out))
$(shell echo >> $(_out))
ALL_DUMP_ANDROIDMK_LOCAL_PATH += $(LOCAL_PATH)
$(warning Dump Android.mk in $(LOCAL_PATH))
endif

$(shell echo 'include $$(CLEAR_VARS)' >> $(_out))

ifeq ($(LOCAL_CXX_STL),default)
BAK_LOCAL_CXX_STL := $(LOCAL_CXX_STL)
LOCAL_CXX_STL :=
endif
ifeq ($(LOCAL_SYSTEM_SHARED_LIBRARIES),none)
BAK_LOCAL_SYSTEM_SHARED_LIBRARIES := $(LOCAL_SYSTEM_SHARED_LIBRARIES)
LOCAL_SYSTEM_SHARED_LIBRARIES :=
endif

$(foreach var,$(shell cat $(BUILD_SYSTEM)/soong_androidmk_wanted_vars.txt),\
    $(eval val := $(strip $($(var))))\
    $(if $(val),\
        $(shell echo '$(var) := $(val)' >> $(_out))))

ifneq ($(BAK_LOCAL_CXX_STL),)
LOCAL_CXX_STL := $(BAK_LOCAL_CXX_STL)
BAK_LOCAL_CXX_STL :=
endif
ifneq ($(BAK_LOCAL_SYSTEM_SHARED_LIBRARIES),)
LOCAL_SYSTEM_SHARED_LIBRARIES := $(BAK_LOCAL_SYSTEM_SHARED_LIBRARIES)
BAK_LOCAL_SYSTEM_SHARED_LIBRARIES :=
endif

$(shell echo 'include $$(BUILD_$(LOCAL_RECORDED_MODULE_TYPE_IS))' >> $(_out))
$(shell echo >> $(_out))

$(shell sed -i 's|$(LOCAL_PATH)|$$(LOCAL_PATH)|g' $(_out))

_out:=
var:=
val:=
