using Beamlines
using Documenter

cp(joinpath(@__DIR__, "..", "README.md"), joinpath(@__DIR__, "src", "index.md"); force=true)

DocMeta.setdocmeta!(Beamlines, :DocTestSetup, :(using Beamlines); recursive=true)

makedocs(;
  modules=[Beamlines],
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
    "For Developers" => "developers.md",
  ],
)

deploydocs(; repo="github.com/bmad-sim/Beamlines.jl")
