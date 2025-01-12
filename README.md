<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Bazel/skylark rules for wrapping Flex/Bison builds.

## `MODULE.bazel`

```
bazel_dep(
    name = "com_github_bcsgh_parser_rules",
    version = ...,
)


register_toolchains("@com_github_bcsgh_parser_rules//parser:linux_flex_bison")
```

<a id="genlex"></a>

## genlex

<pre>
load("@com_github_bcsgh_parser_rules//parser:parser.bzl", "genlex")

genlex(<a href="#genlex-name">name</a>, <a href="#genlex-src">src</a>, <a href="#genlex-data">data</a>, <a href="#genlex-cc">cc</a>, <a href="#genlex-h">h</a>)
</pre>

Generate a lexer using flex.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="genlex-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="genlex-src"></a>src |  The root source file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="genlex-data"></a>data |  Other files needed.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="genlex-cc"></a>cc |  The generated C++ source file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="genlex-h"></a>h |  The generated C++ header file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="genyacc"></a>

## genyacc

<pre>
load("@com_github_bcsgh_parser_rules//parser:parser.bzl", "genyacc")

genyacc(<a href="#genyacc-name">name</a>, <a href="#genyacc-src">src</a>, <a href="#genyacc-data">data</a>, <a href="#genyacc-cc">cc</a>, <a href="#genyacc-graph">graph</a>, <a href="#genyacc-graph_file">graph_file</a>, <a href="#genyacc-h">h</a>, <a href="#genyacc-loc">loc</a>, <a href="#genyacc-report">report</a>, <a href="#genyacc-report_file">report_file</a>)
</pre>

Generate a paser using bison.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="genyacc-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="genyacc-src"></a>src |  The root source file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="genyacc-data"></a>data |  Other files needed.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="genyacc-cc"></a>cc |  The generated C++ source file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="genyacc-graph"></a>graph |  Generate a state machine graph. (Depricated, use graph_file.)   | Boolean | optional |  `False`  |
| <a id="genyacc-graph_file"></a>graph_file |  Generate a state machine graph.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="genyacc-h"></a>h |  The generated C++ header file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="genyacc-loc"></a>loc |  The generated location header (if used). This can be manipulated in the .y file via `%define api.location.file`.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="genyacc-report"></a>report |  Generate a "report" (`--verbose --report=all`). (Depricated, use report_file.)   | Boolean | optional |  `False`  |
| <a id="genyacc-report_file"></a>report_file |  Generate a "report" (`--verbose --report=all`).   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="parser_toolchain"></a>

## parser_toolchain

<pre>
load("@com_github_bcsgh_parser_rules//parser:parser.bzl", "parser_toolchain")

parser_toolchain(<a href="#parser_toolchain-name">name</a>, <a href="#parser_toolchain-lex_gen">lex_gen</a>, <a href="#parser_toolchain-parse_gen">parse_gen</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="parser_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="parser_toolchain-lex_gen"></a>lex_gen |  -   | String | required |  |
| <a id="parser_toolchain-parse_gen"></a>parse_gen |  -   | String | required |  |


<a id="ParserGenInfo"></a>

## ParserGenInfo

<pre>
load("@com_github_bcsgh_parser_rules//parser:parser.bzl", "ParserGenInfo")

ParserGenInfo(<a href="#ParserGenInfo-lex_gen">lex_gen</a>, <a href="#ParserGenInfo-parse_gen">parse_gen</a>)
</pre>

Information about how to invoke lexer and parser generators tools.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="ParserGenInfo-lex_gen"></a>lex_gen |  -    |
| <a id="ParserGenInfo-parse_gen"></a>parse_gen |  -    |


## Setup (for development)
To configure the git hooks, run `./.git_hooks/setup.sh`
