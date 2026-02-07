# Beamlines.jl Documentation

This directory contains all documentation for Beamlines.jl, combining narrative documentation (Sphinx/MyST) with API reference (Documenter.jl).

## Directory Structure

```
docs/
├── src/                    # Narrative documentation (Sphinx/MyST)
│   ├── conf.py            # Sphinx configuration
│   ├── index.md           # Main landing page
│   ├── getting-started.md # Installation and basic usage
│   ├── user-guide/        # Detailed usage guides
│   ├── examples/          # Practical examples
│   ├── developer-guide/   # Contributing guidelines
│   ├── _static/           # CSS, images, and other static files
│   └── _templates/        # Custom HTML templates
├── api/                    # API reference (Documenter.jl)
│   ├── src/
│   │   ├── index.md       # API reference landing page
│   │   └── main-docs.md   # Redirect to main docs
│   └── make.jl            # Documenter build script
├── requirements.txt        # Python dependencies (Sphinx)
├── Project.toml           # Julia dependencies (Documenter)
└── README.md              # This file
```

## Building Documentation

### Prerequisites

**Python dependencies:**
```bash
pip install -r docs/requirements.txt
```

**Julia dependencies:**
```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
```

### Build Narrative Documentation (Sphinx)

```bash
cd docs
sphinx-build -b html src build/html
```

Output: `docs/build/html/`

### Build API Reference (Documenter.jl)

```bash
julia --project=docs docs/api/make.jl
```

Output: `docs/api/build/`

### Build Combined Documentation

```bash
# Build both
cd docs && sphinx-build -b html src build/html
julia --project=docs docs/api/make.jl

# Combine
mkdir -p gh-pages
cp -r docs/build/html/* gh-pages/
mkdir -p gh-pages/api
cp -r docs/api/build/* gh-pages/api/

# Open
open gh-pages/index.html  # macOS
xdg-open gh-pages/index.html  # Linux
start gh-pages/index.html  # Windows
```

## Contributing to Documentation

### Where to Add Content

| Type of Content | Location | Format |
|----------------|----------|--------|
| Installation guide | `src/getting-started.md` | Markdown (MyST) |
| Usage tutorials | `src/user-guide/*.md` | Markdown (MyST) |
| Examples | `src/examples/*.md` | Markdown (MyST) |
| Contributing guide | `src/developer-guide/*.md` | Markdown (MyST) |
| API docstrings | Source code (`src/*.jl`) | Julia docstrings |
| API organization | `api/src/index.md` | Markdown |

### Writing Narrative Documentation

Narrative docs use **MyST Markdown**, an enhanced Markdown with Sphinx directives.

**Basic example:**
```markdown
# Section Title

Regular markdown text with [links](https://example.com).

## Subsection

```julia
# Code example
qf = Quadrupole(Kn1=0.36, L=0.5)
```

**Math:**
Inline math: $E = mc^2$

Display math:
$$
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
$$

**Admonitions:**
```{note}
This is a note box.
```

```{warning}
This is a warning box.
```
```

**Resources:**
- [MyST Markdown Guide](https://myst-parser.readthedocs.io/)
- [Sphinx Documentation](https://www.sphinx-doc.org/)

### Writing API Documentation

API docs are auto-generated from Julia docstrings. Add docstrings to functions in `src/*.jl`:

```julia
"""
    Quadrupole(; Kn1=0.0, L=0.0, kwargs...)

Create a quadrupole magnet element.

# Arguments
- `Kn1::Real`: Normalized quadrupole strength (1/m²)
- `L::Real`: Length (m)
- `kwargs...`: Additional LineElement parameters

# Returns
- `LineElement` with kind="Quadrupole"

# Examples
```jldoctest
julia> qf = Quadrupole(Kn1=0.36, L=0.5)
LineElement(kind="Quadrupole", ...)
```
"""
Quadrupole(; kwargs...) = LineElement(; kind="Quadrupole", kwargs...)
```

The docstrings automatically appear in the API reference.

## Navigation Between Documentation Systems

The documentation has seamless navigation:

**Main Documentation (Sphinx):**
- Sidebar shows "API Reference →" link

**API Reference (Documenter):**
- Sidebar shows "← Documentation" link

Both systems are deployed as a unified site:
- Main docs at root: `https://bmad-sim.github.io/Beamlines.jl/`
- API reference: `https://bmad-sim.github.io/Beamlines.jl/api/`

## Automatic Deployment

Documentation is automatically built and deployed via GitHub Actions when:
- Code is pushed to `main` branch
- A tag is created
- Manually triggered via workflow dispatch

See `.github/workflows/documentation.yml` for details.

## Local Testing

Always test documentation builds locally before pushing:

1. **Test Sphinx build** - Verify no warnings/errors
2. **Test Documenter build** - Verify docstrings render correctly
3. **Test combined output** - Verify cross-links work
4. **Check in browser** - Verify formatting and navigation

## Questions?

- Check the [Sphinx documentation](https://www.sphinx-doc.org/)
- Check the [Documenter.jl documentation](https://documenter.juliadocs.org/)
- Ask in GitHub Discussions
