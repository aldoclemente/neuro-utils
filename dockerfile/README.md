### Get started

Pull the docker image: 
```
docker pull aldoclemente/fsl
```

Run a container with mounted input directory:
```
docker run --rm --name=fsl -v /path/to/input/:/input/ -dit aldoclemente/fsl 
```
*Notes*
- `/path/to/input/` is the local directory containing your inputs
- The `--rm` flag ensures the container is automatically removed after stopping.
- The `-dit` flags allow you to properly run the container. Specifically, it let you run the container in detached mode while keeping it interactive and allocating a pseudo-TTY


You can run fsl commands, such as bet, as follows: 
```
docker exec fsl bet -h
```
Once finished, remember to stop your container. If you did not use the `--rm` flag, you may need to remove it manually:
```
docker stop fsl 
```


### Running on apptainer (formerly, singularity)

Pull the image as follows:
```
/path/to/apptainer pull docker://aldoclemente/fsl
```
Run `fsl` commands using `exec`, for instance:
```
/path/to/apptainer exec /path/to/fsl_latest.sif bet -h
```




