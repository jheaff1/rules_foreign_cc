""" Rule for building GNU Make from sources. """

load("@rules_foreign_cc//tools/build_defs:shell_script_helper.bzl", "convert_shell_script")
load("//tools/build_defs:detect_root.bzl", "detect_root")
load("//tools/build_defs:configure_script.bzl", "get_configure_variables")
load(
    "//tools/build_defs:cc_toolchain_util.bzl",
    "get_flags_info",
    "get_tools_info",
    "absolutize_path_in_str"
)


#def _get_configure_variables(tools, flags, user_env_vars):


def _make_tool(ctx):
    root = detect_root(ctx.attr.make_srcs)
    tools = get_tools_info(ctx)
    flags = get_flags_info(ctx)
    env_vars_string = get_configure_variables(tools, flags, [])

    env_vars_string_fmt = " ".join(["{}=\"{}\""
        .format(key, _join_flags_list(ctx.workspace_name, env_vars_string[key])) for key in env_vars_string])

    print("env_vars_string is ", env_vars_string_fmt)

    make = ctx.actions.declare_directory("make")
    script = [
        "export BUILD_DIR=##pwd##",
        "export BUILD_TMPDIR=$${BUILD_DIR}$$.build_tmpdir",
        "##copy_dir_contents_to_dir## ./{} $BUILD_TMPDIR".format(root),
        "cd $$BUILD_TMPDIR$$",
        "./configure --prefix=$$BUILD_DIR$$/{} {}".format(make.path, env_vars_string_fmt),
        "./build.sh",
        "./make install",
    ]
    script_text = convert_shell_script(ctx, script)

    ctx.actions.run_shell(
        mnemonic = "BootstrapMake",
        inputs = ctx.attr.make_srcs.files,
        outputs = [make],
        tools = [],
        use_default_shell_env = True,
        command = script_text,
        execution_requirements = {"block-network": ""},
    )

    return [DefaultInfo(files = depset([make]))]

make_tool = rule(
    doc = "Rule for building Make. Invokes configure script and make install.",
    attrs = {
        "make_srcs": attr.label(
            doc = "target with the Make sources",
            mandatory = True,
        ),
        # we need to declare this attribute to access cc_toolchain
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
        "deps": attr.label_list(
            doc = (
                "Dummy"
            ),
            mandatory = False,
            allow_files = True,
            default = [],
        ),
    },
    fragments = ["cpp"],
    output_to_genfiles = True,
    implementation = _make_tool,
    toolchains = [
        "@rules_foreign_cc//tools/build_defs/shell_toolchain/toolchains:shell_commands",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)

# TODO copied below from configure_script.bazl
def _absolutize(workspace_name, text):
    return absolutize_path_in_str(workspace_name, "$$EXT_BUILD_ROOT$$/", text)

def _join_flags_list(workspace_name, flags):
    return " ".join([_absolutize(workspace_name, flag) for flag in flags])