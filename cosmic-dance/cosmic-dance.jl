using Javis

function object(r,p=O, color="black")
    sethue(color)
    circle(p, r, :fill)
    return p
end

function connector!(connection,p1, p2, color)
    sethue(color)
    push!(connection,[p1,p2])
    map(x->line(x[1],x[2], :stroke),connection)
end

function ground(args...) 
    background("black") # canvas background
    sethue("white") # pen color
    # circle(O,50,:fill)
end

function circ(p = O, color = "black", action = :fill, radius = 25, edge = "solid")
    sethue(color)
    setdash(edge)
    circle(p, radius, action)
end

function make_animation()

    # to store the connectors
    connection = []
    
    frames = 1000

    # setup the video
    myvideo = Video(900,900)
    Background(1:frames,ground)

    # add the objects
    earth = Object(1:frames,(args...)->object(5,O,"blue"),Point(400,0))
    venus = Object(1:frames,(args...)->object(4,O,"red"),Point(288,0))
    #sun = Object(1:frames,(aegs...)->object(50,O,"yellow"),Point(0,0))

    # draw the orbits
    earth_orbit = Object((args...) -> circ(O, "white", :stroke, 400))
    venus_orbit = Object((args...) -> circ(O, "white", :stroke, 288))

    # move the planets
    act!(earth, Action(anim_rotate_around(12.5*2π, O)))
    act!(venus, Action(anim_rotate_around(12.5*2π*(224.7/365), O)))

    # draw the connectors
    Object(1:frames, (args...)->connector!(connection,pos(earth), pos(venus), "#f05a4f"))

    # render
    render(myvideo,pathname = "cosmic_dance.gif",framerate = 60)
end

make_animation()
