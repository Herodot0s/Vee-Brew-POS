cmake_minimum_required(VERSION 3.10.2)

project(sqlite3_native)

add_library(sqlite3 SHARED sqlite3.c)

# Core SQLite options matching standard dart-sqlite packages
target_compile_definitions(sqlite3 PRIVATE
    SQLITE_ENABLE_DBSTAT_VTAB
    SQLITE_ENABLE_FTS5
    SQLITE_ENABLE_RTREE
    SQLITE_ENABLE_MATH_FUNCTIONS
    SQLITE_DQS=0
    SQLITE_DEFAULT_MEMSTATUS=0
    SQLITE_TEMP_STORE=2
    SQLITE_MAX_EXPR_DEPTH=0
    SQLITE_STRICT_SUBTYPE=1
    SQLITE_OMIT_AUTHORIZATION
    SQLITE_OMIT_DECLTYPE
    SQLITE_OMIT_DEPRECATED
    SQLITE_OMIT_PROGRESS_CALLBACK
    SQLITE_OMIT_SHARED_CACHE
    SQLITE_OMIT_TCL_VARIABLE
    SQLITE_OMIT_TRACE
    SQLITE_USE_ALLOCA
    SQLITE_ENABLE_SESSION
    SQLITE_ENABLE_PREUPDATE_HOOK
    SQLITE_UNTESTABLE
    SQLITE_HAVE_ISNAN
    SQLITE_HAVE_LOCALTIME_R
    SQLITE_HAVE_LOCALTIME_S
    SQLITE_HAVE_MALLOC_USABLE_SIZE
    SQLITE_HAVE_STRCHRNUL
)

# Math library dependency
target_link_libraries(sqlite3 PRIVATE m)

# Linker option: force both sysv (DT_HASH) and gnu (DT_GNU_HASH) hashes 
# to support both modern and pre-6.0 Android linkers.
set_target_properties(sqlite3 PROPERTIES
    LINK_FLAGS "-Wl,--hash-style=both"
)
