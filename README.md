# Jupyter Lab for various languages

Docker images of Jupyter Lab for various languages.

![Launcher](./doc/launcher.png)

## Support Languages

|Languages|Version|jupyter kernel|
|---|--:|---|
| Python|3.8.5|[IPython](https://ipython.org/)|
| Elixir|1.10.4|[ierl](https://github.com/filmor/ierl)|
| Erlang|OTP 23|[ierl](https://github.com/filmor/ierl)|
| Go|1.15.0|[Gophernotes](https://github.com/gopherdata/gophernotes)|
| Java |1.8.0_152|[SciJava Jupyter Kernel](https://github.com/hadim/scijava-jupyter-kernel)|
| JavaScript(Node.js)|12.18.3|[IJavascript](https://github.com/n-riesco/ijavascript)|
| Julia |1.5.0|[IJulia](https://github.com/JuliaLang/IJulia.jl)|
| Kotlin|1.4.20|[jupyter\-kotlin](https://github.com/ligee/kotlin-jupyter)|
| R |4.0.2|[IRKernel](http://irkernel.github.io/)|
| Ruby| 2.7.1 |[IRuby](https://github.com/SciRuby/iruby)|
| Rust |1.46.0|[EvCxR Jupyter Kernel](https://github.com/google/evcxr/tree/master/evcxr_jupyter)|
| Scala |2.13.3|[almond](https://github.com/almond-sh/almond)|
| Sparql||[SPARQL kernel](https://github.com/paulovn/sparql-kernel)|
| Typescript| 3.9.0 | [ITypeScript](https://github.com/nearbydelta/itypescript)|

* Enabled [Plotly](https://plotly.com/python/), Dash and [leaflet](https://ipyleaflet.readthedocs.io/en/latest/) in Python.

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
