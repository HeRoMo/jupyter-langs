# Jupyter Lab for various languages

Docker images of Jupyter Lab for various languages.

![Launcher](./doc/launcher.png)

## Support Languages

|Languages|Version|jupyter kernel|
|---|--:|---|
| Python|3.8.6|[IPython](https://ipython.org/)|
| Elixir|1.11.2|[ierl](https://github.com/filmor/ierl)|
| Erlang|OTP 23|[ierl](https://github.com/filmor/ierl)|
| Go|1.15.5|[Gophernotes](https://github.com/gopherdata/gophernotes)|
| Java |1.8.0_152|[SciJava Jupyter Kernel](https://github.com/hadim/scijava-jupyter-kernel)|
| JavaScript(Node.js)|14.15.1|[tslab](https://github.com/yunabe/tslab)|
| Julia |1.5.3|[IJulia](https://github.com/JuliaLang/IJulia.jl)|
| Kotlin|1.4.30|[jupyter\-kotlin](https://github.com/ligee/kotlin-jupyter)|
| R |4.0.3|[IRKernel](http://irkernel.github.io/)|
| Ruby| 2.7.2 |[IRuby](https://github.com/SciRuby/iruby)|
| Rust |1.48.0|[EvCxR Jupyter Kernel](https://github.com/google/evcxr/tree/master/evcxr_jupyter)|
| Scala |2.13.3|[almond](https://github.com/almond-sh/almond)|
| Sparql||[SPARQL kernel](https://github.com/paulovn/sparql-kernel)|
| Typescript| 4.1.2 | [tslab](https://github.com/yunabe/tslab)|
| C#(.Net5)| 9.0 | [.NET Interactive](https://github.com/dotnet/interactive)|
| F#(.Net5)| 5.0 | [.NET Interactive](https://github.com/dotnet/interactive)|
| Powershell(.Net5)| 7.0.3 | [.NET Interactive](https://github.com/dotnet/interactive)|
| C++| 11/14/17 | [xeus-cling](https://github.com/jupyter-xeus/xeus-cling)|

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
