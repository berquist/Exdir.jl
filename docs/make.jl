using Exdir
using Documenter

DocMeta.setdocmeta!(Exdir, :DocTestSetup, :(using Exdir); recursive=true)

makedocs(;
    modules=[Exdir],
    authors="Eric Berquist <eric.berquist@gmail.com> and contributors",
    repo="https://github.com/berquist/Exdir.jl/blob/{commit}{path}#{line}",
    sitename="Exdir.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://berquist.github.io/Exdir.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/berquist/Exdir.jl",
    devbranch="main",
)
