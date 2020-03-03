# JackCompiler

The JackCompiler compiles `.jack` programs into HACK VM code.

The compiler is made up of 3 modules:
1. `JackTokenizer` - takes the source code and returns a stream of tokens
2. `CompilationEngine` - takes the stream of tokens and parses it into a tree following the Jack grammar
3. `CodeGenerator` - takes the parse tree and generates VM code

## Usage

`$ ruby JackCompiler path_to_file_or_dir`

## Example

Input:
`HelloWorld.jack`
```jack
// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/11/Seven/Main.jack

/**
 * Computes the value of 1 + (2 * 3) and prints the result
 * at the top-left of the screen.  
 */
class Main {

   function void main() {
      do Output.printInt(1 + (2 * 3));
      return;
   }

}

```

Output:
`HelloWorld.vm`
```
function Main.main 0
push constant 1
push constant 2
push constant 3
call Math.multiply 2
add
call Output.printInt 1
pop temp 0
push constant 0
return
```

