```@meta
DocTestSetup = quote
    using Luxor
end
```

# Introduction to Luxor

Luxor is a Julia package for drawing simple static vector graphics. It provides basic drawing functions and utilities for working with shapes, polygons, clipping masks, PNG images, turtle graphics, animations, and shapefiles.

The focus of Luxor is on simplicity and ease of use: it should be easier to use than plain [Cairo.jl](https://github.com/JuliaLang/Cairo.jl), with shorter names, fewer underscores, default contexts, and simplified functions.

Luxor is thoroughly procedural and static: your code issues a sequence of simple graphics 'commands' until you've completed a drawing, then the results are saved into a PDF, PNG, SVG, or EPS file.

There are some Luxor-related videos on [YouTube](https://www.youtube.com/channel/UCfd52kTA5JpzOEItSqXLQxg).

For interactive graphics, you'll find [Gtk.jl](https://github.com/JuliaGraphics/Gtk.jl), [GLVisualize](https://github.com/JuliaGL/GLVisualize.jl), and [Makie](https://github.com/JuliaPlots/Makie.jl) language worth investigating.

Please submit issues and pull requests on [GitHub](https://github.com/JuliaGraphics/Luxor.jl). Original version by [cormullion](https://github.com/cormullion), much improved with contributions from the Julia community.

## Installation and basic usage

Install the package as follows:

```
Pkg.add("Luxor")
```

Cairo.jl and Colors.jl will be installed if necessary.

To use Luxor, type:

```
using Luxor
```

To test:

```
julia> @svg juliacircles()
```

or

```
julia> @png juliacircles()
```

## Documentation

The documentation was built using [Documenter.jl](https://github.com/JuliaDocs).

```@example
println("Documentation built $(now()) with Julia $(VERSION).") # hide
```
