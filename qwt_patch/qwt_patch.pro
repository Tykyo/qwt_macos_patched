TEMPLATE = aux

macx {
    QMAKE_EXTRA_TARGETS += patch_qwt

    TARGET_FRAMEWORK = $$shell_path($$OUT_PWD/../qwt/lib/qwt.framework)
    TARGET_EXE = $$shell_path($$TARGET_FRAMEWORK/Versions/6/qwt)

    patch_qwt.commands = install_name_tool \
        -id @rpath/qwt.framework/Versions/6/qwt \
        $$TARGET_EXE $$escape_expand(\\n\\t)

    # Path to custom macOS codesigning/packaging script
    CODESIGN_SCRIPT = $$shell_path($$PWD/../script/codesign.sh)

    # Handle code signing
    exists($$CODESIGN_SCRIPT) {
        # Execute the custom code signing script if present in the environment
        patch_qwt.commands += bash $$CODESIGN_SCRIPT $$TARGET_FRAMEWORK $$escape_expand(\\n\\t)
        message("Deployment script found: $$CODESIGN_SCRIPT")
    } else {
        # Fallback: self-sign the bundle locally if the dedicated script is missing
        warning("Deployment script not found: $$CODESIGN_SCRIPT. Performing local ad-hoc signing.")
        patch_qwt.commands += codesign --force -s - $$TARGET_FRAMEWORK $$escape_expand(\\n\\t)
    }

    PRE_TARGETDEPS += patch_qwt
}
