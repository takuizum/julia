using LanguageServer
using SymbolServer
using Pkg


envpath = dirname(Pkg.Types.Context().env.project_file)
depotpath = joinpath(ENV["HOME"], ".julia")

server = LanguageServerInstance(stdin, stdout, false, envpath, depotpath)
# server.runlinter = true

run(server)
