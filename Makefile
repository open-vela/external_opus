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

CSRCS  = $(wildcard celt/*.c)
CSRCS += $(wildcard silk/*.c)
CSRCS += $(wildcard silk/fixed/*.c)
CSRCS += $(wildcard src/*.c)

CSRCS += silk/arm/arm_silk_map.c
CSRCS += celt/arm/armcpu.c celt/arm/arm_celt_map.c

DEMO  := src/opus_compare.c src/repacketizer_demo.c
DEMO  += src/opus_demo.c celt/opus_custom_demo.c

CSRCS := $(filter-out $(DEMO), $(CSRCS))

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
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" include/}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" celt/}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" silk/}
CFLAGS += ${shell $(INCDIR) $(INCDIROPT) "$(CC)" silk/fixed/}
CFLAGS += -DHAVE_CONFIG_H -DEMBEDDED_ARM=1

include $(APPDIR)/Application.mk
