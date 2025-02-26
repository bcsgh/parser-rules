# Copyright (c) 2018, Benjamin Shropshire,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

"""
# Bazel/skylark rules for wrapping Flex/Bison builds.

## `MODULE.bazel`

```
bazel_dep(
    name = "com_github_bcsgh_parser_rules",
    version = ...,
)


register_toolchains("@com_github_bcsgh_parser_rules//parser:linux_flex_bison")
```
"""

def _genlex_impl(ctx):
    _PARSER = ctx.toolchains[":toolchain_type"].parser_gen_info

    cc = ctx.actions.declare_file(ctx.attr.cc.name)
    h  = ctx.actions.declare_file(ctx.attr.h.name)

    args = ctx.actions.args()
    args.add("--outfile=%s" % cc.path)
    args.add("--header-file=%s" % h.path)
    args.add_all(ctx.files.src)

    inputs = [t.files for t in _PARSER.lex_deps]
    ctx.actions.run(
        mnemonic = "GenerateLexer",
        inputs=depset(ctx.files.src + ctx.files.data, transitive=inputs),
        outputs=[cc, h],
        env=_PARSER.lex_env,
        executable=_PARSER.lex_gen,
        arguments = [args],
        tools = _PARSER.lex_tools,
    )

    return [DefaultInfo(
        runfiles=ctx.runfiles(files=ctx.files.src + ctx.files.data),
    )]

genlex = rule(
    doc = "Generate a lexer using flex.",

    implementation = _genlex_impl,
    attrs = {
        "src": attr.label(
            doc="The root source file.",
            allow_single_file=[".l"],
            mandatory=True,
        ),
        "data": attr.label_list(
            doc="Other files needed.",
            allow_files=True,
            default=[],
        ),

        "cc": attr.output(
            doc="The generated C++ source file.",
            mandatory=True,
        ),
        "h": attr.output(
            doc="The generated C++ header file.",
            mandatory=True,
        ),
    },
    toolchains = [":toolchain_type"],
)

def _genyacc_impl(ctx):
    _PARSER = ctx.toolchains[":toolchain_type"].parser_gen_info

    if ctx.attr.graph:
        print("genyacc.graph is deprecated. " +
              'Use genyacc.graph_file = "%s.dot"' % ctx.label.name)
    if ctx.attr.report:
        print("genyacc.report is deprecated. " +
              'Use genyacc.report_file = "%s.output"' % ctx.label.name)

    # Default setup.
    cc = ctx.actions.declare_file(ctx.attr.cc.name)
    h = ctx.actions.declare_file(ctx.attr.h.name)
    outs = [cc, h]

    if ctx.attr.loc:
        loc = ctx.actions.declare_file(ctx.attr.loc.name)
        outs += [loc]

    args = ctx.actions.args()
    args.add("--output=%s" % cc.path)
    args.add("--defines=%s" % h.path)
    args.add_all(ctx.files.src)

    # Optional features.
    if ctx.attr.graph or ctx.attr.graph_file:
        gf = ctx.actions.declare_file(ctx.attr.graph_file.name
                                      if ctx.attr.graph_file
                                      else "%s.dot" % ctx.label.name)
        outs += [gf]
        args.add("--graph=%s" % gf.path)

    if ctx.attr.report or ctx.attr.report_file:
        rf = ctx.actions.declare_file(ctx.attr.report_file.name
                                      if ctx.attr.report_file
                                      else "%s.output" % ctx.label.name)
        outs += [rf]
        args.add("--verbose")
        args.add("--report=all")
        args.add("--report-file=%s" % rf.path)

    # Do it.
    inputs = [t.files for t in _PARSER.parse_deps]
    ctx.actions.run(
        mnemonic = "GenerateParser",
        inputs=depset(ctx.files.src + ctx.files.data, transitive=inputs),
        outputs=outs,
        env=_PARSER.parse_env,
        executable=_PARSER.parse_gen,
        arguments = [args],
        tools = _PARSER.parse_tools,
    )

    return [DefaultInfo(
        runfiles=ctx.runfiles(files=ctx.files.src + ctx.files.data),
    )]

genyacc = rule(
    doc = "Generate a paser using bison.",

    implementation = _genyacc_impl,
    attrs = {
        "src": attr.label(
            doc="The root source file.",
            allow_single_file=[".y"],
            mandatory=True,
        ),
        "data": attr.label_list(
            doc="Other files needed.",
            allow_files=True,
            default=[],
        ),

        "cc": attr.output(
            doc="The generated C++ source file.",
            mandatory=True,
        ),
        "h": attr.output(
            doc="The generated C++ header file.",
            mandatory=True,
        ),
        "loc": attr.output(
            doc="""The generated location header (if used).
              This can be manipulated in the .y file via `%define api.location.file`.""",
        ),

        "graph": attr.bool(
            doc="Generate a state machine graph. (Depricated, use graph_file.)",
            default=False,
        ),
        "report": attr.bool(
            doc='Generate a "report" (`--verbose --report=all`). (Depricated, use report_file.)',
            default=False,
        ),

        "graph_file": attr.output(
            doc="Generate a state machine graph.",
        ),
        "report_file": attr.output(
            doc='Generate a "report" (`--verbose --report=all`).',
        ),
    },
    toolchains = [":toolchain_type"],
)

## Parser generator Toolchain
ParserGenInfo = provider(
    doc = "Information about how to invoke lexer and parser generators tools.",

    fields = [
        "lex_gen",
        "lex_tools",
        "lex_env",
        "lex_deps",
        "parse_gen",
        "parse_tools",
        "parse_env",
        "parse_deps",
    ],
)

def _parser_toolchain_impl(ctx):
    if (not ctx.attr.lex_gen) == (not ctx.attr.lex_target):
        fail("Exactly one of lex_gen or lex_target must be set")
    if (not ctx.attr.parse_gen) == (not ctx.attr.parse_target):
        fail("Exactly one of parse_gen or parse_target must be set")

    # configure_make() seems to produce mutiple outputs; filter for one file.
    def filter(bin):
        files = [x for x in bin.files.to_list() if not x.is_directory]
        if len(files) != 1:
            fail("Target requiered exactly one file:", files)
        return files[0].path

    def make_env(e, tar, X):
        ws = tar
        return dict([
            (k, ctx.expand_location(v, X).format(workspace_root=ws))
            for k, v in e.items()
        ])

    if ctx.attr.lex_gen:
        lex = ctx.attr.lex_gen
        lex_tools = []
        lex_env = make_env(ctx.attr.lex_env, None, ctx.attr.lex_deps)
    if ctx.attr.lex_target:
        lex = filter(ctx.attr.lex_target)
        lex_tools = [ctx.attr.lex_target.files]
        lex_env = make_env(ctx.attr.lex_env,
                           ctx.attr.lex_target.label.workspace_root,
                           ctx.attr.lex_deps + [ctx.attr.lex_target])

    if ctx.attr.parse_gen:
        parse = ctx.attr.parse_gen
        parse_tools = []
        parse_env = make_env(ctx.attr.parse_env, None, ctx.attr.parse_deps)
    if ctx.attr.parse_target:
        parse = filter(ctx.attr.parse_target)
        parse_tools = [ctx.attr.parse_target.files]
        parse_env = make_env(ctx.attr.parse_env,
                             ctx.attr.parse_target.label.workspace_root,
                             ctx.attr.parse_deps + [ctx.attr.parse_target])

    return [platform_common.ToolchainInfo(
        parser_gen_info = ParserGenInfo(
            lex_gen = lex,
            lex_tools = depset([], transitive=lex_tools),
            lex_env = ctx.attr.lex_env,
            lex_deps = ctx.attr.lex_deps,
            parse_gen = parse,
            parse_tools = depset([], transitive=parse_tools),
            parse_env = parse_env,
            parse_deps = ctx.attr.parse_deps,
        ),
    )]

parser_toolchain = rule(
    implementation = _parser_toolchain_impl,
    attrs = {
        "lex_gen": attr.string(),
        "lex_target": attr.label(),
        "lex_env": attr.string_dict(),
        "lex_deps": attr.label_list(allow_files=True),
        "parse_gen": attr.string(),
        "parse_target": attr.label(),
        "parse_env": attr.string_dict(),
        "parse_deps": attr.label_list(allow_files=True),
    },
)
