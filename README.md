### A small and fast JSON validator 

Build the release version with: 
```bash 
zig build 
```

or, for the development version: 
```bash 
zig build -Denable-debug=true
```
which enables additional debugging logs throughout the code.


```mermaid 
flowchart TD
    A[main.zig] -->|whole file content string| B(lexer.zig)
    B -->|ArrayList of Token| C[parser.zig]

    style A fill:#f9f,stroke:#333,stroke-width:4px
    style B fill:#bbf,stroke:#333,stroke-width:4px
    style C fill:#fbf,stroke:#333,stroke-width:4px
```