#Create install target
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(FILES "LICENSE" DESTINATION share)

set(NRF_BLE_DRIVER_SHARE_INSTALL_DIR "share/${PROJECT_NAME}" CACHE STRING "install share path for nrf-ble-driver")

foreach(SD_API_VER ${SD_API_VERS})
    string(TOLOWER ${SD_API_VER} SD_API_VER_L)

    install(
        TARGETS ${NRF_BLE_DRIVER_${SD_API_VER}}
        EXPORT ${PROJECT_NAME}-targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${SD_API_VER_L}
        RESOURCE DESTINATION ${NRF_BLE_DRIVER_SHARE_INSTALL_DIR}/hex/${SD_API_VER_L}
        COMPONENT SDK
    )
endforeach(SD_API_VER)

# Create a template package config file
# This part is required because SoftDevice to compile is dynamic
set(CONFIG_TEMPLATE "@PACKAGE_INIT@\n\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/@PROJECT_NAME@Targets.cmake\")\n\n")
set(CONFIG_TEMPLATE "${CONFIG_TEMPLATE}\n")

foreach(SD_API_VER ${SD_API_VERS})
    string(TOLOWER ${SD_API_VER} SD_API_VER_L)

    set(CONFIG_TEMPLATE "${CONFIG_TEMPLATE}\n# ${SD_API_VER} related properties")
    set(CONFIG_TEMPLATE "${CONFIG_TEMPLATE}\nget_target_property(@PROJECT_NAME@_${SD_API_VER}_INCLUDE_DIR nrf::nrf_ble_driver_${SD_API_VER_L} INTERFACE_INCLUDE_DIRECTORIES)")
    set(CONFIG_TEMPLATE "${CONFIG_TEMPLATE}\nget_target_property(@PROJECT_NAME@_${SD_API_VER}_LIBRARY nrf::nrf_ble_driver_${SD_API_VER_L} LOCATION)")
    set(CONFIG_TEMPLATE "${CONFIG_TEMPLATE}\n")
endforeach(SD_API_VER)

set(CONFIG_TEMPLATE_FILENAME "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake.in")
file(WRITE ${CONFIG_TEMPLATE_FILENAME} "${CONFIG_TEMPLATE}")

configure_package_config_file(
    ${CONFIG_TEMPLATE_FILENAME}
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION ${NRF_BLE_DRIVER_SHARE_INSTALL_DIR}
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${NRF_BLE_DRIVER_VERSION}
    COMPATIBILITY AnyNewerVersion
)

install(
    FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${NRF_BLE_DRIVER_SHARE_INSTALL_DIR}
)

install(
    EXPORT ${PROJECT_NAME}-targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE nrf::
    DESTINATION ${NRF_BLE_DRIVER_SHARE_INSTALL_DIR}
)
