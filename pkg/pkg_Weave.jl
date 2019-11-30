using Weave

pwd()
weave("pkg/jmd/myfirst.jmd",doctype = "pandoc2html", out_path=:doc)
