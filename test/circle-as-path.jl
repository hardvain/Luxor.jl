#!/usr/bin/env julia

using Luxor

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

function circle_as_path(fname)
    currentwidth = 1200
    currentheight = 1200 # pts
    Drawing(currentwidth, currentheight, fname)
    origin()
    background(setgray(0.8)...)
    tiles = Tiler(currentwidth, currentheight, 8, 8, margin=20)
    for (pos, n) in tiles
        randomhue()
        circlepath(pos, 70, :path)
        newsubpath()
        circlepath(pos, rand(5:65), :fill, reversepath=true)
    end
    @test finish() == true
end

fname = "circlepath.pdf"
circle_as_path(fname)
println("...finished test: output in $(fname)")
