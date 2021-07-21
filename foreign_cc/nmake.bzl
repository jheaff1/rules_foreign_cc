"""Helper rules and macros for building projects using the MSVC nmake build tool"""

load("//foreign_cc:providers.bzl", "ForeignCcDepsInfo")
load(":configure.bzl", "configure_make")

def _extra_toolchains_transition_impl(settings, attrs):
    return {"//command_line_option:extra_toolchains": attrs.extra_toolchains + settings["//command_line_option:extra_toolchains"]}

_extra_toolchains_transition = transition(
    implementation = _extra_toolchains_transition_impl,
    inputs = ["//command_line_option:extra_toolchains"],
    outputs = ["//command_line_option:extra_toolchains"],
)

def _extra_toolchains_transitioned_foreign_cc_target_impl(ctx):
    # Return the providers from the transitioned foreign_cc target
    return [
        ctx.attr.target[DefaultInfo],
        ctx.attr.target[CcInfo],
        ctx.attr.target[ForeignCcDepsInfo],
        ctx.attr.target[OutputGroupInfo],
    ]

extra_toolchains_transitioned_foreign_cc_target = rule(
    doc = "A rule for adding extra toolchains to consider when building the given target",
    implementation = _extra_toolchains_transitioned_foreign_cc_target_impl,
    cfg = _extra_toolchains_transition,
    attrs = {
        "extra_toolchains": attr.string_list(
            doc = "Additional toolchains to consider",
            mandatory = True,
        ),
        "target": attr.label(
            doc = "The target to build after considering the extra toolchains",
            providers = [ForeignCcDepsInfo],
            mandatory = True,
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    },
    incompatible_use_toolchain_transition = True,
)

def configure_nmake(name, **kwargs):
    """ Wrapper macro around configure_make to force usage of the preinstalled nmake toolchain """
    configure_make_target_name = name + "_nmake"

    configure_make(
        name = configure_make_target_name,
        **kwargs
    )
    extra_toolchains_transitioned_foreign_cc_target(
        name = name,
        extra_toolchains = ["@rules_foreign_cc//toolchains:preinstalled_nmake_toolchain"],
        target = configure_make_target_name,
    )
