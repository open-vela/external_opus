#
# Copyright (C) 2020 Xiaomi Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include $(APPDIR)/Make.defs

include silk_sources.mk
include celt_sources.mk
include opus_sources.mk

CSRCS += $(OPUS_SOURCES)
CSRCS += $(OPUS_SOURCES_FLOAT) # FLOAT API required
CSRCS += $(SILK_SOURCES)
CSRCS += $(SILK_SOURCES_FIXED)
CSRCS += $(CELT_SOURCES)

ifeq ($(CONFIG_ARCH_SIM),y)
  CSRCS += $(CELT_SOURCES_SSE)
endif

ifeq ($(CONFIG_ARCH_ARM),y)
  CSRCS += $(CELT_SOURCES_ARM)
  ASRCS += celt/arm/celt_pitch_xcorr_arm-gnu.S
ifeq ($(CONFIG_ARM_HAVE_NEON),y)
  CSRCS += $(SILK_SOURCES_ARM_NEON_INTR)
  CSRCS += $(SILK_SOURCES_FIXED_ARM_NEON_INTR)
  CSRCS += $(CELT_SOURCES_ARM_NEON_INTR)
endif
ifeq ($(CONFIG_LIB_NE10),y)
  CSRCS += $(CELT_SOURCES_ARM_NE10)
endif
endif

MODULE    = $(CONFIG_LIB_OPUS)
PRIORITY  = $(CONFIG_LIB_OPUS_PRIORITY)
STACKSIZE = $(CONFIG_LIB_OPUS_STACKSIZE)

ifneq ($(CONFIG_LIB_OPUS_DECODE_TEST),)
  PROGNAME += opus_dectest
  MAINSRC  += tests/test_opus_decode.c
endif

ifneq ($(CONFIG_LIB_OPUS_ENCODE_TEST),)
  PROGNAME += opus_enctest
  MAINSRC  += tests/test_opus_encode.c
  CSRCS    += tests/opus_encode_regressions.c
endif

CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" .}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" include}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" celt}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" silk}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" silk/fixed}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" $(APPDIR)/external/Ne10/inc}
CFLAGS += -DHAVE_CONFIG_H

ifeq ($(CONFIG_ARCH_ARM),y)
CFLAGS += -DEMBEDDED_ARM=1
else
CFLAGS += -DEMBEDDED_ARM=0
CFLAGS += -D__OPTIMIZE__
endif

celt/arm/celt_pitch_xcorr_arm-gnu.S:
ifeq ($(CONFIG_ARCH_ARM),y)
	./celt/arm/arm2gnu.pl < celt/arm/celt_pitch_xcorr_arm.s > celt/arm/celt_pitch_xcorr_arm-gnu.S
endif

context:: celt/arm/celt_pitch_xcorr_arm-gnu.S

clean::
	$(call DELFILE, celt/arm/celt_pitch_xcorr_arm-gnu.S)

include $(APPDIR)/Application.mk
