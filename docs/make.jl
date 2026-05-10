using Documenter, Beamlines

cp(joinpath(@__DIR__, "..", "README.md"), joinpath(@__DIR__, "src", "index.md"); force=true)

makedocs(;
  authors="mattsignorelli <mgs255@cornell.edu> and contributors",
  sitename="Beamlines.jl",
  format=Documenter.HTML(;
    canonical="https://bmad-sim.github.io/Beamlines.jl",
    edit_link="main",
    assets=String[],
    size_threshold=nothing,
  ),
  pages=[
    "Home" => "index.md",
    "Quickstart Guide" => "quickstart.md",
    "Parameter Groups" => "parameters.md",
    "Full API" => "api.md",
  ],
)

deploydocs(; repo="github.com/bmad-sim/Beamlines.jl")
