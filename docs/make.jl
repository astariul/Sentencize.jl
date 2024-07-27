using Sentencize
using Documenter

DocMeta.setdocmeta!(Sentencize, :DocTestSetup, :(using Sentencize); recursive = true)

makedocs(;
    modules = [Sentencize],
    authors = "Astariul <remondnicola@gmail.com> and all contributors",
    sitename = "Sentencize.jl",
    format = Documenter.HTML(;
        canonical = "https://github.com/astariul/Sentencize.jl",
        edit_link = "main",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(;
    repo = "github.com/astariul/Sentencize.jl",
    devbranch = "main"
)
