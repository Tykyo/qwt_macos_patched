TEMPLATE = subdirs

CONFIG += ordered

SUBDIRS += \
    qwt/src \
    qwt_patch

patch_qwt.depends = qwt
