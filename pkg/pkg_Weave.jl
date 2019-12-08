using Weave
# pandocを使うなら別途インストールして，必要に応じてパスを通しておく必要がある。
pwd()
weave("pkg/jmd/myfirst.jmd", doctype = "pandoc2html", out_path = :doc)
# ipynb to html
weave("jupyter/DataFrameHandling.ipynb", doctype = "pandoc2html", out_path = :doc)
weave("pkg/jmd/pkg_Query.jmd", doctype = "pandoc2html", out_path = :doc)

# 2019/12/05 optim study
weave("jmd/optimStudy.jmd", doctype = "pandoc2html", out_path = :doc)
# advent calender
weave("jmd/summaryPkg.jmd", doctype = "pandoc2html", out_path = :doc)
