using Weave
# pandocを使うなら別途インストールして，必要に応じてパスを通しておく必要がある。
pwd()
weave("pkg/jmd/myfirst.jmd", doctype = "pandoc2html", out_path = :doc)
# ipynb to html
weave("jupyter/DataFrameHandling.ipynb", doctype = "pandoc2html", out_path = :doc)
weave("pkg/jmd/pkg_Query.jmd", doctype = "pandoc2html", out_path = :doc)
