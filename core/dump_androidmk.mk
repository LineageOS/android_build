ifneq ($(LOCAL_DUMP_ANDROIDMK_FINISHED),true)

ifeq ($(LOCAL_RECORDED_MODULE_TYPE_IS),)
$(warning LOCAL_RECORDED_MODULE_TYPE_IS is empty for module $(LOCAL_MODULE))
endif

_out := $(LOCAL_PATH)/Android_mk_dump

# Only if it's the first time processing this Android.mk
ifeq ($(filter $(LOCAL_PATH),$(ALL_DUMP_ANDROIDMK_LOCAL_PATH)),)
# Override the output file with header
$(shell echo 'LOCAL_PATH := $$(call my-dir)' > $(_out))
$(shell echo >> $(_out))
ALL_DUMP_ANDROIDMK_LOCAL_PATH += $(LOCAL_PATH)
$(warning Dump Android.mk in $(LOCAL_PATH))
endif

# Beginning of module
$(shell echo 'include $$(CLEAR_VARS)' >> $(_out))

BAK_LOCAL_C_INCLUDES := $(LOCAL_C_INCLUDES)
LOCAL_C_INCLUDES :=
# Process LOCAL_C_INCLUDES. If the path is present, remove "../"; If absent, print warning and skip it.
$(foreach inc,$(BAK_LOCAL_C_INCLUDES),\
	$(if $(wildcard $(inc)),\
		$(eval LOCAL_C_INCLUDES += $(shell realpath $(inc) --relative-to=$$ANDROID_BUILD_TOP))\
	,\
		$(warning Include path $(inc) is missing for module $(LOCAL_MODULE))\
	))

# Clear variables set by clear_vars.mk
ifeq ($(LOCAL_CXX_STL),default)
BAK_LOCAL_CXX_STL := $(LOCAL_CXX_STL)
LOCAL_CXX_STL :=
endif
ifeq ($(LOCAL_SYSTEM_SHARED_LIBRARIES),none)
BAK_LOCAL_SYSTEM_SHARED_LIBRARIES := $(LOCAL_SYSTEM_SHARED_LIBRARIES)
LOCAL_SYSTEM_SHARED_LIBRARIES :=
endif

_conditional_vars :=
# Collect a list of variables like LOCAL_SRC_FILES_arm64
$(foreach prefix,$(shell cat $(BUILD_SYSTEM)/soong_androidmk_wanted_conditional_vars_prefix.txt),\
	$(foreach suffix,32 64 arm arm64 x86 x86_64,\
		$(eval _conditional_vars += $(prefix)$(suffix))))

# Dump the variable to output if it's not empty
$(foreach var,$(shell cat $(BUILD_SYSTEM)/soong_androidmk_wanted_vars.txt) $(_conditional_vars),\
	$(eval val := $(subst ',,$(strip $($(var)))))\
	$(if $(val),\
		$(shell echo '$(var) := $(val)' >> $(_out))))

# Restore modified variables
LOCAL_C_INCLUDES := $(BAK_LOCAL_C_INCLUDES)
BAK_LOCAL_C_INCLUDES :=
ifneq ($(BAK_LOCAL_CXX_STL),)
LOCAL_CXX_STL := $(BAK_LOCAL_CXX_STL)
BAK_LOCAL_CXX_STL :=
endif
ifneq ($(BAK_LOCAL_SYSTEM_SHARED_LIBRARIES),)
LOCAL_SYSTEM_SHARED_LIBRARIES := $(BAK_LOCAL_SYSTEM_SHARED_LIBRARIES)
BAK_LOCAL_SYSTEM_SHARED_LIBRARIES :=
endif

# End of module
$(shell echo 'include $$(BUILD_$(LOCAL_RECORDED_MODULE_TYPE_IS))' >> $(_out))
$(shell echo >> $(_out))

# Replace full paths with variables
$(shell sed -i 's|$(LOCAL_PATH)|$$(LOCAL_PATH)|g' $(_out))
$(shell sed -i 's|$(TARGET_OUT)|$$(TARGET_OUT)|g' $(_out))

$(foreach dir,ROOT RECOVERY_ROOT RECOVERY RAMDISK VENDOR_RAMDISK SYSTEM_DLKM,\
	$(shell sed -i 's|$(TARGET_$(dir)_OUT)|$$(TARGET_$(dir)_OUT)|g' $(_out)))

$(foreach dir,SYSTEM_EXT PRODUCT ODM VENDOR VENDOR_DLKM,\
	$(shell sed -i 's|$(TARGET_OUT_$(dir))|$$(TARGET_OUT_$(dir))|g' $(_out)))

# Clear the locally used variables which we've set
_conditional_vars:=
_out:=
inc:=
val:=
var:=

# Avoid processing the same module again
LOCAL_DUMP_ANDROIDMK_FINISHED := true
endif # !LOCAL_DUMP_ANDROIDMK_FINISHED
