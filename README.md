# Jupyter Lab for various languages

Docker images of Jupyter Lab for various languages.

![Launcher](./doc/launcher.png)

## Support Languages

|Languages|Version|jupyter kernel|
|---|--:|---|
| Python|3.7.3|[IPython](https://ipython.org/)|
| Elixir|1.8.2|[ierl](https://github.com/filmor/ierl)|
| Erlang|OTP 22|[ierl](https://github.com/filmor/ierl)|
| Go|1.12.5|[Gophernotes](https://github.com/gopherdata/gophernotes)|
| Groovy|2.5.6|[BeakerX](http://beakerx.com/)|
| Java |1.8.0_152|[BeakerX](http://beakerx.com/)|
| JavaScript(Node.js)|12.3.1|[IJavascript](https://github.com/n-riesco/ijavascript)|
| Kotlin|1.2.41|[BeakerX](http://beakerx.com/)|
| R |3.5.1|[IRKernel](http://irkernel.github.io/)|
| Ruby| 2.6.3 |[IRuby](https://github.com/SciRuby/iruby)|
| Rust |1.35.0|[EvCxR Jupyter Kernel](https://github.com/google/evcxr/tree/master/evcxr_jupyter)|
| Scala |2.11.12|[BeakerX](http://beakerx.com/)|
| Sparql||[SPARQL kernel](https://github.com/paulovn/sparql-kernel)|
| Typescript| 3.5.1 | [ITypeScript](https://github.com/nearbydelta/itypescript)|

## Usage 

```bash
$ mkdir your/jupyter/project/dir
$ cd your/jupyter/project/dir
$ wget https://raw.githubusercontent.com/HeRoMo/jupyter-langs/master/docker-compose.yml
$ docker-compose up
```

After starting container, you can access http://localhost:8888/ to open jupyter lab.

## License

[MIT](License.txt)



