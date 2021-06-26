using Javis
using FFTW
using FFTViews
using FileIO
using Images
using TravelingSalesmanHeuristics

function ground(args...)
    background("black")
    sethue("white")
end

function circ(; r = 10, vec = O, action = :stroke, color = "white")
    sethue(color)
    circle(O, r, action)
    my_arrow(O, vec)
    return vec
end

function my_arrow(start_pos, end_pos)
    arrow(
        start_pos,
        end_pos;
        linewidth = distance(start_pos, end_pos) / 100,
        arrowheadlength = 7,
    )
    return end_pos
end

function draw_line(
    p1 = O,
    p2 = O;
    color = "white",
    action = :stroke,
    edge = "solid",
    linewidth = 3,
)
    sethue(color)
    setdash(edge)
    setline(linewidth)
    line(p1, p2, action)
end

function draw_path!(path, pos, color)
    sethue(color)

    push!(path, pos)
    return draw_line.(path[2:end], path[1:(end - 1)]; color = color)
end

function get_points(img)
    findall(x -> x == 1, img) .|> x -> Point(x.I)
end


c2p(c::Complex) = Point(real(c), imag(c))

remap_idx(i::Int) = (-1)^i * floor(Int, i / 2)
remap_inv(n::Int) = 2n * sign(n) - 1 * (n > 0)

function animate_fourier(options)
    npoints = options.npoints
    nplay_frames = options.nplay_frames
    nruns = options.nruns
    nframes = nplay_frames + options.nend_frames

    # obtain points from julialogo
    points = get_points(load(File(format"PNG", "thin_img.png")))
    npoints = length(points)
    println("#points: $npoints")
    # solve tsp to reduce length of extra edges
    distmat = [distance(points[i], points[j]) for i = 1:npoints, j = 1:npoints]

    path, cost = solve_tsp(distmat; quality_factor = options.tsp_quality_factor)
    println("TSP cost: $cost")
    points = points[path] # tsp saves the last point again

    # optain the fft result and scale
    y = [p.x - options.width for p in points] ./ 3
    x = [p.y - options.height for p in points] ./ 3

    fs = FFTView(fft(complex.(x, y)))
    # normalize the points as fs isn't normalized
    fs ./= npoints
    npoints = length(fs)

    video = Video(options.width, options.height)
    Background(1:nframes, ground)

    circles = Object[]

    for i = 1:npoints
        ridx = remap_idx(i)

        push!(circles, Object((args...) -> circ(; r = abs(fs[ridx]), vec = c2p(fs[ridx]))))

        if i > 1
            # translate to the tip of the vector of the previous circle
            act!(circles[i], Action(1:1, anim_translate(circles[i - 1])))
        end
        ridx = remap_idx(i)
        act!(circles[i], Action(1:nplay_frames, anim_rotate(0.0, ridx * 2π * nruns)))
    end

    trace_points = Point[]
    Object(1:nframes, (args...) -> draw_path!(trace_points, pos(circles[end]), "pink"))

    return render(video; pathname = joinpath(@__DIR__, options.filename))
    # return render(video; liveview = true)
end

function main()
    # hd_options = (
    # npoints = 3001, # rough number of points for the shape => number of circles
    # nplay_frames = 1200, # number of frames for the animation of fourier
    # nruns = 2, # how often it's drawn
    # nend_frames = 200,  # number of frames in the end
    # width = 1920,
    # height = 1080,
    # shape_scale = 2.5, # scale factor for the logo
    # tsp_quality_factor = 50,
    # filename = "julia_hd.mp4",
    # )

    gif_options = (
        npoints = 1001, # rough number of points for the shape => number of circles
        nplay_frames = 600, # number of frames for the animation of fourier
        nruns = 1, # how often it's drawn
        nend_frames = 200,  # number of frames in the end
        width = 455,
        height = 490,
        tsp_quality_factor = 20,
        filename = "julia_fast.gif",
    )

    # gif_options = (
    # npoints = 651, # rough number of points for the shape => number of circles
    # nplay_frames = 600, # number of frames for the animation of fourier
    # nruns = 2, # how often it's drawn
    # nend_frames = 0,  # number of frames in the end
    # width = 350,
    # height = 219,
    # shape_scale = 0.8, # scale factor for the logo
    # tsp_quality_factor = 80,
    # filename = "julia_logo_dft.gif",
    # )
    return animate_fourier(gif_options)
end

