# 这个 `.pri` 文件是一个 Qt 项目文件，用于定义和管理 QDicomViewer 应用程序的构建设置。
# 让我们来分析一下文件的主要部分和它们的功能：
#
# 1. **基本设置和版本定义**:
#    - `QDICOM_PRI_INCLUDED` 和其他变量用于避免重复包含此文件。
#    - 定义了应用的版本号和兼容版本。
#    - 设置了 C++14 标准。
#
# 2. **编译模式和平台设置**:
#    - 根据编译模式（debug 或 release）设置不同的文件后缀和目录。
#    - 根据操作系统（Windows, macOS, Linux）设置不同的平台目录。
#
# 3. **库和插件的命名**:
#    - `qtLibraryTargetName` 和 `qtLibraryName` 函数用于生成库和插件的名称。
#
# 4. **Qt 版本检查**:
#    - `minQtVersion` 测试确保 Qt 版本符合最低要求。
#
# 5. **路径和目录设置**:
#    - 定义了应用程序、库、插件、文档等的路径。
#    - 对于 macOS，还特别设置了 `.app` 包的相关路径。
#
# 6. **测试配置**:
#    - 如果定义了 `TEST`，则包含 Qt 的测试库并定义相关宏。
#
# 7. **路径信息输出**:
#    - 如果设置了 `QDICOMVIEWER_PATH_INFO`，则输出各种路径信息。
#
# 8. **相对路径和宏定义**:
#    - 设置一些相对路径和预处理器宏，用于在代码中引用资源。
#
# 9. **包含路径和库**:
#    - 定义了应用程序和插件的包含路径。
#    - 根据不同的配置和平台，添加了不同的库路径。
#
# 10. **编译器和链接器设置**:
#     - 对于不同的编译器（如 MSVC），设置了特定的编译器标志和链接器选项。
#
# 11. **Qt 模块**:
#     - 根据需要，包含了 Qt 的不同模块，如 `core`、`gui`、`widgets` 等。
#
# 12. **插件和库的依赖关系解析**:
#     - 使用递归逻辑来解析插件和库的依赖关系，并相应地更新链接器设置。
#
# 整体上，这个 `.pri` 文件为 QDicomViewer 应用程序提供了一个全面的构建配置，
# 涵盖了编译选项、路径设置、依赖解析等多个方面。
# 它利用了 Qt 的 qmake 特性来灵活地处理不同平台和配置下的构建需求。
#
!isEmpty(QDICOM_PRI_INCLUDED):error("QDicomViewer.pri already included")
QDICOM_PRI_INCLUDED = 1

QDICOMVIEWER_VERSION = 1.0.0
QDICOMVIEWER_COMPAT_VERSION = 1.1.0
VERSION = $$QDICOMVIEWER_VERSION
QDICOMVIEWER_DISPLAY_VERSION = 1.1.1
QDICOMVIEWER_COPYRIGHT_YEAR = 2021
BINARY_ARTIFACTS_BRANCH = 1.0

CONFIG += c++14

# 避免生成的库自动追加版本号
CONFIG += skip_target_version_ext

# Config Para
CONFIG(debug, debug|release):{
    FILE_POSTFIX = d
    DIR_COMPILEMODE = Debug
}
else:CONFIG(release, debug|release):{
    FILE_POSTFIX =
    DIR_COMPILEMODE = Release
}

win32:{
    DIR_PLATFORM = Win32
}
else:mac:{
    DIR_PLATFORM = MAC
}
else:linux:{
    DIR_PLATFORM = Linux
}

defineReplace(qtLibraryTargetName) {
   LIBRARY_NAME = $$1
   RET = $$member(LIBRARY_NAME, 0)$$FILE_POSTFIX
   return($$RET)
}

defineReplace(qtLibraryName) {
   RET = $$qtLibraryTargetName($$1)
   return($$RET)
}

defineTest(minQtVersion) {
    maj = $$1
    min = $$2
    patch = $$3
    isEqual(QT_MAJOR_VERSION, $$maj) {
        isEqual(QT_MINOR_VERSION, $$min) {
            isEqual(QT_PATCH_VERSION, $$patch) {
                return(true)
            }
            greaterThan(QT_PATCH_VERSION, $$patch) {
                return(true)
            }
        }
        greaterThan(QT_MINOR_VERSION, $$min) {
            return(true)
        }
    }
    greaterThan(QT_MAJOR_VERSION, $$maj) {
        return(true)
    }
    return(false)
}

darwin:!minQtVersion(5, 7, 0) {
    # Qt 5.6 still sets deployment target 10.7, which does not work
    # with all C++11/14 features (e.g. std::future)
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.8
}

isEmpty(IDE_LIBRARY_BASENAME) {
    IDE_LIBRARY_BASENAME = lib
}

equals(TEST, 1) {
    QT +=testlib
    DEFINES += WITH_TESTS
}

IDE_SOURCE_TREE = $$PWD
isEmpty(IDE_BUILD_TREE) {
    sub_dir = $$_PRO_FILE_PWD_
    sub_dir ~= s,^$$re_escape($$PWD),,
    IDE_BUILD_TREE = $$clean_path($$OUT_PWD)
    IDE_BUILD_TREE ~= s,$$re_escape($$sub_dir)$,,
}

IDE_APP_NAME = QDicomViewer
IDE_APP_PATH = $$IDE_BUILD_TREE/Bin
QDV_PREFIX = $$IDE_SOURCE_TREE/Bin/$$DIR_PLATFORM/$$DIR_COMPILEMODE
osx {
    IDE_APP_TARGET   = "QDicomViewer"

    # check if IDE_BUILD_TREE is actually an existing Qt QRadiant.app,
    # for building against a binary package
    exists($$IDE_BUILD_TREE/Contents/MacOS/QRadiant): IDE_APP_BUNDLE = $$IDE_BUILD_TREE
    else: IDE_APP_BUNDLE = $$IDE_APP_PATH/$${IDE_APP_TARGET}.app

    # set output path if not set manually
    isEmpty(IDE_OUTPUT_PATH): IDE_OUTPUT_PATH = $$IDE_APP_BUNDLE/Contents

    IDE_LIBRARY_PATH = $$IDE_OUTPUT_PATH/Frameworks
    IDE_PLUGIN_PATH  = $$IDE_OUTPUT_PATH/PlugIns
    IDE_LIBEXEC_PATH = $$IDE_OUTPUT_PATH/Resources
    IDE_DATA_PATH    = $$IDE_OUTPUT_PATH/Resources
    IDE_DOC_PATH     = $$IDE_DATA_PATH/doc
    IDE_BIN_PATH     = $$IDE_OUTPUT_PATH/MacOS
    copydata = 1

    LINK_LIBRARY_PATH = $$IDE_APP_BUNDLE/Contents/Frameworks
    LINK_PLUGIN_PATH  = $$IDE_APP_BUNDLE/Contents/PlugIns

    INSTALL_LIBRARY_PATH = $$QDV_PREFIX/$${IDE_APP_TARGET}.app/Contents/Frameworks
    INSTALL_PLUGIN_PATH  = $$QDV_PREFIX/$${IDE_APP_TARGET}.app/Contents/PlugIns
    INSTALL_LIBEXEC_PATH = $$QDV_PREFIX/$${IDE_APP_TARGET}.app/Contents/Resources
    INSTALL_DATA_PATH    = $$QDV_PREFIX/$${IDE_APP_TARGET}.app/Contents/Resources
    INSTALL_DOC_PATH     = $$INSTALL_DATA_PATH/doc
    INSTALL_BIN_PATH     = $$QDV_PREFIX/$${IDE_APP_TARGET}.app/Contents/MacOS
    INSTALL_APP_PATH     = $$QDV_PREFIX/
} else {
    contains(TEMPLATE, vc.*):vcproj = 1
    IDE_APP_TARGET   = QDicomViewer

    # target output path if not set manually
    isEmpty(IDE_OUTPUT_PATH): IDE_OUTPUT_PATH = $$IDE_BUILD_TREE

    isEmpty(IDE_BASE_BIN_PATH): IDE_BASE_BIN_PATH = $$QDV_PREFIX/$$IDE_APP_NAME

    IDE_LIBRARY_PATH = $$IDE_BASE_BIN_PATH/bin
    IDE_PLUGIN_PATH  = $$IDE_BASE_BIN_PATH/$$IDE_LIBRARY_BASENAME/$$IDE_APP_TARGET/plugins
    IDE_DATA_PATH    = $$IDE_BASE_BIN_PATH/share/$$IDE_APP_TARGET
    IDE_DOC_PATH     = $$IDE_BASE_BIN_PATH/share/doc/$$IDE_APP_TARGET
    IDE_BIN_PATH     = $$IDE_BASE_BIN_PATH/bin
    IDE_QSS_PATH     = $$IDE_BASE_BIN_PATH/share/$$IDE_APP_TARGET/qss
    win32: \
        IDE_LIBEXEC_PATH = $$IDE_OUTPUT_PATH/bin
    else: \
        IDE_LIBEXEC_PATH = $$IDE_OUTPUT_PATH/libexec/QDicomViewer
    !isEqual(IDE_SOURCE_TREE, $$IDE_OUTPUT_PATH):copydata = 1

    LINK_LIBRARY_PATH = $$IDE_LIBRARY_PATH
    LINK_PLUGIN_PATH  = $$IDE_PLUGIN_PATH
    INSTALL_DOC_PATH  = $$IDE_DOC_PATH
    INSTALL_DATA_PATH = $$IDE_BASE_BIN_PATH/share/doc/$$IDE_APP_TARGET
    STATIC_BASE       = $$IDE_BUILD_TREE/share/$$IDE_APP_NAME
}

QDICOMVIEWER_PATH_INFO = 0
equals(QDICOMVIEWER_PATH_INFO, 1) {
message("=================PATH info =============================")
message("IDE_LIBRARY_PATH:       " $$IDE_LIBRARY_PATH)
message("IDE_PLUGIN_PATH:        " $$IDE_PLUGIN_PATH)
message("IDE_DATA_PATH:          " $$IDE_DATA_PATH)
message("IDE_DOC_PATH:           " $$IDE_DOC_PATH)
message("IDE_BIN_PATH:           " $$IDE_BIN_PATH)
message("IDE_LIBEXEC_PATH:       " $$IDE_LIBEXEC_PATH)
message("LINK_LIBRARY_PATH:      " $$LINK_LIBRARY_PATH)
message("LINK_PLUGIN_PATH:       " $$LINK_PLUGIN_PATH)
message("INSTALL_LIBRARY_PATH:   " $$INSTALL_LIBRARY_PATH)
message("INSTALL_PLUGIN_PATH:    " $$INSTALL_PLUGIN_PATH)
message("INSTALL_LIBEXEC_PATH:   " $$INSTALL_LIBEXEC_PATH)
message("INSTALL_BIN_PATH:       " $$INSTALL_BIN_PATH)
message("INSTALL_APP_PATH:       " $$INSTALL_APP_PATH)
message("==============================================")
}


RELATIVE_PLUGIN_PATH = $$relative_path($$IDE_PLUGIN_PATH, $$IDE_BIN_PATH)
RELATIVE_LIBEXEC_PATH = $$relative_path($$IDE_LIBEXEC_PATH, $$IDE_BIN_PATH)
RELATIVE_DATA_PATH = $$relative_path($$IDE_DATA_PATH, $$IDE_BIN_PATH)
RELATIVE_DOC_PATH = $$relative_path($$IDE_DOC_PATH, $$IDE_BIN_PATH)
DEFINES += $$shell_quote(RELATIVE_PLUGIN_PATH=\"$$RELATIVE_PLUGIN_PATH\")
DEFINES += $$shell_quote(RELATIVE_LIBEXEC_PATH=\"$$RELATIVE_LIBEXEC_PATH\")
DEFINES += $$shell_quote(RELATIVE_DATA_PATH=\"$$RELATIVE_DATA_PATH\")
DEFINES += $$shell_quote(RELATIVE_DOC_PATH=\"$$RELATIVE_DOC_PATH\")
DEFINES += $$shell_quote(IDE_QSS_PATH=\"$$IDE_QSS_PATH\")
DEFINES *= IDE_REVISION
DEFINES *= QDV_SHOW_BUILD_DATE

INCLUDEPATH += \
    $$IDE_BUILD_TREE/src \ # for <app/app_version.h> in case of actual build directory
    $$IDE_SOURCE_TREE/src \ # for <app/app_version.h> in case of binary package with dev package
    $$IDE_SOURCE_TREE/src/libs \
    $$IDE_SOURCE_TREE/tools \
    $$IDE_BUILD_TREE/src/$$IDE_APP_TARGET

win32:exists($$IDE_SOURCE_TREE/lib/QRadiant) {
    # for .lib in case of binary package with dev package
    LIBS *= -L$$IDE_SOURCE_TREE/lib/QRadiant
    LIBS *= -L$$IDE_SOURCE_TREE/lib/QRadiant/plugins
}

QDV_PLUGIN_DIRS_FROM_ENVIRONMENT = $$(QDV_PLUGIN_DIRS)
QDV_PLUGIN_DIRS += $$split(QDV_PLUGIN_DIRS_FROM_ENVIRONMENT, $$QMAKE_DIRLIST_SEP)
QDV_PLUGIN_DIRS += $$IDE_SOURCE_TREE/src/plugins
for(dir, QDV_PLUGIN_DIRS) {
    INCLUDEPATH += $$dir
}

CONFIG += \
    depend_includepath \
    no_include_pwd

LIBS *= -L$$LINK_LIBRARY_PATH  # QRadiant libraries
exists($$IDE_LIBRARY_PATH): LIBS *= -L$$IDE_LIBRARY_PATH  # library path from output path

!isEmpty(vcproj) {
    DEFINES += IDE_LIBRARY_BASENAME=\"$$IDE_LIBRARY_BASENAME\"
} else {
    DEFINES += IDE_LIBRARY_BASENAME=\\\"$$IDE_LIBRARY_BASENAME\\\"
}

DEFINES += \
    QDicomViewer \
    QT_NO_CAST_TO_ASCII \
    QT_RESTRICTED_CAST_FROM_ASCII \
    QT_DISABLE_DEPRECATED_BEFORE=0x050600 \
    QT_USE_FAST_OPERATOR_PLUS \
    QT_USE_FAST_CONCATENATION

unix {
    CONFIG(debug, debug|release):OBJECTS_DIR = $${OUT_PWD}/.obj/debug-shared
    CONFIG(release, debug|release):OBJECTS_DIR = $${OUT_PWD}/.obj/release-shared

    CONFIG(debug, debug|release):MOC_DIR = $${OUT_PWD}/.moc/debug-shared
    CONFIG(release, debug|release):MOC_DIR = $${OUT_PWD}/.moc/release-shared

    RCC_DIR = $${OUT_PWD}/.rcc
    UI_DIR = $${OUT_PWD}/.uic
}

msvc {
    #Don't warn about sprintf, fopen etc being 'unsafe'
    DEFINES += _CRT_SECURE_NO_WARNINGS
    QMAKE_CXXFLAGS_WARN_ON *= -w44996
    # Speed up startup time when debugging with cdb
    QMAKE_LFLAGS_DEBUG += /INCREMENTAL:NO
}

qt {
    contains(QT, core): QT += concurrent
    contains(QT, gui): QT += widgets
}

!isEmpty(QDV_PLUGIN_DEPENDS) {
    LIBS *= -L$$IDE_PLUGIN_PATH  # plugin path from output directory
    LIBS *= -L$$LINK_PLUGIN_PATH  # when output path is different from QRadiant build directory
}

# recursively resolve plugin deps
done_plugins =
for(ever) {
    isEmpty(QDV_PLUGIN_DEPENDS): \
        break()
    done_plugins += $$QDV_PLUGIN_DEPENDS
    for(dep, QDV_PLUGIN_DEPENDS) {
        dependencies_file =
        for(dir, QDV_PLUGIN_DIRS) {
            exists($$dir/$$dep/$${dep}_dependencies.pri) {
                dependencies_file = $$dir/$$dep/$${dep}_dependencies.pri
                break()
            }
        }
        isEmpty(dependencies_file): \
            error("Plugin dependency $$dep not found")
        include($$dependencies_file)
        LIBS += -l$$qtLibraryName($$QDV_PLUGIN_NAME)
    }
    QDV_PLUGIN_DEPENDS = $$unique(QDV_PLUGIN_DEPENDS)
    QDV_PLUGIN_DEPENDS -= $$unique(done_plugins)
}

# recursively resolve library deps
done_libs =
for(ever) {
    isEmpty(QDV_LIB_DEPENDS): \
        break()
    done_libs += $$QDV_LIB_DEPENDS
    for(dep, QDV_LIB_DEPENDS) {
        include($$PWD/src/libs/$$dep/$${dep}_dependencies.pri)
        LIBS += -l$$qtLibraryName($$QDV_LIB_NAME)
    }
    QDV_LIB_DEPENDS = $$unique(QDV_LIB_DEPENDS)
    QDV_LIB_DEPENDS -= $$unique(done_libs)
}
