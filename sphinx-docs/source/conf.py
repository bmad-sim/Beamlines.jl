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
html_theme = 'sphinx_immaterial'

html_theme_options = {
    'repo_url': 'https://github.com/bmad-sim/Beamlines.jl',
    'repo_name': 'Beamlines.jl',
    'edit_uri': 'blob/main/sphinx-docs/source',
    'palette': [
        {
            'primary': 'indigo',
            'accent': 'light-blue',
        }
    ],
    'features': [
        'navigation.tabs',
        'navigation.sections',
        'navigation.expand',
        'search.highlight',
        'toc.integrate',
    ],
}

html_title = 'Beamlines.jl Documentation'
html_static_path = ['_static']
html_css_files = ['custom.css']

# -- Options for MyST --------------------------------------------------------
myst_heading_anchors = 3
