"""A module defining the third party dependency perl"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def perl_repositories():
    maybe(
        http_archive,
        name = "perl",
        build_file = Label("//perl:BUILD.perl.bazel"),
        sha256 = "aeb973da474f14210d3e1a1f942dcf779e2ae7e71e4c535e6c53ebabe632cc98",
        urls = [
            "https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.zip",
        ],
    )

    ##TODO add linux, and make an alias from @perl_win//:perl or @perl_unix or @perl_macos to :perl
