#
# solve the Poisson equation -Delta u = f on unit circle
# with dirichlet values and r.h.s. such that
# u = 1 + cos(pi*(x*x+y*y)) is the solution        
# load geometry
geometry = circle.in2d

# and mesh
mesh = circle.vol.gz

constant geometryorder = 16
constant heapsize = 1e7
        
fespace v -type=h1ho -order=16 -dirichlet=[1]

coefficient sol
(1+cos(pi*(x*x+y*y))),
        
gridfunction u -fespace=v -nested

linearform f -fespace=v
source (4*pi*(pi*(x*x+y*y)*cos(pi*(x*x+y*y))+sin(pi*(x*x+y*y))))

bilinearform a -fespace=v -symmetric -eliminate_internal
laplace 1


preconditioner c -type=direct -bilinearform=a

numproc bvp np1 -bilinearform=a -linearform=f -gridfunction=u -preconditioner=c -maxsteps=1000 -prec=1e-16

# numproc drawflux np2 -bilinearform=a -solution=u -label=flux -applyd

numproc draw np3 -coefficient=sol -label=sol

bilinearform m -fespace=v -symmetric -nonassemble
mass 1

fespace verr -type=l2ho -order=0
gridfunction err -fespace=verr
                
numproc difference npd -bilinearform=m -solution=u -function=sol -diff=err

numproc visualization npv1 -scalarfunction=u -subdivision=2 -nolineartexture -minval=0 -maxval=2

numproc testvariable nptv_err -variable=calcdiff.npd.diff -refvalue=0 -tolerance=2e-14 -abstol -cdash
