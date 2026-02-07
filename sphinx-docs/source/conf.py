# Configuration file for the Sphinx documentation builder.

import os
import sys

# -- Project information -----------------------------------------------------
project = 'Beamlines.jl'
copyright = '2025, Beamlines.jl Contributors'
author = 'Beamlines.jl Contributors'

# -- General configuration ---------------------------------------------------
extensions = [
    'myst_parser',
    'sphinx.ext.githubpages',
    'sphinx.ext.mathjax',
]

# MyST Parser configuration
myst_enable_extensions = [
    "dollarmath",
    "amsmath",
    "deflist",
    "colon_fence",
    "linkify",
]

templates_path = ['_templates']
exclude_patterns = []

# -- Options for HTML output -------------------------------------------------
html_theme = 'furo'

html_theme_options = {
    'source_repository': 'https://github.com/bmad-sim/Beamlines.jl',
    'source_branch': 'main',
    'source_directory': 'sphinx-docs/source/',
}

html_title = 'Beamlines.jl Documentation'
html_static_path = ['_static']
html_css_files = ['custom.css']

# -- Options for MyST --------------------------------------------------------
myst_heading_anchors = 3
