"""Helper rules and macros for building projects using the variants of GNU Make, such as MSVC's NMake"""

load("//foreign_cc/private:transitions.bzl", "extra_toolchains_transitioned_foreign_cc_target")
load(":configure.bzl", "configure_make")
load(":make.bzl", "make")

def make_variant(name, rule, toolchain, **kwargs):
    """ Wrapper macro around configure_make() or make() to force usage of the given make variant toolchain.

    Args:
        name: The target name
        rule: The name of the rule to instantiate, either `configure_make` or `make`
        toolchain: The desired make variant toolchain to use, e.g. @rules_foreign_cc//toolchains:preinstalled_nmake_toolchain
        **kwargs: Remaining keyword arguments
    """

    if not (rule == configure_make or rule == make):
        fail("Provided rule must be either configure_make() or make()")

    make_variant_target_name = name + "_"

    tags = kwargs["tags"] if "tags" in kwargs else []

    rule(
        name = make_variant_target_name,
        tags = tags + ["manual"],
        **kwargs
    )

    extra_toolchains_transitioned_foreign_cc_target(
        name = name,
        extra_toolchains = [toolchain],
        target = make_variant_target_name,
        tags = tags,
    )
