"""A module defining the third party dependency OpenSSL"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def apr_repositories():
    maybe(
        http_archive,
        name = "apr",
        build_file = Label("//apr:BUILD.apr.bazel"),
        sha256 = "70dcf9102066a2ff2ffc47e93c289c8e54c95d8dda23b503f9e61bb0cbd2d105",
        strip_prefix = "apr-1.6.5",
        urls = [
            "https://mirror.bazel.build/www-eu.apache.org/dist//apr/apr-1.6.5.tar.gz",
            "https://www-eu.apache.org/dist//apr/apr-1.6.5.tar.gz",
        ],
    )
