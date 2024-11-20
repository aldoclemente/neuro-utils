# parsing arguments ------------------------------------------------------------
args <- commandArgs(TRUE)
if(length(args)==0) stop("Path to files is needed. Optional parameters: maximum area, minimum angle")

outdir = ""
outdir = paste0( strsplit( args[1], "/" )[[1]], "/", collapse = "")
maximum_area = 10; minimum_angle=30
if(length(args) >= 2) maximum_area = as.double(args[2])
if(length(args) == 3) minimum_angle = as.double(args[3])
# ------------------------------------------------------------------------------
library(RTriangle)
library(sf)

P_ = matrix(nrow=0, ncol=2)
E_ = matrix(nrow=0, ncol=2)
holes = matrix(nrow=0,ncol=2)

n_rings = length(list.files(outdir,pattern = ".txt"))
cum = vector(mode="integer", length = n_rings)

for(i in 1:n_rings){
  pts = read.table(paste0(outdir, "points_ring_", i-1, ".txt"),
                   header = F)
  #seg = read.table(paste0(outdir, "ring_edges_", i-1, ".txt"),
  #                   header = F) + 1
  if((i-1) != 0){
    holes <- rbind( holes, as.numeric(st_point_on_surface(st_polygon(list(as.matrix(rbind(pts,pts[1,])))))))
  }
  cum[i] = nrow(P_)
  
  seg = cbind( 1:(nrow(pts)-1),2:nrow(pts))
  seg = rbind( seg,  c( nrow(pts), 1))
  seg = seg + cum[i]
  
  P_ = rbind(P_, pts)
  E_ = rbind(E_, seg)
}

if( nrow(holes) == 0 ) holes = NA

pslg <- RTriangle::pslg(P = P_, PB = as.matrix(rep(1, times=nrow(P_))),
                        S = E_, SB = as.matrix(rep(1, times=nrow(E_))) , 
                        H = holes) 
triangulation <- RTriangle::triangulate(p = pslg, a = maximum_area, q = minimum_angle)

if(!dir.exists(paste0(outdir, "mesh/"))) dir.create(paste0(outdir, "mesh/"))

vox_centers = as.matrix(read.table(paste0(outdir, "/../fine/voxel_centers.txt")))[,2:3]
vox_mask = as.matrix(read.table(paste0(outdir, "/../fine/voxel_centers_mask.txt"))) + 1

mesh = fdaPDE::create.mesh.2D(nodes=triangulation$P,
                              triangles=triangulation$T)
idx = fdaPDE:::CPP_search_points(mesh, vox_centers[vox_mask,]) # - 1 ?!?! 

write.table(triangulation$P, paste0(outdir, "mesh/points.txt"))
write.table(triangulation$PB, paste0(outdir, "mesh/boundary.txt"))
write.table(triangulation$T, paste0(outdir, "mesh/elements.txt")) # -1 ?!?!

write.csv(triangulation$P, paste0(outdir, "mesh/points.csv"))
write.csv(triangulation$PB, paste0(outdir, "mesh/boundary.csv"))
write.csv(triangulation$T, paste0(outdir, "mesh/elements.csv")) # -1 ?!?!

delete = which(idx == 0)
mask = as.matrix(setdiff(vox_mask, vox_mask[delete]))
write.csv(vox_centers[mask,], paste0(outdir,"mesh/locs.csv"))
write.csv(vox_centers, paste0(outdir,"mesh/voxel_centers.csv"))

mask = mask - 1 
storage.mode(mask) <- "integer"
write.csv(mask, paste0(outdir,"mesh/voxel_mask.csv"))

pdf(paste0(outdir, "mesh/mesh.pdf"))
plot(triangulation, pch=".")
dev.off()