mutable struct Table
    rowheights::Array{T, 1} where T <: Real
    colwidths::Array{T, 1} where T <: Real
    nrows::Int
    ncols::Int
    currentrow::Int
    currentcol::Int
    leftmargin::Real
    topmargin::Real
    center::Point
end

"""
    t = Table(nrows, ncols)
    t = Table(nrows, ncols, cellwidth, cellheight)
    t = Table(rowheights, columnwidths)

Examples

Simple tables

    t = Table(4, 3) # 4 rows and 3 cols
    t = Table(4, 3, 80, 30) # 4 rows of 80pts high, 3 cols of 30pts wide
    t = Table(4, 3, (80, 30)) # 4 rows of 80pts high, 3 cols of 30pts wide
    t = Table(1, 50, 10, 20) # 1 row 10pts high, 50 columns 20pts wide

Specifying heights and widths:

    t = Table([60, 40, 100], [100, 60, 40]) # 3 rows, 3 columns
    t = Table([60, 40, 100], 50) # 3 rows, just 1 column 50 wide
    t = Table(fill(30, (10)), [50, 50, 50]) # 10 rows 30 high, 3 columns 10 wide
    t = Table(50, [60, 60, 60]) # just 1 row (50 high), 3 columns 60 wide
    t = Table([50], [50]) # just 1 row, 1 column, both 50 units wide
    t = Table(50, 50, 10, 5) # 50 rows, 50 columns, 10 units wide, 5 units high
    t = Table(15:5:55, vcat(5:2:15, 15:-2:5))
     # has 108 cells, with:
     #  row heights: 15 20 25 30 35 40 45 50 55
     #  col widths:  5 7 9 11 13 15 15 13 11 9 7 5
    t = Table(vcat(5:10:60, 60:-10:5), vcat(5:10:60, 60:-10:5))
    t = Table(vcat(5:10:60, 60:-10:5), 50) # 1 column 50 units wide
    t = Table(vcat(5:10:60, 60:-10:5), 1:5:50)
    t = Table([6, 11, 16, 21, 26, 31, 36, 41, 46], [6, 11, 16, 21, 26, 31, 36, 41, 46])

A Table is an iterator that, for each iteration, returns a tuple of:

- the `x`/`y` point of the center of cells arranged in rows and columns (relative to current 0/0)

- the number of the cell (left to right, then top to bottom)

`nrows`/`ncols` are the number of rows and columns required.

It's sometimes useful to know which row and column you're currently on:

```
t.currentrow
t.currentcol
```

Row heights and column widths are available in

```
t.rowheights
t.colheights
```

Filling table cells is then possible:

```
@svg begin
    for (pt, n) in (t = Table(8, 3, 30, 15))
        randomhue()
        box(pt, t.colwidths[t.currentcol], t.rowheights[t.currentrow], :fill)
        sethue("white")
        text(string(n), pt)
    end
end
```

To use a Table to make grid points:

```
julia> first.(collect(Table(10, 6)))
60-element Array{Luxor.Point,1}:
 Luxor.Point(-10.0, -18.0)
 Luxor.Point(-6.0, -18.0)
 Luxor.Point(-2.0, -18.0)
 ⋮
 Luxor.Point(2.0, 18.0)
 Luxor.Point(6.0, 18.0)
 Luxor.Point(10.0, 18.0)
```

which returns an array of points that are the center points of the cells in the table.
"""
function Table(nrows::Int, ncols::Int, cellwidth, cellheight, center=O)
    currentrow = 1
    currentcol = 1
    rowheights = repmat([cellheight], nrows)
    colwidths  = repmat([cellwidth],  ncols)
    leftmargin = -sum(colwidths)/2
    topmargin  = -sum(rowheights)/2
    Table(rowheights, colwidths, nrows, ncols, currentrow, currentcol, leftmargin, topmargin, center)
end

# simple: nrows, ncols, (width, height)
Table(nrows::Int, ncols::Int, wh::NTuple{2, T}, center=O) where T <: Real =
    Table(nrows, ncols, wh[1], wh[2], center)

# simple: nrows, ncols using default of 100
function Table(nrows::Int, ncols::Int, center=O)
    cellwidth  = 100
    cellheight = 100
    Table(nrows, ncols, cellwidth, cellheight, center)
end

# row heights in array, column widths in array
function Table(rowheights::Array{T, 1}, colwidths::Array{T, 1}, center=O) where T <: Real
    rowheights = collect(Iterators.flatten(rowheights))
    colwidths =  collect(Iterators.flatten(colwidths))
    nrows = length(rowheights)
    ncols = length(colwidths)
    currentrow = 1
    currentcol = 1
    leftmargin = -sum(colwidths)/2
    topmargin  = -sum(rowheights)/2
    Table(rowheights, colwidths, nrows, ncols, currentrow, currentcol, leftmargin, topmargin, center)
end

# row heights in array, a single column width
Table(rowheights::Array{T, 1}, colwidth::T, center=O) where T <: Real =
    Table(rowheights, [colwidth], center)

# a single row height, column widths in an array
Table(row_height::T, colwidths::Array{T, 1}, center=O) where T <: Real =
    Table([row_height], colwidths, center)

# a range of row heights, a range of column widths
Table(rowheights::Range{T}, colwidths::Range{T}, center=O) where T <: Real =
    Table(collect(rowheights), collect(colwidths), center)

# an array of row heights, a range of column widths
Table(rowheights::Array{T, 1}, colwidths::Range{T}, center=O) where T <: Real =
    Table(rowheights, collect(colwidths), center)

# a range of row heights, an array of column widths
Table(rowheights::Range{T}, colwidths::Array{T, 1}, center=O) where T <: Real =
    Table(collect(rowheights), colwidths, center)

# interfaces

# basic iteration
function Base.start(t::Table)
    # return the initial state
    x = t.leftmargin + (t.colwidths[1]/2)
    y = t.topmargin  + (t.rowheights[1]/2)
    return (t.center + Point(x, y), 1)
end

function Base.next(t::Table, state)
    # state[1] is the Point
    x = state[1].x
    y = state[1].y
    # state[2] is the cellnumber
    cellnumber = state[2]
    # next pos
    t.currentrow = div(cellnumber - 1, t.ncols) + 1
    t.currentcol = mod1(cellnumber, t.ncols)
    x1 = t.leftmargin + sum(t.colwidths[1:t.currentcol - 1]) + t.colwidths[t.currentcol]/2
    y1 = t.topmargin  + sum(t.rowheights[1:t.currentrow - 1]) + t.rowheights[t.currentrow]/2
    nextpoint = t.center + Point(x1, y1)
    return ((nextpoint, cellnumber), (nextpoint, cellnumber + 1))
end

function Base.done(t::Table, state)
    state[2] > t.nrows * t.ncols
end

function Base.size(t::Table)
    return (t.nrows, t.ncols)
end

function Base.length(t::Table)
    t.nrows * t.ncols
end

Base.eltype(::Type{Table}) = Tuple

Base.endof(t::Table) = length(t)

# t[n] -> Luxor.Point(0.0, -192.5)
function Base.getindex(t::Table, i::Int)
    1 <= i <= t.ncols * t.nrows || throw(BoundsError(t, i))
    currentrow = div(i - 1, t.ncols) + 1
    currentcol = mod1(i, t.ncols)
    x1 = t.leftmargin + sum(t.colwidths[1:currentcol - 1]) + t.colwidths[currentcol]/2
    y1 = t.topmargin  + sum(t.rowheights[1:currentrow - 1]) + t.rowheights[currentrow]/2
    return t.center + Point(x1, y1)
end

# t[r, c] -> Luxor.Point(0.0, -192.5)
function Base.getindex(t::Table, r::Int, c::Int)
    r <= t.nrows || throw(BoundsError(t, r))
    c <= t.ncols || throw(BoundsError(t, c))
    x1 = t.leftmargin + sum(t.colwidths[1:c - 1]) + t.colwidths[c]/2
    y1 = t.topmargin  + sum(t.rowheights[1:r - 1]) + t.rowheights[r]/2
    return t.center + Point(x1, y1)
end

Base.getindex(t::Table, I) = [t[i] for i in I]

# get row:    t[1, :]
Base.getindex(t::Table, r::Int64, ::Colon) = [t[r, n] for n in 1:t.ncols]

# get column: t[:, 3]
Base.getindex(t::Table, ::Colon, c::Int64) = [t[n, c] for n in 1:t.nrows]