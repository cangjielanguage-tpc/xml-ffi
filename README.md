<div align="center">
<h1>xml-ffi</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.2-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.1.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-90.8%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

一个标准的 XML 文本处理的工具。    

### 特性

- 🚀 支持Xml DOM 解析模式

- 🚀 支持Xml SAX 解析模式


## 软件架构

### 架构图

<p align="center">
<img src="./doc/assets/readme_framework.png" width="60%" >
</p>

### 源码目录

```shell
.
├── README.md
├── doc 
├── libxml_c
├── src
│   ├── native.cj  
│   └── XmlParser.cj    
│       
├── test
│    ├── DOC
│    ├── FUZZ
│    ├── HLT
│    ├── LLT
│    └── UT
├── CHANGELOG.md
├── LICENSE.txt
├── module.json
├── README.md
├── README.OpenSource
```

- `doc` 文档目录，用于存API接口文档
- `libxml_c` 需要自行编译的c文件
- `src` 是库源码目录
- `test` 存放 HLT 测试用例、LLT 自测用例、DOC 示例用例、FUZZ用例、UT 单元测试用例

### 接口说明

主要是核心类和成员函数说明,详情见 [API](./doc/feature_api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 使用说明

### 编译

#### libxml2 编译

1. linux 编译

   进入 libxml2 根目录，执行下面语句。

   ```shell
   var=`awk '/set_target_properties.*/{print NR;exit;}' CMakeLists.txt` && sed -i ''"$var"',+10{/VERSION/d}' CMakeLists.txt
   ```

   1.1 x86-64

      ```shell
      cmake ./ -DCMAKE_BUILD_TYPE=Release
      make
      ```

   1.2 aarch64

      ```shell
      cmake ./ -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -D LIBXML2_WITH_ICONV=OFF -D LIBXML2_WITH_LZMA=OFF -D LIBXML2_WITH_PYTHON=OFF -D LIBXML2_WITH_ZLIB=OFF
      make
      ```

2. winows 编译

   下载msys2和mingw64

   msys2：https://github.com/msys2/msys2-installer/releases/download/2023-03-18/msys2-x86_64-20230318.exe

   mingw64：https://github.com/niXman/mingw-builds-binaries/releases/download/12.2.0-rt_v10-rev2/x86_64-12.2.0-release-posix-seh-msvcrt-rt_v10-rev2.7z

   将mingw64解压到msys2的根目录

   下载cmake：https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-windows-x86_64.zip

   将cmake解压到D盘

   用mingw64进入libxml2目录，执行下面语句

    ```shell
    pacman -S liblzma-devel zlib-devel
    "D:\cmake-3.26.3-windows-x86_64\bin\cmake" ./ -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
    make
    ```
   
3. ohos 编译

   用mingw64进入libxml2目录，执行下面语句
    
   xx/xx/native 为ohos编译工具链目录

    ```shell
    var=`awk '/set_target_properties.*/{print NR;exit;}' CMakeLists.txt` && sed -i ''"$var"',+10{/VERSION/d}' CMakeLists.txt
    mkdir build
    cd build
    cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER="xx/xx/native/llvm/bin/clang.exe" -DCMAKE_C_FLAGS="--sysroot=xx/xx/native/sysroot --target=aarch64-linux-ohos" -DCMAKE_SYSTEM_NAME=linux -DCMAKE_SYSTEM_PROCESSOR=aarch64  -G "MinGW Makefiles" -DCMAKE_STRIP="xx/xx/native/llvm/bin/llvm-strip.exe" -DCMAKE_MAKE_PROGRAM="xx/msys2/mingw64/bin/make.exe" -D LIBXML2_WITH_ICONV=OFF -D LIBXML2_WITH_LZMA=OFF -D LIBXML2_WITH_PYTHON=OFF -D LIBXML2_WITH_ZLIB=OFF
    make
    ```

#### xml-ffi编译

该三方库依赖 stdx，请参考 [stdx](https://gitcode.com/Cangjie/Cangjie-STDX#%E4%BD%BF%E7%94%A8%E6%8C%87%E5%AF%BC) 文档配置 `CANGJIE_STDX_PATH` 路径

1. linux x86_64 编译

   将上面生成文件 `libxml2.so`，放入根目录的 `lib` 文件夹下，之后执行

   ```
   ./build_linux.sh
   ```

2. windows 编译

   将上面生成文件 `libxml2.dll`，放入根目录的 `lib` 文件夹下，之后执行

   ```
   build_windows.bat
   ```

3. aarch64编译

   将上面生成文件 `libxml2.so`，放入根目录的 `lib` 文件夹下，之后执行

   ```
   ./build_aarch64.sh
   ```

4. ohos编译

   将上面生成文件 `libxml2.so`，放入根目录的 `lib` 文件夹下，之后执行

   ```
   ./build_ohos.sh
   ```

#### **使用脚本编译**

1. 下载配置[编译脚本](https://gitcode.com/Cangjie-TPC/TPC-Test-Framework.git)

    ```ciTest build```

### 功能示例

#### Xml DOM 解析模式功能示例

```cangjie

import xml_ffi.*

main() {
    let x: XmlParser = XmlParser()

    var ret = x.parse("<myxml>Some data </myxml>")
    match (ret) {
        case Some(root) => println(root.name)
        case None => println("XML Parse error.")
    }
    return 0
}
```

执行结果如下：

```shell
myxml
```

#### Xml SAX 解析模式功能示例

```cangjie

import xml_ffi.*
import std.collection.*

let latestMovie = """
<collection shelf="New Arrivals">
<movie title="Movie 2021">
   <score>7.4</score>
   <year>2021-3</year>
   <description>This is a virtual film released in 2021 for testing.</description>
</movie>
<movie title="Movie 2022">
   <type>Anime, Science Fiction</type>
   <score>7</score>
   <year>2022-2</year>
   <description>This is a virtual film released in 2022 for testing.</description>
</movie>
<movie title="Movie 2023">
   <score>6.5</score>
   <year>2023-4</year>
   <description>This is a virtual film released in 2023 for testing.</description>
</movie>
</collection>
"""
class MovieHandler <: SaxHandler {
    private var curTag: String
    private var title: String
    private var score: String
    private var year: String

    init() {
        curTag = ""
        title = ""
        score = ""
        year = ""
    }

    public func startDocument(): Unit {
        println("Start Parsing.")
    }
    public func endDocument(): Unit {
        println("End Parsing.")
    }
    public func startElement(name: String, attrs: ArrayList<XmlAttr>): Unit {
        curTag = name
        if (name == "movie") {
            title = attrs[0].content
            println("Title: ${title}")
        }
    }
    public func endElement(name: String): Unit {
        if (curTag == "score") {
            println("Score: ${score}")
        } else if (curTag == "year") {
            println("Year: ${year}")
        }
    }
    public func characters(content: String): Unit {
        if (curTag == "score") {
            score = content
        } else if (curTag == "year") {
            year = content
        }
    }
}
main() {
    var handler = MovieHandler()
    let x: XmlParser = XmlParser(handler)

    x.parse(latestMovie)
    return 0
}
```

执行结果如下：

```shell
Start Parsing.
Title: Movie 2021
Score: 7.4
Year: 2021-3
Title: Movie 2022
Score: 7
Year: 2022-2
Title: Movie 2023
Score: 6.5
Year: 2024-4
End Parsing.
```

在下述版本验证通过：
```shell
Cangjie Version: 1.0.0
```

## 开源协议

本项目基于 [个人：(C) 1998-2012 Daniel Veillard](./LICENSE) ，请自由的享受和参与开源。

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

欢迎给我们提交 PR，欢迎给我们提交 issue，欢迎参与任何形式的贡献。