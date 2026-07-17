TEMPLATE = subdirs
CONFIG += ordered

SUBDIRS += \
    qwt/src \
    qwt_patch

patch_qwt.depends = qwt

# Deploy target
macx {
    deploy.depends = $$SUBDIRS

    deploy.commands = @echo "=== DEPLOYMENT START ===" $$escape_expand(\\n\\t)
    deploy.commands += rsync -a $$shell_path($$OUT_PWD/qwt/lib/qwt.framework) $$shell_path($$[QT_INSTALL_LIBS]/) $$escape_expand(\\n\\t)
    deploy.commands += @echo "=== DEPLOYMENT END ===" $$escape_expand(\\n\\t)

    QMAKE_EXTRA_TARGETS += deploy
}
