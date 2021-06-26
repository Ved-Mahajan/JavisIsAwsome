using Images
using ImageView

img = load("proxy-image.png")
gray_img = Gray.(img) .|> Float64
inv_img = 1 .- (gray_img .> 0) .|> Bool
thin_img = thinning(inv_img)
save("thin_img.png",thin_img)
imshow(thin_img)
