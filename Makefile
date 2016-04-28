
PROJECT = escpos
DEPS = iconv qrcode
dep_iconv = git https://github.com/processone/iconv 1.0.0
dep_qrcode = git https://github.com/komone/qrcode

#ERLC_OPTS += -Ddebug
#ERLC_OPTS += +debug_info
ERLC_OPTS += +no_debug_info

include erlang.mk

