# Qwt 6.2.0 macOS Patched Build

This repository provides a small qmake project that builds **Qwt 6.2.0** and applies the macOS fixes required to use the generated framework inside a Qt application bundle.

The original Qwt sources are **not modified**. The framework is patched only after it has been built.

## Why is this needed?

When Qwt 6.2.0 is built as a macOS framework, its install name is generated as:

```text
qwt.framework/Versions/6/qwt
```

Instead of the modern form:

```text
@rpath/qwt.framework/Versions/6/qwt
```

Because of this, a Qt application linked against Qwt may fail to locate the framework when it is bundled inside:

```text
MyApplication.app/Contents/Frameworks
```

Even though `macdeployqt6` copies the framework correctly.

This project fixes the framework by running:

```bash
install_name_tool -id @rpath/qwt.framework/Versions/6/qwt \
    qwt.framework/Versions/6/qwt
```

The framework is then signed (either with a custom signing script or using an ad-hoc signature).

## Repository layout

```text
.
├── qwt/                  # Original Qwt sources
├── qwt_macos_patched.pro # Top-level build project
├── qwt_patch/            # Patch project
└── script/
    └── codesign.sh       # Optional custom signing script
```

## Building

Open `qwt_macos_patched.pro` in Qt Creator or build it with qmake.

The project performs two steps:

1. Build the original Qwt framework.
2. Patch the framework install name and sign it.

No modifications are made to the Qwt source tree.

## Code signing

If `script/codesign.sh` exists, it is executed after patching the framework.

Otherwise, an ad-hoc signature is applied automatically:

```bash
codesign --force -s - qwt.framework
```

This is sufficient for local development.

## Using the patched framework from a custom location

The Qwt framework does not have to be installed in the Qt directory. It can also be stored in a project-specific location.

Example:

```qmake
LIB_DIR = path/to/qwt/lib

LIBS += -F$$LIB_DIR -framework qwt
QMAKE_LFLAGS += -Wl,-F$$LIB_DIR -Wl,-framework,qwt
```

When using a custom framework location, `macdeployqt6` may not automatically copy the Qwt framework into the application bundle.

In that case, copy it manually:

```text
MyApplication.app
└── Contents
    └── Frameworks
        └── qwt.framework
```

```qmake
FRAMEWORKS_DIR = $$OUT_PWD/$${TARGET}.app/Contents/Frameworks

QMAKE_POST_LINK += mkdir -p "$$FRAMEWORKS_DIR" $$escape_expand(\\n\\t)

QMAKE_POST_LINK += rsync -a \
    "$$LIB_DIR/qwt.framework" \
    "$$FRAMEWORKS_DIR/" \
    $$escape_expand(\\n\\t)
```

and make sure the application uses:

```text
@rpath/qwt.framework/Versions/6/qwt
```

as the framework install name.

## Installing the framework

The generated framework should be installed in a location where Qt/qmake can find it.

A convenient location is the Qt installation directory:

```text
<Qt>/lib/qwt.framework
```

For example:

```bash
cp -R qwt.framework ~/Qt/6.10.3/macos/lib/
```

Do not rely on `/Library/Frameworks` for Qt projects. While macOS supports this location, qmake does not automatically add it to the framework search paths.

## Using the framework in a qmake project

Add the Qwt framework to your `.pro` file:

```qmake
INCLUDEPATH += "$$[QT_INSTALL_LIBS]/qwt.framework/Headers"

LIBS += -framework qwt
QMAKE_LFLAGS += -Wl,-framework,qwt
```

This allows qmake to locate the framework using the same Qt installation that is used to build the application.

## Why the framework is patched

The generated Qwt framework uses a non-standard install name:

```text
qwt.framework/Versions/6/qwt
```

The patch changes it to:

```text
@rpath/qwt.framework/Versions/6/qwt
```

which allows Qt applications bundled as `.app` files to locate the framework correctly.

During deployment, `macdeployqt6` can then copy the framework into:

```text
MyApplication.app/Contents/Frameworks
```

with the correct runtime paths.


## Tested with

* Qwt 6.2.0
* Qt 6.10.x
* macOS (Apple Silicon)

## License

This repository only contains the build helper project.

Qwt remains licensed under its original license. See the `qwt/` directory for the original copyright and license information.
