## A small and fast JSON validator 

### Building: 
For the release version, do:
```bash 
zig build 
```

or, for the development version: 
```bash 
zig build -Denable-debug=true
```
which enables additional debugging logs throughout the code.


### Using: 
Test it with: 
```bash 
./zig-out/bin/json_parser <filename.json> 
```

### References: 
This project was inspired by the [Coding Challenges newsletter](https://codingchallenges.fyi/challenges/challenge-json-parser).
