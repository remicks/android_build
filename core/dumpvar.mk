# ---------------------------------------------------------------
# the setpath shell function in envsetup.sh uses this to figure out
# what to add to the path given the config we have chosen.
ifneq ($(BUILD_WITH_COLORS),0)
  CL_RED="\033[31m"
  CL_GRN="\033[32m"
  CL_YLW="\033[33m"
  CL_BLU="\033[34m"
  CL_MAG="\033[35m"
  CL_CYN="\033[36m"
  CL_RST="\033[0m"
endif
ifeq ($(CALLED_FROM_SETUP),true)

ifneq ($(filter /%,$(HOST_OUT_EXECUTABLES)),)
ABP:=$(HOST_OUT_EXECUTABLES)
else
ABP:=$(PWD)/$(HOST_OUT_EXECUTABLES)
endif

# Add the ARM toolchain bin dir if it actually exists
ifeq ($(TARGET_ARCH),arm)
    ifneq ($(wildcard $(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-linux-androideabi-$(TARGET_GCC_VERSION_AND)/bin),)
        # this should be copied to HOST_OUT_EXECUTABLES instead
        ABP:=$(ABP):$(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-linux-androideabi-$(TARGET_GCC_VERSION_AND)/bin
    endif
    ifneq ($(wildcard $(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-eabi-$(TARGET_GCC_VERSION_ARM)/bin),)
        # this should be copied to HOST_OUT_EXECUTABLES instead
        ABP:=$(ABP):$(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-eabi-$(TARGET_GCC_VERSION_ARM)/bin
    endif
else ifeq ($(TARGET_ARCH),x86)

# Add the x86 toolchain bin dir if it actually exists
    ifneq ($(wildcard $(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/x86/i686-linux-android-$(TARGET_GCC_VERSION_AND)/bin),)
        # this should be copied to HOST_OUT_EXECUTABLES instead
        ABP:=$(ABP):$(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/x86/i686-linux-android-$(TARGET_GCC_VERSION_AND)/bin
    endif
endif

# Add the mips toolchain bin dir if it actually exists
ifneq ($(wildcard $(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/mips/mipsel-linux-android-$(TARGET_GCC_VERSION_AND)/bin),)
    # this should be copied to HOST_OUT_EXECUTABLES instead
    ABP:=$(ABP):$(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/mips/mipsel-linux-android-$(TARGET_GCC_VERSION_AND)/bin
endif

ANDROID_BUILD_PATHS := $(ABP)
ANDROID_PREBUILTS := prebuilt/$(HOST_PREBUILT_TAG)
ANDROID_GCC_PREBUILTS := prebuilts/gcc/$(HOST_PREBUILT_TAG)

# The "dumpvar" stuff lets you say something like
#
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-TARGET_OUT
# or
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-abs-HOST_OUT_EXECUTABLES
#
# The plain (non-abs) version just dumps the value of the named variable.
# The "abs" version will treat the variable as a path, and dumps an
# absolute path to it.
#
dumpvar_goals := \
	$(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals

  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    ifneq ($(filter /%,$($(dumpvar_goals))),)
      DUMPVAR_VALUE := $($(dumpvar_goals))
    else
      DUMPVAR_VALUE := $(PWD)/$($(dumpvar_goals))
    endif
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)

endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG:=
endif

endif # CALLED_FROM_SETUP


ifneq ($(PRINT_BUILD_CONFIG),)
HOST_OS_EXTRA:=$(shell python -c "import platform; print(platform.platform())")
$(info $(shell clear))
$(info $(shell echo -e ${CL_CYN}=======================${CL_RST}))
$(info $(shell echo ))
$(info $(shell echo -e ${CL_CYN}Welcome to Plain-Andy${CL_RST}))
$(info $(shell echo ))
$(info $(shell echo -e ${CL_CYN}=======================${CL_RST}))
$(info $(shell echo ))
$(info $(shell sleep 1))
$(info $(shell clear))
$(info $(shell echo -e ${CL_CYN}============================================${CL_RST}))
$(info   $(shell echo -e ${CL_YLW}ROM_BUILD_TYPE=${CL_RST})$(shell echo -e ${CL_CYN}$(ROM_BUILDTYPE)${CL_RST}))
$(info   $(shell echo -e ${CL_YLW}PLATFORM_VERSION_CODENAME=${CL_RST})$(PLATFORM_VERSION_CODENAME))
$(info   $(shell echo -e ${CL_YLW}PLATFORM_VERSION=${CL_RST})$(shell echo -e ${CL_GRN}$(PLATFORM_VERSION)${CL_RST}))
$(info   $(shell echo -e ${CL_YLW}TARGET_PRODUCT=${CL_RST})$(shell echo -e ${CL_RED}$(TARGET_PRODUCT)${CL_RST}))
$(info   $(shell echo -e ${CL_YLW}TARGET_BUILD_VARIANT=${CL_RST})$(TARGET_BUILD_VARIANT))
$(info   $(shell echo -e ${CL_YLW}TARGET_BUILD_TYPE=${CL_RST})$(TARGET_BUILD_TYPE))
ifneq ($(AROMA_BUILD),)
$(info   $(shell echo -e ${CL_GRN}AROMA_BUILD=$(AROMA_BUILD)${CL_RST}))
endif
ifneq ($(strip $(TARGET_BUILD_APPS)),)
$(info   $(shell echo -e ${CL_YLW}TARGET_BUILD_APPS=${CL_RST})$(TARGET_BUILD_APPS))
endif
$(info   $(shell echo -e ${CL_YLW}TARGET_ARCH=${CL_RST})$(TARGET_ARCH))
$(info   $(shell echo -e ${CL_YLW}TARGET_ARCH_VARIANT=${CL_RST})$(TARGET_ARCH_VARIANT))
$(info   $(shell echo -e ${CL_YLW}TARGET_CPU_VARIANT=${CL_RST})$(TARGET_CPU_VARIANT))
$(info   $(shell echo -e ${CL_YLW}HOST_ARCH=${CL_RST})$(HOST_ARCH))
$(info   $(shell echo -e ${CL_YLW}HOST_OS=${CL_RST})$(HOST_OS))
$(info   $(shell echo -e ${CL_YLW}HOST_OS_EXTRA=${CL_RST})$(HOST_OS_EXTRA))
$(info   $(shell echo -e ${CL_YLW}HOST_BUILD_TYPE=${CL_RST})$(HOST_BUILD_TYPE))
$(info   $(shell echo -e ${CL_YLW}BUILD_ID=${CL_RST})$(BUILD_ID))
$(info   $(shell echo -e ${CL_YLW}OUT_DIR=${CL_RST})$(OUT_DIR))
ifneq ($(USE_CCACHE),)
$(info   $(shell echo -e ${CL_YLW}CCACHE_DIR=$(CCACHE_DIR)${CL_RST}))
$(info   $(shell echo -e ${CL_YLW}CCACHE_BASEDIR=$(CCACHE_BASEDIR)${CL_RST}))
endif
$(info $(shell echo -e ${CL_CYN}============================================${CL_RST}))
endif
