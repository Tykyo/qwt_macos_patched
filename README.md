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

## Using the patched framework

The generated framework can be linked normally from a Qt application.

For debug builds, simply copy the framework into:

```text
MyApplication.app/Contents/Frameworks
```

For release builds, `macdeployqt6` can bundle the framework correctly once the install name has been patched.

## Installing the framework

The generated framework can be installed in the standard macOS framework location:

```bash
sudo cp -R qwt.framework /Library/Frameworks/
```

Qt Creator and qmake can then find it automatically, allowing multiple projects to share the same Qwt installation.

When building a release application, `macdeployqt6` will automatically copy the framework into the application bundle.

## Why patch the framework?

Without the `install_name_tool` fix, applications may fail to locate `qwt.framework` after it has been deployed inside an application bundle.

The patched framework uses:

```text
@rpath/qwt.framework/Versions/6/qwt
```

which is the recommended form for frameworks embedded in macOS applications.

## Tested with

* Qwt 6.2.0
* Qt 6.10.x
* macOS (Apple Silicon)

## License

This repository only contains the build helper project.

Qwt remains licensed under its original license. See the `qwt/` directory for the original copyright and license information.
