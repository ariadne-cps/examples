# Discover an installed Ariadne library and umbrella header.
find_library(ARIADNE_LIBRARY NAMES ariadne)
find_path(ARIADNE_INCLUDE_DIR NAMES ariadne.hpp PATH_SUFFIXES ariadne)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Ariadne DEFAULT_MSG ARIADNE_LIBRARY ARIADNE_INCLUDE_DIR)

if(Ariadne_FOUND AND NOT TARGET Ariadne::ariadne)
    get_filename_component(ARIADNE_INCLUDE_PARENT_DIR "${ARIADNE_INCLUDE_DIR}" DIRECTORY)
    find_package(Threads REQUIRED)
    add_library(Ariadne::ariadne UNKNOWN IMPORTED)
    set_target_properties(Ariadne::ariadne PROPERTIES
        IMPORTED_LOCATION "${ARIADNE_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${ARIADNE_INCLUDE_PARENT_DIR};${ARIADNE_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Threads::Threads")
endif()
