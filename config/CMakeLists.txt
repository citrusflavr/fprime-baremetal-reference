####
# config/CMakeLists.txt:
#
# Sets a list of source files for cmake to process as part of autocoding.
####
register_fprime_config(
    fprime-baremetal-reference-config
    CONFIGURATION_OVERRIDES
        "${CMAKE_CURRENT_LIST_DIR}/AcConstants.fpp"
        "${CMAKE_CURRENT_LIST_DIR}/BufferManagerComponentImplCfg.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/CommandDispatcherImplCfg.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/DpCatalogCfg.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/EventManagerCfg.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/StaticMemoryConfig.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/TlmChanImplCfg.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/FpConfig.h"
    INTERFACE # No buildable files generated
)
