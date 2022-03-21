# Jupyter Lab for various languages

Docker images of Jupyter Lab for various languages.

![Launcher](./doc/launcher.png)

## Support Languages

|Languages|Version|jupyter kernel|
|---|--:|---|
| [Python](https://www.python.org/) |3.10.0|[IPython](https://ipython.org/)|
| [C#](https://docs.microsoft.com/en-us/dotnet/csharp/)(.Net6)| 10.0 | [.NET Interactive](https://github.com/dotnet/interactive)|
| [Elixir](https://elixir-lang.org/) |1.12.2|[ierl](https://github.com/filmor/ierl)|
| [Erlang](https://www.erlang.org/) |OTP 24.0.4|[ierl](https://github.com/filmor/ierl)|
| [F#](https://fsharp.org/)(.Net5) | 6.0.3 | [.NET Interactive](https://github.com/dotnet/interactive)|
| [Go](https://golang.org/) |1.17.8|[Gophernotes](https://github.com/gopherdata/gophernotes)|
| [Java](https://openjdk.java.net/) |11.0.9.1|[SciJava Jupyter Kernel](https://github.com/hadim/scijava-jupyter-kernel)|
| JavaScript([Node.js](https://nodejs.org/en/))|17.7.2|[tslab](https://github.com/yunabe/tslab)|
| [Julia](https://julialang.org/) |1.7.2|[IJulia](https://github.com/JuliaLang/IJulia.jl)|
| [Kotlin](https://kotlinlang.org/) |1.7.0|[jupyter\-kotlin](https://github.com/ligee/kotlin-jupyter)|
| [Powershell](https://docs.microsoft.com/en-us/powershell/)(.Net6) | 7.2.1 | [.NET Interactive](https://github.com/dotnet/interactive)|
| [R](https://www.r-project.org/) |4.1.1|[IRKernel](http://irkernel.github.io/)|
| [Ruby](https://www.ruby-lang.org/) | 3.1.1 |[IRuby](https://github.com/SciRuby/iruby)|
| [Rust](https://www.rust-lang.org/) |1.59.0|[EvCxR Jupyter Kernel](https://github.com/google/evcxr/tree/master/evcxr_jupyter)|
| [Scala](https://www.scala-lang.org/) |2.13.4|[almond](https://github.com/almond-sh/almond)|
| Sparql||[SPARQL kernel](https://github.com/paulovn/sparql-kernel)|
| [Typescript](https://www.typescriptlang.org/) | 4.6.2 | [tslab](https://github.com/yunabe/tslab)|

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
