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
    "Advanced Usage" => "advanced.md",
    "Manual" => [
        "man/a_toc.md",
    "man/b_descriptor.md", 
    "man/c_tps.md",
    "man/d_varsparams.md",
    "man/e_monoindex.md",
    "man/f_mono.md",
    "man/g_gjh.md",
    "man/h_slice.md",
    "man/i_methods.md",
    "man/j_fastgtpsa.md",
    "man/k_io.md",
    "man/l_global.md",
    "man/m_all.md"],
  ],
)

deploydocs(; repo="github.com/bmad-sim/Beamlines.jl")
