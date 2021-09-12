# Jupyter Lab for various languages

Docker images of Jupyter Lab for various languages.

![Launcher](./doc/launcher.png)

## Support Languages

|Languages|Version|jupyter kernel|
|---|--:|---|
| [Python](https://www.python.org/) |3.9.7|[IPython](https://ipython.org/)|
| [C#](https://docs.microsoft.com/en-us/dotnet/csharp/)(.Net5)| 9.0 | [.NET Interactive](https://github.com/dotnet/interactive)|
| [Elixir](https://elixir-lang.org/) |1.12.2|[ierl](https://github.com/filmor/ierl)|
| [Erlang](https://www.erlang.org/) |OTP 24.0.5|[ierl](https://github.com/filmor/ierl)|
| [F#](https://fsharp.org/)(.Net5) | 5.0.9 | [.NET Interactive](https://github.com/dotnet/interactive)|
| [Go](https://golang.org/) |1.17.1|[Gophernotes](https://github.com/gopherdata/gophernotes)|
| [Java](https://openjdk.java.net/) |1.8.0_152|[SciJava Jupyter Kernel](https://github.com/hadim/scijava-jupyter-kernel)|
| JavaScript([Node.js](https://nodejs.org/en/))|16.9.0|[tslab](https://github.com/yunabe/tslab)|
| [Julia](https://julialang.org/) |1.6.2|[IJulia](https://github.com/JuliaLang/IJulia.jl)|
| [Kotlin](https://kotlinlang.org/) |1.6.0|[jupyter\-kotlin](https://github.com/ligee/kotlin-jupyter)|
| [Powershell](https://docs.microsoft.com/en-us/powershell/)(.Net5) | 7.1.4 | [.NET Interactive](https://github.com/dotnet/interactive)|
| [R](https://www.r-project.org/) |4.1.1|[IRKernel](http://irkernel.github.io/)|
| [Ruby](https://www.ruby-lang.org/en/) | 3.0.2 |[IRuby](https://github.com/SciRuby/iruby)|
| [Rust](https://www.rust-lang.org/) |1.54.0|[EvCxR Jupyter Kernel](https://github.com/google/evcxr/tree/master/evcxr_jupyter)|
| [Scala](https://www.scala-lang.org/) |2.13.4|[almond](https://github.com/almond-sh/almond)|
| Sparql||[SPARQL kernel](https://github.com/paulovn/sparql-kernel)|
| [Typescript](https://www.typescriptlang.org/) | 4.4.3 | [tslab](https://github.com/yunabe/tslab)|

* Enabled [Plotly](https://plotly.com/python/), Dash and [leaflet](https://ipyleaflet.readthedocs.io/en/latest/) in Python.
* Enabled [Plotly](https://plotly.com/python/) in R, Julia.

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
