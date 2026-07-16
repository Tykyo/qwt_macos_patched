TEMPLATE = subdirs
CONFIG += ordered

SUBDIRS += \
    qwt/src \
    qwt_patch

patch_qwt.depends = qwt

macx {
    deploy.depends = $$SUBDIRS

    deploy.commands = @echo "=== DEPLOYMENT START ===" $$escape_expand(\\n\\t)
    deploy.commands += rsync -a $$OUT_PWD/qwt/lib/qwt.framework $$quote($$[QT_INSTALL_LIBS]/) $$escape_expand(\\n\\t)
    deploy.commands += @echo "=== DEPLOYMENT END ===" $$escape_expand(\\n\\t)

    QMAKE_EXTRA_TARGETS += deploy
}

